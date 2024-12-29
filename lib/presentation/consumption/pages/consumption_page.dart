import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:provider/provider.dart';
import 'package:Fitness/presentation/consumption/providers/consumption_provider.dart';
import 'package:Fitness/presentation/consumption/widgets/meal_widget.dart';
import 'package:Fitness/utils/managers/color_manager.dart';
import 'package:Fitness/utils/managers/value_manager.dart';
import 'package:Fitness/utils/router/router.dart';

class ConsumptionPage extends StatefulWidget {
  const ConsumptionPage({super.key});

  @override
  State<ConsumptionPage> createState() => _ConsumptionPageState();
}

class _ConsumptionPageState extends State<ConsumptionPage> {
  @override
  void initState() {
    super.initState();
    Provider.of<ConsumptionProvider>(context, listen: false).fetchAndSetMeals();
  }

  Future<void> _handleRefresh() async {
    await Provider.of<ConsumptionProvider>(context, listen: false).fetchAndSetMeals();
    return Future.delayed(const Duration(seconds: 2));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ConsumptionProvider>(
      builder: (context, consumptionProvider, _) => SafeArea(
        child: LiquidPullToRefresh(
          height: 80.h, // Adjusted height
          color: ColorManager.darkGrey,
          animSpeedFactor: 2,
          backgroundColor: ColorManager.white2,
          onRefresh: _handleRefresh,
          child: Stack(
            children: [
              Column(
                children: [
                  // Goal Progress Section
                  Padding(
                    padding: const EdgeInsets.all(PaddingManager.p16),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(SizeManager.s12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(PaddingManager.p16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Goal Progress",
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w600,
                                color: ColorManager.darkGrey,
                              ),
                            ),
                            const SizedBox(height: SizeManager.s12),
                            LinearProgressIndicator(
                              value: consumptionProvider.kCalaDay /
                                  (consumptionProvider.goalValue > 0
                                      ? consumptionProvider.goalValue
                                      : 2000),
                              backgroundColor: ColorManager.grey,
                              color: ColorManager.limeGreen,
                              minHeight: 8.h,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Meals List Section
                  Expanded(
                    child: ListView.builder(
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
                          onPressed: (_) => consumptionProvider.deleteMeal(meal.id),
                        );
                      },
                    ),
                  ),
                ],
              ),
              // Floating Action Buttons
              Padding(
                padding: const EdgeInsets.all(PaddingManager.p12),
                child: Align(
                  alignment: Alignment.bottomRight,
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
                        onPressed: () => Navigator.of(context).pushNamed(Routes.addWaterRoute),
                      ),
                      const SizedBox(height: 10),
                      FloatingActionButton(
                        backgroundColor: ColorManager.limerGreen2,
                        child: const Icon(
                          Icons.flag,
                          color: ColorManager.darkGrey,
                          size: SizeManager.s28,
                        ),
                        onPressed: () => Navigator.of(context).pushNamed(Routes.setGoalRoute),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
