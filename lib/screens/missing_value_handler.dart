import 'dart:convert';
import 'package:analysis_app/screens/clustering/cluster_screen.dart';
import 'package:analysis_app/screens/prediction/prediction_screen.dart';
import 'package:analysis_app/screens/widgets_functions.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:analysis_app/api/handle_overview.dart';
import 'package:analysis_app/global_state.dart';

class HandleMissingValuesScreen extends StatefulWidget {
  const HandleMissingValuesScreen({super.key});

  @override
  State<HandleMissingValuesScreen> createState() =>
      HandleMissingValuesScreenState();
}

class HandleMissingValuesScreenState extends State<HandleMissingValuesScreen> {
  final String baseUrl = 'http://10.0.2.2:8000';

  List<dynamic> missingSummary = [];
  Map<String, Map<String, dynamic>> selectedStrategies = {};
  List<dynamic> cleanedPreview = [];
  bool isLoading = true;

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
        body: jsonEncode({"data": []}),
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
        body: jsonEncode(selectedStrategies),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        setState(() {
          cleanedPreview = result['preview'];
        });
        showSnack('Data cleaned successfully!');
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
        title: const Text('Handle Missing Values',
            style: TextStyle(fontWeight: FontWeight.w400)),
        backgroundColor: Colors.transparent,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.blue.shade600))
          : Column(
              children: [
                if (missingSummary.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Your data is all set. No missing values found.',
                        style:
                            TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                          margin:
                              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: missingSummary.isEmpty ? null : applyHandling,
                        icon: const Icon(Icons.cleaning_services,
                            color: Colors.white),
                        label: const Text('Clean Data' , style: TextStyle(fontSize: 17)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        onPressed: (missingSummary.isEmpty ||
                                cleanedPreview.isNotEmpty)
                            ? () {
                                handleOverview(context);
                                if (GlobalStore().selectedCatagory =='Make Predictions') {
                                  navigateToPage(context, PredictionScreen());
                                } else {
                                  navigateToPage(context, ClusterScreen());
                                }
                              }
                            : null,
                        icon: const Icon(Icons.analytics, color: Colors.white),
                        label: const Text('Explore Data', style: TextStyle(fontSize: 17),),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 11, 95, 163),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                if (cleanedPreview.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Cleaned Data Preview:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800)),
                  ),
                if (cleanedPreview.isNotEmpty)
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SingleChildScrollView(
                          child: DataTable(
                            headingRowColor:
                                WidgetStateProperty.all(Colors.blue.shade100),
                            columns: cleanedPreview.isNotEmpty
                                ? (cleanedPreview[0] as Map<String, dynamic>)
                                    .keys
                                    .map((key) =>
                                        DataColumn(label: Text(key)))
                                    .toList()
                                : [],
                            rows: cleanedPreview.map((row) {
                              final rowMap = row as Map<String, dynamic>;
                              return DataRow(
                                cells: rowMap.values
                                    .map((value) =>
                                        DataCell(Text(value.toString())))
                                    .toList(),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
