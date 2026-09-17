import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/metro_data.dart';
import '../models/station_model.dart';

class LocationService {
  static Future<bool> openStationOnMap(Station station) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${station.latitude},${station.longitude}',
    );
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }

  static Future<Position?> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  static Station findNearestStation(double latitude, double longitude) {
    Station nearest = MetroData.allStations.first;
    double minDistance = double.infinity;

    for (var station in MetroData.allStations) {
      double distance = Geolocator.distanceBetween(
        latitude,
        longitude,
        station.latitude,
        station.longitude,
      );

      if (distance < minDistance) {
        minDistance = distance;
        nearest = station;
      }
    }
    return nearest;
  }

  static Future<Station?> findNearestStationToPlace(String placeName) async {
    try {
      String searchQuery = placeName.contains('Egypt') || placeName.contains('Cairo')
          ? placeName
          : '$placeName, Cairo, Egypt';

      List<Location> locations = await locationFromAddress(searchQuery);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        return findNearestStation(loc.latitude, loc.longitude);
      }
    } catch (_) {
      return null;
    }
    return null;
  }
}