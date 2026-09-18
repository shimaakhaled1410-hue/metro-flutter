import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/metro_controller.dart';
import '../models/station_model.dart';
import '../services/metro_graph_service.dart';
import 'welcome_view.dart';
import 'widgets/station_picker_sheet.dart';

class HomeView extends StatelessWidget {
  HomeView({super.key});

  final MetroController controller = Get.put(MetroController());
  final TextEditingController placeSearchController = TextEditingController();

  void _openStationPicker(BuildContext context, {required bool isStart}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StationPickerSheet(
        title: isStart ? 'select_dep_station'.tr : 'select_dest_station'.tr,
        onSelected: (stationName) {
          if (isStart) {
            controller.selectStartStation(stationName);
          } else {
            controller.selectEndStation(stationName);
          }
          Navigator.pop(context);
        },
      ),
    );
  }

  String _getCommonLine(Station s1, Station s2) {
    final common = s1.lines.where((l) => s2.lines.contains(l)).toList();
    return common.isNotEmpty ? common.first : '';
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1B3A57);
    const timelineColor = Color(0xFF5C6BC0);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.directions_subway, color: primaryColor),
            const SizedBox(width: 8),
            Text('app_title'.tr),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    const Icon(Icons.badge_outlined, color: primaryColor, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'passenger_type'.tr,
                      style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    Obx(() {
                      String label = 'normal_passenger'.tr;
                      if (controller.passengerType.value == PassengerType.senior) {
                        label = 'senior_passenger'.tr;
                      } else if (controller.passengerType.value == PassengerType.specialNeeds) {
                        label = 'special_needs'.tr;
                      }
                      return InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () => Get.to(() => const WelcomeView()),
                        child: Chip(
                          label: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          backgroundColor: primaryColor.withOpacity(0.08),
                          side: BorderSide.none,
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.trip_origin, color: Color(0xFF43A047), size: 20),
                        const SizedBox(width: 8),
                        Text('starting_point'.tr, style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.bold)),
                        const Spacer(),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          icon: const Icon(Icons.map_outlined, color: primaryColor, size: 22),
                          onPressed: () => controller.openStartStationMap(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _openStationPicker(context, isStart: true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F4F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Obx(() {
                                final s = controller.selectedStartStation;
                                return Text(
                                  s == null ? 'tap_select_start'.tr : s.localizedName,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: s == null ? FontWeight.normal : FontWeight.bold,
                                    color: s == null ? Colors.grey.shade600 : primaryColor,
                                  ),
                                );
                              }),
                            ),
                            const Icon(Icons.arrow_drop_down, color: primaryColor),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.my_location, size: 18, color: primaryColor),
                        label: Obx(() => controller.isLoadingLocation.value
                            ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                            : Text('use_nearest_me'.tr, style: const TextStyle(color: primaryColor))),
                        onPressed: () => controller.findNearestToCurrentLocation(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Color(0xFFE53935), size: 20),
                        const SizedBox(width: 8),
                        Text('destination'.tr, style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _openStationPicker(context, isStart: false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F4F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Obx(() {
                                final s = controller.selectedEndStation;
                                return Text(
                                  s == null ? 'tap_select_end'.tr : s.localizedName,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: s == null ? FontWeight.normal : FontWeight.bold,
                                    color: s == null ? Colors.grey.shade600 : primaryColor,
                                  ),
                                );
                              }),
                            ),
                            const Icon(Icons.arrow_drop_down, color: primaryColor),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: placeSearchController,
                            style: const TextStyle(fontSize: 14),
                            decoration: InputDecoration(
                              hintText: 'going_area_hint'.tr,
                              prefixIcon: const Icon(Icons.travel_explore, size: 18),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () => controller.findNearestStationForDestination(placeSearchController.text),
                          child: Obx(() => controller.isSearchingPlace.value
                              ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : Text('find'.tr)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => controller.calculateTrip(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.alt_route_rounded, size: 20),
                  const SizedBox(width: 8),
                  Text('calculate_trip'.tr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Obx(() {
              final fastest = controller.fastestTrip.value;
              final comfortable = controller.comfortableTrip.value;

              if (fastest == null || comfortable == null) {
                return const SizedBox.shrink();
              }

              final isSameRoute = fastest.stationCount == comfortable.stationCount &&
                  fastest.transferCount == comfortable.transferCount;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    isSameRoute ? 'transit_directions'.tr : 'route_options'.tr,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: primaryColor),
                  ),
                  const SizedBox(height: 10),
                  if (isSameRoute)
                    _buildRouteOptionCard(
                      title: 'fastest_route'.tr,
                      trip: fastest,
                      isSelected: true,
                      onTap: () {},
                      primaryColor: primaryColor,
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: _buildRouteOptionCard(
                            title: 'fastest_route'.tr,
                            trip: fastest,
                            isSelected: controller.selectedRouteIndex.value == 0,
                            onTap: () => controller.selectRouteOption(0),
                            primaryColor: primaryColor,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildRouteOptionCard(
                            title: 'fewest_transfers'.tr,
                            trip: comfortable,
                            isSelected: controller.selectedRouteIndex.value == 1,
                            onTap: () => controller.selectRouteOption(1),
                            primaryColor: primaryColor,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),
                  _buildVerticalTimeline(controller.activeTrip!, primaryColor, timelineColor),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteOptionCard({
    required String title,
    required TripResult trip,
    required bool isSelected,
    required VoidCallback onTap,
    required Color primaryColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isSelected ? primaryColor : Colors.grey.shade300, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: isSelected ? Colors.white : primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${trip.stationCount} ${'stations'.tr} • ${trip.estimatedTimeMinutes} ${'est_time'.tr}',
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.white70 : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${trip.transferCount} ${'transfers_count'.tr} • ${trip.ticketPrice} ${'ticket'.tr}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerticalTimeline(TripResult trip, Color primaryColor, Color timelineColor) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'stations_timeline'.tr,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: primaryColor),
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: trip.path.length,
              itemBuilder: (context, index) {
                final station = trip.path[index];
                final isFirst = index == 0;
                final isLast = index == trip.path.length - 1;

                String? transferText;
                if (!isFirst && !isLast) {
                  final prevLine = _getCommonLine(trip.path[index - 1], station);
                  final nextLine = _getCommonLine(station, trip.path[index + 1]);
                  if (prevLine != nextLine && nextLine.isNotEmpty && prevLine.isNotEmpty) {
                    transferText = '${'transfer'.tr} $nextLine';
                  }
                }

                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        width: 30,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            if (!isLast)
                              Positioned(
                                top: 14,
                                bottom: 0,
                                child: Container(width: 3, color: timelineColor.withOpacity(0.6)),
                              ),
                            if (!isFirst)
                              Positioned(
                                top: 0,
                                bottom: 14,
                                child: Container(width: 3, color: timelineColor.withOpacity(0.6)),
                              ),
                            Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: (isFirst || isLast) ? timelineColor : Colors.white,
                                border: Border.all(color: timelineColor, width: 3),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      station.localizedName,
                                      style: TextStyle(
                                        color: primaryColor,
                                        fontSize: 15,
                                        fontWeight: (isFirst || isLast) ? FontWeight.bold : FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  if (isFirst)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Text('Start', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                    ),
                                  if (isLast)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Text('End', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                    ),
                                ],
                              ),
                              if (transferText != null) ...[
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: timelineColor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.sync_alt_rounded, color: Colors.white, size: 14),
                                      const SizedBox(width: 6),
                                      Text(
                                        transferText,
                                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}