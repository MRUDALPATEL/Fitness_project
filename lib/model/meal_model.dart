import 'package:cloud_firestore/cloud_firestore.dart';

class MealModel {
  String id;
  String title;
  double calories;
  double amount;
  double proteins;
  double fats;
  double carbs;
  DateTime dateTime;
  MealModel({
    required this.id,
    required this.title,
    required this.calories,
    required this.amount,
    required this.carbs,
    required this.fats,
    required this.proteins,
    required this.dateTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'calories': calories,
      'amount': amount,
      'proteins': proteins,
      'fats': fats,
      'carbs': carbs,
      'dateTime': dateTime.toIso8601String(),
    };
  }





  factory MealModel.fromMap(Map<String, dynamic> map) {

    return MealModel(

      id: map['id'],

      title: map['title'],

      amount: map['amount'],

      calories: map['calories'],

      fats: map['fats'],

      carbs: map['carbs'],

      proteins: map['proteins'],

      dateTime: (map['dateTime'] as Timestamp).toDate(),

    );

  }

}

