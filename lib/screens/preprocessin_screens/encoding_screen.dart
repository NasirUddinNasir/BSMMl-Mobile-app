import 'dart:convert';
import 'package:bsmml/api/base_url.dart';
import 'package:bsmml/components/download_csv_file.dart';
import 'package:bsmml/global_state.dart';
import 'package:bsmml/screens/ml_screens/ml_type_selection_screen.dart';
import 'package:bsmml/screens/previe_data/preview_data.dart';
import 'package:bsmml/screens/upload_screen.dart';
import 'package:bsmml/components/widgets_functions.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
  String selectedEncodingMethod = "onehot";
  bool isLoading = true;
  bool isProcessing = false;
  bool encodingDone = false;

  @override
  void initState() {
    super.initState();
    fetchCategoricalColumns();
  }

  Future<void> fetchCategoricalColumns() async {
    setState(() {
      isLoading = true;
      selectedColumns.clear();
    });
    try {
      final response = await http.post(
        Uri.parse(getColumnsUrl),
        body: jsonEncode({
          'uid': GlobalStore().uid
        })
        );
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
    setState(() => isProcessing = true);

    try {
      final response = await http.post(
        Uri.parse(applyEncodingUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'uid': GlobalStore().uid,
          'selected_columns': selectedColumns.toList(),
          'encoding_method': selectedEncodingMethod,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Encoding completed")),
        );
        setState(() {
          encodingDone = true;
        });
        await fetchCategoricalColumns();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Encoding failed")),
        );
      }
    } catch (e) {
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
    final bool noColumnsLeft = categoricalColumns.isEmpty;
    final bool shouldNormalize =
        selectedColumns.isEmpty || (encodingDone || categoricalColumns.isEmpty);

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
          : Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: noColumnsLeft
                  ? const Center(
                      child: Text(
                        "🎉 Good News!\n\nAll categorical columns are encoded.",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          color: Color.fromARGB(255, 52, 158, 56),
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            border: Border.all(color: Colors.red),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            "⚠️ Warning...\nAlways use label encoding for the target feature (Y). If not encoded with label encoder, the model will be trained incorrectly and custom predictions will fail.",
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Select encoding method",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, ),
                          decoration: BoxDecoration(
                            border:
                                Border.all(color: Colors.grey), 
                            borderRadius:
                                BorderRadius.circular(8), 
                          ),
                          child: DropdownButton<String>(
                            value: selectedEncodingMethod,
                            onChanged: (value) {
                              setState(() {
                                selectedEncodingMethod = value!;
                              });
                            },
                            items: const [
                              DropdownMenuItem(
                                value: 'onehot',
                                child: Text('One-Hot Encoding'),
                              ),
                              DropdownMenuItem(
                                value: 'label',
                                child: Text('Label Encoding'),
                              ),
                            ],
                            underline: SizedBox(), // Removes default underline
                            isExpanded:
                                true, // Optional: makes dropdown fill width
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Select columns to encode",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 7),
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
                                encodingDone = false;
                              });
                            },
                          );
                        }),
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
                              if (shouldNormalize) {
                                navigateToPage(
                                    context, MLTypeSelectionScreen());
                              } else {
                                applyEncoding();
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
                        shouldNormalize ? "Next" : "Apply Encoding",
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
