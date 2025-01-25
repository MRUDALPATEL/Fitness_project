import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitnessapp/presentation/consumption/providers/consumption_provider.dart';
import 'package:fitnessapp/utils/managers/color_manager.dart';
import 'package:fitnessapp/utils/managers/string_manager.dart';
import 'package:fitnessapp/utils/managers/style_manager.dart';
import 'package:fitnessapp/utils/managers/value_manager.dart';
import 'package:fitnessapp/utils/widgets/lime_green_rounded_button.dart';

class SetGoalPage extends StatefulWidget {
  const SetGoalPage({super.key});

  @override
  State<SetGoalPage> createState() => _SetGoalPageState();
}

class _SetGoalPageState extends State<SetGoalPage> {
  final TextEditingController _goalValueController = TextEditingController();
  String? _goalType;
  String? _duration;

  @override
  void dispose() {
    _goalValueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final consumptionProvider = Provider.of<ConsumptionProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: ColorManager.darkGrey,
      appBar: AppBar(
        backgroundColor: ColorManager.darkGrey,
        elevation: SizeManager.s0,
        title: Text(StringsManager.setGoal, style: StyleManager.abTitleTextStyle),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(PaddingManager.p28),
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _goalType,
                items: const [
                  DropdownMenuItem(value: 'Protein', child: Text('Protein')),
                  DropdownMenuItem(value: 'Vitamins', child: Text('Vitamins')),
                  // Add more goal types as needed
                ],
                onChanged: (value) {
                  setState(() {
                    _goalType = value;
                  });
                },
                decoration: const InputDecoration(
                  labelText: StringsManager.goalType,
                  labelStyle: TextStyle(color: ColorManager.white),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: ColorManager.white),
                  ),
                ),
              ),
              TextField(
                controller: _goalValueController,
                decoration: const InputDecoration(
                  labelText: StringsManager.goalValue,
                  labelStyle: TextStyle(color: ColorManager.white),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: ColorManager.white),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              DropdownButtonFormField<String>(
                value: _duration,
                items: const [
                  DropdownMenuItem(value: 'Daily', child: Text('Daily')),
                  DropdownMenuItem(value: 'Weekly', child: Text('Weekly')),
                  DropdownMenuItem(value: 'Monthly', child: Text('Monthly')),
                ],
                onChanged: (value) {
                  setState(() {
                    _duration = value;
                  });
                },
                decoration: const InputDecoration(
                  labelText: StringsManager.duration,
                  labelStyle: TextStyle(color: ColorManager.white),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: ColorManager.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              LimeGreenRoundedButtonWidget(
                onTap: () {
                  consumptionProvider.setGoal(
                    goalType: _goalType!,
                    goalValue: double.parse(_goalValueController.text),
                    duration: _duration!,
                  );
                  Navigator.of(context).pop();
                },
                title: StringsManager.setGoal,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
