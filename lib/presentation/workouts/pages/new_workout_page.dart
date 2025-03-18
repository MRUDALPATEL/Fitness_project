import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitnessapp/presentation/home/providers/home_provider.dart';
import 'package:fitnessapp/presentation/workouts/providers/workout_provider.dart';
import 'package:fitnessapp/utils/managers/color_manager.dart';
import 'package:fitnessapp/utils/managers/string_manager.dart';
import 'package:fitnessapp/utils/widgets/lime_green_rounded_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class NewWorkoutPage extends StatefulWidget {
  const NewWorkoutPage({super.key});

  @override
  _NewWorkoutPageState createState() => _NewWorkoutPageState();
}

class _NewWorkoutPageState extends State<NewWorkoutPage> {
  String? athleteCategory;
  Map<String, List<Map<String, dynamic>>> exercises = {};
  Set<String> selectedExercises = {}; // Set to store selected exercises

  @override
  void initState() {
    super.initState();
    fetchAthleteCategory();
  }

  void fetchAthleteCategory() {
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    if (homeProvider.userData.containsKey('category')) {
      setState(() {
        athleteCategory = homeProvider.userData['category'].toLowerCase();
      });
      fetchExercises();
    } else {
      print("Category not found in userData");
    }
  }

  Future<void> fetchExercises() async {
    if (athleteCategory == null) return;

    DocumentSnapshot exerciseDoc =
        await FirebaseFirestore.instance.collection('exercises').doc(athleteCategory).get();

    if (!exerciseDoc.exists) {
      print("No exercises found for category: $athleteCategory");
      return;
    }

    setState(() {
      exercises = (exerciseDoc.data() as Map<String, dynamic>).map(
        (key, value) => MapEntry(
          key, (value as List).map((e) => e as Map<String, dynamic>).toList(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final workoutProvider = Provider.of<WorkoutProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text("Select Workouts", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: ColorManager.darkGrey,
        iconTheme:
            const IconThemeData(color: Colors.white),
      ),
      backgroundColor: ColorManager.darkGrey,
      body: exercises.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    children: exercises.keys.map((category) {
                      return Card(
                        color: ColorManager.darkGrey,
                        margin: EdgeInsets.all(8.0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ExpansionTile(
                          title: Text(
                            category.toUpperCase(),
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 18,
                              
                            ),
                          ),
                          children: exercises[category]!.map((exercise) {
                            final exerciseName = exercise['name'] ?? 'Unnamed Exercise';
                            final isSelected = selectedExercises.contains(exerciseName);
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    selectedExercises.remove(exerciseName);
                                  } else {
                                    selectedExercises.add(exerciseName);
                                  }
                                });
                              },
                              child: Card(
                                color: isSelected ? Colors.lime[700] : Colors.grey[850],
                                elevation: 4,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                child: ListTile(
                                  title: Text(
                                    exerciseName,
                                    style: GoogleFonts.poppins(
                                      color: isSelected ? Colors.black : Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: exercise.containsKey('reps')
                                      ? Text("Reps: ${exercise['reps']}", style: GoogleFonts.poppins(color: Colors.white70))
                                      : (exercise.containsKey('duration')
                                          ? Text("Duration: ${exercise['duration']}",
                                              style: GoogleFonts.poppins(color: Colors.white70))
                                          : null),
                                  trailing: Icon(
                                    isSelected ? Icons.check_circle : Icons.fitness_center,
                                    color: isSelected ? Colors.black : Colors.white70,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: LimeGreenRoundedButtonWidget(
                    onTap: () async {
                      if (selectedExercises.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Please select at least one exercise.")),
                        );
                        return;
                      }

                      try {
                        for (String exerciseName in selectedExercises) {
                          final selectedExercise = exercises.values
                              .expand((categoryExercises) => categoryExercises)
                              .firstWhere(
                                (e) => e['name'] == exerciseName,
                                orElse: () => {},
                              );

                          if (selectedExercise.isEmpty) {
                            print("Selected exercise not found in list.");
                            continue;
                          }

                          await workoutProvider.addNewWorkout(
                            name: selectedExercise['name'],
                            repNumber: selectedExercise['reps'] ?? 0,
                            setNumber: selectedExercise['sets'] ?? 0,
                            dateTime: DateTime.now(),
                          );
                        }

                        await workoutProvider.getProgressPercent();
                        Navigator.of(context).pop();
                      } catch (e) {
                        print("Error adding workout: $e");
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error adding workout: $e")),
                        );
                      }
                    },
                    title: StringsManager.add,
                  ),
                ),
              ],
            ),
    );
  }
}
