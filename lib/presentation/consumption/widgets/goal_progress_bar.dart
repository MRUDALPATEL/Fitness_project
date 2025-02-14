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
        
        // Goals in a horizontal scrollable row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              GoalCard(
                title: "Calories",
                goal: consumptionProvider.goalValue,
                current: consumptionProvider.kCalaDay,
                icon: Icons.local_fire_department,
                color: Colors.green,
              ),
              GoalCard(
                title: "Carbs",
                goal: consumptionProvider.goalCarbs,
                current: consumptionProvider.currentCarbs,
                icon: Icons.restaurant,
                color: Colors.blue,
              ),
              GoalCard(
                title: "Proteins",
                goal: consumptionProvider.goalProteins,
                current: consumptionProvider.currentProteins,
                icon: Icons.fitness_center,
                color: Colors.orange,
              ),
              GoalCard(
                title: "Fats",
                goal: consumptionProvider.goalFats,
                current: consumptionProvider.currentFats,
                icon: Icons.fastfood,
                color: Colors.red,
              ),
            ],
          ),
        ),
      ],
    );
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
    return Container(
      width: 85, // Compact width for better row fit
      margin: const EdgeInsets.symmetric(horizontal: 5),
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
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold,color: Colors.white),
          ),
          const SizedBox(height: 3),
          Text(
            "${current.toStringAsFixed(1)} / ${goal.toStringAsFixed(1)}",
            style: TextStyle(color: Colors.white, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
