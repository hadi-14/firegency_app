import 'dart:convert';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/services.dart';
import 'map.dart';
import 'sidebar.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const FiregencyApp());
}

class FiregencyApp extends StatelessWidget {
  const FiregencyApp({super.key});
  final customPrimaryColor = const MaterialColor(
    0xFFFF5A00, // Replace with your desired color code
    <int, Color>{
      50: Color(0xFFFF5A00),
      100: Color(0xFFFF5A00),
      200: Color(0xFFFF5A00),
      300: Color(0xFFFF5A00),
      400: Color(0xFFFF5A00),
      500: Color(0xFFFF5A00), // Same color code as 300
      600: Color(0xFFFF5A00),
      700: Color(0xFFFF5A00),
      800: Color(0xFFFF5A00),
      900: Color(0xFFFF5A00),
    },
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firegency',
      theme: ThemeData(
          colorScheme: ColorScheme.fromSwatch(
              primarySwatch: customPrimaryColor,
              cardColor: Color(0xFFFF5A00),
              backgroundColor: Colors.red,
              brightness: Brightness.dark)),
      home: const LocationScreen(),
    );
  }
}

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class CountriesData {
  final String name;
  final List<double> apis;

  CountriesData(this.name, this.apis);
}

class _LocationScreenState extends State<LocationScreen> {
  late AutoCompleteTextField<String> textField;
  GlobalKey<AutoCompleteTextFieldState<String>> key = GlobalKey();
  Map<String, dynamic> selectedLocation = {"": ""};
  String selectedCountry = "e.g. Pakistan";
  TextEditingController inputController =
      TextEditingController(); // Controller for the user's input
  List<String> suggestions = []; // List to store autocomplete suggestions

  List<Map<String, dynamic>> countries = [];

  Future<List<Map<String, dynamic>>> loadCountries() async {
    final String countriesData =
        await rootBundle.loadString('assets/countries.json');
    final List<dynamic> jsonCountries = json.decode(countriesData);
    return jsonCountries.cast<Map<String, dynamic>>();
}

  Map<String, dynamic> getCountryDataByName(String name) {
    final countryData = countries.firstWhere(
        (country) => country['name'] == name,
        orElse: () => {"": ""});
    return countryData;
  }

  // Sample list of locations (you can replace this with your data source)
  List<Map<String, dynamic>> locations = [];
  List<String> countryNames = [];

  @override
  void initState() {
    super.initState();
    loadCountries().then((loadedCountries) {
      setState(() {
        locations = loadedCountries;
        // countryNames = countries.map<String>((country) => country['name'] as String).toList();
        for (var country in locations) {
          if (country.containsKey('name')) {
            countryNames.add(country['name'] as String);
          }
        }

        print(countryNames);
      });
    });
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Enter your Country:',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: textField = AutoCompleteTextField<String>(
                key: key,
                suggestions: countryNames,
                decoration: const InputDecoration(
                  hintText: 'e.g. Pakistan',
                ),
                textChanged: (value) {
                  selectedLocation = getCountryDataByName(value);
                },
                clearOnSubmit: false,
                itemBuilder: (context, suggestion) => ListTile(
                  title: Text(suggestion),
                ),
                itemSorter: (a, b) => a.compareTo(b),
                itemFilter: (suggestion, query) =>
                    suggestion.toLowerCase().startsWith(query.toLowerCase()),
                itemSubmitted: (value) {
                  setState(() {
                    selectedLocation = getCountryDataByName(value);
                  });
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Find the selected location based on user input
                selectedLocation = getCountryDataByName(selectedCountry);
                if (selectedLocation.isNotEmpty) {
                  // Navigate to the next page with the selected location
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          InteractiveMap(selectedLocation: selectedLocation),
                    ),
                  );
                } else {
                  // Handle invalid input or show an error message
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Invalid Input'),
                        content:
                            const Text('Please enter a valid country name.'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: const Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}
