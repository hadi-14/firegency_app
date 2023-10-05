import 'package:autocomplete_textfield/autocomplete_textfield.dart';
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
      900: Color(git),
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

class _LocationScreenState extends State<LocationScreen> {
  late AutoCompleteTextField<String> textField;
  GlobalKey<AutoCompleteTextFieldState<String>> key = GlobalKey();
  String selectedLocation = '';

  // Sample list of locations (you can replace this with your data source)
  List<String> locations = [
    'Aruba, ABW',
    'Afghanistan, AFG',
    'Angola, AGO',
    'Anguilla, AIA',
    'Aland Islands, ALA',
    'Albania, ALB',
    'Andorra, AND',
    'United Arab Emirates, ARE',
    'Argentina, ARG',
    'Armenia, ARM',
    'American Samoa, ASM',
    'Antarctica, ATA',
    'French Southern and Antarctic Lands, ATF',
    'Antigua and Barbuda, ATG',
    'Australia, AUS',
    'Austria, AUT',
    'Azerbaijan, AZE',
    'Burundi, BDI',
    'Belgium, BEL',
    'Benin, BEN',
    'Burkina Faso, BFA',
    'Bangladesh, BGD',
    'Bulgaria, BGR',
    'Bahrain, BHR',
    'Bahamas, BHS',
    'Bosnia and Herzegovina, BIH',
    'Saint-Barthelemy, BLM',
<<<<<<< HEAD
    //'Belarus, BLR',
=======
    'Belarus, BLR',
>>>>>>> 116be9eca83e788fde99ef7aabdc197fba5bdcca
    'Belize, BLZ',
    'Bermuda, BMU',
    'Bolivia, BOL',
    'Brazil, BRA',
    'Barbados, BRB',
    'Brunei Darussalam, BRN',
    'Bhutan, BTN',
    'Botswana, BWA',
    'Central African Republic, CAF',
    'Canada, CAN',
    'Switzerland, CHE',
    'Chile, CHL',
    'China, CHN',
    "Cote d'Ivoire, CIV",
    'Cameroon, CMR',
    'Democratic Republic of the Congo, COD',
    'Republic of Congo, COG',
    'Cook Islands, COK',
    'Colombia, COL',
    'Comoros, COM',
    'Cape Verde, CPV',
    'Costa Rica, CRI',
    'Cuba, CUB',
    'Curacao, CUW',
    'Cayman Islands, CYM',
    'Cyprus, CYP',
    'Czech Republic, CZE',
    'Germany, DEU',
    'Djibouti, DJI',
    'Dominica, DMA',
    'Denmark, DNK',
    'Dominican Republic, DOM',
    'Algeria, DZA',
    'Ecuador, ECU',
    'Egypt, EGY',
    'Eritrea, ERI',
    'Spain, ESP',
    'Estonia, EST',
    'Ethiopia, ETH',
    'Finland, FIN',
    'Fiji, FJI',
    'Falkland Islands, FLK',
    'France, FRA',
    'Faeroe Islands, FRO',
    'Federated States of Micronesia, FSM',
    'Gabon, GAB',
    'United Kingdom, GBR',
    'Georgia, GEO',
    'Guernsey, GGY',
    'Ghana, GHA',
    'Gibraltar, GIB',
    'Guinea, GIN',
    'Guadeloupe, GLP',
    'The Gambia, GMB',
    'Guinea-Bissau, GNB',
    'Equatorial Guinea, GNQ',
    'Greece, GRC',
    'Grenada, GRD',
    'Greenland, GRL',
    'Guatemala, GTM',
    'French Guiana, GUF',
    'Guam, GUM',
    'Guyana, GUY',
    'Hong Kong, HKG',
    'Heard I. and McDonald Islands, HMD',
    'Honduras, HND',
    'Croatia, HRV',
    'Haiti, HTI',
    'Hungary, HUN',
    'Indonesia, IDN',
    'Isle of Man, IMN',
    'India, IND',
    'British Indian Ocean Territory, IOT',
    'Ireland, IRL',
    'Iran, IRN',
    'Iraq, IRQ',
    'Iceland, ISL',
    'Israel, ISR',
    'Italy, ITA',
    'Jamaica, JAM',
    'Jersey, JEY',
    'Jordan, JOR',
    'Japan, JPN',
    'Kazakhstan, KAZ',
    'Kenya, KEN',
    'Kyrgyzstan, KGZ',
    'Cambodia, KHM',
    'Kiribati, KIR',
    'Saint Kitts and Nevis, KNA',
    'Republic of Korea, KOR',
    'Kosovo, KOS',
    'Kuwait, KWT',
    'Lao PDR, LAO',
    'Lebanon, LBN',
    'Liberia, LBR',
    'Libya, LBY',
    'Saint Lucia, LCA',
    'Liechtenstein, LIE',
    'Sri Lanka, LKA',
    'Lesotho, LSO',
    'Lithuania, LTU',
    'Luxembourg, LUX',
    'Latvia, LVA',
    'Macao, MAC',
    'Saint-Martin, MAF',
    'Morocco, MAR',
    'Monaco, MCO',
    'Moldova, MDA',
    'Madagascar, MDG',
    'Maldives, MDV',
    'Mexico, MEX',
    'Marshall Islands, MHL',
    'Macedonia, Former Yugoslav Republic of, MKD',
    'Mali, MLI',
    'Malta, MLT',
    'Myanmar, MMR',
    'Montenegro, MNE',
    'Mongolia, MNG',
    'Northern Mariana Islands, MNP',
    'Mozambique, MOZ',
    'Mauritania, MRT',
    'Montserrat, MSR',
    'Martinique, MTQ',
    'Mauritius, MUS',
    'Malawi, MWI',
    'Malaysia, MYS',
    'Mayotte, MYT',
    'Namibia, NAM',
    'New Caledonia, NCL',
    'Niger, NER',
    'Norfolk Island, NFK',
    'Nigeria, NGA',
    'Nicaragua, NIC',
    'Niue, NIU',
    'Netherlands, NLD',
    'Norway, NOR',
    'Nepal, NPL',
    'Nauru, NRU',
    'New Zealand, NZL',
    'Oman, OMN',
    'Pakistan, PAK',
    'Panama, PAN',
    'Pitcairn Islands, PCN',
    'Peru, PER',
    'Philippines, PHL',
    'Palau, PLW',
    'Papua New Guinea, PNG',
    'Poland, POL',
    'Puerto Rico, PRI',
    'Dem. Rep. Korea, PRK',
    'Portugal, PRT',
    'Paraguay, PRY',
    'Palestine, PSE',
    'French Polynesia, PYF',
    'Qatar, QAT',
    'Reunion, REU',
    'Romania, ROU',
    'Russian Federation, RUS',
    'Rwanda, RWA',
    'Saudi Arabia, SAU',
    'Sudan, SDN',
    'Senegal, SEN',
    'Singapore, SGP',
    'South Georgia and South Sandwich Islands, SGS',
    'Saint Helena, SHN',
    'Svalbard and Jan Mayen, SJM',
    'Solomon Islands, SLB',
    'Sierra Leone, SLE',
    'El Salvador, SLV',
    'San Marino, SMR',
    'Somalia, SOM',
    'Saint Pierre and Miquelon, SPM',
    'Serbia, SRB',
    'South Sudan, SSD',
    'Sao Tome and Principe, STP',
    'Suriname, SUR',
    'Slovakia, SVK',
    'Slovenia, SVN',
    'Sweden, SWE',
    'Swaziland, SWZ',
    'Sint Maarten, SXM',
    'Seychelles, SYC',
    'Syria, SYR',
    'Turks and Caicos Islands, TCA',
    'Chad, TCD',
    'Togo, TGO',
    'Thailand, THA',
    'Tajikistan, TJK',
    'Turkmenistan, TKM',
    'Timor-Leste, TLS',
    'Tonga, TON',
    'Trinidad and Tobago, TTO',
    'Tunisia, TUN',
    'Turkey, TUR',
    'Tuvalu, TUV',
    'Taiwan, TWN',
    'Tanzania, TZA',
    'Uganda, UGA',
    'Ukraine, UKR',
    'United States Minor Outlying Islands, UMI',
    'Uruguay, URY',
    'United States, USA',
    'Uzbekistan, UZB',
    'Vatican, VAT',
    'Saint Vincent and the Grenadines, VCT',
    'Venezuela, VEN',
    'British Virgin Islands, VGB',
    'United States Virgin Islands, VIR',
    'Vietnam, VNM',
    'Vanuatu, VUT',
    'Wallis and Futuna Islands, WLF',
    'Samoa, WSM',
    'Yemen, YEM',
    'South Africa, ZAF',
    'Zambia, ZMB',
    'Zimbabwe, ZWE'
  ];

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
                suggestions: locations,
                decoration: const InputDecoration(
                  hintText: 'e.g. Pakistan, PAK',
                ),
                textChanged: (value) {
                  selectedLocation = value;
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
                    selectedLocation = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to the next page with the selected location
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        InteractiveMap(selectedLocation: selectedLocation),
                  ),
                );
              },
              child: const Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}
