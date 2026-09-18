import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/metro_controller.dart';
import '../../services/metro_graph_service.dart';
import '../welcome_view.dart';

class PassengerBadgeCard extends StatelessWidget {
  final MetroController controller;

  const PassengerBadgeCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Icon(Icons.badge_outlined, color: Theme.of(context).colorScheme.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              'passenger_type'.tr,
              style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Obx(() {
              String label = 'normal_passenger'.tr;
              if (controller.passengerType.value == PassengerType.senior) {
                label = 'senior_passenger'.tr;
              } else if (controller.passengerType.value == PassengerType.specialNeeds) {
                label = 'special_needs'.tr;
              }
              return InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => Get.to(() => const WelcomeView()),
                child: Chip(
                  label: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  backgroundColor: isDark ? const Color(0xFF2C3240) : const Color(0xFFE9EEF5),
                  side: BorderSide.none,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}