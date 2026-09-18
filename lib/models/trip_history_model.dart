class TripHistory {
  final String id;
  final String startStation;
  final String endStation;
  final int stationCount;
  final int timeInMinutes;
  final int price;
  final DateTime timestamp;
  final List<String> routeStations;

  TripHistory({
    required this.id,
    required this.startStation,
    required this.endStation,
    required this.stationCount,
    required this.timeInMinutes,
    required this.price,
    required this.timestamp,
    required this.routeStations,
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
      };

  factory TripHistory.fromJson(Map<String, dynamic> json) => TripHistory(
        id: json['id'] as String,
        startStation: json['startStation'] as String,
        endStation: json['endStation'] as String,
        stationCount: json['stationCount'] as int,
        timeInMinutes: json['timeInMinutes'] as int,
        price: json['price'] as int,
        timestamp: DateTime.parse(json['timestamp'] as String),
        routeStations: (json['routeStations'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
      );
}