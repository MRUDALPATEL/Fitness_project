import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter/foundation.dart';
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


    // If a device is already connected, disconnect it first
    if (_connectedDevice != null) {
      debugPrint("🔄 Disconnecting from previous device...");
      await _connectedDevice!.disconnect();
      await Future.delayed(const Duration(seconds: 2)); // Ensure clean disconnection
    }

    debugPrint("🔍 Connecting to ${device.platformName}...");

    // Attempt connection with retry logic
    for (int attempt = 1; attempt <= 2; attempt++) {
      try {
        await device.connect(timeout: const Duration(seconds: 15));
        _connectedDevice = device;
        _services = await device.discoverServices();
        _subscribeToHeartRate();
        _subscribeToStepsAndCalories();
        debugPrint("✅ Successfully connected to ${device.platformName}");
        return; // Exit loop if successful
      } catch (e) {
        debugPrint("⚠️ Attempt $attempt: Connection failed: $e");
        if (attempt == 2) {
          debugPrint("❌ Connection completely failed after retries.");
        } else {
          await Future.delayed(const Duration(seconds: 3)); // Wait before retrying
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
      }
    });
  }

  void _subscribeToStepsAndCalories() {
    _subscribeToCharacteristic("feea", "fee1", (value) {
      if (value.isNotEmpty) {
        stepsNotifier.value = value[0] + (value[1] << 8);
        caloriesNotifier.value = value[6];
      }
    });
  }

  Future<void> disconnect() async {
    if (_connectedDevice != null) {
      await _connectedDevice!.disconnect();
      _connectedDevice = null;
    }
  }
}
