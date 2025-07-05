import 'dart:convert';
import 'package:analysis_app/api/base_url.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:analysis_app/screens/previe_data/preview_data.dart';
import 'package:analysis_app/screens/widgets_functions.dart';
import 'package:analysis_app/components/download_csv_file.dart';
import 'package:analysis_app/screens/ml_screens/ml_type_selection_screen.dart';

class FeatureSelectionScreen extends StatefulWidget {
  const FeatureSelectionScreen({super.key});

  @override
  State<FeatureSelectionScreen> createState() => _FeatureSelectionScreenState();
}

class _FeatureSelectionScreenState extends State<FeatureSelectionScreen> {
  final String getFeaturesUrl = "$baseUrl/get-features";
  final String dropFeaturesUrl = "$baseUrl/drop-features";

  List<String> allFeatures = [];
  Set<String> selectedFeatures = {};
  bool isLoading = true;
  bool isProcessing = false;
  bool featuresDropped = false;

  @override
  void initState() {
    super.initState();
    fetchFeatures();
  }

  Future<void> fetchFeatures() async {
    setState(() {
      isLoading = true;
      selectedFeatures.clear(); // reset selection
    });
    try {
      final response = await http.get(Uri.parse(getFeaturesUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> features = data['features'];
        setState(() {
          allFeatures = List<String>.from(features);
        });
      }
    } catch (e) {
      debugPrint("Error fetching features: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> dropSelectedFeatures() async {
    if (selectedFeatures.isEmpty) {
      navigateToPage(context, const MLTypeSelectionScreen());
      return;
    }

    setState(() => isProcessing = true);
    try {
      final response = await http.post(
        Uri.parse(dropFeaturesUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'features': selectedFeatures.toList()}),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Selected features dropped.")),
        );
        setState(() {
          featuresDropped = true;
        });
        await fetchFeatures();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to drop features.")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      debugPrint("Drop features error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An error occurred")),
      );
    } finally {
      setState(() => isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final noFeatures = allFeatures.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Feature Selection"),
        backgroundColor: Colors.transparent,
        leading: iconButton(context),
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : noFeatures
              ? Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '⚠️ No Features Remaining',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 183, 28, 28),
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'No features found.\nHave you dropped all features accidentally?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text("Want to download the clean data?  "),
                          GestureDetector(
                            onTap: () => downloadCleanedCSV(context),
                            child: const Text(
                              "Touch here",
                              style: TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                                fontSize: 15,
                              ),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Select features to drop",
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView.builder(
                          itemCount: allFeatures.length,
                          itemBuilder: (context, index) {
                            final feature = allFeatures[index];
                            return CheckboxListTile(
                              title: Text(feature),
                              value: selectedFeatures.contains(feature),
                              onChanged: (selected) {
                                setState(() {
                                  if (selected == true) {
                                    selectedFeatures.add(feature);
                                  } else {
                                    selectedFeatures.remove(feature);
                                  }
                                  featuresDropped = false;
                                });
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 15),
          child: Row(
            children: [
              // Preview button
              SizedBox(
                width: 60,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    navigateToPage(context, const DataPreviewScreen());
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

              // Main button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isProcessing || allFeatures.length < 2
                      ? null
                      : () {
                          if (featuresDropped || noFeatures) {
                            navigateToPage(
                                context, const MLTypeSelectionScreen());
                          } else {
                            dropSelectedFeatures();
                          }
                        },
                  icon: isProcessing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.arrow_forward),
                  label: Text(
                    allFeatures.length < 2
                        ? "Need 2+ features"
                        : (featuresDropped || noFeatures)
                            ? "Next"
                            : (selectedFeatures.isEmpty
                                ? "Next"
                                : "Drop Selected Features"),
                    style: const TextStyle(fontSize: 17),
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
            ],
          ),
        ),
      ),
    );
  }
}
