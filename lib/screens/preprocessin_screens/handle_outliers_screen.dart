import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:analysis_app/screens/preprocessin_screens/feature_selection_screen.dart';
import 'package:analysis_app/screens/previe_data/preview_data.dart';
import 'package:analysis_app/screens/widgets_functions.dart';

class HandleOutliersScreen extends StatefulWidget {
  const HandleOutliersScreen({super.key});

  @override
  State<HandleOutliersScreen> createState() => _HandleOutliersScreenState();
}

class _HandleOutliersScreenState extends State<HandleOutliersScreen> {
  final String getOutliersUrl = "http://10.0.2.2:8000/get-outliers";
  final String handleOutliersUrl = "http://10.0.2.2:8000/handle-outliers";

  List<Map<String, dynamic>> outliers = [];
  bool isLoading = true;
  bool isProcessing = false;
  bool outlierHandled = false;

  String selectedMethod = 'iqr';
  final List<String> methods = ['iqr', 'clipping', 'median', 'drop'];

  @override
  void initState() {
    super.initState();
    fetchOutliers();
  }

  Future<void> fetchOutliers() async {
    setState(() => isLoading = true);
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
          SnackBar(content: Text("Outliers handled using $selectedMethod method")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to handle outliers")),
        );
      }
    } catch (e) {
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
              ? const Center(child: Text("No outliers detected"))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView(
                    children: [
                      const Text(
                        "Select method to handle outliers",
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
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
                          columns: outliers[0].keys.map((key) => DataColumn(label: Text(key))).toList(),
                          rows: outliers.map((row) {
                            return DataRow(
                              cells: row.values.map((value) => DataCell(Text(value.toString()))).toList(),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: isProcessing
                  ? null
                  : () {
                      if (outlierHandled || noOutliers) {
                        navigateToPage(context, DataPreviewScreen(buttontext: "Next, feature selection", nextScreen: FeatureSelectionScreen()));
                      } else {
                        applyOutlierHandling();
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 11, 95, 163),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: isProcessing
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      (outlierHandled || noOutliers) ? "Preview Data" : "Apply Method",
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
