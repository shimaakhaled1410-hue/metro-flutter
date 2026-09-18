import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/metro_controller.dart';
import 'history_view.dart';
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
        title: isStart
            ? 'Select Departure Station'
            : 'Select Destination Station',
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
    const primaryColor = Color(0xFF1B3A57);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.directions_subway, color: primaryColor),
            SizedBox(width: 8),
            Text('Cairo Metro'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.language_rounded),
            tooltip: 'Change Language',
            onPressed: () {
              if (Get.locale?.languageCode == 'ar') {
                Get.updateLocale(const Locale('en', 'US'));
              } else {
                Get.updateLocale(const Locale('ar', 'EG'));
              }
            },
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: 'Trip History',
            onPressed: () => Get.to(() => const HistoryView()),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Start Station Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.trip_origin,
                          color: Color(0xFF43A047),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Starting Point',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          icon: const Icon(
                            Icons.map_outlined,
                            color: primaryColor,
                            size: 22,
                          ),
                          tooltip: 'Open on Maps',
                          onPressed: () => controller.openStartStationMap(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => _openStationPicker(context, isStart: true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F4F9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Obx(() {
                                final station = controller.selectedStartStation;
                                return Text(
                                  station == null
                                      ? 'tap_select_start'.tr
                                      : station.localizedName,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: station == null
                                        ? FontWeight.normal
                                        : FontWeight.bold,
                                    color: station == null
                                        ? Colors.grey.shade600
                                        : primaryColor,
                                  ),
                                );
                              }),
                            ),
                            const Icon(
                              Icons.arrow_drop_down,
                              color: primaryColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(
                          Icons.my_location,
                          size: 18,
                          color: primaryColor,
                        ),
                        label: Obx(
                          () => controller.isLoadingLocation.value
                              ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Use Nearest Station to Me',
                                  style: TextStyle(color: primaryColor),
                                ),
                        ),
                        onPressed: () =>
                            controller.findNearestToCurrentLocation(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Destination Station Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Color(0xFFE53935),
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Destination',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => _openStationPicker(context, isStart: false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F4F9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Obx(() {
                                final station = controller.selectedEndStation;
                                return Text(
                                  station == null
                                      ? 'tap_select_end'.tr
                                      : station.localizedName,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: station == null
                                        ? FontWeight.normal
                                        : FontWeight.bold,
                                    color: station == null
                                        ? Colors.grey.shade600
                                        : primaryColor,
                                  ),
                                );
                              }),
                            ),
                            const Icon(
                              Icons.arrow_drop_down,
                              color: primaryColor,
                            ),
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
                            decoration: const InputDecoration(
                              hintText:
                                  'Going to an area? (e.g. Abbas El Akkad)',
                              prefixIcon: Icon(Icons.travel_explore, size: 18),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            controller.findNearestStationForDestination(
                              placeSearchController.text,
                            );
                          },
                          child: Obx(
                            () => controller.isSearchingPlace.value
                                ? const SizedBox(
                                    height: 16,
                                    width: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Find'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Calculate Button
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => controller.calculateTrip(),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.alt_route_rounded, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Calculate Trip',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Results View
            Obx(() {
              if (!controller.hasCalculated.value) {
                return const SizedBox.shrink();
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Overview stats
                  Card(
                    color: const Color(0xFF1B3A57),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16.0,
                        horizontal: 8.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(
                            'Stations',
                            '${controller.stationCount.value}',
                            Icons.train_outlined,
                          ),
                          _buildStatItem(
                            'Est. Time',
                            '${controller.tripTime.value} min',
                            Icons.timer_outlined,
                          ),
                          _buildStatItem(
                            'Ticket',
                            '${controller.ticketPrice.value} EGP',
                            Icons.confirmation_number_outlined,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Directions steps
                  if (controller.instructions.isNotEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Transit Directions',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: primaryColor,
                              ),
                            ),
                            const Divider(height: 16),
                            ...controller.instructions.map(
                              (inst) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 18,
                                      color: primaryColor,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        inst,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          height: 1.3,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),

                  // Route station list (Scrollable)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    child: Text(
                      'Stations Timeline',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: primaryColor,
                      ),
                    ),
                  ),
                  Container(
                    height: 280,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: controller.routeStations.length,
                      itemBuilder: (context, index) {
                        final station = controller.routeStations[index];
                        final isFirst = index == 0;
                        final isLast =
                            index == controller.routeStations.length - 1;

                        Color indicatorColor = Colors.blueGrey.shade300;
                        if (isFirst) indicatorColor = const Color(0xFF43A047);
                        if (isLast) indicatorColor = const Color(0xFFE53935);

                        return ListTile(
                          dense: true,
                          leading: CircleAvatar(
                            radius: 13,
                            backgroundColor: indicatorColor,
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            station.localizedName,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isFirst || isLast
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: isFirst || isLast
                                  ? primaryColor
                                  : Colors.black87,
                            ),
                          ),
                          subtitle: Text(
                            station.lines.join(' | '),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 22),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 11),
        ),
      ],
    );
  }
}
