import 'dart:convert';
import 'package:analysis_app/screens/preprocessin_screens/handle_outliers_screen.dart';
import 'package:analysis_app/screens/previe_data/preview_data.dart';
import 'package:analysis_app/screens/widgets_functions.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NormalizeScreen extends StatefulWidget {
  const NormalizeScreen({super.key});

  @override
  State<NormalizeScreen> createState() => _NormalizeScreenState();
}

class _NormalizeScreenState extends State<NormalizeScreen> {
  final String getNumericalColumnsUrl = "http://10.0.2.2:8000/get-numerical-columns";
  final String normalizeColumnsUrl = "http://10.0.2.2:8000/normalize-columns";

  Map<String, String> numericalColumns = {};
  Set<String> selectedColumns = {};
  bool isLoading = true;
  bool isProcessing = false;
  bool normalizationDone = false;

  @override
  void initState() {
    super.initState();
    fetchNumericalColumns();
  }

  Future<void> fetchNumericalColumns() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse(getNumericalColumnsUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final Map<String, dynamic> columns = data['numerical_columns'];
        setState(() {
          numericalColumns = columns.map((k, v) => MapEntry(k, v.toString()));
        });
      }
    } catch (e) {
      debugPrint("Error fetching numerical columns: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> normalizeSelectedColumns() async {
    if (selectedColumns.isEmpty) {
       navigateToPage(context, DataPreviewScreen(buttontext: "Next, handle outliers", nextScreen: HandleOutliersScreen()));
      return;
    }

    setState(() => isProcessing = true);
    try {
      final response = await http.post(
        Uri.parse(normalizeColumnsUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'columns': selectedColumns.toList()}),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() => normalizationDone = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Normalization completed")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Normalization failed")),
        );
      }
    } catch (e) {
      debugPrint("Normalization error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An error occurred")),
      );
    } finally {
      setState(() => isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final noColumns = numericalColumns.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Normalize Numerical Data"),
        backgroundColor: Colors.transparent,
        leading: iconButton(context),
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : noColumns
              ? const Center(child: Text("All numerical data is normalized" ,style:TextStyle(fontSize: 20),))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView(
                    children: [
                      const Text(
                        "Select numerical columns to normalize",
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      ...numericalColumns.keys.map((col) {
                        return CheckboxListTile(
                          title: Text(col),
                          value: selectedColumns.contains(col),
                          onChanged: (selected) {
                            setState(() {
                              if (selected == true) {
                                selectedColumns.add(col);
                              } else {
                                selectedColumns.remove(col);
                              }
                            });
                          },
                        );
                      }),
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
                      if (normalizationDone || noColumns) {
                        navigateToPage(context, DataPreviewScreen(buttontext: "Next, handle outliers", nextScreen: HandleOutliersScreen()));
                      } else {
                        normalizeSelectedColumns();
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
                      (normalizationDone || noColumns)
                          ? "Preview Data"
                          : "Apply Normalization",
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
