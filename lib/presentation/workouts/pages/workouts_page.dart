import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:provider/provider.dart';
import 'package:fitnessapp/presentation/workouts/providers/workout_provider.dart';
import 'package:fitnessapp/presentation/workouts/widgets/new_exercise_button.dart';
import 'package:fitnessapp/presentation/workouts/widgets/exercise_widget.dart';
import 'package:fitnessapp/utils/managers/color_manager.dart';
import 'package:fitnessapp/utils/router/router.dart';

class WorkoutPage extends StatefulWidget {
  const WorkoutPage({super.key});

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  @override
  void initState() {
    super.initState();
    final provider = Provider.of<WorkoutProvider>(context, listen: false);
    provider.fetchAndSetWorkouts();
  }

  Future<void> _handleRefresh() async {
    final provider = Provider.of<WorkoutProvider>(context, listen: false);
    
    try {
      await provider.fetchAndSetWorkouts();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to refresh: $e')),
        );
      }
    }
  }

  void _deleteWorkout(String workoutID) {
    Provider.of<WorkoutProvider>(context, listen: false).deleteWorkout(workoutID: workoutID);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Workout deleted successfully!')),
    );
  }

  void _finishWorkout(String workoutID, String name, int repNumber, int setNumber, DateTime dateTime) {
    final provider = Provider.of<WorkoutProvider>(context, listen: false);
    provider.finishWorkout(
      workoutID: workoutID,
      name: name,
      repNumber: repNumber,
      setNumber: setNumber,
      dateTime: dateTime,
    );
    provider.deleteWorkout(workoutID: workoutID);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Workout marked as finished!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LiquidPullToRefresh(
          height: 80.h,
          color: ColorManager.white,
          animSpeedFactor: 2,
          backgroundColor: ColorManager.black,
          onRefresh: _handleRefresh,
          child: Container(
            color: ColorManager.darkGrey,
            child: Stack(
              children: [
                Consumer<WorkoutProvider>(
                  builder: (context, workoutsProvider, _) {
                    if (workoutsProvider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (workoutsProvider.hasError) {
                      return Center(
                        child: Text(
                          'An error occurred: ${workoutsProvider.errorMessage}',
                          style: TextStyle(fontSize: 16.sp, color: Colors.red),
                        ),
                      );
                    }

                    final workouts = workoutsProvider.workouts;
                    return ListView(
                      padding: EdgeInsets.all(16.w),
                      children: [
                        // ✅ Add Exercise Button at the top
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          child: NewExerciseButton(
                            onTap: () => Navigator.of(context).pushNamed(Routes.newWorkoutRoute),
                          ),
                        ),
                        
                        if (workouts.isEmpty)
                          Center(
                            child: Text(
                              "No exercises available. Tap the button above to add a new exercise!",
                              style: TextStyle(fontSize: 16.sp, color: ColorManager.limeGreen),
                              textAlign: TextAlign.center,
                            ),
                          )
                        else
                          ...workouts.map((workout) => ExerciseWidget(
                                name: workout.name,
                                repNumber: workout.repNumber,
                                setNumber: workout.setNumber,
                                id: workout.id,
                                onDeleted: (_) => _deleteWorkout(workout.id),
                                onFinished: (_) => _finishWorkout(
                                  workout.id,
                                  workout.name,
                                  workout.repNumber,
                                  workout.setNumber,
                                  workout.dateTime,
                                ),
                              )),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
