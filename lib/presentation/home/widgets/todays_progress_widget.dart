import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:fitnessapp/presentation/workouts/providers/workout_provider.dart';
import 'package:fitnessapp/utils/managers/color_manager.dart';
import 'package:fitnessapp/utils/managers/string_manager.dart';
import 'package:fitnessapp/utils/managers/style_manager.dart';
import 'package:fitnessapp/utils/managers/value_manager.dart';

class TodaysProgressWidget extends StatelessWidget {
  const TodaysProgressWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final deviceHeight = MediaQuery.of(context).size.height;

    return Consumer<WorkoutProvider>(builder: (context, workoutProvider, _) {
      var isLoaded = workoutProvider.progressPercent == null ||
          workoutProvider.shownPercent == null ||
          workoutProvider.exercisesLeft == null;

      if (isLoaded) {
        return SizedBox(
          height: deviceHeight * 0.2,
          child: Center(
            child: SpinKitSpinningLines(color: ColorManager.limerGreen2),
          ),
        );
      } else {
        workoutProvider.getProgressPercent();
        double progressPercent = workoutProvider.progressPercent!;
        double shownPercent = workoutProvider.shownPercent!;
        int exercisesLeft = workoutProvider.exercisesLeft!;

        var isResetDay = progressPercent.isNaN &&
            shownPercent.isNaN &&
            workoutProvider.workouts.isEmpty &&
            workoutProvider.finishedWorkouts.isEmpty;
        if (isResetDay) {
          progressPercent = 0.0;
          shownPercent = 0.0;
        }

        Text subText(WorkoutProvider workoutProvider, int exercisesLeft) {
          if (workoutProvider.workouts.isNotEmpty) {
            return Text(
              '$exercisesLeft Exercises Left',
              style: StyleManager.homePageS14RegularWhite2L1,
              textAlign: TextAlign.left,
            );
          } else if (workoutProvider.finishedWorkouts.isEmpty &&
              workoutProvider.workouts.isEmpty) {
            return Text(
              StringsManager.startYourExercises,
              style: StyleManager.homePageS14RegularWhite2L1,
              textAlign: TextAlign.left,
            );
          } else if (workoutProvider.finishedWorkouts.isNotEmpty &&
              workoutProvider.workouts.isEmpty) {
            return Text(
              StringsManager.exercisesDoneTxt,
              style: StyleManager.homePageS14RegularWhite2L1,
              textAlign: TextAlign.left,
            );
          } else {
            return Text(
              StringsManager.error,
              style: StyleManager.homePageS14RegularWhite2L1,
              textAlign: TextAlign.left,
            );
          }
        }

        return Padding(
          padding: EdgeInsets.symmetric(
            vertical: deviceHeight * 0.02,
            horizontal: deviceWidth * 0.03,
          ),
          child: Container(
            width: deviceWidth,
            padding: EdgeInsets.symmetric(
              vertical: deviceHeight * 0.02,
              horizontal: deviceWidth * 0.04,
            ),
            decoration: BoxDecoration(
              color: ColorManager.black87,
              borderRadius: BorderRadius.circular(RadiusManager.r40.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      StringsManager.todaysProg,
                      style: StyleManager.homePageTodaysProgressTextSTyle,
                      textAlign: TextAlign.left,
                    ),
                    SizedBox(height: deviceHeight * 0.01),
                    subText(workoutProvider, exercisesLeft),
                  ],
                ),
                CircularPercentIndicator(
                  circularStrokeCap: CircularStrokeCap.round,
                  radius: deviceWidth * 0.10,
                  lineWidth: deviceWidth * 0.02,
                  percent: progressPercent,
                  progressColor: ColorManager.limerGreen2,
                  backgroundColor: ColorManager.grey3,
                  animateFromLastPercent: true,
                  animation: true,
                  center: Text(
                    '${shownPercent.toStringAsFixed(0)}%',
                    style: StyleManager.homePagePogressBarTextStyle,
                  ),
                ),
              ],
            ),
          ),
        );
      }
    });
  }
}
