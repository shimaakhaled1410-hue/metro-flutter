import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/trip_history_model.dart';

class HistoryService {
  static const String _key = 'metro_trips_history';

  static Future<List<TripHistory>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> list = prefs.getStringList(_key) ?? [];
    return list
        .map((item) => TripHistory.fromJson(jsonDecode(item) as Map<String, dynamic>))
        .toList();
  }

  static Future<void> saveTrip(TripHistory trip) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> list = prefs.getStringList(_key) ?? [];
    list.insert(0, jsonEncode(trip.toJson()));
    await prefs.setStringList(_key, list);
  }

  static Future<void> deleteTrip(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> list = prefs.getStringList(_key) ?? [];
    final updatedList = list.where((item) {
      final decoded = jsonDecode(item) as Map<String, dynamic>;
      return decoded['id'] != id;
    }).toList();
    await prefs.setStringList(_key, updatedList);
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}