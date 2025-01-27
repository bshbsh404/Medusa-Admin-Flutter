import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../../core/utils/medusa_icons_icons.dart';
import '../../../../data/service/language_service.dart';
import '../../../components/language_selection/language_selection_view.dart';
import '../controllers/app_settings_controller.dart';

class AppSettingsView extends StatelessWidget {
  const AppSettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppSettingsController>(builder: (controller) {
      final tr = AppLocalizations.of(context)!;
      return Scaffold(
        appBar: AppBar(
          title: const Text('App Settings'),
        ),
        body: SettingsList(
          lightTheme: SettingsThemeData(
              settingsListBackground: Theme.of(context).scaffoldBackgroundColor,
              settingsSectionBackground: Theme.of(context).cardColor),
          darkTheme: SettingsThemeData(
              settingsListBackground: Theme.of(context).scaffoldBackgroundColor,
              settingsSectionBackground: Theme.of(context).cardColor),
          sections: [
            SettingsSection(
              title: Text(tr.appearance),
              tiles: ThemeMode.values.map((e) {
                String title = tr.automaticAppearance;
                IconData iconData = Icons.brightness_auto;
                switch (e) {
                  case ThemeMode.system:
                    break;
                  case ThemeMode.light:
                    title = tr.lightAppearance;
                    iconData = MedusaIcons.sun;
                    break;
                  case ThemeMode.dark:
                    title = tr.darkAppearance;
                    iconData = MedusaIcons.moon;
                    break;
                }
                return SettingsTile(
                  title: Text(title),
                  leading: Icon(iconData),
                  trailing: controller.themeMode == e ? const Icon(Icons.check) : null,
                  onPressed: (_) async => await controller.changeThemeMode(e),
                );
              }).toList(),
            ),
            SettingsSection(
              // title: Text(tr.language),
              tiles: <SettingsTile>[
                SettingsTile.navigation(
                  title: Text(tr.language),
                  value: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(LanguageService.languageModel.nativeName),
                      if (LanguageService.languageModel.name != LanguageService.languageModel.nativeName)
                        const SizedBox(width: 6.0),
                      if (LanguageService.languageModel.name != LanguageService.languageModel.nativeName)
                        Text(LanguageService.languageModel.name),
                    ],
                  ),
                  leading: const Icon(Icons.language),
                  onPressed: (_) async => await showBarModalBottomSheet(
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    context: context,
                    builder: (context) => const LanguageSelectionView(),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}
