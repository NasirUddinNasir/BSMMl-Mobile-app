import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:analysis_app/api/base_url.dart';
import 'package:analysis_app/screens/widgets_functions.dart';
import 'package:analysis_app/screens/ml_screens/prediction/model_selection_screen.dart';

class PredictionTargetSelectionScreen extends StatefulWidget {
  const PredictionTargetSelectionScreen({super.key});

  @override
  State<PredictionTargetSelectionScreen> createState() =>
      _PredictionTargetSelectionScreenState();
}

class _PredictionTargetSelectionScreenState
    extends State<PredictionTargetSelectionScreen> {
  final String getFeaturesUrl = "$baseUrl/get-features";
  final String dropTargetUrl = "$baseUrl/drop-target";

  List<String> features = [];
  String? selectedTarget;
  bool isLoading = true;
  bool isSubmitting = false;

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
        setState(() {
          features = List<String>.from(data['features']);
        });
      }
    } catch (e) {
      debugPrint("Error fetching features: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> submitTargetColumn() async {
    if (selectedTarget == null) return;
    setState(() => isSubmitting = true);

    try {
      final response = await http.post(
        Uri.parse(dropTargetUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'target_column': selectedTarget}),
      );
      if (!mounted) return;
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Target column set successfully.")),
        );
        navigateToPage(context, ModelSelectionScreen());
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to set target column.")),
        );
      }
    } catch (e) {
      debugPrint("Error submitting target column: $e");
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Target Column"),
        backgroundColor: Colors.transparent,
        leading: iconButton(context),
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Choose the column you want to predict:",
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: features.length,
                      itemBuilder: (context, index) {
                        final column = features[index];
                        return RadioListTile<String>(
                          title: Text(column),
                          value: column,
                          activeColor: Colors.blue,
                          groupValue: selectedTarget,
                          onChanged: (value) {
                            setState(() {
                              selectedTarget = value;
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
              onPressed: selectedTarget == null || isSubmitting
                  ? null
                  : submitTargetColumn,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 11, 95, 163),
                disabledBackgroundColor: Colors.grey.shade300,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      "Proceed",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
