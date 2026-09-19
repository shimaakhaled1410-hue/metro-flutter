import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'controllers/theme_controller.dart';
import 'controllers/metro_controller.dart';
import 'utils/app_themes.dart';
import 'utils/app_translations.dart';
import 'views/welcome_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('isDarkMode') ?? false;
  final savedLanguage = prefs.getString('languageCode') ?? 'en';

  Get.put(ThemeController());
  Get.put(MetroController());

  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => CairoMetroApp(
        initialThemeMode: isDark ? ThemeMode.dark : ThemeMode.light,
        initialLocale: Locale(savedLanguage),
      ),
    ),
  );
}

class CairoMetroApp extends StatelessWidget {
  final ThemeMode initialThemeMode;
  final Locale initialLocale;

  const CairoMetroApp({
    super.key,
    required this.initialThemeMode,
    required this.initialLocale,
  });

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context) ?? initialLocale,
      builder: DevicePreview.appBuilder,
      debugShowCheckedModeBanner: false,
      title: 'Cairo Metro',
      translations: AppTranslations(),
      fallbackLocale: const Locale('en', 'US'),
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: initialThemeMode,
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 250),
      home: const WelcomeView(),
    );
  }
}