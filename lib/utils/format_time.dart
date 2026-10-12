import 'package:get/get.dart';

String formatTripDuration(int totalMinutes) {
  final isAr = Get.locale?.languageCode == 'ar';
  if (totalMinutes < 60) {
    return isAr ? '$totalMinutes دقيقة' : '$totalMinutes mins';
  }

  final hours = totalMinutes ~/ 60;
  final minutes = totalMinutes % 60;

  if (isAr) {
    if (minutes == 0) {
      if (hours == 1) return 'ساعة واحدة';
      if (hours == 2) return 'ساعتان';
      return '$hours ساعات';
    }
    String hoursText;
    if (hours == 1) {
      hoursText = 'ساعة';
    } else if (hours == 2) {
      hoursText = 'ساعتان';
    } else {
      hoursText = '$hours ساعات';
    }
    return '$hoursText و $minutes دقيقة';
  } else {
    if (minutes == 0) return '${hours}h';
    return '${hours}h ${minutes}m';
  }
}
