import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HistoryController());

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
          )
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
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: controller.historyList.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final item = controller.historyList[index];
            final startName = _getStationName(item.startStation);
            final endName = _getStationName(item.endStation);

            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.15),
                  child: Icon(Icons.train, color: Theme.of(context).primaryColor),
                ),
                title: Text(
                  '$startName → $endName',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${'stations'.tr}: ${item.stationCount} | ${'est_time'.tr}: ${item.timeInMinutes} ${'min'.tr} | ${'ticket'.tr}: ${item.price} ${'egp'.tr}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => controller.deleteItem(item.id),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}