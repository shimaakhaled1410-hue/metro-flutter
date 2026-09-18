import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/metro_controller.dart';
import 'widgets/passenger_badge_card.dart';
import 'widgets/route_option_card.dart';
import 'widgets/station_picker_sheet.dart';
import 'widgets/vertical_timeline.dart';

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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.directions_subway, color: primaryColor),
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
            PassengerBadgeCard(controller: controller),
            const SizedBox(height: 12),
            Card(
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
                          icon: Icon(Icons.map_outlined, color: primaryColor, size: 22),
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
                          color: isDark ? const Color(0xFF252A36) : const Color(0xFFF1F4F9),
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
                                    color: s == null ? Colors.grey.shade500 : (isDark ? Colors.white : Colors.black87),
                                  ),
                                );
                              }),
                            ),
                            Icon(Icons.arrow_drop_down, color: primaryColor),
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
                        icon: Icon(Icons.my_location, size: 18, color: primaryColor),
                        label: Obx(() => controller.isLoadingLocation.value
                            ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                            : Text('use_nearest_me'.tr, style: TextStyle(color: primaryColor))),
                        onPressed: () => controller.findNearestToCurrentLocation(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
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
                          color: isDark ? const Color(0xFF252A36) : const Color(0xFFF1F4F9),
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
                                    color: s == null ? Colors.grey.shade500 : (isDark ? Colors.white : Colors.black87),
                                  ),
                                );
                              }),
                            ),
                            Icon(Icons.arrow_drop_down, color: primaryColor),
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
                              filled: true,
                              fillColor: isDark ? const Color(0xFF252A36) : const Color(0xFFF1F4F9),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              hintText: 'going_area_hint'.tr,
                              prefixIcon: const Icon(Icons.travel_explore, size: 18),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark ? const Color(0xFF2A364F) : primaryColor,
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
                backgroundColor: isDark ? const Color(0xFF2A364F) : primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => controller.calculateTrip(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.alt_route_rounded, size: 20),
                  const SizedBox(width: 8),
                  Text('calculate_trip'.tr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
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
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: primaryColor),
                  ),
                  const SizedBox(height: 10),
                  if (isSameRoute)
                    RouteOptionCard(
                      title: 'fastest_route'.tr,
                      trip: fastest,
                      isSelected: true,
                      onTap: () {},
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: RouteOptionCard(
                            title: 'fastest_route'.tr,
                            trip: fastest,
                            isSelected: controller.selectedRouteIndex.value == 0,
                            onTap: () => controller.selectRouteOption(0),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: RouteOptionCard(
                            title: 'fewest_transfers'.tr,
                            trip: comfortable,
                            isSelected: controller.selectedRouteIndex.value == 1,
                            onTap: () => controller.selectRouteOption(1),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),
                  VerticalTimeline(trip: controller.activeTrip!),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}