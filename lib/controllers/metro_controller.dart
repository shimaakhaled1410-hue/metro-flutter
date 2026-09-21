import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/metro_data.dart';
import '../models/station_model.dart';
import '../models/trip_history_model.dart';
import '../services/history_service.dart';
import '../services/location_service.dart';
import '../services/metro_graph_service.dart';
import 'history_controller.dart';

class MetroController extends GetxController {
  final MetroGraphService _graphService = MetroGraphService();

  var startStationName = ''.obs;
  var endStationName = ''.obs;
  var passengerType = PassengerType.normal.obs;

  var fastestTrip = Rxn<TripResult>();
  var comfortableTrip = Rxn<TripResult>();
  var selectedRouteIndex = 0.obs;

  var isLoadingLocation = false.obs;
  var isSearchingPlace = false.obs;

  var searchPlaceText = ''.obs;
  final RxnString selectedDestinationTag = RxnString();

  List<Station> get allStations => MetroData.allStations;

  Station? get selectedStartStation =>
      startStationName.value.isEmpty ? null : _graphService.getStationByName(startStationName.value);

  Station? get selectedEndStation =>
      endStationName.value.isEmpty ? null : _graphService.getStationByName(endStationName.value);

  TripResult? get activeTrip =>
      selectedRouteIndex.value == 0 ? fastestTrip.value : comfortableTrip.value;

  void selectStartStation(String name) {
    startStationName.value = name;
  }

  void selectEndStation(String name, {String? tag}) {
    endStationName.value = name;
    selectedDestinationTag.value = tag;
  }

  void swapStations() {
    if (startStationName.value.isEmpty && endStationName.value.isEmpty) return;
    final temp = startStationName.value;
    startStationName.value = endStationName.value;
    endStationName.value = temp;
    selectedDestinationTag.value = null;

    if (startStationName.value.isNotEmpty && endStationName.value.isNotEmpty) {
      calculateTrip();
    }
  }

  void setPassengerType(PassengerType type) {
    passengerType.value = type;
    if (startStationName.value.isNotEmpty && endStationName.value.isNotEmpty) {
      calculateTrip();
    }
  }

  void selectRouteOption(int index) {
    selectedRouteIndex.value = index;
  }

  void calculateTrip() {
    if (startStationName.value.isEmpty || endStationName.value.isEmpty) {
      Get.snackbar(
        'Warning',
        'Please select both start and destination stations',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (startStationName.value == endStationName.value) {
      fastestTrip.value = null;
      comfortableTrip.value = null;
      Get.snackbar(
        'app_title'.tr,
        'same_station_error'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade800,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      );
      return;
    }

    selectedRouteIndex.value = 0;

    fastestTrip.value = _graphService.calculateTrip(
      startStationName.value,
      endStationName.value,
      passengerType.value,
      preferFewerTransfers: false,
    );

    comfortableTrip.value = _graphService.calculateTrip(
      startStationName.value,
      endStationName.value,
      passengerType.value,
      preferFewerTransfers: true,
    );

    if (fastestTrip.value != null && comfortableTrip.value != null) {
      final minFare = fastestTrip.value!.ticketPrice < comfortableTrip.value!.ticketPrice
          ? fastestTrip.value!.ticketPrice
          : comfortableTrip.value!.ticketPrice;

      fastestTrip.value = fastestTrip.value!.copyWith(ticketPrice: minFare);
      comfortableTrip.value = comfortableTrip.value!.copyWith(ticketPrice: minFare);
    }
  }

  void saveActiveTrip() {
    final trip = activeTrip;
    if (trip == null) return;

    final historyItem = TripHistory(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      startStation: startStationName.value,
      endStation: endStationName.value,
      stationCount: trip.stationCount,
      timeInMinutes: trip.estimatedTimeMinutes,
      price: trip.ticketPrice.toDouble(),
      timestamp: DateTime.now(),
      routeStations: trip.path.map((s) => s.name).toList(),
      passengerType: passengerType.value,
      destinationTag: selectedDestinationTag.value,
    );

    HistoryService.saveTrip(historyItem).then((_) {
      if (Get.isRegistered<HistoryController>()) {
        Get.find<HistoryController>().loadHistory();
      }
      Get.snackbar(
        'app_title'.tr,
        'trip_saved_success'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF1B3A57),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      );
    });
  }

  void openStartStationMap() {
    if (selectedStartStation != null) {
      LocationService.openStationOnMap(selectedStartStation!);
    } else {
      Get.snackbar(
        'app_title'.tr,
        'select_dep_station'.tr,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
  }

  Future<void> findNearestToCurrentLocation() async {
    isLoadingLocation.value = true;
    try {
      final pos = await LocationService.getCurrentPosition();
      if (pos != null) {
        final nearest = LocationService.findNearestStation(pos.latitude, pos.longitude);
        startStationName.value = nearest.name;
      }
    } finally {
      isLoadingLocation.value = false;
    }
  }

  Future<void> findNearestStationForDestination(String place) async {
    final trimmedPlace = place.trim();
    if (trimmedPlace.isEmpty) return;
    isSearchingPlace.value = true;
    try {
      final nearest = await LocationService.findNearestStationToPlace(trimmedPlace);
      if (nearest != null) {
        selectEndStation(nearest.name, tag: trimmedPlace);
      }
    } catch (_) {
      Get.snackbar(
        'no_internet_search_title'.tr,
        'no_internet_search_desc'.tr,
        snackPosition: SnackPosition.BOTTOM,
        icon: const Icon(Icons.wifi_off_rounded, color: Colors.white),
        backgroundColor: const Color(0xFFD32F2F),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      );
    } finally {
      isSearchingPlace.value = false;
    }
  }
}