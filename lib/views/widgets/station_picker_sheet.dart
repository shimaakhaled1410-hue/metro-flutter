import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/metro_data.dart';
import '../../models/station_model.dart';

class StationPickerSheet extends StatefulWidget {
  final String title;
  final Function(String stationName) onSelected;

  const StationPickerSheet({
    super.key,
    required this.title,
    required this.onSelected,
  });

  @override
  State<StationPickerSheet> createState() => _StationPickerSheetState();
}

class _StationPickerSheetState extends State<StationPickerSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  static const Color line1Color = Color(0xFF1E88E5);
  static const Color line2Color = Color(0xFFE53935);
  static const Color line3Color = Color(0xFF43A047);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Station> _getStationsForLine(int lineIndex) {
    List<String> names;
    if (lineIndex == 0) {
      names = MetroData.line1Names;
    } else if (lineIndex == 1) {
      names = MetroData.line2Names;
    } else {
      names = {
        ...MetroData.line3Common,
        ...MetroData.line3BranchA,
        ...MetroData.line3BranchB
      }.toList();
    }

    var stations = names
        .map((name) =>
            MetroData.allStations.firstWhere((st) => st.name == name))
        .toList();

    if (_searchQuery.isNotEmpty) {
      stations = stations
          .where((s) =>
              s.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              s.nameAr.contains(_searchQuery))
          .toList();
    }

    return stations;
  }

  Widget _buildLineList(int lineIndex, Color lineColor) {
    final stations = _getStationsForLine(lineIndex);

    if (stations.isEmpty) {
      return Center(
        child: Text(
          'no_trips'.tr,
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: stations.length,
      separatorBuilder: (_, __) => const SizedBox(height: 6),
      itemBuilder: (context, index) {
        final station = stations[index];
        final isInterchange = station.lines.length > 1;

        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => widget.onSelected(station.name),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: lineColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    station.localizedName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (isInterchange)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'transfer'.tr,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber.shade900,
                      ),
                    ),
                  ),
                const SizedBox(width: 6),
                const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.78,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'search_station'.tr,
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          TabBar(
            controller: _tabController,
            indicatorColor: const Color(0xFF1B3A57),
            labelColor: const Color(0xFF1B3A57),
            unselectedLabelColor: Colors.grey,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircleAvatar(radius: 4, backgroundColor: line1Color),
                    const SizedBox(width: 6),
                    Text('line_1'.tr),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircleAvatar(radius: 4, backgroundColor: line2Color),
                    const SizedBox(width: 6),
                    Text('line_2'.tr),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircleAvatar(radius: 4, backgroundColor: line3Color),
                    const SizedBox(width: 6),
                    Text('line_3'.tr),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildLineList(0, line1Color),
                _buildLineList(1, line2Color),
                _buildLineList(2, line3Color),
              ],
            ),
          ),
        ],
      ),
    );
  }
}