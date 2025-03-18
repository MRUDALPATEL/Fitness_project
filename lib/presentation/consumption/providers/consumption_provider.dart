import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fitnessapp/model/meal_model.dart';
import 'package:fitnessapp/model/water_model.dart';
import 'package:fitnessapp/utils/notifications/notification_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

class ConsumptionProvider with ChangeNotifier {
  double goalCalories = 0.0;
  double goalCarbs = 0.0;
  double goalProteins = 0.0;
  double goalFats = 0.0;

  double currentCalories = 0.0;
  double currentCarbs = 0.0;
  double currentProteins = 0.0;
  double currentFats = 0.0;

  double kCalaDay = 0.0;
  double waterADay = 0.0;
  double goalValue = 0.0;

  // Set goals
  void setGoalCalories(double value) {
    goalCalories = value;
    notifyListeners();
  }

  void setGoalCarbs(double value) {
    goalCarbs = value;
    notifyListeners();
  }

  void setGoalProteins(double value) {
    goalProteins = value;
    notifyListeners();
  }

  void setGoalFats(double value) {
    goalFats = value;
    notifyListeners();
  }

  // Log consumption
  void logCalories(double value) {
    currentCalories += value;
    notifyListeners();
  }

  void logCarbs(double value) {
    currentCarbs += value;
    notifyListeners();
  }

  void logProteins(double value) {
    currentProteins += value;
    notifyListeners();
  }

  void logFats(double value) {
    currentFats += value;
    notifyListeners();
  }

  // Reset progress
  void resetProgress() {
    currentCalories = 0.0;
    currentCarbs = 0.0;
    currentProteins = 0.0;
    currentFats = 0.0;
    notifyListeners();
  }

  final NotificationManager _notificationManager = NotificationManager();

  final List<MealModel> meals = [];
  final List<WaterModel> water = [];
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';

  // Progress calculation
  double calculateProgress(double achieved, double goal) {
    if (goal == 0) {
      return 0; // No progress if goal is not set
    }
    double progress = (achieved / goal) * 100;
    return progress > 100 ? 100 : progress; // Cap progress at 100%
  }

  double getGoalProgress() {
    // Debug logs for checking values during runtime
    print('Calories Today (Achieved): $kCalaDay, Goal Value: $goalValue');
    return calculateProgress(kCalaDay, goalValue);
  }

  /// Meals Handling
  Future<void> addNewMeal({
    required String title,
    required double amount,
    required double calories,
    required double fats,
    required double carbs,
    required double proteins,
    required DateTime dateTime,
  }) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('User is not authenticated');
        return;
      }

      await FirebaseFirestore.instance
          .collection('meals')
          .doc(user.uid)
          .collection('mealData')
          .doc()
          .set({
        'title': title,
        'amount': amount,
        'calories': calories,
        'fats': fats,
        'carbs': carbs,
        'proteins': proteins,
        'dateTime': dateTime,
      });
      print('Meal added successfully');
      notifyListeners();
    } catch (e) {
      print('Error adding meal: $e');
      rethrow;
    }
  }

  Future<void> fetchAndSetMeals() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('User is not authenticated');
      return;
    }

    try {
      print("Fetching meals...");
      isLoading = true;  // Set to true while loading

      final mealsSnapshot = await FirebaseFirestore.instance
          .collection('meals')
          .doc(user.uid)
          .collection('mealData')
          .get();

      if (mealsSnapshot.docs.isEmpty) {
        print("No meals found.");
        meals.clear(); // Clear the meals list if no data is found
      } else {
        print("Meals fetched: ${mealsSnapshot.docs.length}");
        meals.clear(); // Clear old data
        meals.addAll(_mapSnapshotToMealList(
            mealsSnapshot)); // Map snapshot to meal models
      }

      // Sorting the meals list by dateTime in descending order
      meals.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      print('Meals fetched successfully');
      isLoading = false;  // Set to false while loading
      await getkCal();
      notifyListeners();
    } catch (e) {
      print('Error fetching meals: $e');
      rethrow;
    }
  }

// This function is used to map the snapshot to a list of MealModel
  List<MealModel> _mapSnapshotToMealList(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      final mealData = doc.data() as Map<String, dynamic>;
      return MealModel(
        id: doc.id,
        title: mealData['title'],
        amount: (mealData['amount'] as num).toDouble(),
        calories: (mealData['calories'] as num).toDouble(),
        carbs: (mealData['carbs'] as num).toDouble(),
        fats: (mealData['fats'] as num).toDouble(),
        proteins: (mealData['proteins'] as num).toDouble(),
        dateTime: (mealData['dateTime'] as Timestamp).toDate(),
      );
    }).toList();
  }

  Future<void> deleteMeal(String id) async {
    User? user = FirebaseAuth.instance.currentUser;
    try {
      await FirebaseFirestore.instance
          .collection('meals')
          .doc(user!.uid)
          .collection('mealData')
          .doc(id)
          .delete();
      meals.removeWhere((meal) => meal.id == id);
      await getkCal();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> getkCal() async {
    kCalaDay = meals.fold(0.0, (sum, meal) => sum + meal.calories);
    notifyListeners();
  }

  /// Water Handling
  Future<void> addWater({
    required double amount,
    required DateTime dateTime,
  }) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance
          .collection('meals')
          .doc(user!.uid)
          .collection('waterData')
          .doc()
          .set({
        'amount': amount,
        'dateTime': dateTime,
      });
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> fetchAndSetWater() async {
  User? user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    print('User is not authenticated');
    return;
  }

  

  try {
    final waterSnapshot = await FirebaseFirestore.instance
        .collection('meals')
        .doc(user.uid)
        .collection('waterData')
        .get();

    print('Water data fetched: ${waterSnapshot.docs.length} documents');

    final List<WaterModel> loadedWater = waterSnapshot.docs.map((doc) {
      final waterData = doc.data();
      
      return WaterModel(
        id: doc.id,
        amount: (waterData['amount'] as num).toDouble(),
        dateTime: (waterData['dateTime'] as Timestamp).toDate(),
      );
    }).toList();

    print('Loaded water data: ${loadedWater.length} entries');

    water.clear();
    water.addAll(loadedWater);

    // Optionally check water list after adding new data
    print('Water list after fetching: ${water.length} entries');

    await getWater();

    print('Finished fetching water data and notifying listeners');
    notifyListeners();
  } catch (e) {
    print('Error fetching water data: $e');
    rethrow;
  }
}


  Future<void> getWater() async {
    waterADay = water.fold(0.0, (sum, water) => sum + water.amount);
    notifyListeners();
  }

  /// Goal Handling
  Future<void> setGoal({
    required String goalType,
    required double goalValue,
    required String duration,
  }) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance.collection('goals').doc(user!.uid).set({
        'goalType': goalType,
        'goalValue': goalValue,
        'duration': duration,
      });
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
  
 Future<void> fetchGoal() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    print('User is not authenticated');
    return;
  }

  try {
    final goalSnapshot =
        await FirebaseFirestore.instance.collection('goals').doc(user.uid).get();

    if (goalSnapshot.exists) {
      final goalData = goalSnapshot.data()!;
      goalValue = (goalData['goalValue'] as num).toDouble();
      print("Goal fetched: $goalValue");
      notifyListeners();
    } else {
      print("No goal found.");
    }
  } catch (e) {
    print("Error fetching goal: $e");
    rethrow;
  }
}

  /// Notifications
  Future<void> sendNotification({
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    try {
      await _notificationManager.scheduleNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: title,
        body: body,
        scheduledTime: tz.TZDateTime.from(scheduledTime, tz.local),
      );
    } catch (e) {
      rethrow;
    }
  }

 
Future<void> clearDataIfDayChanges() async {
  final prefs = await SharedPreferences.getInstance();
  final lastUpdateTimestamp = prefs.getInt('last_update') ?? 0;
  final lastUpdate = DateTime.fromMillisecondsSinceEpoch(lastUpdateTimestamp);

  final now = DateTime.now();
  
  if (now.year > lastUpdate.year ||
      now.month > lastUpdate.month ||
      now.day > lastUpdate.day) {
    meals.clear();
    water.clear();
    notifyListeners();

    // Update last update time
    await prefs.setInt('last_update', now.millisecondsSinceEpoch);
  }
}





}
