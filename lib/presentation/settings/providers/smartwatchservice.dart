import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitnessapp/core/smartwatch_notifiers.dart';

class SmartwatchService {
  static final SmartwatchService _instance = SmartwatchService._internal();
  factory SmartwatchService() => _instance;
  SmartwatchService._internal();

  BluetoothDevice? _connectedDevice;
  List<BluetoothService> _services = [];

  BluetoothDevice? get connectedDevice => _connectedDevice;

  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      // Ensure Bluetooth is ON
      if (await FlutterBluePlus.adapterState.first != BluetoothAdapterState.on) {
        debugPrint("❌ Bluetooth is OFF. Please turn it ON.");
        return;
      }

      // Disconnect previous device
      if (_connectedDevice != null) {
        debugPrint("🔄 Disconnecting from previous device...");
        await _connectedDevice!.disconnect();
        await Future.delayed(const Duration(seconds: 2));
      }

      debugPrint("🔍 Connecting to ${device.platformName}...");

      // Attempt connection
      for (int attempt = 1; attempt <= 2; attempt++) {
        try {
          await device.connect(timeout: const Duration(seconds: 15));
          _connectedDevice = device;
          _services = await device.discoverServices();
          _subscribeToHeartRate();
          _subscribeToStepsAndCalories();
          debugPrint("✅ Successfully connected to ${device.platformName}");
          return;
        } catch (e) {
          debugPrint("⚠️ Attempt $attempt: Connection failed: $e");
          if (attempt == 2) {
            debugPrint("❌ Connection completely failed after retries.");
          } else {
            await Future.delayed(const Duration(seconds: 3));
          }
        }
      }
    } catch (e) {
      debugPrint("❌ Connection error: $e");
    }
  }

  Future<void> _subscribeToCharacteristic(
      String serviceUuid, String characteristicUuid, Function(List<int>) onData) async {
    for (var service in _services) {
      if (service.uuid.toString().toLowerCase() == serviceUuid.toLowerCase()) {
        for (var characteristic in service.characteristics) {
          if (characteristic.uuid.toString().toLowerCase() == characteristicUuid.toLowerCase()) {
            await characteristic.setNotifyValue(true);
            characteristic.lastValueStream.listen(onData);
          }
        }
      }
    }
  }

  void _subscribeToHeartRate() {
    _subscribeToCharacteristic("180d", "2a37", (value) {
      if (value.isNotEmpty) {
        heartRateNotifier.value = value[1];
        saveData(); // ✅ Save heart rate update
      }
    });
  }

  void _subscribeToStepsAndCalories() {
    _subscribeToCharacteristic("feea", "fee1", (value) {
      if (value.isNotEmpty) {
        stepsNotifier.value = value[0] + (value[1] << 8);
        caloriesNotifier.value = value[6];
        saveData(); // ✅ Save steps & calories update
      }
    });
  }

  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('daily_steps', stepsNotifier.value);
    prefs.setInt('daily_kcal', caloriesNotifier.value);
    prefs.setInt('last_heart_rate', heartRateNotifier.value);
  }

  Future<void> loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    stepsNotifier.value = prefs.getInt('daily_steps') ?? 0;
    caloriesNotifier.value = prefs.getInt('daily_kcal') ?? 0;
    heartRateNotifier.value = prefs.getInt('last_heart_rate') ?? 0;
  }

  Future<String?> getUserId() async {
  User? user = FirebaseAuth.instance.currentUser;
  return user?.uid;
}

Future<void> uploadDailyData() async {
  String? userId = await getUserId(); // ✅ Get the logged-in user's ID
  if (userId == null) {
    debugPrint("❌ User not logged in. Cannot upload data.");
    return;
  }

  await FirebaseFirestore.instance.collection('smartwatch_data').add({
    'userId': userId,
    'date': DateTime.now().toIso8601String(),
    'steps': stepsNotifier.value,
    'calories': caloriesNotifier.value,
    'heart_rate': heartRateNotifier.value,
  });

  // Reset for the new day
  stepsNotifier.value = 0;
  caloriesNotifier.value = 0;
  heartRateNotifier.value = 0;
  saveData(); // ✅ Save reset values locally
}

  void scheduleMidnightReset() {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1, 0, 0, 0);
    final durationUntilMidnight = midnight.difference(now);

    Future.delayed(durationUntilMidnight, () async {
      await uploadDailyData();
      scheduleMidnightReset(); // Schedule next day's reset
    });
  }

  Future<void> disconnect() async {
    if (_connectedDevice != null) {
      await _connectedDevice!.disconnect();
      _connectedDevice = null;
    }
  }

  void init() {
    loadSavedData();
    scheduleMidnightReset();
  }
}
