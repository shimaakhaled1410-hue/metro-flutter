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

  void selectEndStation(String name) {
    endStationName.value = name;
  }

  void setPassengerType(PassengerType type) {
    passengerType.value = type;
    if (startStationName.value.isNotEmpty && endStationName.value.isNotEmpty) {
      calculateTrip();
    }
  }

  void selectRouteOption(int index) {
    selectedRouteIndex.value = index;
    final trip = activeTrip;
    if (trip != null) {
      _persistTrip(trip);
    }
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

    final tripToSave = activeTrip;
    if (tripToSave != null) {
      _persistTrip(tripToSave);
    }
  }

 void _persistTrip(TripResult result) {
    final trip = TripHistory(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      startStation: startStationName.value,
      endStation: endStationName.value,
      stationCount: result.stationCount,
      timeInMinutes: result.estimatedTimeMinutes,
      price: result.ticketPrice,
      timestamp: DateTime.now(),
      routeStations: result.path.map((s) => s.name).toList(),
    );

    HistoryService.saveTrip(trip).then((_) {
      if (Get.isRegistered<HistoryController>()) {
        Get.find<HistoryController>().loadHistory();
      }
    });
  }

  void openStartStationMap() {
    if (selectedStartStation != null) {
      LocationService.openStationOnMap(selectedStartStation!);
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
    if (place.trim().isEmpty) return;
    isSearchingPlace.value = true;
    try {
      final nearest = await LocationService.findNearestStationToPlace(place);
      if (nearest != null) {
        endStationName.value = nearest.name;
      }
    } finally {
      isSearchingPlace.value = false;
    }
  }
}