import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitnessapp/utils/managers/color_manager.dart';
import 'package:fitnessapp/utils/managers/string_manager.dart';
import 'package:fitnessapp/utils/managers/style_manager.dart';
import 'package:fitnessapp/utils/managers/value_manager.dart';

class EditTextButton extends StatelessWidget {
  const EditTextButton({
    super.key,
    required this.onTap,
  });
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: PaddingManager.p3,
        right: PaddingManager.p12,
      ),
      child: Align(
        alignment: Alignment.centerRight,
        child: GestureDetector(
          onTap: onTap,
          child: Flexible(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  StringsManager.edit,
                  textAlign: TextAlign.right,
                  style: StyleManager.editTextButtonTextStyle,
                ),
                SizedBox(
                  width: SizeManager.s3.w,
                ),
                const Icon(
                  Icons.edit,
                  color: ColorManager.white,
                  size: SizeManager.s18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
