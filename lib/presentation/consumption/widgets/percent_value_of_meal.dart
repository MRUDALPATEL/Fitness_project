import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:fitnessapp/utils/managers/color_manager.dart';
import 'package:fitnessapp/utils/managers/style_manager.dart';
import 'package:fitnessapp/utils/managers/value_manager.dart';

class PercentValueOfMeal extends StatelessWidget {
  const PercentValueOfMeal({
    super.key,
    required this.value,
    required this.amount,
    required this.title,
  });

  final double value;
  final double amount;
  final String title;

  @override
  Widget build(BuildContext context) {
    // Ensure the percent value is normalized between 0.0 and 1.0
    final double percent = (amount > 0) ? (value / amount).clamp(0.0, 1.0) : 0.0;

    // Round the value to 1 decimal place for display
    final String roundedValue = value.toStringAsFixed(1);

    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(
            bottom: PaddingManager.p12,
          ),
          child: RotatedBox(
            quarterTurns: 3,
            child: LinearPercentIndicator(
              percent: percent, // Pass the normalized value here
              width: SizeManager.s60.w,
              backgroundColor: ColorManager.grey3,
              progressColor: ColorManager.limerGreen2,
              lineHeight: SizeManager.s8.w,
              animation: true,
              barRadius: Radius.circular(RadiusManager.r15.r),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            left: PaddingManager.p8,
            bottom: PaddingManager.p12,
          ),
          child: Column(
            children: [
              Text(
                '$roundedValue g', // Display the exact rounded value
                style: StyleManager.percentValueOfMealTextStyle,
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: PaddingManager.p3,
                ),
                child: Text(
                  title,
                  style: StyleManager.percentValueOfMealTitleTextSTyle,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
