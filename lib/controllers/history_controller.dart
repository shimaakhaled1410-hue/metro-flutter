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

  Future<void> deleteItem(String id) async {
    await HistoryService.deleteTrip(id);
    historyList.removeWhere((item) => item.id == id);
  }

  Future<void> clearAll() async {
    await HistoryService.clearAll();
    historyList.clear();
  }
}