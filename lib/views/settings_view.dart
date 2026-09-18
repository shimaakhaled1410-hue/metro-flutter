import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/theme_controller.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.put(ThemeController());
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text('settings_title'.tr),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.palette_outlined, color: primaryColor),
                      const SizedBox(width: 10),
                      Text(
                        'Appearance',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Obx(
                    () => SwitchListTile(
                      title: const Text('Dark Mode'),
                      value: themeController.isDarkMode.value,
                      onChanged: (_) => themeController.toggleTheme(),
                      secondary: Icon(
                        themeController.isDarkMode.value ? Icons.dark_mode : Icons.light_mode,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.language_rounded, color: primaryColor),
                      const SizedBox(width: 10),
                      Text(
                        'language_title'.tr,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  RadioListTile<String>(
                    title: Text('arabic'.tr),
                    value: 'ar',
                    groupValue: Get.locale?.languageCode ?? 'ar',
                    onChanged: (val) => Get.updateLocale(const Locale('ar', 'EG')),
                  ),
                  RadioListTile<String>(
                    title: Text('english'.tr),
                    value: 'en',
                    groupValue: Get.locale?.languageCode ?? 'ar',
                    onChanged: (val) => Get.updateLocale(const Locale('en', 'US')),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}