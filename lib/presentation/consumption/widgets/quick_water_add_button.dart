import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitnessapp/utils/managers/color_manager.dart';
import 'package:fitnessapp/utils/managers/font_manager.dart';
import 'package:fitnessapp/utils/managers/value_manager.dart';

class QuickWaterAddButton extends StatelessWidget {
  const QuickWaterAddButton({
    super.key,
    required this.label,
    required this.addWater,
  });

  final String label;
  final VoidCallback addWater;

  @override
  Widget build(BuildContext context) {
    
    return GestureDetector(
      onTap: addWater,
      child: Material(
        color: Colors.transparent,
        child: Container(
          height: SizeManager.s50.h,
          width: SizeManager.s100.w,
          decoration: BoxDecoration(
            color: ColorManager.grey3,
            borderRadius: BorderRadius.circular(
              RadiusManager.r15.r,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                offset: Offset(0, 4),
                blurRadius: 8,
              ),
            ],
          ),
          child: Center(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: ColorManager.white,
                fontSize: FontSize.s20.sp,
                fontWeight: FontWightManager.semiBold,
                letterSpacing: SizeManager.s1_5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
