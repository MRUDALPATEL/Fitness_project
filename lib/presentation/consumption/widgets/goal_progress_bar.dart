import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:Fitness/presentation/consumption/providers/consumption_provider.dart';

class GoalProgressBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final consumptionProvider =
        Provider.of<ConsumptionProvider>(context); // Listen for changes

    // Safely access the goal and current values from the provider
    final double goalCalories = consumptionProvider.goalValue != 0
        ? consumptionProvider.goalValue
        : 1.0; // Avoid division by zero
    final double currentCalories = consumptionProvider.kCalaDay;

    final double goalCarbs = consumptionProvider.goalCarbs != 0
        ? consumptionProvider.goalCarbs
        : 1.0; // Avoid division by zero
    final double currentCarbs = consumptionProvider.currentCarbs;

    final double goalProteins = consumptionProvider.goalProteins != 0
        ? consumptionProvider.goalProteins
        : 1.0; // Avoid division by zero
    final double currentProteins = consumptionProvider.currentProteins;

    final double goalFats = consumptionProvider.goalFats != 0
        ? consumptionProvider.goalFats
        : 1.0; // Avoid division by zero
    final double currentFats = consumptionProvider.currentFats;

    // Calculate progress percentages
    final double caloriesProgress =
        (currentCalories / goalCalories).clamp(0.0, 1.0);
    final double carbsProgress = (currentCarbs / goalCarbs).clamp(0.0, 1.0);
    final double proteinsProgress =
        (currentProteins / goalProteins).clamp(0.0, 1.0);
    final double fatsProgress = (currentFats / goalFats).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProgressIndicatorRow(
          title: "Calories Progress",
          progress: caloriesProgress,
          progressColor: Colors.green,
        ),
        SizedBox(height: 10),
        ProgressIndicatorRow(
          title: "Carbs Progress",
          progress: carbsProgress,
          progressColor: Colors.blue,
        ),
        SizedBox(height: 10),
        ProgressIndicatorRow(
          title: "Proteins Progress",
          progress: proteinsProgress,
          progressColor: Colors.orange,
        ),
        SizedBox(height: 10),
        ProgressIndicatorRow(
          title: "Fats Progress",
          progress: fatsProgress,
          progressColor: Colors.red,
        ),
      ],
    );
  }
}

class ProgressIndicatorRow extends StatelessWidget {
  final String title;
  final double progress;
  final Color progressColor;

  const ProgressIndicatorRow({
    Key? key,
    required this.title,
    required this.progress,
    required this.progressColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        LinearPercentIndicator(
          lineHeight: 14.0,
          percent: progress, // Ensures it's clamped between 0.0 and 1.0
          center: Text(
            "${(progress * 100).toStringAsFixed(1)}%",
            style: TextStyle(fontSize: 12),
          ),
          backgroundColor: Colors.grey[300]!,
          progressColor: progressColor,
        ),
      ],
    );
  }
}
