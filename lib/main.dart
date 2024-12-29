import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:Fitness/utils/notifications/notification_manager.dart';

import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  NotificationManager notificationManager = NotificationManager();
  await notificationManager.init();
  runApp(
    MyApp(),
  );
}
