import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MetroMapView extends StatelessWidget {
  const MetroMapView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('metro_map'.tr),
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true,
          boundaryMargin: const EdgeInsets.all(20),
          minScale: 0.8,
          maxScale: 4.5,
          child: Image.asset(
  'assets/images/metro_map.jpg',
  fit: BoxFit.contain,
  errorBuilder: (context, error, stackTrace) => Center(
    child: Text(
      'Failed to load metro map image',
      style: TextStyle(color: Colors.grey.shade500),
    ),
  ),
),
        ),
      ),
    );
  }
}