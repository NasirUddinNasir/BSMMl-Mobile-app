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

  static const Map<String, Map<String, dynamic>> _defaultParams = {
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

  static const Map<String, List<String>> _dropdownOptions = {
    "penalty": ["l1", "l2"],
    "kernel": ["linear", "poly", "rbf", "sigmoid"],
  };

  // Dynamic solver options based on penalty
  static const Map<String, List<String>> _solverOptions = {
    "l1": ["liblinear", "saga"],
    "l2": ["lbfgs", "liblinear", "newton-cg", "newton-cholesky", "sag", "saga"],
  };

  @override
  void initState() {
    super.initState();
    final defaultParam = _defaultParams[widget.endpoint];
    if (defaultParam != null) {
      params.addAll(defaultParam);
    }
  }

  // Get available solver options based on current penalty
  List<String> _getAvailableSolvers() {
    final penalty = params["penalty"]?.toString() ?? "l2";
    return _solverOptions[penalty] ?? _solverOptions["l2"]!;
  }

  // Check if current solver is valid for the penalty, if not, set to first available
  void _validateSolver() {
    final availableSolvers = _getAvailableSolvers();
    final currentSolver = params["solver"]?.toString();
    
    if (currentSolver == null || !availableSolvers.contains(currentSolver)) {
      params["solver"] = availableSolvers.first;
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
        headers: const {"Content-Type": "application/json"},
        body: jsonEncode(params),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (mounted) {
          setState(() {
            // Safe parsing with fallback
            trainScore = _parseDouble(data["train_score"]);
            testScore = _parseDouble(data["test_score"]);
            samplePredictions = data["sample_predictions"] as List<dynamic>?;
          });
        }
      } else {
        if (mounted) {
          _showError("Failed to run model: ${res.statusCode}");
        }
      }
    } catch (e) {
      if (mounted) {
        _showError("Error: $e");
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  Widget _buildDropdownInput(String key, dynamic value) {
    List<String>? options;
    
    if (key == "solver") {
      options = _getAvailableSolvers();
    } else {
      options = _dropdownOptions[key];
    }
    
    if (options == null) return _buildTextInput(key, value);
    
    final stringValue = value?.toString();
    final validValue = options.contains(stringValue) ? stringValue : options.first;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        value: validValue,
        decoration: InputDecoration(
          labelText: key,
          labelStyle: TextStyle(fontSize: 20,fontWeight: FontWeight.w500, color: const Color.fromARGB(255, 13, 106, 182)),
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        items: options.map((option) => DropdownMenuItem<String>(
          value: option,
          child: Text(option),
        )).toList(),
        onChanged: (newValue) {
          if (newValue != null) {
            setState(() {
              params[key] = newValue;
              if (key == "penalty") {
                _validateSolver();
              }
            });
          }
        },
      ),
    );
  }

  Widget _buildTextInput(String key, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        initialValue: value?.toString() ?? "",
        decoration: InputDecoration(
          labelText: key,
          labelStyle: TextStyle(fontSize: 20,fontWeight: FontWeight.w500,color: Color.fromARGB(255, 13, 106, 182)),
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        onChanged: (val) => params[key] = num.tryParse(val) ?? val,
      ),
    );
  }

  Widget paramInput(String key, dynamic value) {
    return (_dropdownOptions.containsKey(key) || key == "solver")
        ? _buildDropdownInput(key, value)
        : _buildTextInput(key, value);
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
        if (samplePredictions != null && samplePredictions!.isNotEmpty) ...[
          const Text("Sample Predictions:"),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade100),
            ),
            child: Text(
              samplePredictions!
                  .map((e) => e?.toString() ?? 'null')
                  .join(", "),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ] else if (samplePredictions != null) ...[
          const Text("Sample Predictions:"),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Text("No predictions available"),
          ),
        ]
      ],
    );
  }

  Widget _buildActionButton({
    required VoidCallback? onPressed,
    required IconData icon,
    required String label,
    required Color backgroundColor,
    required double borderRadius,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20, color: Colors.white),
      label: Text(label, style: const TextStyle(fontSize: 16, color: Colors.white)),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        elevation: 6,
        shadowColor: Colors.black,
      ),
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
          padding: const EdgeInsets.only(bottom: 150),
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
                    ? const CircularProgressIndicator(color: Color.fromARGB(255, 13, 92, 156))
                    : const Text("Run Model",
                        style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 20),
            buildResultsSection(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildActionButton(
                  onPressed: () => navigateToPage(context, PredictionVisualizationScreen()),
                  icon: Icons.bar_chart,
                  label: "Visualize",
                  backgroundColor: const Color.fromARGB(255, 17, 57, 143),
                  borderRadius: 50,
                ),
                const SizedBox(width: 20),
                _buildActionButton(
                  onPressed: trainScore != null ? () => downloadTrainedModel(context) : null,
                  icon: Icons.download_rounded,
                  label: "Model",
                  backgroundColor: const Color(0xFF2F9E44),
                  borderRadius: 10,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0, top: 5),
              child: IconButton(
                icon: const Icon(Icons.home),
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