import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:medusa_admin/app/data/service/language_service.dart';
import 'package:medusa_admin/app/modules/components/adaptive_button.dart';
import 'package:medusa_admin/app/modules/components/adaptive_icon.dart';
import 'package:medusa_admin/app/modules/components/error_widget.dart';
import 'package:medusa_admin/app/routes/app_pages.dart';
import 'package:medusa_admin/core/utils/medusa_icons_icons.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import '../../../components/language_selection/language_selection_view.dart';
import '../components/sign_in_components.dart';
import '../controllers/sign_in_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SignInView extends GetView<SignInController> {
  const SignInView({Key? key}) : super(key: key);

  @override
  Widget build(context) {
    final tr = AppLocalizations.of(context)!;
    final bool isRTL = Directionality.of(context) == TextDirection.rtl;
    const space = SizedBox(height: 12.0);
    // Since there no app bar, annotated region is used to apply theme ui overlay
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: Theme.of(context).appBarTheme.systemOverlayStyle!,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Obx(
                        () {
                          return Align(
                            alignment: isRTL ? Alignment.topRight : Alignment.topLeft,
                            child: Hero(
                              tag: 'closeReset',
                              child: AdaptiveIcon(
                                iosPadding: const EdgeInsets.all(16.0),
                                androidPadding: const EdgeInsets.all(16.0),
                                onPressed: () async => await controller.changeThemeMode(),
                                icon: Icon(themeIcon(controller.themeMode.value)),
                              ),
                            ),
                          );
                        },
                      ),
                      Align(
                        alignment: isRTL ? Alignment.topLeft : Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: AdaptiveButton(
                            onPressed: () async => await showBarModalBottomSheet(
                              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                              context: context,
                              builder: (context) => const LanguageSelectionView(),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.language),
                                const SizedBox(width: 4.0),
                                Text(LanguageService.languageModel.nativeName),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Obx(() {
                    return GestureDetector(
                      onTap: () {
                        controller.animate.value = !controller.animate.value;
                      },
                      child: Hero(
                        tag: 'medusa',
                        child: Image.asset(
                          'assets/images/medusa.png',
                          scale: 5,
                        ).animate(
                          effects: [const RotateEffect()],
                          target: controller.animate.value ? 1 : 0,
                          autoPlay: false,
                        ),
                      ),
                    );
                  }),
                  Column(
                    children: [
                      Text(
                        tr.welcome,
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                      Text(
                        tr.greatToSeeYou,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        tr.loginBelow,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  space,
                  GestureDetector(
                    onTap: () => controller.errorMessage.value = '',
                    child: errorMessage(
                      errorMessage: controller.errorMessage,
                      context: context,
                      emptyChildHeight: 0,
                      horizontalPadding: 12.0,
                    ),
                  ),
                  space,
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Column(
                      children: [
                        Hero(tag: 'email', child: EmailTextField(controller: controller.emailCtrl)),
                        const SizedBox(height: 12.0),
                        Hero(
                          tag: 'password',
                          child: PasswordTextField(controller: controller.passwordCtrl),
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: isRTL ? Alignment.centerLeft : Alignment.centerRight,
                    child: Padding(
                      padding: Platform.isAndroid ? const EdgeInsets.symmetric(horizontal: 12.0) : EdgeInsets.zero,
                      child: AdaptiveButton(
                        child: Text(
                          tr.resetPassword,
                        ),
                        onPressed: () {
                          if (controller.errorMessage.value.isNotEmpty) {
                            controller.errorMessage.value = '';
                          }
                          Get.toNamed(Routes.RESET_PASSWORD);
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Hero(
                      tag: 'continue',
                      child: SignInButton(
                        onPressed: () async => await controller.signIn(context),
                        label: tr.cont,
                        buttonWidth: double.maxFinite,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData themeIcon(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.system:
        return Icons.brightness_auto;
      case ThemeMode.light:
        return MedusaIcons.sun;
      case ThemeMode.dark:
        return MedusaIcons.moon;
    }
  }
}
