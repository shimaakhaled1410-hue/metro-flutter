import 'package:metro/services/metro_graph_service.dart';

class TripHistory {
  final String id;
  final String startStation;
  final String endStation;
  final int stationCount;
  final int timeInMinutes;
  final double price;
  final DateTime timestamp;
  final List<String> routeStations;
  final PassengerType passengerType;

  TripHistory({
    required this.id,
    required this.startStation,
    required this.endStation,
    required this.stationCount,
    required this.timeInMinutes,
    required this.price,
    required this.timestamp,
    required this.routeStations,
    this.passengerType = PassengerType.normal,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'startStation': startStation,
        'endStation': endStation,
        'stationCount': stationCount,
        'timeInMinutes': timeInMinutes,
        'price': price,
        'timestamp': timestamp.toIso8601String(),
        'routeStations': routeStations,
        'passengerType': passengerType.name,
      };

  factory TripHistory.fromJson(Map<String, dynamic> json) {
    PassengerType resolvedType = PassengerType.normal;
    final savedType = json['passengerType'] as String?;
    if (savedType != null) {
      resolvedType = PassengerType.values.firstWhere(
        (e) => e.name == savedType,
        orElse: () => PassengerType.normal,
      );
    }

    return TripHistory(
      id: json['id'] as String,
      startStation: json['startStation'] as String,
      endStation: json['endStation'] as String,
      stationCount: json['stationCount'] as int,
      timeInMinutes: json['timeInMinutes'] as int,
      price: (json['price'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      routeStations: List<String>.from(json['routeStations'] as List),
      passengerType: resolvedType,
    );
  }
}