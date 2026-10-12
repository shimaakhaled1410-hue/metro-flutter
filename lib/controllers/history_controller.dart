import 'package:get/get.dart';
import '../models/trip_history_model.dart';
import '../services/history_service.dart';
import '../utils/app_snackbar.dart';

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
    historyList.removeAt(index);
    await HistoryService.deleteTrip(item.id);

    AppSnackbar.showWithUndo(
      title: 'route_deleted_title'.tr,
      message: 'route_deleted_desc'.tr,
      onUndo: () async {
        final restoreIndex = index.clamp(0, historyList.length);
        historyList.insert(restoreIndex, item);
        await HistoryService.saveAllTrips(historyList);
      },
    );
  }

  Future<void> clearAllWithUndo() async {
    if (historyList.isEmpty) return;

    final backupList = List<TripHistory>.from(historyList);
    historyList.clear();
    await HistoryService.clearAll();

    AppSnackbar.showWithUndo(
      title: 'history_cleared_title'.tr,
      message: 'history_cleared_desc'.tr,
      onUndo: () async {
        historyList.assignAll(backupList);
        await HistoryService.saveAllTrips(backupList);
      },
    );
  }
}