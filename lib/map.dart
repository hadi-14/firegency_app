import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart'; // For LatLng
import 'package:http/http.dart' as http;
import 'package:csv/csv.dart';

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
  Future<List<List<dynamic>>?>? modisData; // Store MODIS data here
  String apiKey = "ed115b05d57d59b2d98a5c03e40f5ca3";
  String countrycode = "";
  String url = "";
<<<<<<< HEAD
  Future<List<String>>? randomFacts;
=======
  List<String> randomFacts = [];
>>>>>>> b9f410545971539f9f9220e177343a95312e8951git
  // Fetch and parse MODIS data
  String dataDate = (DateTime.now()).toString().split(' ')[0];
  // ignore: body_might_complete_normally_nullable
  Future<List<List<dynamic>>?> fetchModisData() async {
    DateTime date = widget.selectedDate;

    dataDate = date.toString().split(' ')[0];
    String previousDate =
        (date.subtract(const Duration(days: 1))).toString().split(' ')[0];

    String apiUrlToday =
        'https://firms.modaps.eosdis.nasa.gov/api/country/csv/$apiKey/VIIRS_SNPP_NRT/$countrycode/1/$date';
    String apiUrlYesterday =
        'https://firms.modaps.eosdis.nasa.gov/api/country/csv/$apiKey/VIIRS_SNPP_NRT/$countrycode/1/$previousDate';

    final responseToday = await http.get(Uri.parse(
      apiUrlToday,
    ));

    if (responseToday.statusCode == 200) {
      final csvData =
          const CsvToListConverter().convert(responseToday.body, eol: "\n");
      csvData.removeAt(0);

      if (csvData.isEmpty) {
        // If today's data is not available, try fetching data from yesterday
        final responseYesterday = await http.get(Uri.parse(
          apiUrlYesterday,
        ));

        dataDate = previousDate;

        if (responseYesterday.statusCode == 200) {
          final csvData = const CsvToListConverter()
              .convert(responseYesterday.body, eol: "\n");
          csvData.removeAt(0);
          return csvData;
        } else {
          throw Exception('Failed to fetch MODIS data');
        }
      }
      return csvData;
    }
  }

  Future<List<String>> loadInfo() async {
    final String countriesData =
        await rootBundle.loadString('assets/info.json');
    final List<dynamic> jsonCountries = json.decode(countriesData);
    return jsonCountries.cast<String>();
  }

  @override
  void initState() {
    super.initState();

<<<<<<< HEAD
    countrycode = widget.selectedLocation['code'];
    modisData = fetchModisData();
    randomFacts = loadInfo();
=======
    loadInfo().then((fireinfo) {
      setState(() {
        randomFacts = fireinfo;
        randomFacts.shuffle();

      });
    });
      countrycode = widget.selectedLocation['code'];
      modisData = fetchModisData();
>>>>>>> b9f410545971539f9f9220e177343a95312e8951
  }

  @override
  Widget build(BuildContext context) {
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
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No MODIS data available'));
              } else {
                final modisData = snapshot.data!;
                final markers = <Marker>[];

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
                            color:
                                Colors.red, // You can customize the marker icon
                          ),
                        ),
                      );
                    }
                  }
                } // Logic to create markers from modisData

                if (markers.isEmpty) {
                  return const Center(
                      child: Text('No valid MODIS data available'));
                } else {
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
                            'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                        subdomains: const ['a', 'b', 'c'],
                      ),
                      MarkerLayer(
                        markers: markers,
                      ),
                    ],
                  );
                }
              }
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
                    color: Colors.black.withOpacity(0.5),
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
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  // Right side text (today's date)
                  Text(
                    dataDate,
                    style: const TextStyle(
                      fontSize: 20.0,
                      color: Colors.black,
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
