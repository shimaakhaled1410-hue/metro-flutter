import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'utils/app_themes.dart';
import 'utils/app_translations.dart';
import 'views/welcome_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => const CairoMetroApp(),
    ),
  );
}

class CairoMetroApp extends StatelessWidget {
  const CairoMetroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Cairo Metro',
      translations: AppTranslations(),
      locale: const Locale('ar', 'EG'),
      fallbackLocale: const Locale('en', 'US'),
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: ThemeMode.system,
      useInheritedMediaQuery: true,
      builder: DevicePreview.appBuilder,
      debugShowCheckedModeBanner: false,
      home: const WelcomeView(),
    );
  }
}