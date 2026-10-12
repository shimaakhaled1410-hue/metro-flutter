import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/trip_history_model.dart';
import '../services/history_service.dart';

class HistoryController extends GetxController {
  var historyList = <TripHistory>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadHistory();
  }

  Future<void> loadHistory() async {
    isLoading.value = true;
    try {
      final items = await HistoryService.getHistory();
      historyList.assignAll(items);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteItemWithUndo(TripHistory item, int index) async {
    // 1. Remove locally
    historyList.removeAt(index);
    await HistoryService.deleteTrip(item.id);

    final isAr = Get.locale?.languageCode == 'ar';

    // 2. Show Snackbar with Undo
    Get.closeCurrentSnackbar();
    Get.snackbar(
      isAr ? 'تم حذف المسار' : 'Route Deleted',
      isAr ? 'تم مسح المسار من السجل' : 'Route removed from history',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(16),
      mainButton: TextButton(
        onPressed: () async {
          Get.closeCurrentSnackbar();
          // Undo: re-insert at previous position
          final restoreIndex = index.clamp(0, historyList.length);
          historyList.insert(restoreIndex, item);
          await HistoryService.saveAllTrips(historyList);
        },
        child: Text(
          isAr ? 'تراجع' : 'Undo',
          style: const TextStyle(
            color: Colors.amber,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Future<void> clearAllWithUndo() async {
    if (historyList.isEmpty) return;

    final backupList = List<TripHistory>.from(historyList);
    historyList.clear();
    await HistoryService.clearAll();

    final isAr = Get.locale?.languageCode == 'ar';

    Get.closeCurrentSnackbar();
    Get.snackbar(
      isAr ? 'تم مسح السجل' : 'History Cleared',
      isAr ? 'تم مسح جميع المسارات بنجاح' : 'All routes have been cleared',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(16),
      mainButton: TextButton(
        onPressed: () async {
          Get.closeCurrentSnackbar();
          // Undo: restore all
          historyList.assignAll(backupList);
          await HistoryService.saveAllTrips(backupList);
        },
        child: Text(
          isAr ? 'تراجع' : 'Undo',
          style: const TextStyle(
            color: Colors.amber,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
