import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/metro_controller.dart';
import 'history_view.dart';

class HomeView extends StatelessWidget {
  HomeView({super.key});

  final MetroController controller = Get.put(MetroController());
  final TextEditingController placeSearchController = TextEditingController();

  void _showStationPicker(BuildContext context, {required bool isStart}) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                isStart ? 'Select Start Station' : 'Select End Station',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: controller.allStations.length,
                  itemBuilder: (context, index) {
                    final station = controller.allStations[index];
                    return ListTile(
                      title: Text(station.name),
                      subtitle: Text(station.lines.join(' | ')),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        if (isStart) {
                          controller.selectStartStation(station.name);
                        } else {
                          controller.selectEndStation(station.name);
                        }
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cairo Metro Navigator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Trip History',
            onPressed: () => Get.to(() => const HistoryView()),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Start Station Selection Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.trip_origin, color: Colors.green),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Obx(() => Text(
                                controller.startStationName.value.isEmpty
                                    ? 'Select Start Station'
                                    : controller.startStationName.value,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              )),
                        ),
                        ElevatedButton(
                          onPressed: () => _showStationPicker(context, isStart: true),
                          child: const Text('Choose'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.my_location),
                            label: Obx(() => controller.isLoadingLocation.value
                                ? const SizedBox(
                                    height: 16,
                                    width: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text('Nearest to Me')),
                            onPressed: () => controller.findNearestToCurrentLocation(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filledTonal(
                          icon: const Icon(Icons.map_outlined),
                          tooltip: 'Open Station on Google Maps',
                          onPressed: () => controller.openStartStationMap(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Destination Station Selection Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Obx(() => Text(
                                controller.endStationName.value.isEmpty
                                    ? 'Select End Station'
                                    : controller.endStationName.value,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              )),
                        ),
                        ElevatedButton(
                          onPressed: () => _showStationPicker(context, isStart: false),
                          child: const Text('Choose'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Place search field for Feature 4
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: placeSearchController,
                            decoration: const InputDecoration(
                              isDense: true,
                              hintText: 'e.g. Abbas El Akkad, Cairo Univ...',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.search),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            controller.findNearestStationForDestination(
                              placeSearchController.text,
                            );
                          },
                          child: Obx(() => controller.isSearchingPlace.value
                              ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Find')),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Calculate Button
            FilledButton.icon(
              icon: const Icon(Icons.alt_route),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Calculate Route', style: TextStyle(fontSize: 16)),
              ),
              onPressed: () => controller.calculateTrip(),
            ),
            const SizedBox(height: 16),

            // Results Section
            Obx(() {
              if (!controller.hasCalculated.value) {
                return const SizedBox.shrink();
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Trip Summary Card
                  Card(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              const Icon(Icons.train),
                              const SizedBox(height: 4),
                              Text(
                                '${controller.stationCount.value} Stations',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              const Icon(Icons.timer),
                              const SizedBox(height: 4),
                              Text(
                                '${controller.tripTime.value} Min',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              const Icon(Icons.confirmation_number),
                              const SizedBox(height: 4),
                              Text(
                                '${controller.ticketPrice.value} EGP',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Route Instructions
                  if (controller.instructions.isNotEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Directions:',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            ...controller.instructions.map((inst) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 2),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.arrow_right, size: 20),
                                      const SizedBox(width: 4),
                                      Expanded(child: Text(inst)),
                                    ],
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),

                  // Scrollable Route Stations List
                  const Text(
                    'Full Route:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 250,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListView.builder(
                      itemCount: controller.routeStations.length,
                      itemBuilder: (context, index) {
                        final station = controller.routeStations[index];
                        final isFirst = index == 0;
                        final isLast = index == controller.routeStations.length - 1;

                        return ListTile(
                          dense: true,
                          leading: CircleAvatar(
                            radius: 12,
                            backgroundColor: isFirst
                                ? Colors.green
                                : (isLast ? Colors.red : Colors.blueGrey),
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(fontSize: 11, color: Colors.white),
                            ),
                          ),
                          title: Text(
                            station.name,
                            style: TextStyle(
                              fontWeight: isFirst || isLast ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          subtitle: Text(
                            station.lines.join(', '),
                            style: const TextStyle(fontSize: 11),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}