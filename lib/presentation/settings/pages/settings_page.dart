import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:Fitness/presentation/settings/widgets/button_settings.dart';
import 'package:Fitness/utils/managers/string_manager.dart';
import 'package:Fitness/utils/managers/style_manager.dart';
import 'package:Fitness/utils/managers/value_manager.dart';
import 'package:Fitness/utils/router/router.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(
                  left: PaddingManager.p12,
                  bottom: PaddingManager.p12,
                  top: PaddingManager.p12,
                ),
                child: Text(
                  StringsManager.accountSpacer,
                  style: StyleManager.settingsPageSpacerTextStyle,
                ),
              ),
            ),
            SettingsPageButton(
              deviceWidth: deviceWidth,
              onTap: () =>
                  Navigator.of(context).pushNamed(Routes.changeEmailRoute),
              iconData: Icons.email_outlined,
              title: StringsManager.changeEmail,
            ),
            SettingsPageButton(
              deviceWidth: deviceWidth,
              onTap: () =>
                  Navigator.of(context).pushNamed(Routes.changePasswordRoute),
              iconData: Icons.lock_open_sharp,
              title: StringsManager.changePassword,
            ),
            SettingsPageButton(
              deviceWidth: deviceWidth,
              onTap: () =>
                  Navigator.of(context).pushNamed(Routes.deleteAccRoute),
              iconData: Icons.delete_outlined,
              title: StringsManager.deleteAcc,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(
                  left: PaddingManager.p12,
                  bottom: PaddingManager.p12,
                  top: PaddingManager.p12,
                ),
                child: Text(
                  StringsManager.generalSpacer,
                  style: StyleManager.settingsPageSpacerTextStyle,
                ),
              ),
            ),
            SettingsPageButton(
              deviceWidth: deviceWidth,
              onTap: () {
                //TODO:
              },
              iconData: Icons.nightlight_outlined,
              title: StringsManager.theme,
            ),
            SettingsPageButton(
              deviceWidth: deviceWidth,
              onTap: () {
                //TODO:
              },
              iconData: Icons.help_outline,
              title: StringsManager.support,
            ),
            SettingsPageButton(
              deviceWidth: deviceWidth,
              onTap: () {
                //TODO:
              },
              iconData: Icons.library_books_outlined,
              title: StringsManager.termsOfService,
            ),
            SettingsPageButton(
              deviceWidth: deviceWidth,
              onTap: () {
                //TODO:
              },
              iconData: Icons.person_add_alt_1_outlined,
              title: StringsManager.inviteFriend,
            ),
          ],
        ).animate().fadeIn(
              duration: 500.ms,
            ),
      ),
    );
  }
}
