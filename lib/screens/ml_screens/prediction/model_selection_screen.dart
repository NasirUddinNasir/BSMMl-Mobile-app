import 'dart:convert';
import 'package:analysis_app/api/base_url.dart';
import 'package:analysis_app/screens/widgets_functions.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:analysis_app/components/model_parameters.dart';

class ModelSelectionScreen extends StatefulWidget {
  const ModelSelectionScreen({super.key});

  @override
  State<ModelSelectionScreen> createState() => _ModelSelectionScreenState();
}

class _ModelSelectionScreenState extends State<ModelSelectionScreen> {
  String? targetType;
  bool isLoading = true;
  String? selectedModelName;
  String? selectedEndpoint;

  final classificationModels = {
    "Logistic Regression": "predict-logistic-regression",
    "Random Forest Classifier": "predict-random-forest-classifier",
    "KNN Classifier": "predict-knn-classifier",
    "XGBoost Classifier": "predict-xgb-classifier",
  };

  final regressionModels = {
    "Linear Regression": "predict-linear-regression",
    "Random Forest Regressor": "predict-random-forest-regressor",
    "XGBoost Regressor": "predict-xgb-regressor",
    "SVR": "predict-svr",
  };

  @override
  void initState() {
    super.initState();
    fetchTargetType();
  }

  Future<void> fetchTargetType() async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/get-target-type"));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          targetType = data["type"].toString().toLowerCase().trim();
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching target type: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final models = targetType == "categorical" ? classificationModels : regressionModels;

    return Scaffold(
      appBar: AppBar(
        leading: iconButton(context),
        title: const Text("Choose a Model"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "Select a machine learning model:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: models.entries.map((entry) {
                  final isSelected = selectedModelName == entry.key;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedModelName = entry.key;
                        selectedEndpoint = entry.value;
                      });
                    },
                    child: Card(
                      elevation: 0,
                      color: isSelected ? Colors.blue.shade50 : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: isSelected ? Colors.blue : Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(
                          entry.key,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.blue : Colors.black,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle, color: Colors.blue)
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: selectedModelName == null
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ModelParametersScreen(
                              modelName: selectedModelName!,
                              endpoint: selectedEndpoint!,
                            ),
                          ),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 11, 95, 163),
                  disabledBackgroundColor: Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Next",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
