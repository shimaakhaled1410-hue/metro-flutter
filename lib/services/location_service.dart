import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/metro_data.dart';
import '../models/station_model.dart';

class LandmarkItem {
  final String titleEn;
  final String titleAr;
  final String stationKeyword;

  const LandmarkItem({
    required this.titleEn,
    required this.titleAr,
    required this.stationKeyword,
  });
}

class LocationService {
  static const List<LandmarkItem> popularPlacesList = [
    LandmarkItem(titleEn: 'Abbas El Akkad', titleAr: 'عباس العقاد', stationKeyword: 'Stadium'),
    LandmarkItem(titleEn: 'Makram Ebeid', titleAr: 'مكرم عبيد', stationKeyword: 'Stadium'),
    LandmarkItem(titleEn: 'City Stars', titleAr: 'سيتي ستارز', stationKeyword: 'Ahram'),
    LandmarkItem(titleEn: 'Cairo University', titleAr: 'جامعة القاهرة', stationKeyword: 'Cairo University'),
    LandmarkItem(titleEn: 'Ain Shams Univ.', titleAr: 'جامعة عين شمس', stationKeyword: 'Sadr'),
    LandmarkItem(titleEn: 'Tahrir Square', titleAr: 'ميدان التحرير', stationKeyword: 'Sadat'),
    LandmarkItem(titleEn: 'Downtown', titleAr: 'وسط البلد', stationKeyword: 'Sadat'),
    LandmarkItem(titleEn: 'Ramses Station', titleAr: 'محطة مصر (رمسيس)', stationKeyword: 'Shohadaa'),
    LandmarkItem(titleEn: 'Al Azhar & Hussein', titleAr: 'الأزهر والحسين', stationKeyword: 'Bab'),
    LandmarkItem(titleEn: 'Zamalek', titleAr: 'الزمالك', stationKeyword: 'Safaa'),
    LandmarkItem(titleEn: 'Mohandessin', titleAr: 'المهندسين', stationKeyword: 'Gamaat'),
    LandmarkItem(titleEn: 'Nasr City', titleAr: 'مدينة نصر', stationKeyword: 'Stadium'),
    LandmarkItem(titleEn: 'Heliopolis', titleAr: 'مصر الجديدة', stationKeyword: 'Heliopolis'),
    LandmarkItem(titleEn: 'Maadi', titleAr: 'المعادي', stationKeyword: 'Maadi'),
    LandmarkItem(titleEn: 'Cairo Tower', titleAr: 'برج القاهرة', stationKeyword: 'Opera'),
    LandmarkItem(titleEn: 'Cairo Airport', titleAr: 'مطار القاهرة', stationKeyword: 'Adly'),
  ];

  static final Map<String, String> cairoAreasDirectory = {
    'سلام': 'Adly',
    'السلام': 'Adly',
    'مدينة السلام': 'Adly',
    'موقف العاشر': 'Adly',
    'الشروق': 'Adly',
    'بدر': 'Adly',
    'العاشر': 'Adly',
    'salam': 'Adly',
    'عباس': 'Stadium',
    'عباس العقاد': 'Stadium',
    'مكرم': 'Stadium',
    'مكرم عبيد': 'Stadium',
    'مدينة نصر': 'Stadium',
    'طريق النصر': 'Stadium',
    'الاستاد': 'Stadium',
    'nasr city': 'Stadium',
    'سيتي ستارز': 'Ahram',
    'الكوربة': 'Ahram',
    'الاهرام': 'Ahram',
    'مصر الجديدة': 'Heliopolis',
    'روكسي': 'Heliopolis',
    'شيراتون': 'Heliopolis',
    'مطار القاهرة': 'Adly',
    'airport': 'Adly',
    'عين شمس': 'Ain Shams',
    'المطرية': 'Matariya',
    'الزيتون': 'Zaytoun',
    'سراي القبة': 'Saray',
    'حدائق القبة': 'Koubba',
    'العباسية': 'Abbassia',
    'جامعة عين شمس': 'Sadr',
    'منشية الصدر': 'Sadr',
    'الدمرداش': 'Demerdash',
    'التحرير': 'Sadat',
    'وسط البلد': 'Sadat',
    'طلعت حرب': 'Sadat',
    'tahrir': 'Sadat',
    'downtown': 'Sadat',
    'رمسيس': 'Shohadaa',
    'محطة مصر': 'Shohadaa',
    'ramses': 'Shohadaa',
    'العتبة': 'Attaba',
    'الازهر': 'Bab',
    'الحسين': 'Bab',
    'خان الخليلي': 'Bab',
    'المعز': 'Bab',
    'السيدة زينب': 'Zeinab',
    'قصر العيني': 'Zeinab',
    'مصر القديمة': 'Girgis',
    'مارجرجس': 'Girgis',
    'المعادي': 'Maadi',
    'ثكنات المعادي': 'Maadi',
    'حلوان': 'Helwan',
    'جامعة حلوان': 'Helwan',
    'الدقي': 'Dokki',
    'المهندسين': 'Gamaat',
    'جامعة الدول': 'Gamaat',
    'البحوث': 'Bohooth',
    'جامعة القاهرة': 'Cairo University',
    'الجيزة': 'Giza',
    'فيصل': 'Faisal',
    'الهرم': 'Giza',
    'الزمالك': 'Safaa',
    'zamalek': 'Safaa',
    'الكيت كات': 'Kit Kat',
    'إمبابة': 'Imbaba',
    'شبرا': 'Shubra',
    'شبرا الخيمة': 'Shubra',
    'المظلات': 'Mezallat',
  };

  static Station? resolveStationByKeyword(String keyword) {
    final clean = keyword.trim().toLowerCase();
    for (var station in MetroData.allStations) {
      if (station.name.toLowerCase().contains(clean) ||
          station.nameAr.contains(clean)) {
        return station;
      }
    }
    return null;
  }

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
    final cleanQuery = placeName.trim().toLowerCase().replaceAll('أ', 'ا').replaceAll('إ', 'ا').replaceAll('ة', 'ه');

    for (var entry in cairoAreasDirectory.entries) {
      final key = entry.key.toLowerCase().replaceAll('أ', 'ا').replaceAll('إ', 'ا').replaceAll('ة', 'ه');
      if (cleanQuery.contains(key) || key.contains(cleanQuery)) {
        final station = resolveStationByKeyword(entry.value);
        if (station != null) return station;
      }
    }

    for (var item in popularPlacesList) {
      final titleEn = item.titleEn.toLowerCase();
      final titleAr = item.titleAr.replaceAll('أ', 'ا').replaceAll('إ', 'ا').replaceAll('ة', 'ه');
      if (cleanQuery.contains(titleEn) || titleEn.contains(cleanQuery) ||
          cleanQuery.contains(titleAr) || titleAr.contains(cleanQuery)) {
        final station = resolveStationByKeyword(item.stationKeyword);
        if (station != null) return station;
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