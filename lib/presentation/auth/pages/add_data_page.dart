import 'package:fitnessapp/utils/managers/color_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../utils/managers/string_manager.dart';
import '../../../utils/managers/style_manager.dart';
import '../../../utils/managers/value_manager.dart';
import '../../../utils/router/router.dart';
import '../../../utils/widgets/lime_green_rounded_button.dart';
import '../../home/providers/home_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/add_data_widgets.dart';

class AddDataPage extends StatefulWidget {
  const AddDataPage({super.key});

  @override
  State<AddDataPage> createState() => _AddDataPageState();
}

class _AddDataPageState extends State<AddDataPage> {
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  String? _valueGender;
  String? _valueActivity;
  String? _valueGoal;
  void _onChangedGender(Object? selectedGenderValue) {
    if (selectedGenderValue is String) {
      setState(() {
        _valueGender = selectedGenderValue;
      });
    }
  }

  void _onChangedActivity(Object? selectedActivityValue) {
    if (selectedActivityValue is String) {
      setState(() {
        _valueActivity = selectedActivityValue;
      });
    }
  }

  void _onChangedGoal(Object? selectedGoalValue) {
    if (selectedGoalValue is String) {
      setState(() {
        _valueGoal = selectedGoalValue;
      });
    }
  }

  @override
  void dispose() {
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _nameController.dispose();
    _surnameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final email = Provider.of<AuthProvider>(context).user!.email;
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    Future addUserData() async {
      try {
        await homeProvider
            .getUsersBMR(
              gender: _valueGender!,
              weight: double.parse(_weightController.text),
              height: double.parse(_heightController.text),
              age: int.parse(_ageController.text),
              activity: _valueActivity!,
              goal: _valueGoal!,
            )
            .then((_) => homeProvider.getUsersBMI(
                  height: double.parse(_heightController.text),
                  weight: double.parse(_weightController.text),
                ))
            .then(
              (_) => authProvider.addUserData(
                email: email!,
                name: _nameController.text,
                surname: _surnameController.text,
                age: int.parse(_ageController.text),
                context: context,
                gender: _valueGender!,
                height: double.parse(_heightController.text),
                weight: double.parse(_weightController.text),
                activity: _valueActivity!,
                bmr: homeProvider.userBMRwithGoal,
                goal: _valueGoal!,
                bmi: homeProvider.usersBMI,
              ),
            );
      } catch (e) {
        rethrow;
      }
    }

    return Scaffold(
      backgroundColor: ColorManager.darkGrey,
      appBar: AppBar(
        backgroundColor: ColorManager.darkGrey,
        elevation: SizeManager.s0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: PaddingManager.p28),
                child: Center(
                  child: Text(
                    StringsManager.enterData,
                    textAlign: TextAlign.center,
                    style: StyleManager.addDataTitleTextStyle,
                  ),
                ),
              ),
              AddDataWidgets(
                ageController: _ageController,
                heightController: _heightController,
                weightController: _weightController,
                onChangedGender: _onChangedGender,
                valueGender: _valueGender,
                valueActivity: _valueActivity,
                onChangedActivity: _onChangedActivity,
                nameController: _nameController,
                surnameController: _surnameController,
                valueGoal: _valueGoal,
                onChangedGoal: _onChangedGoal,
              ),
              LimeGreenRoundedButtonWidget(
                onTap: () {
                  addUserData().then(
                    (value) => Navigator.of(context)
                        .pushReplacementNamed(Routes.mainRoute),
                  );
                },
                title: StringsManager.procede,
              )
            ],
          ),
        ),
      ),
    );
  }
}
