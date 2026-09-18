import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/station_model.dart';

class RouteOptionCard extends StatelessWidget {
  final String title;
  final TripResult trip;
  final bool isSelected;
  final VoidCallback onTap;

  const RouteOptionCard({
    super.key,
    required this.title,
    required this.trip,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    Color bg;
    if (isSelected) {
      bg = isDark ? const Color(0xFF2A364F) : const Color(0xFF1B3A57);
    } else {
      bg = isDark ? const Color(0xFF1E222B) : Colors.white;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? primary : (isDark ? const Color(0xFF2C3240) : Colors.grey.shade300),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: isSelected ? Colors.white : primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${trip.stationCount} ${'stations'.tr} • ${trip.estimatedTimeMinutes} ${'est_time'.tr}',
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.white70 : (isDark ? Colors.grey.shade400 : Colors.black87),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${trip.transferCount} ${'transfers_count'.tr} • ${trip.ticketPrice} ${'ticket'.tr}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: isSelected ? Colors.white : (isDark ? Colors.white : Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}