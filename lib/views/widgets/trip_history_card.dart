import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/trip_history_model.dart';
import '../../services/metro_graph_service.dart';
import '../../data/metro_data.dart';

class TripHistoryCard extends StatelessWidget {
  final TripHistory item;
  final int index;
  final VoidCallback onDelete;

  const TripHistoryCard({
    super.key,
    required this.item,
    required this.index,
    required this.onDelete,
  });

  String _getStationName(String name) {
    try {
      final station = MetroData.allStations.firstWhere((s) => s.name == name);
      return station.localizedName;
    } catch (_) {
      return name;
    }
  }

  Widget _buildPassengerBadge(BuildContext context, PassengerType type) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    String label;
    Color badgeColor;

    switch (type) {
      case PassengerType.senior:
        label = 'senior_passenger'.tr;
        badgeColor = Colors.orange;
        break;
      case PassengerType.specialNeeds:
        label = 'special_needs'.tr;
        badgeColor = Colors.teal;
        break;
      case PassengerType.normal:
        label = 'normal_passenger'.tr;
        badgeColor = Colors.blue;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: badgeColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final start = _getStationName(item.startStation);
    final dest = item.destinationTag != null && item.destinationTag!.isNotEmpty
        ? '${item.destinationTag} (${_getStationName(item.endStation)})'
        : _getStationName(item.endStation);

    final routeList = item.routeStations.isNotEmpty
        ? item.routeStations.map((s) => _getStationName(s)).toList()
        : [start, dest];

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.route, color: Color(0xFF1976D2)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '$start ➔ $dest',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                _buildPassengerBadge(context, item.passengerType),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: onDelete,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Builder(
              builder: (context) {
                String priceText = '${item.price.toInt()} ${'egp'.tr}';
                if (item.monorailPrice > 0 && item.metroPrice > 0) {
                  final isAr = Get.locale?.languageCode == 'ar';
                  final detail = isAr
                      ? ' (${item.monorailPrice.toInt()} مونوريل + ${item.metroPrice.toInt()} مترو)'
                      : ' (${item.monorailPrice.toInt()} Mono + ${item.metroPrice.toInt()} Metro)';
                  priceText += detail;
                }
                return Text(
                  '${item.stationCount} ${'stations'.tr} • ${item.timeInMinutes} ${'est_time'.tr} • $priceText',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                );
              },
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: routeList.length,
                separatorBuilder: (_, _) => const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    Icons.arrow_forward,
                    size: 14,
                    color: Colors.grey,
                  ),
                ),
                itemBuilder: (context, rIndex) {
                  return Chip(
                    label: Text(
                      routeList[rIndex],
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: isDark
                        ? const Color(0xFF2C2C2C)
                        : Colors.grey.shade100,
                    side: BorderSide.none,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
