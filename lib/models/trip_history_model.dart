import 'dart:convert';

class TripHistory {
  final String id;
  final String startStation;
  final String endStation;
  final int stationCount;
  final int timeInMinutes;
  final int price;
  final DateTime timestamp;

  TripHistory({
    required this.id,
    required this.startStation,
    required this.endStation,
    required this.stationCount,
    required this.timeInMinutes,
    required this.price,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'startStation': startStation,
    'endStation': endStation,
    'stationCount': stationCount,
    'timeInMinutes': timeInMinutes,
    'price': price,
    'timestamp': timestamp.toIso8601String(),
  };

  factory TripHistory.fromMap(Map<String, dynamic> map) => TripHistory(
    id: map['id'],
    startStation: map['startStation'],
    endStation: map['endStation'],
    stationCount: map['stationCount'],
    timeInMinutes: map['timeInMinutes'],
    price: map['price'],
    timestamp: DateTime.parse(map['timestamp']),
  );

  String toJson() => jsonEncode(toMap());
  factory TripHistory.fromJson(String source) => TripHistory.fromMap(jsonDecode(source));
}