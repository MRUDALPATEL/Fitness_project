import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  Map<String, double> _userGoals = {}; // Store multiple goals

  @override
  void dispose() {
    _goalValueController.dispose();
    super.dispose();
  }

  void _setGoal(BuildContext context) {
  if (_goalType == null || _duration == null || _goalValueController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please fill all fields before setting a goal.')),
    );
    return;
  }

  final double? goalValue = double.tryParse(_goalValueController.text);
  if (goalValue == null || goalValue <= 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please enter a valid goal value.')),
    );
    return;
  }

  final consumptionProvider = Provider.of<ConsumptionProvider>(context, listen: false);

  // Fetch existing goals from provider before updating
  Map<String, double> updatedGoals = Map.from(consumptionProvider.goals);
  updatedGoals[_goalType!] = goalValue;

  consumptionProvider.setGoal(goals: updatedGoals, duration: _duration!);

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Goal set successfully!')),
  );

  Navigator.of(context).pop();
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.darkGrey,
      appBar: AppBar(
        backgroundColor: ColorManager.darkGrey,
        elevation: SizeManager.s0,
        title: Text(StringsManager.setGoal, style: StyleManager.abTitleTextStyle),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(PaddingManager.p28),
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _goalType,
                dropdownColor: ColorManager.darkGrey,
                items: const [
                  DropdownMenuItem(value: 'Protein', child: Text('Protein')),
                  DropdownMenuItem(value: 'Carbs', child: Text('Carbs')),
                  DropdownMenuItem(value: 'Fats', child: Text('Fats')),
                  DropdownMenuItem(value: 'Fiber', child: Text('Fiber')),
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
                style: const TextStyle(color: ColorManager.white),
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
                style: const TextStyle(color: ColorManager.white),
              ),
              DropdownButtonFormField<String>(
                value: _duration,
                dropdownColor: ColorManager.darkGrey,
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
                style: const TextStyle(color: ColorManager.white),
              ),
              const SizedBox(height: 20),
              LimeGreenRoundedButtonWidget(
                onTap: () => _setGoal(context),
                title: StringsManager.setGoal,
              ),
              const SizedBox(height: 20),
              
            ],
          ),
        ),
      ),
    );
  }
}
