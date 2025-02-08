import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';
import 'package:fitnessapp/presentation/consumption/providers/consumption_provider.dart';
import 'package:fitnessapp/presentation/home/widgets/fitness_data_widget.dart';
import 'package:fitnessapp/presentation/home/widgets/smartwatchdatawidget.dart';
import 'package:fitnessapp/presentation/home/widgets/home_page_text_spacer_widget.dart';
import 'package:fitnessapp/presentation/home/widgets/todays_progress_widget.dart';
import 'package:fitnessapp/utils/managers/string_manager.dart';
import 'package:fitnessapp/core/smartwatch_notifiers.dart'; // ✅ Ensure this file correctly defines the notifiers

class HomePage extends StatefulWidget {
  final BluetoothDevice? connectedDevice; // ✅ Pass connected smartwatch

  const HomePage({super.key, this.connectedDevice});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<BluetoothService> services = [];

  @override
  void initState() {
    super.initState();

    // Fetch data after build completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ConsumptionProvider>(context, listen: false).fetchAndSetMeals();
      Provider.of<ConsumptionProvider>(context, listen: false).fetchAndSetWater();
    });

    // 🔹 Fetch smartwatch services if a device is connected
    if (widget.connectedDevice != null) {
      _fetchBluetoothServices();
    }
  }

  Future<void> _fetchBluetoothServices() async {
    try {
      List<BluetoothService> fetchedServices = await widget.connectedDevice!.discoverServices();
      setState(() {
        services = fetchedServices;
      });
    } catch (e) {
      print("Error fetching services: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const TodaysProgressWidget(),
            const HomePageTextSpacerWidget(title: StringsManager.todaysAct),
            const FitnessDataWidget(),
            const HomePageTextSpacerWidget(title: StringsManager.explore),

            // ✅ Display smartwatch data
            SmartwatchDataWidget(
              heartRateNotifier: heartRateNotifier,
              stepsNotifier: stepsNotifier,
              caloriesNotifier: caloriesNotifier,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms);
  }
}
