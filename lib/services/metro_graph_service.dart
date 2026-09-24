import '../data/metro_data.dart';
import '../models/station_model.dart';
import 'dart:collection';

enum PassengerType { normal, senior, specialNeeds }

class MetroGraphService {
  final Map<String, List<String>> _adjacencyList = {};

  MetroGraphService() {
    _buildGraph();
  }

  void _buildGraph() {
    _addBidirectionalEdges(MetroData.line1Names);
    _addBidirectionalEdges(MetroData.line2Names);
    _addBidirectionalEdges(MetroData.line3Common);
    _addBidirectionalEdges(MetroData.line3BranchA);
    _addBidirectionalEdges(MetroData.line3BranchB);
    _addBidirectionalEdges(MetroData.monorailEastNames);

    _addTransfer("Kit Kat", ["El-Tawfiqiya", "Sudan"]);
    _addTransfer("Adly Mansour", ["El Haykestep"]);
    // Walking transfer between Metro Stadium and Monorail Stadium (~4-5 min walk)
    _addTransfer("Stadium", ["Stadium (Monorail)"]);
  }

  void _addBidirectionalEdges(List<String> stations) {
    for (int i = 0; i < stations.length - 1; i++) {
      _addEdge(stations[i], stations[i + 1]);
      _addEdge(stations[i + 1], stations[i]);
    }
  }

  void _addEdge(String u, String v) {
    _adjacencyList.putIfAbsent(u, () => []);
    if (!_adjacencyList[u]!.contains(v)) {
      _adjacencyList[u]!.add(v);
    }
  }

  void _addTransfer(String station, List<String> branches) {
    for (var b in branches) {
      _addEdge(station, b);
      _addEdge(b, station);
    }
  }

  Station? getStationByName(String name) {
    final cleanSearch = name
        .trim()
        .toLowerCase()
        .replaceAll('-', ' ')
        .replaceAll('el ', '')
        .replaceAll('al ', '');
    try {
      return MetroData.allStations.firstWhere((s) {
        final cleanStation = s.name
            .trim()
            .toLowerCase()
            .replaceAll('-', ' ')
            .replaceAll('el ', '')
            .replaceAll('al ', '');
        return cleanStation == cleanSearch ||
            s.name.toLowerCase() == name.trim().toLowerCase();
      });
    } catch (_) {
      return null;
    }
  }

  int calculateTicketPrice(int stationCount, PassengerType type) {
    if (type == PassengerType.specialNeeds) return 5;

    int normalPrice;
    if (stationCount <= 9) {
      normalPrice = 10;
    } else if (stationCount <= 16) {
      normalPrice = 12;
    } else if (stationCount <= 23) {
      normalPrice = 15;
    } else {
      normalPrice = 20;
    }

    if (type == PassengerType.senior) {
      return (normalPrice / 2).ceil();
    }
    return normalPrice;
  }

  int countTransfers(List<String> path) {
    if (path.length < 2) return 0;
    int transfers = 0;
    String currentLine = _getCommonLine(path[0], path[1]);

    for (int i = 1; i < path.length - 1; i++) {
      String nextLine = _getCommonLine(path[i], path[i + 1]);
      if (currentLine != nextLine &&
          nextLine.isNotEmpty &&
          currentLine.isNotEmpty) {
        transfers++;
        currentLine = nextLine;
      }
    }
    return transfers;
  }

  String _getCommonLine(String s1Name, String s2Name) {
    final s1 = getStationByName(s1Name);
    final s2 = getStationByName(s2Name);
    if (s1 == null || s2 == null) return '';
    final common = s1.lines.where((l) => s2.lines.contains(l)).toList();
    return common.isNotEmpty ? common.first : '';
  }

  List<String> generateInstructions(List<Station> path) {
    if (path.length < 2) return [];
    List<String> steps = [];
    String currentLine = _getCommonLine(path[0].name, path[1].name);
    steps.add('Start at ${path[0].localizedName} ($currentLine)');

    for (int i = 1; i < path.length - 1; i++) {
      final currName = path[i].name;
      final nextName = path[i + 1].name;

      if ((currName == "Stadium" && nextName == "Stadium (Monorail)") ||
          (currName == "Stadium (Monorail)" && nextName == "Stadium")) {
        steps.add('Exit and walk ~5 mins to ${path[i + 1].localizedName}');
        currentLine = _getCommonLine(currName, nextName);
        continue;
      }

      String nextLine = _getCommonLine(currName, nextName);
      if (currentLine != nextLine && nextLine.isNotEmpty) {
        steps.add('Transfer at ${path[i].localizedName} to $nextLine');
        currentLine = nextLine;
      }
    }
    steps.add('Arrive at destination: ${path.last.localizedName}');
    return steps;
  }

  TripResult? calculateTrip(
    String start,
    String end,
    PassengerType passengerType, {
    bool preferFewerTransfers = false,
  }) {
    if (start == end) {
      final s = getStationByName(start);
      if (s == null) return null;
      return TripResult(
        path: [s],
        stationCount: 1,
        estimatedTimeMinutes: 0,
        ticketPrice: calculateTotalTripFare([s], passengerType),
        instructions: ['You are already at the destination'],
        transferCount: 0,
      );
    }

    List<List<String>> allPaths = [];
    Queue<List<String>> queue = Queue();
    queue.add([start]);

    while (queue.isNotEmpty && allPaths.length < 25) {
      List<String> current = queue.removeFirst();
      String last = current.last;

      if (last == end) {
        allPaths.add(current);
        continue;
      }

      for (String neighbor in _adjacencyList[last] ?? []) {
        if (!current.contains(neighbor) && current.length <= 40) {
          queue.add(List.from(current)..add(neighbor));
        }
      }
    }

    if (allPaths.isEmpty) return null;

    if (preferFewerTransfers) {
      allPaths.sort((a, b) {
        int tA = countTransfers(a);
        int tB = countTransfers(b);
        if (tA != tB) return tA.compareTo(tB);
        return a.length.compareTo(b.length);
      });
    } else {
      allPaths.sort((a, b) {
        if (a.length != b.length) return a.length.compareTo(b.length);
        return countTransfers(a).compareTo(countTransfers(b));
      });
    }

    final chosenPathNames = allPaths.first;
    final path = chosenPathNames
        .map((name) => getStationByName(name)!)
        .toList();
    final stationCount = path.length;
    final transfers = countTransfers(chosenPathNames);
    final time = (stationCount * 2) + (transfers * 5);

    return TripResult(
      path: path,
      stationCount: stationCount,
      estimatedTimeMinutes: time,
      ticketPrice: calculateTotalTripFare(path, passengerType),
      instructions: generateInstructions(path),
      transferCount: transfers,
    );
  }

  int calculateMonorailPrice(int stationCount, PassengerType type) {
    if (stationCount <= 0) return 0;
    if (type == PassengerType.specialNeeds) return 5;

    int normalPrice;
    if (stationCount <= 5) {
      normalPrice = 20;
    } else if (stationCount <= 10) {
      normalPrice = 40;
    } else if (stationCount <= 15) {
      normalPrice = 55;
    } else {
      normalPrice = 80;
    }

    if (type == PassengerType.senior) {
      return (normalPrice / 2).ceil();
    }
    return normalPrice;
  }

  int calculateTotalTripFare(List<Station> path, PassengerType passengerType) {
    if (path.isEmpty) return 0;

    int metroCount = 0;
    int monorailCount = 0;

    for (var station in path) {
      if (station.lines.contains("Monorail East")) {
        monorailCount++;
      } else {
        metroCount++;
      }
    }

    int metroPrice = 0;
    if (metroCount > 0) {
      metroPrice = calculateTicketPrice(metroCount, passengerType);
    }

    int monorailPrice = 0;
    if (monorailCount > 0) {
      monorailPrice = calculateMonorailPrice(monorailCount, passengerType);
    }

    return metroPrice + monorailPrice;
  }
}
