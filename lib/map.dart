import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart'; // For LatLng
import 'package:http/http.dart' as http;
import 'package:csv/csv.dart';

class Facts {
  final String name;
  final List<String> sentence;

  Facts(this.name, this.sentence);
}

class InteractiveMap extends StatefulWidget {
  final Map<String, dynamic>
      selectedLocation; // Declare the selectedLocation field

  DateTime selectedDate;

  // Constructor to receive the selectedLocation value
  InteractiveMap(
      {required this.selectedLocation, required this.selectedDate, Key? key})
      : super(key: key);

  @override
  _InteractiveMapState createState() => _InteractiveMapState();
}

class _InteractiveMapState extends State<InteractiveMap> {
  Future<List<List<dynamic>>?>? modisData;
  String apiKey = "ed115b05d57d59b2d98a5c03e40f5ca3";
  String countrycode = "";
  String url = "";
  List<Marker> randomMarkers = [];
  bool isBlinking = true; // Add a bool variable for blinking animation
  int selectedMarkerIndex = -1; // To track the selected marker
  late Timer blinkTimer;
  bool isNoDataDialogShown = false;

  // Fetch and parse MODIS data
  String dataDate = (DateTime.now()).toString().split(' ')[0];
  Future<List<List<dynamic>>?> fetchModisData() async {
    DateTime date = widget.selectedDate;

    dataDate = date.toString().split(' ')[0];

    String apiUrlToday =
        'https://firms.modaps.eosdis.nasa.gov/api/country/csv/$apiKey/VIIRS_SNPP_NRT/$countrycode/1/$dataDate';

    final responseToday = await http.get(Uri.parse(
      apiUrlToday,
    ));

    if (responseToday.statusCode == 200) {
      final csvData =
          const CsvToListConverter().convert(responseToday.body, eol: "\n");
      csvData.removeAt(0);
      return csvData;
    }
    return null;
  }

  Future<Map<String, List<String>>> loadInfo() async {
    final jsonString = await rootBundle.loadString('assets/info.json');
    final Map<String, dynamic> data = json.decode(jsonString);

    final Map<String, List<String>> categories = {};

    data.forEach((key, value) {
      final List<String> facts = List<String>.from(value)..shuffle();
      categories[key] = facts;
    });
    return categories;
  }

  void generateRandomMarkers(Map<String, List<String>> randomFacts) {
    LatLngBounds mapBounds = LatLngBounds(
      const LatLng(-90, -180),
      const LatLng(90, 180),
    );

    // Generate a specified number of random markers
    for (int i = 0; i < 50; i++) {
      double randomLat =
          Random().nextDouble() * (mapBounds.north - mapBounds.south) +
              mapBounds.south;
      double randomLng =
          Random().nextDouble() * (mapBounds.east - mapBounds.west) +
              mapBounds.west;

      int randomCategory = Random().nextInt(4);

      String category = "";
      String? text = "";

      switch (randomCategory) {
        case 0:
          category = "Prevention";
          text = randomFacts[category]?[i];
          break;
        case 1:
          category = "Cause";
          text = randomFacts[category]?[i];
          break;
        case 2:
          category = "Effect";
          text = randomFacts[category]?[i];
          break;
        case 3:
          category = "Types";
          text = randomFacts[category]?[i];
          break;
      }

      // Create a marker with a unique key to distinguish it from other markers
      Marker randomMarker = Marker(
        width: 30.0,
        height: 30.0,
        point: LatLng(randomLat, randomLng),
        builder: (ctx) => GestureDetector(
          onTap: () {
            _showFactListDialog(context, category, text as String);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            child: Icon(
              Icons.info_rounded,
              color: isBlinking
                  ? const Color.fromARGB(255, 0, 84, 14)
                  : const Color.fromARGB(255, 0, 255, 8),
            ),
          ),
        ),
      );

      setState(() {
        randomMarkers.add(randomMarker);
      });
    }
  }

  void startBlinkingAnimation() {
    const Duration blinkDuration = Duration(milliseconds: 750); // 0.75 seconds

    blinkTimer = Timer.periodic(blinkDuration, (timer) {
      if (!mounted) {
        // Check if the state is still mounted before updating the UI
        timer.cancel(); // Cancel the timer if the state is no longer mounted
        return;
      }

      setState(() {
        isBlinking = !isBlinking; // Toggle the blinking state
      });
    });
  }

  @override
  void initState() {
    super.initState();

    loadInfo().then((fireinfo) {
      setState(() {
        generateRandomMarkers(fireinfo);
      });
    });
    countrycode = widget.selectedLocation['code'];
    modisData = fetchModisData();
    startBlinkingAnimation(); // Start the blinking animation
  }

  void _showFactListDialog(BuildContext context, String category, String fact) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(category),
          content: SizedBox(
            child: Text(fact),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Close"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  void _showNoDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: AlertDialog(
            title: const Text('No Data Available'),
            content:
                const Text('There is no data available for this location.'),
            actions: <Widget>[
              TextButton(
                child: const Text("Back to Main"),
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
              ),
              TextButton(
                child: const Text("OK"),
                onPressed: () {
                  // Close the dialog and show the map with no fire icons
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final markers = <Marker>[];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firegency'),
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context); // Navigate back to the main page
          },
          child: Image.asset(
            'assets/logo.png',
            width: 30,
            height: 30,
          ),
        ),
      ),
      body: Stack(
        children: <Widget>[
          FutureBuilder<List<List<dynamic>>?>(
            future: modisData,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Center(child: Text('Error: ${snapshot.error}')));
              } else {
                final modisData = snapshot.data!;

                for (final data in modisData) {
                  if (data.length >= 3) {
                    final lat = data[1];
                    final lon = data[2];
                    if (lat is double && lon is double) {
                      markers.add(
                        Marker(
                          width: 30.0,
                          height: 30.0,
                          point: LatLng(lat, lon),
                          builder: (ctx) => const Icon(
                            Icons.local_fire_department_sharp,
                            color: Color(0xFFFF5A00),
                          ),
                        ),
                      );
                    }
                  }
                } // Logic to create markers from modisData
              }
              if (markers.isEmpty && !isNoDataDialogShown) {
                isNoDataDialogShown = true; // Set the flag to true
                Future.delayed(Duration.zero, () {
                  _showNoDataDialog(context);
                });
              }
              return FlutterMap(
                options: MapOptions(
                    zoom: 5.0,
                    bounds: LatLngBounds(
                        LatLng(widget.selectedLocation['coordinates'][0],
                            widget.selectedLocation['coordinates'][1]),
                        LatLng(widget.selectedLocation['coordinates'][2],
                            widget.selectedLocation['coordinates'][3]))),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                    subdomains: const ['a', 'b', 'c', 'd'],
                  ),
                  MarkerLayer(
                    markers: markers.isNotEmpty
                        ? markers + randomMarkers
                        : randomMarkers,
                  ),
                ],
              );
            },
          ),
          Positioned(
            left: 8,
            right: 8,
            bottom: 30,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFF5A00).withOpacity(0.9),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                  bottomLeft: Radius.circular(20.0),
                  bottomRight: Radius.circular(20.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left side text
                  Expanded(
                    child: Text(
                      widget.selectedLocation['name'],
                      style: const TextStyle(
                          fontSize: 20.0,
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  // Right side text (today's date)
                  Text(
                    dataDate,
                    style: const TextStyle(
                      fontSize: 20.0,
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
