import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:provider/provider.dart';
import 'package:fitnessapp/presentation/workouts/providers/workout_provider.dart';
import 'package:fitnessapp/presentation/workouts/widgets/new_exercise_button.dart';
import 'package:fitnessapp/presentation/workouts/widgets/exercise_widget.dart';
import 'package:fitnessapp/utils/managers/color_manager.dart';
import 'package:fitnessapp/utils/managers/value_manager.dart';
import 'package:fitnessapp/utils/router/router.dart';

class WorkoutPage extends StatefulWidget {
  const WorkoutPage({super.key});

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  late Future<void> _workoutsFuture;

  @override
  void initState() {
    super.initState();
    _workoutsFuture = Provider.of<WorkoutProvider>(context, listen: false).fetchAndSetWorkouts();
  }

  Future<void> _handleRefresh() async {
    await Provider.of<WorkoutProvider>(context, listen: false).fetchAndSetWorkouts();
  }

  void _deleteWorkout(String workoutID) {
    Provider.of<WorkoutProvider>(context, listen: false).deleteWorkout(workoutID: workoutID);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Workout deleted successfully!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _finishWorkout(String workoutID, String name, int repNumber, int setNumber, DateTime dateTime) {
    Provider.of<WorkoutProvider>(context, listen: false).finishWorkout(
      workoutID: workoutID,
      name: name,
      repNumber: repNumber,
      setNumber: setNumber,
      dateTime: dateTime,
    );
    Provider.of<WorkoutProvider>(context, listen: false).deleteWorkout(workoutID: workoutID);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Workout marked as finished!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutProvider>(
      builder: (context, workoutsProvider, _) => SafeArea(
        child: Column(
          children: [
            // Add Exercise Button
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: NewExerciseButton(
                onTap: () {
                  Navigator.of(context).pushNamed(Routes.addNewExerciseRoute);
                },
              ),
            ),
            Expanded(
              child: LiquidPullToRefresh(
                height: SizeManager.s250.h,
                color: ColorManager.darkGrey,
                animSpeedFactor: 2,
                backgroundColor: ColorManager.white2,
                onRefresh: _handleRefresh,
                child: FutureBuilder<void>(
                  future: _workoutsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'An error occurred: ${snapshot.error}',
                          style: TextStyle(fontSize: 16.sp, color: Colors.red),
                        ),
                      );
                    }

                    final workouts = workoutsProvider.workouts;
                    if (workouts.isEmpty) {
                      return Center(
                        child: Text(
                          "No exercises available. Tap the button above to add a new exercise!",
                          style: TextStyle(fontSize: 16.sp, color: ColorManager.limeGreen),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: workouts.length,
                      itemBuilder: (context, index) {
                        final workout = workouts[index];
                        return ExerciseWidget(
                          name: workout.name,
                          repNumber: workout.repNumber,
                          setNumber: workout.setNumber,
                          id: workout.id,
                          onDeleted: (_) {
                            _deleteWorkout(workout.id);
                          },
                          onFinished: (_) {
                            _finishWorkout(
                              workout.id,
                              workout.name,
                              workout.repNumber,
                              workout.setNumber,
                              workout.dateTime,
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
