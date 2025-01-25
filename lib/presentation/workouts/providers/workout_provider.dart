import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fitnessapp/model/workout_model.dart';

class WorkoutProvider with ChangeNotifier {
  final List<WorkoutModel> _workouts = [];
  final List<WorkoutModel> _finishedWorkouts = [];
  final List<WorkoutModel> _allWorkouts = [];
  double? progressPercent;
  int? exercisesLeft;
  double? shownPercent;

  static const String workoutsPath = 'workouts';
  static const String finishedWorkoutsPath = 'finishedWorkouts';
  static const String allWorkoutsPath = 'allWorkouts';

 
  List<WorkoutModel> get workouts {
  print("Current workouts: ${_workouts.length}");
  return [..._workouts];
}

  List<WorkoutModel> get finishedWorkouts => [..._finishedWorkouts];
  List<WorkoutModel> get allWorkouts => [..._allWorkouts];

  Future<void> getProgressPercent() async {
    final int allWorkoutsNum = _allWorkouts.length;
    final int finishedWorkoutsNum = _finishedWorkouts.length;
    progressPercent = allWorkoutsNum > 0 ? finishedWorkoutsNum / allWorkoutsNum : 0;
    shownPercent = progressPercent! * 100;
    exercisesLeft = allWorkoutsNum - finishedWorkoutsNum;
  }

  Future<void> addNewWorkout({
    required String name,
    required int repNumber,
    required int setNumber,
    required DateTime dateTime,
  }) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      String docId = FirebaseFirestore.instance.collection(workoutsPath).doc().id;

      await FirebaseFirestore.instance
          .collection(workoutsPath)
          .doc(user.uid)
          .collection('workoutData')
          .doc(docId)
          .set({
        'name': name,
        'repNumber': repNumber,
        'setNumber': setNumber,
        'dateTime': dateTime,
        'id': docId,
      });

      await FirebaseFirestore.instance
          .collection(allWorkoutsPath)
          .doc(user.uid)
          .collection('allWorkoutsData')
          .doc(docId)
          .set({
        'name': name,
        'repNumber': repNumber,
        'setNumber': setNumber,
        'dateTime': dateTime,
        'id': docId,
      });

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
Future<void> fetchAndSetWorkouts() async {
  User? user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    print("Error: User is not authenticated.");
    return;
  }

  print("Fetching workouts for user: ${user.uid}");

  try {
    final workoutSnapshot = await FirebaseFirestore.instance
        .collection('workouts')
        .doc(user.uid)
        .collection('workoutData')
        .get();

    if (workoutSnapshot.docs.isEmpty) {
      print("No workouts found.");
      _workouts.clear(); // Ensure the list is cleared if no data
    } else {
      print("Workouts fetched: ${workoutSnapshot.docs.length}");
      _workouts.clear(); // Clear old data
      _workouts.addAll(_mapSnapshotToWorkoutList(workoutSnapshot));
    }

    notifyListeners(); // Notify the UI to update
  } catch (e) {
    print("Error fetching workouts: $e");
    rethrow;
  }
}




  Future<void> clearWorkoutsIfDayChanges(DateTime lastDateTime) async {
    DateTime now = DateTime.now();
    if (!now.isSameDay(lastDateTime)) {
      try {
        User? user = FirebaseAuth.instance.currentUser;
        if (user == null) return;

        for (String collection in [workoutsPath, finishedWorkoutsPath, allWorkoutsPath]) {
          await _clearOldWorkouts(collection, user.uid, now);
        }
      } catch (e) {
        rethrow;
      } finally {
        notifyListeners();
      }
    }
  }

  

  
  List<WorkoutModel> _mapSnapshotToWorkoutList(QuerySnapshot snapshot) {
  return snapshot.docs.map((doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WorkoutModel(
      id: data['id'] ?? '',
      name: data['name'] ?? 'Unnamed',
      repNumber: data['repNumber'] ?? 0,
      setNumber: data['setNumber'] ?? 0,
      dateTime: (data['dateTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }).toList()
    ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
}


  Future<void> _clearOldWorkouts(String collection, String userId, DateTime now) async {
    await FirebaseFirestore.instance
        .collection(collection)
        .doc(userId)
        .collection('${collection}Data')
        .where('dateTime', isLessThan: Timestamp.fromDate(now))
        .get()
        .then((snapshot) {
      for (var doc in snapshot.docs) {
        doc.reference.delete();
      }
    });
  }

  Future<void> deleteWorkout({required String workoutID}) async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("User is not authenticated.");
    }

    // Delete workout from the 'workouts' collection
    await FirebaseFirestore.instance
        .collection(workoutsPath)
        .doc(user.uid)
        .collection('workoutData')
        .doc(workoutID)
        .delete();

    // Remove the workout locally from the _workouts list
    _workouts.removeWhere((workout) => workout.id == workoutID);

    notifyListeners(); // Notify the UI to refresh
  } catch (e) {
    print("Error deleting workout: $e");
    rethrow;
  }
}

Future<void> finishWorkout({
  required String workoutID,
  required String name,
  required int repNumber,
  required int setNumber,
  required DateTime dateTime,
}) async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("User is not authenticated.");
    }

    // Add the workout to the 'finishedWorkouts' collection
    await FirebaseFirestore.instance
        .collection(finishedWorkoutsPath)
        .doc(user.uid)
        .collection('finishedWorkoutsData')
        .doc(workoutID)
        .set({
      'name': name,
      'repNumber': repNumber,
      'setNumber': setNumber,
      'dateTime': dateTime,
      'id': workoutID,
    });

    // Remove the workout from the 'workouts' collection
    await deleteWorkout(workoutID: workoutID);

    // Add the workout locally to the _finishedWorkouts list
    _finishedWorkouts.add(WorkoutModel(
      id: workoutID,
      name: name,
      repNumber: repNumber,
      setNumber: setNumber,
      dateTime: dateTime,
    ));

    notifyListeners(); // Notify the UI to refresh
  } catch (e) {
    print("Error finishing workout: $e");
    rethrow;
  }
}

}

extension DateTimeComparison on DateTime {
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}
