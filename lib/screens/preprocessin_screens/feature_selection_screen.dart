import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:analysis_app/screens/home_screen.dart';
import 'package:analysis_app/screens/previe_data/preview_data.dart';
import 'package:analysis_app/screens/widgets_functions.dart';
import 'package:analysis_app/components/download_csv_file.dart';

class FeatureSelectionScreen extends StatefulWidget {
  const FeatureSelectionScreen({super.key});

  @override
  State<FeatureSelectionScreen> createState() => _FeatureSelectionScreenState();
}

class _FeatureSelectionScreenState extends State<FeatureSelectionScreen> {
  final String getFeaturesUrl = "http://10.0.2.2:8000/get-features";
  final String dropFeaturesUrl = "http://10.0.2.2:8000/drop-features";

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
    setState(() => isLoading = true);
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
      navigateToPage(
        context,
        DataPreviewScreen(buttontext: "Home", nextScreen: const HomeScreen(title: "")),
      );
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
        setState(() => featuresDropped = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Selected features dropped.")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to drop features.")),
        );
      }
    } catch (e) {
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
              ? const Center(child: Text("No features available to drop"))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => downloadCleanedCSV(context),
                        child: const Text(
                          "Want to download the clean data? Click here",
                          style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Select features to drop",
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
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
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: isProcessing
                  ? null
                  : () {
                      if (featuresDropped || noFeatures) {
                        navigateToPage(
                          context,
                          DataPreviewScreen(buttontext: "Home", nextScreen: const HomeScreen(title: "")),
                        );
                      } else {
                        dropSelectedFeatures();
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
                      (featuresDropped || noFeatures)
                          ? "Preview Data"
                          : "Drop Selected Features",
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
