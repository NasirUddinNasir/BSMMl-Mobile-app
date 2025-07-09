import 'dart:convert';
import 'package:analysis_app/api/base_url.dart';
import 'package:analysis_app/components/download_csv_file.dart';
import 'package:analysis_app/screens/ml_screens/ml_type_selection_screen.dart';
import 'package:analysis_app/screens/upload_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:analysis_app/screens/previe_data/preview_data.dart';
import 'package:analysis_app/screens/widgets_functions.dart';

class HandleOutliersScreen extends StatefulWidget {
  const HandleOutliersScreen({super.key});

  @override
  State<HandleOutliersScreen> createState() => _HandleOutliersScreenState();
}

class _HandleOutliersScreenState extends State<HandleOutliersScreen> {
  final String getOutliersUrl = "$baseUrl/get-outliers";
  final String handleOutliersUrl = "$baseUrl/handle-outliers";

  List<Map<String, dynamic>> outliers = [];
  bool isLoading = true;
  bool isProcessing = false;
  bool outlierHandled = false;

  String selectedMethod = 'iqr';
  final List<String> methods = ['iqr', 'median', 'drop'];

  @override
  void initState() {
    super.initState();
    fetchOutliers();
  }

  Future<void> fetchOutliers() async {
    setState(() {
      isLoading = true;
      outlierHandled = false;
    });
    try {
      final response = await http.get(Uri.parse(getOutliersUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> outlierList = data['outliers'];
        setState(() {
          outliers = List<Map<String, dynamic>>.from(outlierList);
        });
      }
    } catch (e) {
      debugPrint("Error fetching outliers: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> applyOutlierHandling() async {
    setState(() => isProcessing = true);
    try {
      final response = await http.post(
        Uri.parse(handleOutliersUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'method': selectedMethod}),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() => outlierHandled = true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Outliers handled using $selectedMethod method")),
        );
        await fetchOutliers();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to handle outliers")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      debugPrint("Outlier handling error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An error occurred")),
      );
    } finally {
      setState(() => isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final noOutliers = outliers.isEmpty;
    final proceedToNext = noOutliers || outlierHandled;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Handle Outliers"),
        backgroundColor: Colors.transparent,
        leading: iconButton(context),
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : noOutliers
              ? Center(
                  child: Container(
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "🎉 Good News!",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 0, 100, 0),
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Outliers handled or not found in your dataset. You can safely proceed to the next step.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView(
                    children: [
                      const Text(
                        "Select method to handle outliers",
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: selectedMethod,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        ),
                        items: methods.map((method) {
                          return DropdownMenuItem(
                            value: method,
                            child: Text(method.toUpperCase()),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => selectedMethod = value);
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Outlier information",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: outliers[0]
                              .keys
                              .map((key) => DataColumn(label: Text(key)))
                              .toList(),
                          rows: outliers.map((row) {
                            return DataRow(
                              cells: row.values
                                  .map((value) =>
                                      DataCell(Text(value.toString())))
                                  .toList(),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
      bottomNavigationBar: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Download your cleaned data ",
                    style: TextStyle(
                      fontSize: 15,
                    )),
                GestureDetector(
                  onTap: () => downloadCleanedCSV(context),
                  child: const Text(
                    " here",
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                      fontSize: 17,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8, top: 8),
              child: Row(
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
                      onPressed: isProcessing
                          ? null
                          : () {
                              if (proceedToNext) {
                                navigateToPage(
                                    context, MLTypeSelectionScreen());
                              } else {
                                applyOutlierHandling();
                              }
                            },
                      icon: isProcessing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.blue,
                              ),
                            )
                          : const Icon(Icons.arrow_forward),
                      label: Text(
                        proceedToNext ? "Next" : "Apply Method",
                        style: const TextStyle(fontSize: 18),
                      ),
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
          ],
        ),
      ),
    );
  }
}
