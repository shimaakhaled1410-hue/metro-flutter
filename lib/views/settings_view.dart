import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/theme_controller.dart';
import 'widgets/appearance_card.dart';
import 'widgets/language_card.dart';
import 'widgets/legal_card.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ThemeController());

    return Scaffold(
      appBar: AppBar(title: Text('settings_title'.tr)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          AppearanceCard(),
          SizedBox(height: 12),
          LanguageCard(),
          SizedBox(height: 12),
          LegalCard(),
        ],
      ),
    );
  }
}