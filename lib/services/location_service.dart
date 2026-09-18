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
    final cleanQuery = placeName.trim().toLowerCase();

    final Map<String, String> popularPlaces = {
      'abbas el akkad': 'Stadium',
      'abbas elakkad': 'Stadium',
      'عباس العقاد': 'Stadium',
      'makram ebeid': 'Stadium',
      'مكرم عبيد': 'Stadium',
      'city stars': 'Al-Ahram',
      'سيتي ستارز': 'Al-Ahram',
      'el salam': 'Adly Mansour',
      'salam': 'Adly Mansour',
      'السلام': 'Adly Mansour',
      'مدينة السلام': 'Adly Mansour',
      'cairo university': 'Cairo University',
      'جامعة القاهرة': 'Cairo University',
      'ain shams university': 'El Demerdash',
      'جامعة عين شمس': 'El Demerdash',
      'tahrir': 'El Sadat',
      'التحرير': 'El Sadat',
      'downtown': 'El Sadat',
      'وسط البلد': 'El Sadat',
      'ramses': 'El Shohadaa',
      'رمسيس': 'El Shohadaa',
      'محطة مصر': 'El Shohadaa',
      'al azhar': 'Bab El-Shaaria',
      'el hussein': 'Bab El-Shaaria',
      'الحسين': 'Bab El-Shaaria',
      'الازهر': 'Bab El-Shaaria',
      'zamalek': 'Safaa Hijazy',
      'الزمالك': 'Safaa Hijazy',
      'mohandessin': 'Gamaat El Dowal',
      'المهندسين': 'Gamaat El Dowal',
      'cairo festival': 'Al-Ahram',
      'كوديرو فيستيفال': 'Al-Ahram',
      'nasr city': 'Stadium',
      'مدينة نصر': 'Stadium',
      'heliopolis': 'Heliopolis',
      'مصر الجديدة': 'Heliopolis',
      'maadi': 'Maadi',
      'المعادي': 'Maadi',
      'giza zoo': 'Opera',
      'حديقة الحيوان': 'Opera',
      'cairo tower': 'Opera',
      'برج القاهرة': 'Opera',
    };

    for (var key in popularPlaces.keys) {
      if (cleanQuery.contains(key) || key.contains(cleanQuery)) {
        final stationName = popularPlaces[key]!;
        try {
          return MetroData.allStations.firstWhere((s) => s.name == stationName);
        } catch (_) {}
      }
    }

    try {
      List<Location> locations = await locationFromAddress('$placeName, Egypt');
      if (locations.isNotEmpty) {
        final loc = locations.first;
        return findNearestStation(loc.latitude, loc.longitude);
      }
    } catch (_) {
      try {
        List<Location> locations = await locationFromAddress(placeName);
        if (locations.isNotEmpty) {
          final loc = locations.first;
          return findNearestStation(loc.latitude, loc.longitude);
        }
      } catch (_) {
        return null;
      }
    }

    return null;
  }
}
