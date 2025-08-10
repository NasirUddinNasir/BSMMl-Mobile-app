import 'dart:convert';
import 'package:bsmml/global_state.dart';
import 'package:bsmml/screens/upload_screen.dart';
import 'package:bsmml/components/widgets_functions.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:bsmml/screens/preprocessin_screens/duplicate_handler.dart';
import 'package:bsmml/api/base_url.dart';
import 'package:bsmml/screens/previe_data/preview_data.dart';

class HandleMissingValuesScreen extends StatefulWidget {
  const HandleMissingValuesScreen({super.key});

  @override
  State<HandleMissingValuesScreen> createState() =>
      HandleMissingValuesScreenState();
}

class HandleMissingValuesScreenState extends State<HandleMissingValuesScreen> {
  List<dynamic> missingSummary = [];
  Map<String, Map<String, dynamic>> selectedStrategies = {};
  bool isLoading = true;
  String? message;

  @override
  void initState() {
    super.initState();
    fetchMissingInfo();
  }

  Future<void> fetchMissingInfo() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/missing-info'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'uid': GlobalStore().uid}),
      );

      if (!mounted) return;
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          missingSummary = data;
          if (missingSummary.isNotEmpty) {
            for (var item in missingSummary) {
              final column = item['column'];
              selectedStrategies[column] = {
                'method': item['suggested_methods'][0],
                'value': null,
              };
            }
          }
          isLoading = false;
        });
      } else {
        showSnack('Failed to load missing value info');
      }
    } catch (e) {
      if (!mounted) return;
      showSnack('Error: $e');
    }
  }

  Future<void> applyHandling() async {
    if (missingSummary.isEmpty) {
      showSnack('No missing values. You can now explore the data!');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/handle-missing-values'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'uid': GlobalStore().uid,
          'strategies': selectedStrategies,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        setState(() {
         message = result['message'];
        });

        showSnack(message!);

        await fetchMissingInfo();
      } else {
        showSnack('Failed to clean data');
      }
    } catch (e) {
      if (!mounted) return;
      showSnack('Error: $e');
    }
  }

  void showSnack(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: iconButton(context),
        title:
            const Text('Handle Missing Values', style: TextStyle(fontSize: 20)),
        backgroundColor: Colors.transparent,
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(color: Colors.blue.shade600))
          : Column(
              children: [
                if (missingSummary.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.shade300),
                      ),
                      child: const Text(
                        '🎉 Good News!\n\nYour data is all set. No more missing values.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          color: Color.fromARGB(255, 45, 148, 49),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                if (missingSummary.isNotEmpty)
                  Expanded(
                    child: ListView.builder(
                      itemCount: missingSummary.length,
                      itemBuilder: (context, index) {
                        final item = missingSummary[index];
                        final column = item['column'];
                        final dtype = item['dtype'];
                        final missing = item['missing_count'];
                        final methods =
                            List<String>.from(item['suggested_methods']);

                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          color: Colors.white,
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('$column ($dtype, missing: $missing)',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade800)),
                                const SizedBox(height: 8),
                                DropdownButton<String>(
                                  value: selectedStrategies[column]!['method'],
                                  isExpanded: true,
                                  dropdownColor: Colors.blue.shade50,
                                  items: methods.map((method) {
                                    return DropdownMenuItem(
                                      value: method,
                                      child: Text(method),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedStrategies[column]!['method'] =
                                          value!;
                                    });
                                  },
                                ),
                                if (selectedStrategies[column]!['method'] ==
                                    'custom_value')
                                  TextField(
                                    decoration: InputDecoration(
                                      labelText: 'Custom value',
                                      border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.blue.shade300)),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.blue.shade600)),
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedStrategies[column]!['value'] =
                                            value;
                                      });
                                    },
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ElevatedButton.icon(
                    onPressed: missingSummary.isEmpty ? null : applyHandling,
                    icon: const Icon(Icons.cleaning_services,
                        color: Colors.white),
                    label: const Text('Clean Data',
                        style: TextStyle(fontSize: 17)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 15, bottom: 17),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 60,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  navigateToPage(context, DataPreviewScreen());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  padding: EdgeInsets.zero,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.dataset,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: (missingSummary.isEmpty )
                    ? () {
                        navigateToPage(context, RemoveDuplicatesScreen());
                      }
                    : null,
                icon: Icon(
                  Icons.arrow_forward,
                  size: 22,
                ),
                label: const Text('Duplicates', style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 11, 95, 163),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.home),
              color: const Color.fromARGB(255, 17, 57, 143),
              iconSize: 45,
              onPressed: () => navigateToPage(context, CSVUploader()),
            ),
          ],
        ),
      ),
    );
  }
}
