import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/station_model.dart';
import '../../utils/app_themes.dart';

class VerticalTimeline extends StatelessWidget {
  final TripResult trip;

  const VerticalTimeline({super.key, required this.trip});

  String _getCommonLine(Station s1, Station s2) {
    final common = s1.lines.where((l) => s2.lines.contains(l)).toList();
    return common.isNotEmpty ? common.first : '';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const timelineColor = AppThemes.timelineColor;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'stations_timeline'.tr,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
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
                                child: Container(width: 3, color: timelineColor.withValues(alpha: 0.6)),
                              ),
                            if (!isFirst)
                              Positioned(
                                top: 0,
                                bottom: 14,
                                child: Container(width: 3, color: timelineColor.withValues(alpha: 0.6)),
                              ),
                            Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: (isFirst || isLast) ? timelineColor : (isDark ? const Color(0xFF1E222B) : Colors.white),
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
                                        color: isDark ? Colors.white : Colors.black87,
                                        fontSize: 15,
                                        fontWeight: (isFirst || isLast) ? FontWeight.bold : FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  if (isFirst)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: isDark ? const Color(0xFF2C3240) : Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Text('Start', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                    ),
                                  if (isLast)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: isDark ? const Color(0xFF2C3240) : Colors.grey.shade200,
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