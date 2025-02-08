import 'package:flutter/material.dart';

class SmartwatchDataWidget extends StatelessWidget {
  // ✅ Declare the fields
  final ValueNotifier<int> heartRateNotifier;
  final ValueNotifier<int> stepsNotifier;
  final ValueNotifier<int> caloriesNotifier;

  // ✅ Proper constructor
  const SmartwatchDataWidget({
    super.key,
    required this.heartRateNotifier,
    required this.stepsNotifier,
    required this.caloriesNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDataBox(
                title: "Heart Rate",
                icon: Icons.favorite,
                color: Colors.redAccent,
                notifier: heartRateNotifier,
                unit: "bpm",
              ),
              _buildDataBox(
                title: "Steps",
                icon: Icons.directions_walk,
                color: Colors.blueAccent,
                notifier: stepsNotifier,
                unit: "steps",
              ),
              _buildDataBox(
                title: "Calories",
                icon: Icons.local_fire_department,
                color: Colors.orangeAccent,
                notifier: caloriesNotifier,
                unit: "kcal",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDataBox({
    required String title,
    required IconData icon,
    required Color color,
    required ValueNotifier<int> notifier,
    required String unit,
  }) {
    return Expanded(
      child: ValueListenableBuilder<int>(
        valueListenable: notifier,
        builder: (context, value, child) {
          return Container(
            height: 120,
            margin: const EdgeInsets.symmetric(horizontal: 8.0),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color, width: 2),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(2, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 32, color: color),
                const SizedBox(height: 8),
                Text(
                  "$value $unit",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
