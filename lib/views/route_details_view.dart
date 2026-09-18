import 'package:flutter/material.dart';
import '../models/station_model.dart';

class RouteDetailsView extends StatelessWidget {
  final String startStation;
  final String endStation;
  final List<Station> path;

  const RouteDetailsView({
    super.key,
    required this.startStation,
    required this.endStation,
    required this.path,
  });

  String _getCommonLine(Station s1, Station s2) {
    final common = s1.lines.where((l) => s2.lines.contains(l)).toList();
    return common.isNotEmpty ? common.first : '';
  }

  @override
  Widget build(BuildContext context) {
    const timelineColor = Color(0xFF5C6BC0);

    return Scaffold(
      backgroundColor: const Color(0xFF121418),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121418),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'All Stations',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        itemCount: path.length,
        itemBuilder: (context, index) {
          final station = path[index];
          final isFirst = index == 0;
          final isLast = index == path.length - 1;

          String? transferText;
          if (!isFirst && !isLast) {
            final prevLine = _getCommonLine(path[index - 1], station);
            final nextLine = _getCommonLine(station, path[index + 1]);
            if (prevLine != nextLine && nextLine.isNotEmpty && prevLine.isNotEmpty) {
              transferText = 'Change to $nextLine';
            }
          }

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
                            color: timelineColor,
                          ),
                        ),
                      if (!isFirst)
                        Positioned(
                          top: 0,
                          bottom: 14,
                          child: Container(
                            width: 3,
                            color: timelineColor,
                          ),
                        ),
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: (isFirst || isLast) ? timelineColor : const Color(0xFF121418),
                          border: Border.all(
                            color: timelineColor,
                            width: 3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                station.localizedName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (isFirst)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Start',
                                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ),
                            if (isLast)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'End',
                                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ),
                          ],
                        ),
                        if (transferText != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: timelineColor,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.sync_alt_rounded, color: Colors.white, size: 14),
                                const SizedBox(width: 6),
                                Text(
                                  transferText,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
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
    );
  }
}