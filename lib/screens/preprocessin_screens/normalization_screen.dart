import 'dart:convert';
import 'package:analysis_app/api/base_url.dart';
import 'package:analysis_app/screens/preprocessin_screens/encoding_screen.dart';
import 'package:analysis_app/screens/previe_data/preview_data.dart';
import 'package:analysis_app/screens/upload_screen.dart';
import 'package:analysis_app/screens/widgets_functions.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NormalizeScreen extends StatefulWidget {
  const NormalizeScreen({super.key});

  @override
  State<NormalizeScreen> createState() => _NormalizeScreenState();
}

class _NormalizeScreenState extends State<NormalizeScreen> {
  final String getNumericalColumnsUrl = "$baseUrl/get-numerical-columns";
  final String normalizeColumnsUrl = "$baseUrl/normalize-columns";

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
    setState(() {
      isLoading = true;
      selectedColumns.clear();
    });

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
    setState(() => isProcessing = true);

    try {
      final response = await http.post(
        Uri.parse(normalizeColumnsUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'columns': selectedColumns.toList()}),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() => normalizationDone = true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Normalization completed")),
          );
        }
        await fetchNumericalColumns();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Normalization failed")),
          );
        }
      }
    } catch (e) {
      debugPrint("Normalization error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("An error occurred")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final noColumns = numericalColumns.isEmpty;
    final showHandleOutlierButton =
        normalizationDone || noColumns || selectedColumns.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Normalize Data",style:TextStyle(fontSize: 20)),
        backgroundColor: Colors.transparent,
        leading: iconButton(context),
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
              color: Color.fromARGB(255, 13, 92, 156),
            ))
          : noColumns
              ? const Center(
                  child: Text(
                    "All numerical data is already normalized.",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: Color.fromARGB(255, 52, 158, 56),
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0,vertical: 8),
                  child: ListView(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50, 
                          border: Border.all(color: Colors.red), 
                          borderRadius:
                              BorderRadius.circular(10), 
                        ),
                        child: const Text(
                          "⚠️ Warning....\nDo not normalize the feature you intend to predict (target variable Y). If the target is normalized, the model will produce inaccurate results, and custom input predictions may fail.",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      const Text(
                        "Select numerical columns to normalize",
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
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
                              normalizationDone = false;
                            });
                          },
                        );
                      }),
                    ],
                  ),
                ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 15, bottom: 8),
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
                          if (showHandleOutlierButton) {
                            navigateToPage(context, EncodeScreen());
                          } else {
                            normalizeSelectedColumns();
                          }
                        },
                  icon: isProcessing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color.fromARGB(255, 13, 92, 156),
                          ),
                        )
                      : const Icon(Icons.arrow_forward),
                  label: Text(
                    showHandleOutlierButton ? "Next, Encoding" : "Apply",
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
      ),
    );
  }
}
