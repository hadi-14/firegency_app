import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:csv/csv.dart';

class InteractiveMap extends StatefulWidget {
  final String selectedLocation;

  InteractiveMap({required this.selectedLocation, Key? key}) : super(key: key);

  @override
  _InteractiveMapState createState() => _InteractiveMapState();
}

class _InteractiveMapState extends State<InteractiveMap> {
  Future<List<List<dynamic>>?>? modisData;
  String apiKey = "ed115b05d57d59b2d98a5c03e40f5ca3";
  String countrycode = "";

  @override
  void initState() {
    super.initState();
    List<String> locationParts = widget.selectedLocation.split(',');
    countrycode = locationParts[1].trim();
    modisData = fetchModisData();
  }

  Future<List<List<dynamic>>?> fetchModisData() async {
    // Fetch MODIS data logic (same as in your code)
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
              // Your existing FutureBuilder code
            },
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Information goes here',
                style: TextStyle(fontSize: 18.0, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}