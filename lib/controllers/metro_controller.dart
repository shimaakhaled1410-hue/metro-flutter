import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:metro/utils/app_snackbar.dart';
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

  Station? get selectedStartStation => startStationName.value.isEmpty
      ? null
      : _graphService.getStationByName(startStationName.value);

  Station? get selectedEndStation => endStationName.value.isEmpty
      ? null
      : _graphService.getStationByName(endStationName.value);

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
      AppSnackbar.warning(
        title: 'warning'.tr,
        message: 'select_both_stations'.tr,
      );
      return;
    }

    if (startStationName.value == endStationName.value) {
      fastestTrip.value = null;
      comfortableTrip.value = null;
      AppSnackbar.warning(
        title: 'metro_title'.tr,
        message: 'same_station_error'.tr,
      );
      return;
    }

    final isStadiumInterchange =
        (startStationName.value == "Stadium" &&
            endStationName.value == "Stadium (Monorail)") ||
        (startStationName.value == "Stadium (Monorail)" &&
            endStationName.value == "Stadium");

    if (isStadiumInterchange) {
      fastestTrip.value = null;
      comfortableTrip.value = null;
      AppSnackbar.warning(
        title: 'notice'.tr,
        message: 'stadium_walk_notice'.tr,
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
      final minFare =
          fastestTrip.value!.ticketPrice < comfortableTrip.value!.ticketPrice
          ? fastestTrip.value!.ticketPrice
          : comfortableTrip.value!.ticketPrice;

      fastestTrip.value = fastestTrip.value!.copyWith(ticketPrice: minFare);
      comfortableTrip.value = comfortableTrip.value!.copyWith(
        ticketPrice: minFare,
      );
    }
  }

  void saveActiveTrip() {
    final trip = activeTrip;
    if (trip == null) return;

    int mCount = 0;
    int monoCount = 0;
    for (var s in trip.path) {
      if (s.lines.contains("Monorail East")) {
        monoCount++;
      } else {
        mCount++;
      }
    }

    final double calculatedMetroPrice = mCount > 0
        ? _graphService
              .calculateTicketPrice(mCount, passengerType.value)
              .toDouble()
        : 0.0;
    final double calculatedMonoPrice = monoCount > 0
        ? _graphService
              .calculateMonorailPrice(monoCount, passengerType.value)
              .toDouble()
        : 0.0;

    final historyItem = TripHistory(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      startStation: startStationName.value,
      endStation: endStationName.value,
      stationCount: trip.stationCount,
      timeInMinutes: trip.estimatedTimeMinutes,
      price: trip.ticketPrice.toDouble(),
      metroPrice: calculatedMetroPrice,
      monorailPrice: calculatedMonoPrice,
      timestamp: DateTime.now(),
      routeStations: trip.path.map((s) => s.name).toList(),
      passengerType: passengerType.value,
      destinationTag: selectedDestinationTag.value,
    );

    HistoryService.saveTrip(historyItem).then((_) {
      if (Get.isRegistered<HistoryController>()) {
        Get.find<HistoryController>().loadHistory();
      }
      AppSnackbar.success(
        title: 'metro_title'.tr,
        message: 'trip_saved_success'.tr,
      );
    });
  }

  void openStartStationMap() {
    if (selectedStartStation != null) {
      LocationService.openStationOnMap(selectedStartStation!);
    } else {
      AppSnackbar.warning(
        title: 'metro_title'.tr,
        message: 'select_dep_station'.tr,
      );
    }
  }

  Future<void> findNearestToCurrentLocation({String? filterType}) async {
    isLoadingLocation.value = true;
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        AppSnackbar.warning(
          title: 'location_notice_title'.tr,
          message: 'location_notice_desc'.tr,
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          AppSnackbar.error(
            title: 'location_permission_title'.tr,
            message: 'location_permission_denied'.tr,
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        AppSnackbar.error(
          title: 'location_permission_title'.tr,
          message: 'location_permission_denied_forever'.tr,
        );
        return;
      }

      final pos = await LocationService.getCurrentPosition();
      if (pos != null) {
        final nearest = LocationService.findNearestStation(
          pos.latitude,
          pos.longitude,
          filterType: filterType,
        );
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
      final nearest = await LocationService.findNearestStationToPlace(
        trimmedPlace,
      );
      if (nearest != null) {
        selectEndStation(nearest.name, tag: trimmedPlace);
      }
    } catch (_) {
      AppSnackbar.error(
        title: 'no_internet_search_title'.tr,
        message: 'no_internet_search_desc'.tr,
      );
    } finally {
      isSearchingPlace.value = false;
    }
  }

  void showNearestStationPicker() {
    final isAr = Get.locale?.languageCode == 'ar';

    Get.bottomSheet(
      Material(
        color: Get.theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isAr ? 'اختر نوع وسيلة النقل' : 'Select Transit Type',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isAr
                    ? 'اختر الوسيلة التي تريد البحث عن أقرب محطة لها'
                    : 'Choose the transit type to locate nearest station',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(
                  Icons.directions_subway_rounded,
                  color: Color(0xFF1976D2),
                ),
                title: Text(isAr ? 'مترو الأنفاق' : 'Metro'),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                tileColor: Colors.grey.withValues(alpha: 0.08),
                onTap: () {
                  Get.back();
                  findNearestToCurrentLocation(filterType: 'metro');
                },
              ),
              const SizedBox(height: 10),
              ListTile(
                leading: const Icon(
                  Icons.train_rounded,
                  color: Color(0xFF388E3C),
                ),
                title: Text(isAr ? 'المونوريل' : 'Monorail'),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                tileColor: Colors.grey.withValues(alpha: 0.08),
                onTap: () {
                  Get.back();
                  findNearestToCurrentLocation(filterType: 'monorail');
                },
              ),
              const SizedBox(height: 10),
              ListTile(
                leading: const Icon(
                  Icons.near_me_rounded,
                  color: Color(0xFFF57C00),
                ),
                title: Text(
                  isAr ? 'أقرب محطة عموماً (الكل)' : 'Nearest Any (All)',
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                tileColor: Colors.grey.withValues(alpha: 0.08),
                onTap: () {
                  Get.back();
                  findNearestToCurrentLocation(filterType: null);
                },
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}
