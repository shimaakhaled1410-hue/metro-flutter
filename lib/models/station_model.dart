import 'package:get/get.dart';

class Station {
  final String name;
  final String nameAr;
  final double latitude;
  final double longitude;
  final List<String> lines;

  const Station({
    required this.name,
    required this.nameAr,
    required this.latitude,
    required this.longitude,
    required this.lines,
  });

  String get localizedName {
    return Get.locale?.languageCode == 'ar' ? nameAr : name;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Station &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;
}

class TripResult {
  final List<Station> path;
  final int stationCount;
  final int estimatedTimeMinutes;
  final int ticketPrice;
  final List<String> instructions;
  final int transferCount;

  TripResult({
    required this.path,
    required this.stationCount,
    required this.estimatedTimeMinutes,
    required this.ticketPrice,
    required this.instructions,
    required this.transferCount,
  });

  TripResult copyWith({
    List<Station>? path,
    int? stationCount,
    int? estimatedTimeMinutes,
    int? ticketPrice,
    List<String>? instructions,
    int? transferCount,
  }) {
    return TripResult(
      path: path ?? this.path,
      stationCount: stationCount ?? this.stationCount,
      estimatedTimeMinutes: estimatedTimeMinutes ?? this.estimatedTimeMinutes,
      ticketPrice: ticketPrice ?? this.ticketPrice,
      instructions: instructions ?? this.instructions,
      transferCount: transferCount ?? this.transferCount,
    );
  }
}