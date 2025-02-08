import 'package:fitnessapp/core/smartwatch_notifiers.dart';
import 'package:fitnessapp/presentation/home/widgets/smartwatchdatawidget.dart';
import 'package:fitnessapp/presentation/settings/providers/smartwatchservice.dart';
import 'package:fitnessapp/utils/managers/color_manager.dart';
import 'package:fitnessapp/utils/managers/style_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class SmartwatchSettingsPage extends StatefulWidget {
  const SmartwatchSettingsPage({super.key});

  @override
  State<SmartwatchSettingsPage> createState() => _SmartwatchSettingsPageState();
}

class _SmartwatchSettingsPageState extends State<SmartwatchSettingsPage> {
  List<ScanResult> scanResults = [];
  final SmartwatchService _smartwatchService = SmartwatchService();

  @override
  void initState() {
    super.initState();
    requestPermissions();
  }

  Future<void> requestPermissions() async {
    await [
      Permission.bluetooth,
      Permission.location,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
    ].request();
  }

  void scanForDevices() {
    setState(() => scanResults = []);
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));
    FlutterBluePlus.scanResults
        .listen((results) => setState(() => scanResults = results));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.darkGrey,
      appBar: AppBar(
        title: const Text(
          'Smartwatch Settings',
          style: TextStyle(color: Colors.white), // Title color white
        ),
        backgroundColor: ColorManager.darkGrey,
        elevation: 0,
        iconTheme:
            const IconThemeData(color: Colors.white), // Back arrow color white
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: scanForDevices,
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorManager.limerGreen2,
                foregroundColor: ColorManager.darkGrey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('🔍 Scan for Smartwatch',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ColorManager.darkGrey,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: scanResults.isEmpty
                    ? Center(
                        child: Text(
                          "No devices found",
                          style: StyleManager.homePageS17BoldWhite,
                        ),
                      )
                    : ListView.builder(
                        itemCount: scanResults.length,
                        itemBuilder: (context, index) {
                          final device = scanResults[index].device;
                          return Card(
                            color: Colors.black87,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              title: Text(
                                device.platformName.isNotEmpty
                                    ? device.platformName
                                    : "Unknown Device",
                                style: StyleManager.homePageS17BoldWhite,
                              ),
                              subtitle: Text(device.remoteId.toString(),
                                  style: TextStyle(color: Colors.grey)),
                              trailing: Icon(Icons.bluetooth,
                                  color: ColorManager.limerGreen2),
                              onTap: () async {
                                await _smartwatchService
                                    .connectToDevice(device);
                                setState(() {});
                              },
                            ),
                          );
                        },
                      ),
              ),
            ),
            if (_smartwatchService.connectedDevice != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ColorManager.black87,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      "✅ Connected to: ${_smartwatchService.connectedDevice!.platformName}",
                      style: StyleManager.homePageS17BoldWhite,
                    ),
                    // const SizedBox(height: 10),
                    // SmartwatchDataWidget(
                    //   heartRateNotifier: heartRateNotifier,
                    //   stepsNotifier: stepsNotifier,
                    //   caloriesNotifier: caloriesNotifier,
                    // ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () async {
                        await _smartwatchService.disconnect();
                        setState(() {});
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text("❌ Disconnect",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
