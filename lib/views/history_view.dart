import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/history_controller.dart';
import 'widgets/trip_history_card.dart';

class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

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
                controller.clearAllWithUndo();
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
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.historyList.length,
          itemBuilder: (context, index) {
            final item = controller.historyList[index];
            return TripHistoryCard(
              item: item,
              index: index,
              onDelete: () => controller.deleteItemWithUndo(item, index),
            );
          },
        );
      }),
    );
  }
}
