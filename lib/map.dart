import 'dart:convert';

import 'package:flutter_map/plugin_api.dart';

import 'sidebar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart'; // For LatLng
import 'package:http/http.dart' as http;
import 'package:csv/csv.dart';

class InteractiveMap extends StatefulWidget {
  final String selectedLocation; // Declare the selectedLocation field

  // Constructor to receive the selectedLocation value
  InteractiveMap({required this.selectedLocation, Key? key}) : super(key: key);

  @override
  _InteractiveMapState createState() => _InteractiveMapState();
}

class _InteractiveMapState extends State<InteractiveMap> {
  Future<List<List<dynamic>>?>? modisData; // Store MODIS data here
  String apiKey = "ed115b05d57d59b2d98a5c03e40f5ca3";
  String countrycode = "";
  String url = "";

  // Fetch and parse MODIS data
  Future<List<List<dynamic>>?> fetchModisData() async {
    String previousDate =
        (DateTime.now().subtract(Duration(days: 1))).toString().split(' ')[0];

    String apiUrlToday =
        'https://firms.modaps.eosdis.nasa.gov/api/country/csv/$apiKey/VIIRS_SNPP_NRT/$countrycode/1/';
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

Future<String?> fetchExtentForCountry(String countryCode) async {
  final response = await http.get(Uri.parse('https://firms.modaps.eosdis.nasa.gov/api/countries'));

  if (response.statusCode == 200) {
    final csvData = const CsvToListConverter().convert(response.body, eol: "\n", textDelimiter: ";");
    
    for (final row in csvData) {
      final abreviation = row[1] as String;
      final extent = row[3] as String;

      if (abreviation == countryCode) {
        return extent;
      }
    }
  }

  return null; // Return null if data fetching or parsing fails
}

  @override
  void initState() {
    super.initState();

    List<String> locationParts = widget.selectedLocation.split(',');
    countrycode = locationParts[1].trim();

    modisData = fetchModisData();
    final extant = fetchExtentForCountry(countrycode);
    print(extant);
    // LatLngBounds(LatLng() , LatLng())
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firegency'),
        leading: Image.asset(
          'assets/logo.png', // Replace with your custom image path
          width: 3, // Adjust the width as needed
          height: 3, // Adjust the height as needed
        ),
      ),
      drawer: const Sidebar(),
      body: FutureBuilder<List<List<dynamic>>?>(
        future: modisData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator()); // Show a loading indicator
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Text('No MODIS data available');
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
                      width: 40.0,
                      height: 40.0,
                      point: LatLng(lat, lon),
                      builder: (ctx) => const Icon(
                        Icons.local_fire_department_sharp,
                        color: Colors.red, // You can customize the marker icon
                      ),
                    ),
                  );
                }
              }
            }

            if (markers.isEmpty) {
              return const Text('No valid MODIS data available');
            } else {
              return FlutterMap(
                options: MapOptions(
                  // bounds: LatLngBounds(LatLng() , LatLng()),
                  zoom: 5.0,
                ),
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
    );
  }
}
