import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:Fitness/presentation/auth/providers/auth_provider.dart';
import 'package:Fitness/presentation/consumption/providers/consumption_provider.dart';
import 'package:Fitness/presentation/home/providers/home_provider.dart';
import 'package:Fitness/presentation/profile/providers/profile_provider.dart';
import 'package:Fitness/presentation/settings/providers/settings_provider.dart';
import 'package:Fitness/presentation/workouts/providers/workout_provider.dart';
import 'package:Fitness/utils/router/router.dart';

// ignore: must_be_immutable
class MyApp extends StatefulWidget {
  MyApp._internal();
  int appState = 0;
  static final MyApp instance = MyApp._internal();

  factory MyApp() => instance;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: AuthProvider(),
        ),
        ChangeNotifierProvider.value(
          value: SettingsProvider(),
        ),
        ChangeNotifierProvider.value(
          value: HomeProvider(),
        ),
        ChangeNotifierProvider.value(
          value: WorkoutProvider(),
        ),
        ChangeNotifierProvider.value(
          value: ConsumptionProvider(),
        ),
        ChangeNotifierProvider.value(
          value: ProfileProvider(),
        )
      ],
      child: ScreenUtilInit(
        builder: (context, child) => const MaterialApp(
          debugShowCheckedModeBanner: false,
          onGenerateRoute: RouteGenerator.getRoute,
          initialRoute: Routes.boardingRoute,
        ),
        designSize: const Size(430, 810),
      ),
    );
  }
}
