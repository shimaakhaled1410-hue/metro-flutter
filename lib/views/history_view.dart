import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:metro/services/metro_graph_service.dart';
import '../controllers/history_controller.dart';
import '../data/metro_data.dart';

class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

  String _getStationName(String name) {
    try {
      final station = MetroData.allStations.firstWhere((s) => s.name == name);
      return station.localizedName;
    } catch (_) {
      return name;
    }
  }

  Widget _buildPassengerBadge(BuildContext context, PassengerType type) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    String label;
    Color badgeColor;

    switch (type) {
      case PassengerType.senior:
        label = 'senior_passenger'.tr;
        badgeColor = Colors.orange;
        break;
      case PassengerType.specialNeeds:
        label = 'special_needs'.tr;
        badgeColor = Colors.teal;
        break;
      case PassengerType.normal:
        label = 'normal_passenger'.tr;
        badgeColor = Colors.blue;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: badgeColor.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: badgeColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HistoryController());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('trip_history'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'clear_history'.tr,
            onPressed: () {
              if (controller.historyList.isNotEmpty) {
                Get.defaultDialog(
                  title: 'clear_history'.tr,
                  middleText: 'clear_history_confirm'.tr,
                  textConfirm: 'delete'.tr,
                  textCancel: 'cancel'.tr,
                  confirmTextColor: Colors.white,
                  buttonColor: Colors.red,
                  onConfirm: () {
                    controller.clearAll();
                    Get.back();
                  },
                );
              }
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.historyList.isEmpty) {
          return Center(
            child: Text(
              'no_trips'.tr,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.historyList.length,
          itemBuilder: (context, index) {
            final item = controller.historyList[index];
            final start = _getStationName(item.startStation);
            final dest = _getStationName(item.endStation);
            final routeList = item.routeStations.isNotEmpty
                ? item.routeStations.map((e) => _getStationName(e)).toList()
                : [start, dest];

            return Card(
              margin: const EdgeInsets.only(bottom: 14),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.route,
                          color: Color(0xFFE53935),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '$start → $dest',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        _buildPassengerBadge(context, item.passengerType),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => controller.deleteItem(item.id),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${item.stationCount} ${'stations'.tr} • ${item.timeInMinutes} ${'est_time'.tr} • ${item.price} ${'ticket'.tr}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 44,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: routeList.length,
                        separatorBuilder: (_, _) => const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(Icons.arrow_forward, size: 16, color: Colors.grey),
                        ),
                        itemBuilder: (context, rIdx) {
                          return Chip(
                            label: Text(
                              routeList[rIdx],
                              style: const TextStyle(fontSize: 12),
                            ),
                            backgroundColor: isDark ? const Color(0xFF252A36) : const Color(0xFFF1F4F9),
                            side: BorderSide.none,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}