import 'package:fitnessapp/utils/managers/color_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitnessapp/presentation/consumption/providers/consumption_provider.dart';

class GoalProgressBar extends StatelessWidget {
  const GoalProgressBar({super.key});

  @override
  Widget build(BuildContext context) {
    final consumptionProvider = Provider.of<ConsumptionProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Your Goals",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 10),

        // Check if there are no goals set
        if (consumptionProvider.goals.isEmpty)
          const Center(
            child: Text(
              "No goals set yet.",
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          )
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: consumptionProvider.goals.entries.map((entry) {
                return GoalCard(
                  title: entry.key,
                  goal: entry.value,
                  current: consumptionProvider.getCurrentValue(entry.key),
                  icon: getGoalIcon(entry.key),
                  color: getGoalColor(entry.key),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}

// Function to get icons dynamically based on goal type
IconData getGoalIcon(String goalType) {
  switch (goalType.toLowerCase()) {
    case "calories":
      return Icons.local_fire_department;
    case "carbs":
      return Icons.restaurant;
    case "proteins":
      return Icons.fitness_center;
    case "fats":
      return Icons.fastfood;
    default:
      return Icons.flag; // Default icon for other goals
  }
}

// Function to get colors dynamically based on goal type
Color getGoalColor(String goalType) {
  switch (goalType.toLowerCase()) {
    case "calories":
      return Colors.green;
    case "carbs":
      return Colors.blue;
    case "proteins":
      return Colors.orange;
    case "fats":
      return Colors.red;
    default:
      return Colors.purple; // Default color for other goals
  }
}

class GoalCard extends StatelessWidget {
  final String title;
  final double goal;
  final double current;
  final IconData icon;
  final Color color;

  const GoalCard({
    Key? key,
    required this.title,
    required this.goal,
    required this.current,
    required this.icon,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double progress = (current / goal).clamp(0.0, 1.0); // Ensure progress doesn't exceed 1.0

    return Container(
      width: 100,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ColorManager.darkGrey,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 5),
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 3),
          Stack(
            alignment: Alignment.center,
            children: [
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white24,
                color: color,
                minHeight: 6,
              ),
              Text(
                "${(progress * 100).toStringAsFixed(0)}%",
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            "${current.toStringAsFixed(1)} / ${goal.toStringAsFixed(1)}",
            style: const TextStyle(color: Colors.white70, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
