import 'package:fitnessapp/presentation/consumption/providers/consumption_provider.dart';
import 'package:fitnessapp/presentation/home/providers/home_provider.dart';
import 'package:fitnessapp/utils/managers/color_manager.dart';
import 'package:fitnessapp/utils/managers/string_manager.dart';
import 'package:fitnessapp/utils/managers/style_manager.dart';
import 'package:fitnessapp/utils/managers/value_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';

class FitnessDataWidget extends StatelessWidget {
  const FitnessDataWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    final deviceWidth = MediaQuery.of(context).size.width;

    return Consumer<ConsumptionProvider>(
      builder: (context, consumptionProvider, _) => FutureBuilder<
              Map<String, dynamic>>(
          future: homeProvider.fetchUserData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return SpinKitSpinningLines(color: ColorManager.limerGreen2);
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              double bmr = homeProvider.userData['bmr'];
              double bmi = homeProvider.userData['bmi'];

              Color getProgressColor(double bmi) {
                if (bmi >= 18.5 && bmi <= 25) {
                  return ColorManager.limerGreen2;
                } else if ((bmi >= 17 && bmi < 18.5) || (bmi > 25 && bmi <= 30)) {
                  return ColorManager.yellow;
                } else {
                  return ColorManager.red;
                }
              }

              String getMessage(double bmi) {
                if (bmi >= 18.5 && bmi <= 25) {
                  return StringsManager.normalBmi;
                } else if (bmi >= 17 && bmi < 18.5) {
                  return StringsManager.underWeightBmi;
                } else if (bmi > 25 && bmi <= 30) {
                  return StringsManager.overWeightBmi;
                } else {
                  return StringsManager.dangerousBmi;
                }
              }

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: PaddingManager.p12.w),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// **BMI Box**
                    Expanded(
                      flex: 1,
                      child: Container(
                        height: 210.h,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        decoration: BoxDecoration(
                          color: ColorManager.black87,
                          borderRadius: BorderRadius.circular(RadiusManager.r15.r),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularPercentIndicator(
                              circularStrokeCap: CircularStrokeCap.round,
                              radius: 40.r,
                              lineWidth: 8.w,
                              percent: bmi / 40,
                              progressColor: getProgressColor(bmi),
                              backgroundColor: ColorManager.grey3,
                              animateFromLastPercent: true,
                              animation: true,
                              center: Icon(
                                Icons.favorite_border,
                                color: getProgressColor(bmi),
                                size: 28,
                              ),
                            ),
                            SizedBox(height: 10.h),
                            Text(
                              'BMI ${bmi.toStringAsFixed(1)}',
                              style: StyleManager.homePageS20BoldWhite,
                            ),
                            SizedBox(height: 5.h),
                            Text(
                              getMessage(bmi),
                              style: StyleManager.fitnessappBmiTextStyle,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(width: 12.w),

                    /// **BMR & Water/Calorie Boxes**
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          /// **BMR Box**
                          Container(
                            height: 100.h,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: ColorManager.limerGreen2,
                              borderRadius: BorderRadius.circular(RadiusManager.r15.r),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  StringsManager.kcalConsumption,
                                  style: StyleManager.homePageS18BoldDarkGrey,
                                ),
                                Text(
                                  bmr.toStringAsFixed(0),
                                  style: StyleManager.homePageS20BoldDarkGrey,
                                ),
                                Text(
                                  StringsManager.kcalPerDay,
                                  style: StyleManager.homePageS16RegularDarkGrey,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 12.h),

                          /// **Water & Calories Row**
                          Row(
                            children: [
                              /// **Water Box**
                              Expanded(
                                child: _buildDataBox(
                                  title: StringsManager.water,
                                  value: "${consumptionProvider.waterADay.toStringAsFixed(1)} ${StringsManager.liters}",
                                  icon: Icons.water_drop_outlined,
                                  color: ColorManager.black87,
                                  iconColor: ColorManager.limerGreen2,
                                ),
                              ),
                              SizedBox(width: 12.w),

                              /// **Calories Box**
                              Expanded(
                                child: _buildDataBox(
                                  title: StringsManager.calories,
                                  value: "${consumptionProvider.kCalaDay.toStringAsFixed(0)} ${StringsManager.kcal}",
                                  icon: Icons.local_pizza_outlined,
                                  color: ColorManager.black87,
                                  iconColor: ColorManager.limerGreen2,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }
          }),
    );
  }

  /// **Reusable Box Widget**
  Widget _buildDataBox({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color iconColor,
  }) {
    return Container(
      height: 90.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(RadiusManager.r15.r),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: StyleManager.homePageS17BoldWhite,
              ),
              Icon(icon, size: 28, color: iconColor),
            ],
          ),
          SizedBox(height: 5.h),
          Text(
            value,
            style: StyleManager.homePageS20BoldWhite,
          ),
        ],
      ),
    );
  }
}
