import 'package:fitnessapp/presentation/consumption/widgets/goal_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:provider/provider.dart';
import 'package:fitnessapp/presentation/consumption/providers/consumption_provider.dart';
import 'package:fitnessapp/presentation/consumption/widgets/meal_widget.dart';
import 'package:fitnessapp/utils/managers/color_manager.dart';
import 'package:fitnessapp/utils/managers/value_manager.dart';
import 'package:fitnessapp/utils/router/router.dart';

class ConsumptionPage extends StatefulWidget {
  const ConsumptionPage({super.key});

  @override
  State<ConsumptionPage> createState() => _ConsumptionPageState();
}

class _ConsumptionPageState extends State<ConsumptionPage> {
  @override
  void initState() {
    super.initState();
    final provider = Provider.of<ConsumptionProvider>(context, listen: false);
    provider.fetchAndSetMeals();
    provider.fetchGoal();
  }
Future<void> _handleRefresh() async {
  final provider = Provider.of<ConsumptionProvider>(context, listen: false);
  
  try {
    await provider.fetchAndSetMeals();
    await provider.fetchGoal();
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to refresh: $e')),
      );
    }
  }
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
              Consumer<ConsumptionProvider>(
                builder: (context, consumptionProvider, _) {
                  if (consumptionProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (consumptionProvider.hasError) {
                    return Center(
                      child: Text(
                        'An error occurred: ${consumptionProvider.errorMessage}',
                        style: TextStyle(fontSize: 16.sp, color: Colors.red),
                      ),
                    );
                  }

                  return ListView(
                    padding: EdgeInsets.all(16.w),
                    children: [
                      // ✅ Add the GoalProgressBar at the top
                      const GoalProgressBar(),
                      const SizedBox(height: 20),

                      if (consumptionProvider.meals.isEmpty)
                        Center(
                          child: Text(
                            "No meals found. Add your meals now!",
                            style: TextStyle(fontSize: 16.sp, color: ColorManager.limeGreen),
                            textAlign: TextAlign.center,
                          ),
                        )
                      else
                        ...consumptionProvider.meals.map((meal) => MealWidget(
                              id: meal.id,
                              title: meal.title,
                              amount: meal.amount,
                              calories: meal.calories,
                              fats: meal.fats,
                              carbs: meal.carbs,
                              proteins: meal.proteins,
                              onPressed: (_) => consumptionProvider.deleteMeal(meal.id),
                            )),
                    ],
                  );
                },
              ),
              
              // Floating Buttons
              Positioned(
                bottom: 16.h,
                right: 16.w,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FloatingActionButton(
                      backgroundColor: ColorManager.limerGreen2,
                      child: const Icon(Icons.water_drop_outlined, color: ColorManager.darkGrey, size: SizeManager.s28),
                      onPressed: () => Navigator.of(context).pushNamed(Routes.addWaterRoute),
                    ),
                    const SizedBox(height: 10),
                    FloatingActionButton(
                      backgroundColor: ColorManager.limerGreen2,
                      child: const Icon(Icons.flag, color: ColorManager.darkGrey, size: SizeManager.s28),
                      onPressed: () => Navigator.of(context).pushNamed(Routes.setGoalRoute),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

}
