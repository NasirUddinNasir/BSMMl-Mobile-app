import 'dart:convert';
import 'package:analysis_app/api/base_url.dart';
import 'package:analysis_app/screens/previe_data/preview_data.dart';
import 'package:analysis_app/screens/widgets_functions.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:analysis_app/screens/preprocessin_screens/normalization_screen.dart';

class EncodeScreen extends StatefulWidget {
  const EncodeScreen({super.key});

  @override
  State<EncodeScreen> createState() => _EncodeScreenState();
}

class _EncodeScreenState extends State<EncodeScreen> {
  final String getColumnsUrl = "$baseUrl/get-categorical-columns";
  final String applyEncodingUrl = "$baseUrl/encode-columns";

  Map<String, String> categoricalColumns = {};
  Set<String> selectedColumns = {};
  bool isLoading = true;
  bool isProcessing = false;
  bool encodingDone = false;

  @override
  void initState() {
    super.initState();
    fetchCategoricalColumns();
  }

  Future<void> fetchCategoricalColumns() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse(getColumnsUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final Map<String, dynamic> columns = data['categorical_columns'];
        setState(() {
          categoricalColumns = columns.map((k, v) => MapEntry(k, v.toString()));
        });
      }
    } catch (e) {
      debugPrint("Error fetching columns: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> applyEncoding() async {
    if (selectedColumns.isEmpty) {
      navigateToPage(context, DataPreviewScreen(buttontext: "Next, Normalize data", nextScreen: NormalizeScreen()));
      return;
    }

    setState(() => isProcessing = true);

    try {
      final response = await http.post(
        Uri.parse(applyEncodingUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'selected_columns': selectedColumns.toList()}),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() => encodingDone = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Encoding completed")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Encoding failed")),
        );
      }
    } catch (e) {
      debugPrint("Encoding error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An error occurred")),
      );
    } finally {
      setState(() => isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final noColumns = categoricalColumns.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Encode Categorical Values",
          style: TextStyle(fontSize: 20),
        ),
        backgroundColor: Colors.transparent,
        leading: iconButton(context),
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : noColumns
              ? const Center(child: Text("Data is all set,no encoding needed"))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView(
                    children: [
                      const Text(
                        "Select columns to apply one-hot-encoding",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...categoricalColumns.keys.map((col) {
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
                      if (encodingDone || noColumns) {
                        navigateToPage(context, DataPreviewScreen(buttontext: "Next, Normalize data", nextScreen: NormalizeScreen()));
                      } else {
                        applyEncoding();
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
                      (encodingDone || noColumns)
                          ? "Preview data"
                          : "Apply Encoding",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
