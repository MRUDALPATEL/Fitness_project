import 'package:flutter/material.dart';

// Global notifiers to share smartwatch data across pages
final ValueNotifier<int> heartRateNotifier = ValueNotifier(0);
final ValueNotifier<int> stepsNotifier = ValueNotifier(0);
final ValueNotifier<int> caloriesNotifier = ValueNotifier(0);
