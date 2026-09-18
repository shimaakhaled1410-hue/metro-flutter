import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1B3A57);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: Text('settings_title'.tr),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.language_rounded, color: primaryColor),
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
                    onChanged: (val) {
                      Get.updateLocale(const Locale('ar', 'EG'));
                    },
                  ),
                  RadioListTile<String>(
                    title: Text('english'.tr),
                    value: 'en',
                    groupValue: Get.locale?.languageCode ?? 'ar',
                    onChanged: (val) {
                      Get.updateLocale(const Locale('en', 'US'));
                    },
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