import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/metro_controller.dart';
import '../services/metro_graph_service.dart';
import 'main_navigation_view.dart';

class WelcomeView extends StatelessWidget {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final MetroController controller = Get.put(MetroController());
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.directions_subway_rounded,
                    size: 40,
                    color: primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'welcome_title'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'welcome_subtitle'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: Obx(
                  () => ListView(
                    children: [
                      _buildCategoryTile(
                        context: context,
                        type: PassengerType.normal,
                        title: 'normal_passenger'.tr,
                        subtitle: 'normal_desc'.tr,
                        icon: Icons.person_outline_rounded,
                        isSelected: controller.passengerType.value == PassengerType.normal,
                        onTap: () => controller.setPassengerType(PassengerType.normal),
                        primaryColor: primaryColor,
                      ),
                      const SizedBox(height: 12),
                      _buildCategoryTile(
                        context: context,
                        type: PassengerType.senior,
                        title: 'senior_passenger'.tr,
                        subtitle: 'senior_desc'.tr,
                        icon: Icons.elderly_rounded,
                        isSelected: controller.passengerType.value == PassengerType.senior,
                        onTap: () => controller.setPassengerType(PassengerType.senior),
                        primaryColor: primaryColor,
                      ),
                      const SizedBox(height: 12),
                      _buildCategoryTile(
                        context: context,
                        type: PassengerType.specialNeeds,
                        title: 'special_needs'.tr,
                        subtitle: 'special_desc'.tr,
                        icon: Icons.accessible_forward_rounded,
                        isSelected: controller.passengerType.value == PassengerType.specialNeeds,
                        onTap: () => controller.setPassengerType(PassengerType.specialNeeds),
                        primaryColor: primaryColor,
                      ),
                    ],
                  ),
                ),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.black87 : Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () => Get.off(() => const MainNavigationView()),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'get_started'.tr,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded, size: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTile({
    required BuildContext context,
    required PassengerType type,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required Color primaryColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withValues(alpha: isDark ? 0.15 : 0.06)
              : (isDark ? const Color(0xFF1E222B) : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? primaryColor : (isDark ? const Color(0xFF2C3240) : Colors.grey.shade200),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: isSelected ? primaryColor : (isDark ? const Color(0xFF2A303C) : Colors.grey.shade100),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? (isDark ? Colors.black87 : Colors.white)
                    : (isDark ? Colors.grey.shade400 : Colors.grey.shade700),
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? primaryColor : (isDark ? Colors.white : Colors.black87),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
              color: isSelected ? primaryColor : Colors.grey.shade500,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}