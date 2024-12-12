import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ongkir Apps',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const OngkirApps(),
    );
  }
}

class OngkirApps extends StatefulWidget {
  const OngkirApps({super.key});

  @override
  _OngkirAppsState createState() => _OngkirAppsState();
}

class _OngkirAppsState extends State<OngkirApps> {
  final TextEditingController weightController = TextEditingController();

  String selectedExpedition = "jne";
  String? selectedOriginProvinceId;
  String? selectedOriginCity;
  String? selectedDestinationProvinceId;
  String? selectedDestinationCity;

  List<Map<String, String>> originProvinces = [];
  List<Map<String, String>> destinationProvinces = [];
  List<Map<String, String>> originCities = [];
  List<Map<String, String>> destinationCities = [];
  final List<String> expeditions = ["jne", "pos", "tiki"];

  List<Map<String, dynamic>> costs = [];
  bool isLoading = false;
  bool isOriginProvincesLoading = true;
  bool isOriginCitiesLoading = false;
  bool isDestinationProvincesLoading = true;
  bool isDestinationCitiesLoading = false;

  @override
  void initState() {
    super.initState();
    fetchOriginProvinces();
    fetchDestinationProvinces();
  }

  Future<void> fetchOriginProvinces() async {
    try {
      final response = await http
          .get(Uri.parse('https://sp.sandalmely.com/resi/config_province.php'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          originProvinces = data
              .map((province) => {
                    'id': province['province_id'].toString(),
                    'name': province['province'].toString()
                  })
              .toList();
          selectedOriginProvinceId =
              originProvinces.isNotEmpty ? originProvinces.first['id'] : null;
          isOriginProvincesLoading = false;
        });
      } else {
        throw Exception("Failed to load provinces");
      }
    } catch (e) {
      print("Error fetching origin provinces: $e");
      setState(() {
        isOriginProvincesLoading = false;
      });
    }
  }

  Future<void> fetchDestinationProvinces() async {
    try {
      final response = await http
          .get(Uri.parse('https://sp.sandalmely.com/resi/config_province.php'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          destinationProvinces = data
              .map((province) => {
                    'id': province['province_id'].toString(),
                    'name': province['province'].toString()
                  })
              .toList();
          selectedDestinationProvinceId = destinationProvinces.isNotEmpty
              ? destinationProvinces.first['id']
              : null;
          isDestinationProvincesLoading = false;
        });
      } else {
        throw Exception("Failed to load provinces");
      }
    } catch (e) {
      print("Error fetching destination provinces: $e");
      setState(() {
        isDestinationProvincesLoading = false;
      });
    }
  }

  Future<void> fetchOriginCities(String provinceId) async {
    setState(() {
      isOriginCitiesLoading = true;
      originCities = [];
      selectedOriginCity = null;
    });

    try {
      final url =
          'https://sp.sandalmely.com/resi/config_city.php?province_id=$provinceId';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          originCities = data
              .map((city) => {
                    'id': city['city_id'].toString(),
                    'name': city['city_name'].toString()
                  })
              .toList();
          selectedOriginCity =
              originCities.isNotEmpty ? originCities.first['id'] : null;
        });
      } else {
        throw Exception("Failed to load origin cities");
      }
    } catch (e) {
      print("Error fetching origin cities: $e");
    } finally {
      setState(() {
        isOriginCitiesLoading = false;
      });
    }
  }

  Future<void> fetchDestinationCities(String provinceId) async {
    setState(() {
      isDestinationCitiesLoading = true;
      destinationCities = [];
      selectedDestinationCity = null;
    });

    try {
      final url =
          'https://sp.sandalmely.com/resi/config_city.php?province_id=$provinceId';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          destinationCities = data
              .map((city) => {
                    'id': city['city_id'].toString(),
                    'name': city['city_name'].toString()
                  })
              .toList();
          selectedDestinationCity = destinationCities.isNotEmpty
              ? destinationCities.first['id']
              : null;
        });
      } else {
        throw Exception("Failed to load destination cities");
      }
    } catch (e) {
      print("Error fetching destination cities: $e");
    } finally {
      setState(() {
        isDestinationCitiesLoading = false;
      });
    }
  }

  Future<Map<String, dynamic>> fetchCost({
    required String courier,
    required String origin,
    required String destination,
    required int weight,
  }) async {
    const url =
        'https://sp.sandalmely.com/resi/config.php'; // Replace with your actual endpoint
    final response = await http.post(
      Uri.parse(url),
      body: {
        'courier': courier,
        'origin': origin,
        'destination': destination,
        'weight': weight.toString(),
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Failed to fetch costs");
    }
  }

  void calculatePostage() async {
    if (selectedOriginCity == null ||
        selectedDestinationCity == null ||
        weightController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields.")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('https://sp.sandalmely.com/resi/config.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'courier': selectedExpedition,
          'origin': selectedOriginCity!,
          'destination': selectedDestinationCity!,
          'weight': weightController.text,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['rajaongkir']?['status']?['code'] == 200) {
          setState(() {
            costs = List<Map<String, dynamic>>.from(
                data['rajaongkir']['results']?.first['costs'] ?? []);
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(data['rajaongkir']?['status']?['description'] ??
                    "Unknown error")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "Failed to fetch costs. Status code: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred: $e")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget buildDropdown({
    required String label,
    required String? value,
    required List<Map<String, String>> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items
          .map((item) => DropdownMenuItem(
                value: item['id'],
                child: Text(item['name']!),
              ))
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calculator Postage')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Expedition and Weight Fields
            Row(
              children: [
                Expanded(
                  child: buildDropdown(
                    label: "Expedition",
                    value: selectedExpedition,
                    items: expeditions
                        .map((exp) => {'id': exp, 'name': exp})
                        .toList(),
                    onChanged: (value) => setState(() {
                      selectedExpedition = value!;
                    }),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: buildTextField(
                    label: "Weight (grams)",
                    controller: weightController,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Origin Section
            const Padding(
              padding: EdgeInsets.only(top: 10),
              child:
                  Text('Origin', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                return Row(
                  children: [
                    Flexible(
                      flex: 1,
                      child: isOriginProvincesLoading
                          ? const CircularProgressIndicator()
                          : DropdownButton<String>(
                              isExpanded: true,
                              value: selectedOriginProvinceId,
                              items: originProvinces
                                  .map((province) => DropdownMenuItem(
                                        value: province['id'],
                                        child: Text(province['name']!),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedOriginProvinceId = value;
                                });
                                if (value != null) {
                                  fetchOriginCities(value);
                                }
                              },
                            ),
                    ),
                    const SizedBox(width: 16),
                    Flexible(
                      flex: 1,
                      child: isOriginCitiesLoading
                          ? const CircularProgressIndicator()
                          : DropdownButton<String>(
                              isExpanded: true,
                              value: selectedOriginCity,
                              items: originCities
                                  .map((city) => DropdownMenuItem(
                                        value: city['id'], // Store city_id
                                        child: Text(
                                            city['name']!), // Display city_name
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedOriginCity = value;
                                });
                              },
                            ),
                    ),
                  ],
                );
              },
            ),

            // Destination Section
            const Padding(
              padding: EdgeInsets.only(top: 10),
              child: Text('Destination',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                return Row(
                  children: [
                    Flexible(
                      flex: 1,
                      child: isDestinationProvincesLoading
                          ? const CircularProgressIndicator()
                          : DropdownButton<String>(
                              isExpanded: true,
                              value: selectedDestinationProvinceId,
                              items: destinationProvinces
                                  .map((province) => DropdownMenuItem(
                                        value: province['id'],
                                        child: Text(province['name']!),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedDestinationProvinceId = value;
                                });
                                if (value != null) {
                                  fetchDestinationCities(value);
                                }
                              },
                            ),
                    ),
                    const SizedBox(width: 16),
                    Flexible(
                      flex: 1,
                      child: isDestinationCitiesLoading
                          ? const CircularProgressIndicator()
                          : DropdownButton<String>(
                              isExpanded: true,
                              value: selectedDestinationCity,
                              items: destinationCities
                                  .map((city) => DropdownMenuItem<String>(
                                        value: city[
                                            'id'], // Use the ID as the value
                                        child: Text(city['name']!),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedDestinationCity = value;
                                });
                              },
                            ),
                    ),
                  ],
                );
              },
            ),

            // Calculate Button
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: calculatePostage,
                child: const Text("Calculate"),
              ),
            ),

            const SizedBox(height: 16),
            // Costs List
            if (costs.isEmpty)
              const Center(child: Text("No costs available."))
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: costs.length,
                itemBuilder: (context, index) {
                  final cost = costs[index];
                  final service = cost['service'] ?? "Unknown";
                  final description = cost['description'] ?? "No description";
                  final price = cost['cost'][0]['value'] ?? 0;
                  final etd = cost['cost'][0]['etd'] ?? "N/A";

                  // Format the price with thousand separators
                  final formattedPrice = NumberFormat.currency(
                    locale: 'id_ID', // For Indonesian locale
                    symbol: '', // Remove currency symbol if not needed
                    decimalDigits: 0, // No decimals
                  ).format(price);

                  return Card(
                    child: ListTile(
                      title: Text("$service ($description)"),
                      subtitle: Text("ETD: $etd days"),
                      trailing: Text("Rp $formattedPrice"),
                    ),
                  );
                },
              )
          ],
        ),
      ),
    );
  }
}
