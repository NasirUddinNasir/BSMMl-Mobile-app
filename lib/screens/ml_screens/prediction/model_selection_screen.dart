import 'dart:convert';
import 'package:analysis_app/api/base_url.dart';
import 'package:analysis_app/screens/previe_data/preview_data.dart';
import 'package:analysis_app/screens/upload_screen.dart';
import 'package:analysis_app/screens/widgets_functions.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:analysis_app/screens/ml_screens/prediction/model_parameters_screen.dart';

class ModelSelectionScreen extends StatefulWidget {
  const ModelSelectionScreen({super.key});

  @override
  State<ModelSelectionScreen> createState() => _ModelSelectionScreenState();
}

class _ModelSelectionScreenState extends State<ModelSelectionScreen> {
  String? targetType;
  bool isLoading = true;
  String? selectedModelName;
  String selectedEndpoint = '';

  final classificationModels = {
    "Logistic Regression": {
      "endpoint": "predict-logistic-regression",
      "info": "Best for binary classification problems."
    },
    "Random Forest Classifier": {
      "endpoint": "predict-random-forest-classifier",
      "info":
          "Handles both binary and multi-class classification with high accuracy."
    },
    "KNN Classifier": {
      "endpoint": "predict-knn-classifier",
      "info": "Works well with small datasets and simple patterns."
    },
    "XGBoost Classifier": {
      "endpoint": "predict-xgb-classifier",
      "info": "High-performance model for complex classification problems."
    },
  };

  final regressionModels = {
    "Linear Regression": {
      "endpoint": "predict-linear-regression",
      "info": "Simple and fast, ideal for linear relationships."
    },
    "Random Forest Regressor": {
      "endpoint": "predict-random-forest-regressor",
      "info": "Great for capturing nonlinear relationships in data."
    },
    "XGBoost Regressor": {
      "endpoint": "predict-xgb-regressor",
      "info": "Powerful model for complex regression tasks."
    },
    "SVR": {
      "endpoint": "predict-svr",
      "info": "Best for small datasets with nonlinear patterns."
    },
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
        body: Center(
            child: CircularProgressIndicator(
          color: Color.fromARGB(255, 13, 92, 156),
        )),
      );
    }

    final models =
        targetType == "categorical" ? classificationModels : regressionModels;

    return Scaffold(
      appBar: AppBar(
        leading: iconButton(context),
        title: const Text("Prediction Models"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Select a machine learning model",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.80, 
                children: models.entries.map((entry) {
                  final modelDetails = entry.value;
                  final isSelected = selectedModelName == entry.key;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedModelName = entry.key;
                        selectedEndpoint = modelDetails['endpoint']!;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue.shade50 : Colors.white,
                        border: Border.all(
                          color:
                              isSelected ? Colors.blue : Colors.grey.shade300,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.memory_rounded,
                            color:
                                isSelected ? Colors.blue : Colors.grey.shade700,
                            size: 34,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            entry.key,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: isSelected
                                  ? Colors.blue.shade900
                                  : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            modelDetails['info']!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
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
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: selectedModelName == null
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ModelParametersScreen(
                                modelName: selectedModelName!,
                                endpoint: selectedEndpoint,
                              ),
                            ),
                          );
                        },
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text(
                    "Next",
                    style: TextStyle(fontSize: 17),
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
                icon: const Icon(Icons.home),
                color: const Color.fromARGB(255, 17, 57, 143),
                iconSize: 45,
                onPressed: () => navigateToPage(context, const CSVUploader()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
