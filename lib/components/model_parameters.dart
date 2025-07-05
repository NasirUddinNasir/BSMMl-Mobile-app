import 'dart:convert';
import 'package:analysis_app/api/base_url.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:analysis_app/screens/upload_screen.dart';
import 'package:analysis_app/screens/widgets_functions.dart';
import 'package:analysis_app/screens/ml_screens/prediction/prediction_visualization_screen.dart';
import 'package:analysis_app/api/download_train_model.dart';

class ModelParametersScreen extends StatefulWidget {
  final String modelName;
  final String endpoint;

  const ModelParametersScreen({
    super.key,
    required this.modelName,
    required this.endpoint,
  });

  @override
  State<ModelParametersScreen> createState() => _ModelParametersScreenState();
}

class _ModelParametersScreenState extends State<ModelParametersScreen> {
  final Map<String, dynamic> params = {};
  bool isLoading = false;

  double? trainScore;
  double? testScore;
  List<dynamic>? samplePredictions;

  final Map<String, Map<String, dynamic>> defaultParams = {
    "predict-logistic-regression": {
      "penalty": "l2",
      "C": 1.0,
      "solver": "lbfgs"
    },
    "predict-random-forest-classifier": {
      "n_estimators": 100,
      "max_depth": null
    },
    "predict-knn-classifier": {"n_neighbors": 5},
    "predict-xgb-classifier": {
      "n_estimators": 100,
      "learning_rate": 0.1,
      "max_depth": 3
    },
    "predict-random-forest-regressor": {"n_estimators": 100, "max_depth": null},
    "predict-xgb-regressor": {
      "n_estimators": 100,
      "learning_rate": 0.1,
      "max_depth": 3
    },
    "predict-svr": {"kernel": "rbf", "C": 1.0, "epsilon": 0.1}
  };

  @override
  void initState() {
    super.initState();
    if (defaultParams.containsKey(widget.endpoint)) {
      params.addAll(defaultParams[widget.endpoint]!);
    }
  }

  Future<void> submit() async {
    setState(() {
      isLoading = true;
      trainScore = null;
      testScore = null;
      samplePredictions = null;
    });

    try {
      final res = await http.post(
        Uri.parse("$baseUrl/${widget.endpoint}"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(params),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          trainScore = data["train_score"];
          testScore = data["test_score"];
          samplePredictions = data["sample_predictions"];
        });
      } else {
        _showError("Failed to run model");
      }
    } catch (e) {
      _showError("Error: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Widget paramInput(String key, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        initialValue: value?.toString() ?? "",
        decoration: InputDecoration(labelText: key),
        onChanged: (val) {
          params[key] = num.tryParse(val) ?? val;
        },
      ),
    );
  }

  Widget buildResultsSection() {
    if (trainScore == null && testScore == null) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 32),
        const Text("Results",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        if (trainScore != null)
          Text("Training Data Accuracy: ${trainScore!.toStringAsFixed(4)}"),
        if (testScore != null)
          Text("Test Data Accuracy: ${testScore!.toStringAsFixed(4)}"),
        const SizedBox(height: 12),
        if (samplePredictions != null) ...[
          const Text("Sample Predictions:"),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade100),
            ),
            child: Text(samplePredictions!.join(", ")),
          ),
        ]
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: iconButton(context),
        title: Text(widget.modelName),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          padding:
              EdgeInsets.only(bottom: 150), // Leave space for bottom widgets
          children: [
            const Text("Set Parameters",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...params.entries.map((e) => paramInput(e.key, e.value)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: isLoading ? null : submit,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.blue)
                    : const Text("Run Model",
                        style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 20),
            buildResultsSection(),
          ],
        ),
      ),

      // Fixed bottom buttons and rows
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () =>
                      navigateToPage(context, PredictionVisualizationScreen()),
                  icon: const Icon(Icons.bar_chart,
                      size: 20, color: Colors.white),
                  label: const Text(
                    "Visualize",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                    backgroundColor: const Color.fromARGB(255, 17, 57, 143),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    elevation: 6,
                    shadowColor: Colors.black,
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    downloadTrainedModel(context);
                  },
                  icon: const Icon(Icons.download_rounded,
                      size: 20, color: Colors.white),
                  label: const Text(
                    "Download",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                    backgroundColor: const Color(0xFF2F9E44), 
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 6,
                    shadowColor: Colors.black,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0,top: 10),
              child: IconButton(
                icon: Icon(Icons.home),
                color: const Color.fromARGB(255, 17, 57, 143),
                iconSize: 35,
                onPressed: () => navigateToPage(context, CSVUploader()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
