import 'dart:convert';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/services.dart';
import 'map.dart';
import 'sidebar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
          cardColor: const Color(0xFFFF5A00),
          backgroundColor: Colors.red,
          brightness: Brightness.dark,
        ),
      ),
      home: const LocationScreen(),
    );
  }
}

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  late AutoCompleteTextField<String> textField;
  GlobalKey<AutoCompleteTextFieldState<String>> key = GlobalKey();
  Map<String, dynamic> selectedLocation = {};
  TextEditingController inputController =
      TextEditingController(); // Controller for the user's input
  List<String> suggestions = []; // List to store autocomplete suggestions
  List<Map<String, dynamic>> countries = [];
  DateTime selectedDate = DateTime.now();

  Future<List<Map<String, dynamic>>> loadCountries() async {
    final String countriesData =
        await rootBundle.loadString('assets/countries.json');
    final List<dynamic> jsonCountries = json.decode(countriesData);
    return jsonCountries.cast<Map<String, dynamic>>();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Map<String, dynamic> getCountryDataByName(String name) {
    final countryData = countries.firstWhere(
      (country) => country['name'].toLowerCase() == name.toLowerCase(),
      orElse: () => {},
    );
    return countryData;
  }

  List<String> countryNames = [];

  @override
  void initState() {
    super.initState();
    loadCountries().then((loadedCountries) {
      setState(() {
        countries = loadedCountries;
        for (var country in countries) {
          if (country.containsKey('name')) {
            countryNames.add(country['name'] as String);
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('dd/MM/yyyy').format(selectedDate);

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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text(
              'Enter your Country:',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: AutoCompleteTextField<String>(
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: GestureDetector(
                onTap: () => _selectDate(context), // Open date picker on tap
                child: InputDecorator(
                  decoration: const InputDecoration(
                    hintText: 'Select a Date', // Show hint text
                  ),
                  child: Text(
                    formattedDate, // Display selected date
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      if (selectedLocation.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => InteractiveMap(
                                selectedLocation: selectedLocation,
                                selectedDate: selectedDate),
                          ),
                        );
                      } else {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Invalid Input'),
                              content: const Text(
                                  'Please enter a valid country name.'),
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
                        const SizedBox(height: 50);
                      }
                    },
                    child: const Text(
                      'Next',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: 'Dont forget to click ',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey),
                        ),
                        WidgetSpan(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 4.0), // Adjust padding as needed
                            child: Icon(
                              Icons.info_rounded,
                              size:
                                  20, // You can adjust the size of the icon as needed
                              color: Color.fromARGB(255, 0, 225,
                                  8), // You can change the color of the icon
                            ),
                          ),
                        ),
                        TextSpan(
                          text:
                              ' icon to see fun facts and more info regarding fires',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
