import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/metro_data.dart';
import '../../models/station_model.dart';
import '../../utils/app_themes.dart';

class VerticalTimeline extends StatelessWidget {
  final TripResult trip;

  const VerticalTimeline({super.key, required this.trip});

  String _getCommonLine(Station s1, Station s2) {
    final common = s1.lines.where((l) => s2.lines.contains(l)).toList();
    return common.isNotEmpty ? common.first : '';
  }

  String _getTrainDirection(String line, Station current, Station next) {
    List<String> lineList;
    if (line == 'Line 1') {
      lineList = MetroData.line1Names;
    } else if (line == 'Line 2') {
      lineList = MetroData.line2Names;
    } else {
      if (MetroData.line3BranchA.contains(next.name)) {
        return MetroData.allStations
            .firstWhere((s) => s.name == MetroData.line3BranchA.last)
            .localizedName;
      } else if (MetroData.line3BranchB.contains(next.name)) {
        return MetroData.allStations
            .firstWhere((s) => s.name == MetroData.line3BranchB.last)
            .localizedName;
      }
      lineList = MetroData.line3Common;
    }

    final currIdx = lineList.indexOf(current.name);
    final nextIdx = lineList.indexOf(next.name);

    if (currIdx != -1 && nextIdx != -1) {
      final targetName = nextIdx > currIdx ? lineList.last : lineList.first;
      try {
        return MetroData.allStations
            .firstWhere((s) => s.name == targetName)
            .localizedName;
      } catch (_) {
        return targetName;
      }
    }
    return '';
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

                String? transferLine;
                if (!isFirst && !isLast) {
                  final prevLine = _getCommonLine(
                    trip.path[index - 1],
                    station,
                  );
                  final nextLine = _getCommonLine(
                    station,
                    trip.path[index + 1],
                  );
                  if (prevLine != nextLine &&
                      nextLine.isNotEmpty &&
                      prevLine.isNotEmpty) {
                    transferLine = nextLine;
                  }
                }

                String? directionInfo;
                if (isFirst && trip.path.length > 1) {
                  final line = _getCommonLine(station, trip.path[1]);
                  final dir = _getTrainDirection(line, station, trip.path[1]);
                  if (dir.isNotEmpty) {
                    directionInfo = '${'take_line_towards'.tr} $dir';
                  }
                } else if (transferLine != null &&
                    index + 1 < trip.path.length) {
                  final dir = _getTrainDirection(
                    transferLine,
                    station,
                    trip.path[index + 1],
                  );
                  if (dir.isNotEmpty) {
                    directionInfo = '${'take_line_towards'.tr} $dir';
                  }
                }

                final isInterchange = transferLine != null;

                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        width: 32,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            if (!isLast)
                              Positioned(
                                top: 14,
                                bottom: 0,
                                child: Container(
                                  width: 3,
                                  color: timelineColor.withValues(alpha: 0.6),
                                ),
                              ),
                            if (!isFirst)
                              Positioned(
                                top: 0,
                                bottom: 14,
                                child: Container(
                                  width: 3,
                                  color: timelineColor.withValues(alpha: 0.6),
                                ),
                              ),
                            Container(
                              width: isInterchange ? 18 : 14,
                              height: isInterchange ? 18 : 14,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isInterchange
                                    ? Colors.amber.shade700
                                    : ((isFirst || isLast)
                                          ? timelineColor
                                          : (isDark
                                                ? const Color(0xFF1E222B)
                                                : Colors.white)),
                                border: Border.all(
                                  color: isInterchange
                                      ? Colors.amber.shade300
                                      : timelineColor,
                                  width: isInterchange ? 2 : 3,
                                ),
                              ),
                              child: isInterchange
                                  ? const Icon(
                                      Icons.sync_alt,
                                      size: 10,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      station.localizedName,
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black87,
                                        fontSize: 15,
                                        fontWeight:
                                            (isFirst || isLast || isInterchange)
                                            ? FontWeight.bold
                                            : FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  if (isFirst)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? const Color(0xFF2C3240)
                                            : Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'Start'.tr,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  if (isLast)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? const Color(0xFF2C3240)
                                            : Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'End'.tr,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              if (transferLine != null) ...[
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 4,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: timelineColor,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.transfer_within_a_station,
                                            color: Colors.white,
                                            size: 13,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${'transfer'.tr} $transferLine',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? Colors.orange.shade900.withValues(
                                                alpha: 0.35,
                                              )
                                            : Colors.orange.shade100,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.directions_walk,
                                            size: 13,
                                            color: isDark
                                                ? Colors.orange.shade200
                                                : Colors.orange.shade900,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'interchange_walk'.tr,
                                            style: TextStyle(
                                              color: isDark
                                                  ? Colors.orange.shade200
                                                  : Colors.orange.shade900,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              if (directionInfo != null) ...[
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.navigation_outlined,
                                      size: 14,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        directionInfo,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                  ],
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
