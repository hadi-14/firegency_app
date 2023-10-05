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
  String todayDate = (DateTime.now()).toString().split(' ')[0];
  // Fetch and parse MODIS data
  Future<List<List<dynamic>>?> fetchModisData() async {
    String previousDate =
        (DateTime.now().subtract(Duration(days: 1))).toString().split(' ')[0];
    String todayDate = (DateTime.now()).toString().split(' ')[0];

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
    final response = await http
        .get(Uri.parse('https://firms.modaps.eosdis.nasa.gov/api/countries/'));

    if (response.statusCode == 200) {
      // print(response.body);
      final csvData = const CsvToListConverter()
          .convert(response.body, eol: "\n", textDelimiter: ";");

      for (final row in csvData) {
        final abreviation = row[1] as String;
        final extent = row[3] as String;
        print(extent);
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
    // print(extant);
    // LatLngBounds(LatLng() , LatLng())
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firegency'),
        leading: Image.asset(
          'assets/logo.png',
          width: 3,
          height: 3,
        ),
      ),
      body: Stack(
        children: <Widget>[
          FutureBuilder<List<List<dynamic>>?>(
            future: modisData,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No MODIS data available'));
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
                            color:
                                Colors.red, // You can customize the marker icon
                          ),
                        ),
                      );
                    }
                  }
                } // Logic to create markers from modisData

                if (markers.isEmpty) {
                  return Center(child: Text('No valid MODIS data available'));
                } else {
                  return FlutterMap(
                    options: MapOptions(
                        zoom: 5.0,
                        bounds: LatLngBounds(
                            LatLng(37.0489709880002, 77.0544835410001),
                            LatLng(23.8443787030001, 60.6945254580001))),
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
                color: Color(0xFFFF5A00).withOpacity(0.9),
                borderRadius: BorderRadius.only(
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
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              padding: EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left side text
                  Expanded(
                    child: Text(
                      widget.selectedLocation,
                      style: TextStyle(
                          fontSize: 20.0,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  // Right side text (today's date)
                  Text(
                    todayDate,
                    style: TextStyle(
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
