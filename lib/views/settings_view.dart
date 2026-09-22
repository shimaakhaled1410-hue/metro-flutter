import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/theme_controller.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  Future<void> _changeLanguage(String langCode, String countryCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', langCode);
    Get.updateLocale(Locale(langCode, countryCode));
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Get.put(ThemeController());
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: Text('settings_title'.tr)),
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
                        'appearance'.tr,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Obx(
                    () => SwitchListTile(
                      title: Text('dark_mode'.tr),
                      value: themeController.isDarkMode.value,
                      onChanged: (_) => themeController.toggleTheme(),
                      secondary: Icon(
                        themeController.isDarkMode.value
                            ? Icons.dark_mode
                            : Icons.light_mode,
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
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  ListTile(
                    title: Text('arabic'.tr),
                    trailing: Icon(
                      Get.locale?.languageCode == 'ar'
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: Get.locale?.languageCode == 'ar'
                          ? primaryColor
                          : Colors.grey,
                    ),
                    onTap: () => _changeLanguage('ar', 'EG'),
                  ),
                  ListTile(
                    title: Text('english'.tr),
                    trailing: Icon(
                      Get.locale?.languageCode == 'en'
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: Get.locale?.languageCode == 'en'
                          ? primaryColor
                          : Colors.grey,
                    ),
                    onTap: () => _changeLanguage('en', 'US'),
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
