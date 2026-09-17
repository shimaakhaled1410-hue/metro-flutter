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

  var routeStations = <Station>[].obs;
  var instructions = <String>[].obs;
  var stationCount = 0.obs;
  var tripTime = 0.obs;
  var ticketPrice = 0.obs;
  var hasCalculated = false.obs;

  var isLoadingLocation = false.obs;
  var isSearchingPlace = false.obs;

  List<Station> get allStations => MetroData.allStations;

  Station? get selectedStartStation =>
      startStationName.value.isEmpty ? null : _graphService.getStationByName(startStationName.value);

  Station? get selectedEndStation =>
      endStationName.value.isEmpty ? null : _graphService.getStationByName(endStationName.value);

  void selectStartStation(String name) {
    startStationName.value = name;
  }

  void selectEndStation(String name) {
    endStationName.value = name;
  }

  void calculateTrip() {
    if (startStationName.value.isEmpty || endStationName.value.isEmpty) {
      Get.snackbar(
        'Warning',
        'Please select both start and end stations first',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withValues(alpha:0.9),
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
      );
      return;
    }

    final result = _graphService.calculateTrip(
      startStationName.value,
      endStationName.value,
    );

    if (result != null) {
      routeStations.assignAll(result.path);
      instructions.assignAll(result.instructions);
      stationCount.value = result.stationCount;
      tripTime.value = result.estimatedTimeMinutes;
      ticketPrice.value = result.ticketPrice;
      hasCalculated.value = true;

      if (result.stationCount > 0) {
        final trip = TripHistory(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          startStation: startStationName.value,
          endStation: endStationName.value,
          stationCount: result.stationCount,
          timeInMinutes: result.estimatedTimeMinutes,
          price: result.ticketPrice,
          timestamp: DateTime.now(),
        );

        HistoryService.saveTrip(trip).then((_) {
          if (Get.isRegistered<HistoryController>()) {
            Get.find<HistoryController>().loadHistory();
          }
        });
      }
    }
  }

  void openStartStationMap() {
    if (selectedStartStation == null) {
      Get.snackbar('Error', 'Select a start station first to open its location');
      return;
    }
    LocationService.openStationOnMap(selectedStartStation!);
  }

  Future<void> findNearestToCurrentLocation() async {
    isLoadingLocation.value = true;
    try {
      final position = await LocationService.getCurrentPosition();
      if (position != null) {
        final nearest = LocationService.findNearestStation(
          position.latitude,
          position.longitude,
        );
        startStationName.value = nearest.name;
        Get.snackbar(
          'Nearest Station',
          'Nearest station to your location: ${nearest.name}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withValues(alpha:0.9),
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
        );
      } else {
        Get.snackbar(
          'Location Error',
          'Could not retrieve current location. Check GPS and permissions.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      isLoadingLocation.value = false;
    }
  }

  Future<void> findNearestStationForDestination(String placeName) async {
    if (placeName.trim().isEmpty) return;

    isSearchingPlace.value = true;
    try {
      final nearest = await LocationService.findNearestStationToPlace(placeName);
      if (nearest != null) {
        endStationName.value = nearest.name;
        Get.snackbar(
          'Destination Station',
          'Nearest station to "$placeName" is: ${nearest.name}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withValues(alpha:0.9),
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
        );
      } else {
        Get.snackbar(
          'Place Not Found',
          'Could not find coordinates for the specified place.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      isSearchingPlace.value = false;
    }
  }
}