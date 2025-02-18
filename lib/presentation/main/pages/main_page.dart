import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:fitnessapp/presentation/consumption/providers/consumption_provider.dart';
import 'package:fitnessapp/presentation/main/widgets/appbar_consumption.dart';
import 'package:fitnessapp/presentation/main/widgets/appbar_profile.dart';
import 'package:fitnessapp/presentation/main/widgets/appbar_workouts.dart';
import 'package:fitnessapp/presentation/main/widgets/appbar_settings.dart';
import 'package:fitnessapp/presentation/consumption/pages/consumption_page.dart';
import 'package:fitnessapp/presentation/home/pages/home_page.dart';
import 'package:fitnessapp/presentation/main/widgets/appbar_home.dart';
import 'package:fitnessapp/presentation/profile/pages/profile_page.dart';
import 'package:fitnessapp/presentation/workouts/pages/workouts_page.dart';
import 'package:fitnessapp/presentation/settings/pages/settings_page.dart';
import 'package:fitnessapp/presentation/workouts/providers/workout_provider.dart';
import 'package:fitnessapp/utils/managers/color_manager.dart';
import 'package:fitnessapp/utils/managers/value_manager.dart';
import 'package:fitnessapp/utils/notifications/notification_manager.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final NotificationManager _notificationManager = NotificationManager();
  var _currentIndex = 0;
  ontap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
  
  
   
  List<Widget> pages = const [
    HomePage(),
    ConsumptionPage(),
    WorkoutPage(),
    SettingsPage(),
    ProfilePage(),
  ];

  appBar() {
    if (isHomePage) {
      return const HomePageAppBarWidget();
    } else if (isConsumptionPage) {
      return const ConsumptionPageAppBarWidget();
    } else if (isWorkoutsPage) {
      return const WorkoutsPageAppBarWidget();
    } else if (isSettingsPage) {
      return const SettingsPageAppBarWidget();
    } else if (isProfilePage) {
      return const ProfilePageAppBarWidget();
    }
  }

  bool get isProfilePage => _currentIndex == 4;
  bool get isSettingsPage => _currentIndex == 3;
  bool get isWorkoutsPage => _currentIndex == 2;
  bool get isConsumptionPage => _currentIndex == 1;
  bool get isHomePage => _currentIndex == 0;

  @override
  void initState() {
    super.initState();
    _notificationManager.init();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final consumptionProvider =
          Provider.of<ConsumptionProvider>(context, listen: false);
      final workoutsProvider =
          Provider.of<WorkoutProvider>(context, listen: false);
      await consumptionProvider.fetchAndSetMeals();
      await consumptionProvider.fetchAndSetWater();
      await workoutsProvider.fetchAndSetWorkouts();
      await workoutsProvider.getProgressPercent();
      final workouts = workoutsProvider.workouts;
      final meals = consumptionProvider.meals;
      final water = consumptionProvider.water;
      if (meals.isNotEmpty) {
        final lastMealDateTime = meals.last.dateTime;
        final now = DateTime.now();
        if (now.year > lastMealDateTime.year ||
            now.month > lastMealDateTime.month ||
            now.day > lastMealDateTime.day) {
          await consumptionProvider.clearMealsIfDayChanges(lastMealDateTime);
          await consumptionProvider.fetchAndSetMeals();
        }
      }
      if (water.isNotEmpty) {
        final lastWaterDateTime = water.last.dateTime;
        final now = DateTime.now();
        if (now.year > lastWaterDateTime.year ||
            now.month > lastWaterDateTime.month ||
            now.day > lastWaterDateTime.day) {
          await consumptionProvider.clearWaterIfDayChanges(lastWaterDateTime);
          await consumptionProvider.fetchAndSetWater();
        }
      }
      if (workouts.isNotEmpty) {
        final lastWorkoutDateTime = workouts.last.dateTime;
        final now = DateTime.now();
        if (now.year > lastWorkoutDateTime.year ||
            now.month > lastWorkoutDateTime.month ||
            now.day > lastWorkoutDateTime.day) {
          await workoutsProvider.clearWorkoutsIfDayChanges(lastWorkoutDateTime);
          await workoutsProvider.fetchAndSetWorkouts();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> bottomNavItems = [
      Icon(
        Icons.other_houses_outlined,
        color: isHomePage ? ColorManager.limerGreen2 : ColorManager.grey2,
        size: SizeManager.s28,
      ),
      Icon(
        Icons.fastfood_outlined,
        color:
            isConsumptionPage ? ColorManager.limerGreen2 : ColorManager.grey2,
        size: SizeManager.s28,
      ),
      Icon(
        Icons.fitness_center,
        color: isWorkoutsPage ? ColorManager.limerGreen2 : ColorManager.grey2,
        size: SizeManager.s28,
      ),
      Icon(
        Icons.settings_outlined,
        color: isSettingsPage ? ColorManager.limerGreen2 : ColorManager.grey2,
        size: SizeManager.s28,
      ),
      Icon(
        Icons.person_4_outlined,
        color: isProfilePage ? ColorManager.limerGreen2 : ColorManager.grey2,
        size: SizeManager.s28,
      ),
    ];
    return Scaffold(
      backgroundColor: ColorManager.darkGrey,
      appBar: PreferredSize(
        preferredSize: Size(
          double.infinity,
          isProfilePage ? SizeManager.s0 : SizeManager.s60.h,
        ),
        child: appBar(),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        color: ColorManager.black87,
        buttonBackgroundColor: Colors.transparent,
        backgroundColor: ColorManager.darkGrey,
        onTap: ontap,
        index: _currentIndex,
        items: bottomNavItems,
      ),
      body: pages[_currentIndex].animate().fadeIn(duration: 500.ms),
    );
  }
}
