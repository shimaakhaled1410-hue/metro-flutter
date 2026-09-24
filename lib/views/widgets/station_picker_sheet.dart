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
  static const Color monorailColor = Color(0xFF00897B);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
    } else if (lineIndex == 2) {
      names = {
        ...MetroData.line3Common,
        ...MetroData.line3BranchA,
        ...MetroData.line3BranchB,
      }.toList();
    } else {
      names = MetroData.monorailEastNames;
    }

    return names
        .map(
          (name) => MetroData.allStations.firstWhere((st) => st.name == name),
        )
        .toList();
  }

  List<Station> _getAllSearchResults() {
    final query = _searchQuery.trim().toLowerCase();
    return MetroData.allStations.where((s) {
      return s.name.toLowerCase().contains(query) || s.nameAr.contains(query);
    }).toList();
  }

  Color _getStationColor(Station station) {
    if (station.lines.contains('Line 1')) return line1Color;
    if (station.lines.contains('Line 2')) return line2Color;
    if (station.lines.contains('Line 3')) return line3Color;
    return monorailColor;
  }

  Widget _buildStationTile(Station station, Color indicatorColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isInterchange = station.lines.length > 1;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => widget.onSelected(station.name),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF252A36) : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? const Color(0xFF2E3544) : Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: indicatorColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    station.localizedName,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  if (_searchQuery.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      station.lines.join(' | '),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isInterchange)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.amber.shade900.withValues(alpha: 0.3)
                      : Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'transfer'.tr,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? Colors.amber.shade200
                        : Colors.amber.shade900,
                  ),
                ),
              ),
            const SizedBox(width: 6),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Colors.grey.shade500,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineList(int lineIndex, Color lineColor) {
    final stations = _getStationsForLine(lineIndex);

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: stations.length,
      separatorBuilder: (_, _) => const SizedBox(height: 6),
      itemBuilder: (context, index) {
        return _buildStationTile(stations[index], lineColor);
      },
    );
  }

  Widget _buildGlobalSearchResults() {
    final results = _getAllSearchResults();

    if (results.isEmpty) {
      return Center(
        child: Text(
          'no_trips'.tr,
          style: TextStyle(color: Colors.grey.shade500),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: results.length,
      separatorBuilder: (_, _) => const SizedBox(height: 6),
      itemBuilder: (context, index) {
        final station = results[index];
        return _buildStationTile(station, _getStationColor(station));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final isSearching = _searchQuery.trim().isNotEmpty;

    return Container(
      height: MediaQuery.of(context).size.height * 0.78,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF333B4D) : Colors.grey.shade300,
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
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : primaryColor,
                  ),
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
                filled: true,
                fillColor: isDark
                    ? const Color(0xFF1E222B)
                    : Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
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
          if (!isSearching) ...[
            TabBar(
              controller: _tabController,
              indicatorColor: primaryColor,
              labelColor: primaryColor,
              unselectedLabelColor: Colors.grey,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircleAvatar(
                        radius: 4,
                        backgroundColor: line1Color,
                      ),
                      const SizedBox(width: 6),
                      Text('line_1'.tr),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircleAvatar(
                        radius: 4,
                        backgroundColor: line2Color,
                      ),
                      const SizedBox(width: 6),
                      Text('line_2'.tr),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircleAvatar(
                        radius: 4,
                        backgroundColor: line3Color,
                      ),
                      const SizedBox(width: 6),
                      Text('line_3'.tr),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircleAvatar(
                        radius: 4,
                        backgroundColor: monorailColor,
                      ),
                      const SizedBox(width: 6),
                      Text('monorail_line'.tr),
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
                  _buildLineList(3, monorailColor),
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: 8),
            Expanded(child: _buildGlobalSearchResults()),
          ],
        ],
      ),
    );
  }
}
