import 'dart:collection';
import '../data/metro_data.dart';
import '../models/station_model.dart';

class MetroGraphService {
  final Map<String, List<String>> _graph = {};
  final Map<String, Station> _stationLookup = {};

  MetroGraphService() {
    _initGraph();
  }

  void _addConnection(String a, String b) {
    _graph.putIfAbsent(a, () => []).add(b);
    _graph.putIfAbsent(b, () => []).add(a);
  }

  void _addLineConnections(List<String> stations) {
    for (int i = 0; i < stations.length - 1; i++) {
      _addConnection(stations[i], stations[i + 1]);
    }
  }

  void _initGraph() {
    for (var s in MetroData.allStations) {
      _stationLookup[s.name] = s;
    }

    _addLineConnections(MetroData.line1Names);
    _addLineConnections(MetroData.line2Names);
    _addLineConnections(MetroData.line3Common);
    _addLineConnections(MetroData.line3BranchA);
    _addLineConnections(MetroData.line3BranchB);
  }

  Station? getStationByName(String name) => _stationLookup[name];

  TripResult? calculateTrip(String startName, String endName) {
    if (startName == endName) {
      final station = getStationByName(startName);
      if (station == null) return null;
      return TripResult(
        path: [station],
        stationCount: 0,
        estimatedTimeMinutes: 0,
        ticketPrice: 0,
        instructions: ["You are already at the destination."],
      );
    }

    final queue = Queue<List<String>>();
    final visited = <String>{};

    queue.add([startName]);
    visited.add(startName);

    List<String>? foundPath;

    while (queue.isNotEmpty) {
      final currentPath = queue.removeFirst();
      final currentStation = currentPath.last;

      if (currentStation == endName) {
        foundPath = currentPath;
        break;
      }

      for (var neighbor in _graph[currentStation] ?? []) {
        if (!visited.contains(neighbor)) {
          visited.add(neighbor);
          queue.add([...currentPath, neighbor]);
        }
      }
    }

    if (foundPath == null) return null;

    final stationPath = foundPath
        .map((name) => _stationLookup[name]!)
        .toList();

    final count = stationPath.length - 1;
    final time = count * 2; 
    final price = _calculateTicketPrice(count);
    final instructions = _generateInstructions(foundPath);

    return TripResult(
      path: stationPath,
      stationCount: count,
      estimatedTimeMinutes: time,
      ticketPrice: price,
      instructions: instructions,
    );
  }

  int _calculateTicketPrice(int count) {
    if (count <= 9) return 10;
    if (count <= 16) return 12;
    if (count <= 23) return 15;
    return 20;
  }

  List<String> _generateInstructions(List<String> path) {
    if (path.length <= 1) return ["You have arrived."];

    final instructions = <String>[];
    String currentLine = _getCommonLine(path[0], path[1]);
    String lineDirection = _getLineDirection(currentLine, path[0], path[1]);

    instructions.add("Take $currentLine towards ($lineDirection)");

    for (int i = 1; i < path.length - 1; i++) {
      String nextLine = _getCommonLine(path[i], path[i + 1]);
      if (currentLine != nextLine) {
        instructions.add("Change at (${path[i]}) to $nextLine");
        currentLine = nextLine;
        lineDirection = _getLineDirection(currentLine, path[i], path[i + 1]);
        instructions.add("Take $currentLine towards ($lineDirection)");
      }
    }

    return instructions;
  }

  String _getCommonLine(String s1, String s2) {
    final st1 = _stationLookup[s1]!;
    final st2 = _stationLookup[s2]!;
    for (var line in st1.lines) {
      if (st2.lines.contains(line)) return line;
    }
    return st1.lines.first;
  }

  String _getLineDirection(String line, String s1, String s2) {
    List<String> lineList;
    if (line == "Line 1") {
      lineList = MetroData.line1Names;
    } else if (line == "Line 2") {
      lineList = MetroData.line2Names;
    } else {
      if (MetroData.line3BranchB.contains(s1) || MetroData.line3BranchB.contains(s2)) {
        lineList = [...MetroData.line3Common, ...MetroData.line3BranchB.sublist(1)];
      } else {
        lineList = [...MetroData.line3Common, ...MetroData.line3BranchA.sublist(1)];
      }
    }

    int i1 = lineList.indexOf(s1);
    int i2 = lineList.indexOf(s2);

    if (i1 != -1 && i2 != -1) {
      return i2 > i1 ? lineList.last : lineList.first;
    }
    return "End of Line";
  }
}