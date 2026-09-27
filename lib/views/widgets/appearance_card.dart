import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/theme_controller.dart';

class AppearanceCard extends StatelessWidget {
  const AppearanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Card(
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
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                  themeController.isDarkMode.value ? Icons.dark_mode : Icons.light_mode,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}