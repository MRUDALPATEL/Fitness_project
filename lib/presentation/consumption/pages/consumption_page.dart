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
    // Fetch meals on page load
    Provider.of<ConsumptionProvider>(context, listen: false).fetchAndSetMeals();
  }

  Future<void> _handleRefresh() async {
    await Provider.of<ConsumptionProvider>(context, listen: false)
        .fetchAndSetMeals();
    return Future.delayed(const Duration(seconds: 2));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LiquidPullToRefresh(
          height: 80.h,
          color: ColorManager.darkGrey,
          animSpeedFactor: 2,
          backgroundColor: ColorManager.black,
          onRefresh: _handleRefresh,
          child: Container(
            color: ColorManager.darkGrey, // Set background color to black
            child: Stack(
              children: [
                // Main content: Shows loading, error, or meal list
                Consumer<ConsumptionProvider>(
                  builder: (context, consumptionProvider, _) {
                    if (consumptionProvider.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    // Error state
                    if (consumptionProvider.hasError) {
                      return Center(
                        child: Text(
                          'An error occurred: ${consumptionProvider.errorMessage}',
                          style: TextStyle(fontSize: 16.sp, color: Colors.red),
                        ),
                      );
                    }

                    // Empty state
                    if (consumptionProvider.meals.isEmpty) {
                      return Center(
                        child: Text(
                          "No meals found. Add your meals now!",
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: ColorManager.limeGreen,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    // Show meal list when data is available
                    return ListView.builder(
                      itemCount: consumptionProvider.meals.length,
                      itemBuilder: (context, index) {
                        final meal = consumptionProvider.meals[index];
                        return MealWidget(
                          id: meal.id,
                          title: meal.title,
                          amount: meal.amount,
                          calories: meal.calories,
                          fats: meal.fats,
                          carbs: meal.carbs,
                          proteins: meal.proteins,
                          onPressed: (_) =>
                              consumptionProvider.deleteMeal(meal.id),
                        );
                      },
                    );
                  },
                ),
                // Floating Action Button (always visible)
                Positioned(
                  bottom: 16.h,
                  right: 16.w,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FloatingActionButton(
                        backgroundColor: ColorManager.limerGreen2,
                        child: const Icon(
                          Icons.water_drop_outlined,
                          color: ColorManager.darkGrey,
                          size: SizeManager.s28,
                        ),
                        onPressed: () {
                          print("Water log button pressed");
                          Navigator.of(context).pushNamed(Routes.addWaterRoute);
                        },
                      ),
                      const SizedBox(height: 10),
                      FloatingActionButton(
                        backgroundColor: ColorManager.limerGreen2,
                        child: const Icon(
                          Icons.flag,
                          color: ColorManager.darkGrey,
                          size: SizeManager.s28,
                        ),
                        onPressed: () {
                          print("Set goal button pressed");
                          Navigator.of(context).pushNamed(Routes.setGoalRoute);
                        },
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
