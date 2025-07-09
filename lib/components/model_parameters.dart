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

  // Updated to handle structured metrics
  Map<String, dynamic>? trainMetrics;
  Map<String, dynamic>? testMetrics;
  List<dynamic>? samplePredictions;
  String? modelType;

  static const Map<String, Map<String, dynamic>> _defaultParams = {
    // Classification Models
    "predict-logistic-regression": {
      "penalty": "l2",
      "C": 1.0,
      "solver": "lbfgs",
      "max_iter": 1000,
      "class_weight": null,
      "random_state": 42,
      "tol": 1e-4,
      "fit_intercept": true,
      "l1_ratio": null
    },
    "predict-random-forest-classifier": {
      "n_estimators": 100,
      "max_depth": null,
      "min_samples_split": 2,
      "min_samples_leaf": 1,
      "max_features": "sqrt",
      "bootstrap": true,
      "class_weight": null,
      "random_state": 42,
      "max_leaf_nodes": null,
      "min_impurity_decrease": 0.0,
      "oob_score": false,
      "n_jobs": null
    },
    "predict-knn-classifier": {
      "n_neighbors": 5,
      "weights": "uniform",
      "algorithm": "auto",
      "leaf_size": 30,
      "p": 2,
      "metric": "minkowski",
      "metric_params": null,
      "n_jobs": null
    },
    "predict-xgb-classifier": {
      "n_estimators": 100,
      "learning_rate": 0.1,
      "max_depth": 6,
      "subsample": 1.0,
      "colsample_bytree": 1.0,
      "colsample_bylevel": 1.0,
      "colsample_bynode": 1.0,
      "reg_alpha": 0.0,
      "reg_lambda": 1.0,
      "min_child_weight": 1,
      "gamma": 0.0,
      // "scale_pos_weight": 1.0,
      "random_state": 42,
      "n_jobs": null,
      "objective": "binary:logistic",
      "booster": "gbtree",
      "tree_method": "auto"
    },
    // Regression Models
    "predict-linear-regression": {
      "model_type": "linear",
      "alpha": 1.0,
      "l1_ratio": 0.5,
      "fit_intercept": true,
      "normalize": false
    },
    "predict-random-forest-regressor": {
      "n_estimators": 100,
      "max_depth": null,
      "min_samples_split": 2,
      "min_samples_leaf": 1,
      "max_features": "sqrt",
      "bootstrap": true,
      "oob_score": false,
      "n_jobs": -1,
      "criterion": "squared_error"
    },
    "predict-xgb-regressor": {
      "n_estimators": 100,
      "learning_rate": 0.1,
      "max_depth": 3,
      "subsample": 1.0,
      "colsample_bytree": 1.0,
      "reg_alpha": 0.0,
      "reg_lambda": 1.0,
      "min_child_weight": 1,
      "gamma": 0.0,
      "objective": "reg:squarederror",
      "early_stopping_rounds": null,
      "eval_metric": "rmse"
    },
    "predict-svr": {
      "kernel": "rbf",
      "C": 1.0,
      "epsilon": 0.1,
      "gamma": "scale",
      "degree": 3,
      "coef0": 0.0,
      "shrinking": true,
      "tol": 1e-3,
      "cache_size": 200,
      "max_iter": -1
    }
  };

  static const Map<String, List<String>> _dropdownOptions = {
    // Classification options
    "penalty": [
      "l1",
      "l2",
      "elasticnet",
    ],
    "class_weight": ["balanced", "balanced_subsample"],
    "weights": ["uniform", "distance"],
    "algorithm": ["auto", "ball_tree", "kd_tree", "brute"],
    "metric": ["euclidean", "manhattan", "chebyshev", "minkowski"],
    "objective": ["binary:logistic", "multi:softmax"],
    "booster": ["gbtree", "gblinear", "dart"],
    "tree_method": ["auto", "exact", "approx", "hist"],

    // Regression options
    "model_type": ["linear", "ridge", "lasso", "elastic_net"],
    "max_features": ["sqrt", "log2"],
    "criterion": ["squared_error", "absolute_error", "poisson"],
    "kernel": ["linear", "poly", "rbf", "sigmoid"],
    "eval_metric": ["rmse", "mae", "logloss"]
  };

  // Dynamic solver options based on penalty
  static const Map<String, List<String>> _solverOptions = {
    "l1": ["liblinear", "saga"],
    "l2": ["lbfgs", "liblinear", "newton-cg", "sag", "saga"],
    "elasticnet": ["saga"],
  };

  @override
  void initState() {
    super.initState();
    final defaultParam = _defaultParams[widget.endpoint];
    if (defaultParam != null) {
      params.addAll(Map<String, dynamic>.from(defaultParam));
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

  // Determine if this is a classification or regression model
  bool isClassificationModel() {
    return widget.endpoint.contains('classifier') ||
        widget.endpoint.contains('logistic-regression');
  }

  Future<void> submit() async {
    setState(() {
      isLoading = true;
      trainMetrics = null;
      testMetrics = null;
      samplePredictions = null;
      modelType = null;
    });

    try {
      // Clean up null values and prepare parameters
      final cleanedParams = <String, dynamic>{};
      params.forEach((key, value) {
        if (value != null && value != "null") {
          cleanedParams[key] = value;
        }
      });

      final res = await http.post(
        Uri.parse("$baseUrl/${widget.endpoint}"),
        headers: const {"Content-Type": "application/json"},
        body: jsonEncode(cleanedParams),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (mounted) {
          setState(() {
            modelType = data["model"] as String?;
            trainMetrics = data["train_metrics"] as Map<String, dynamic>?;
            testMetrics = data["test_metrics"] as Map<String, dynamic>?;
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
    final validValue =
        options.contains(stringValue) ? stringValue : options.first;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        value: validValue,
        decoration: InputDecoration(
          labelText: key,
          labelStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Color.fromARGB(255, 13, 106, 182)),
          border: const OutlineInputBorder(),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        items: options
            .map((option) => DropdownMenuItem<String>(
                  value: option,
                  child: Text(option),
                ))
            .toList(),
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

  Widget _buildBooleanInput(String key, dynamic value) {
    final boolValue =
        value is bool ? value : (value?.toString().toLowerCase() == 'true');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SwitchListTile(
        title: Text(
          key,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        value: boolValue,
        activeColor: const Color.fromARGB(255, 13, 106, 182),
        onChanged: (newValue) {
          setState(() {
            params[key] = newValue;
          });
        },
      ),
    );
  }

  Widget _buildNullableInput(String key, dynamic value) {
    final isNull = value == null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Checkbox(
                value: isNull,
                onChanged: (checked) {
                  setState(() {
                    if (checked == true) {
                      params[key] = null;
                    } else {
                      // Set to a default value based on expected type
                      if (key.contains('depth') ||
                          key.contains('estimators') ||
                          key.contains('iter')) {
                        params[key] = 100;
                      } else if (key.contains('weight') ||
                          key.contains('ratio')) {
                        params[key] = 1.0;
                      } else {
                        params[key] = 0;
                      }
                    }
                  });
                },
              ),
              Text(
                "Set $key to null",
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
          if (!isNull) _buildTextInput(key, value),
        ],
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
          labelStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Color.fromARGB(255, 13, 106, 182)),
          border: const OutlineInputBorder(),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        onChanged: (val) {
          if (val.isEmpty) {
            params[key] = null;
          } else {
            params[key] = num.tryParse(val) ?? val;
          }
        },
      ),
    );
  }

  Widget paramInput(String key, dynamic value) {
    // Handle boolean parameters
    if (key == "fit_intercept" ||
        key == "normalize" ||
        key == "bootstrap" ||
        key == "oob_score" ||
        key == "shrinking") {
      return _buildBooleanInput(key, value);
    }

    // Handle nullable parameters
    if (key == "max_depth" ||
        key == "class_weight" ||
        key == "l1_ratio" ||
        key == "early_stopping_rounds" ||
        key == "n_jobs" ||
        key == "max_leaf_nodes" ||
        key == "metric_params") {
      return _buildNullableInput(key, value);
    }

    // Handle dropdown parameters
    if (_dropdownOptions.containsKey(key) || key == "solver") {
      return _buildDropdownInput(key, value);
    }

    // Default text input
    return _buildTextInput(key, value);
  }

  Widget _buildMetricsCard(
      String title, Map<String, dynamic> metrics, Color color) {
    return Card(
      color: Colors.green.shade50,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 12),
            ...metrics.entries.map((entry) {
              final value = entry.value;
              final displayValue =
                  value is num ? value.toStringAsFixed(3) : value.toString();
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatMetricName(entry.key),
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      displayValue,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  String _formatMetricName(String metricName) {
    switch (metricName) {
      case 'accuracy':
        return 'Accuracy';
      case 'precision':
        return 'Precision';
      case 'recall':
        return 'Recall';
      case 'f1':
        return 'F1 Score';
      case 'r2_score':
        return 'R² Score';
      case 'mse':
        return 'MSE';
      case 'rmse':
        return 'RMSE';
      case 'mae':
        return 'MAE';
      default:
        return metricName.toUpperCase();
    }
  }

  Widget buildResultsSection() {
    if (trainMetrics == null && testMetrics == null) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 32),
        Row(
          children: [
            const Icon(Icons.analytics, color: Colors.blue),
            const SizedBox(width: 8),
            Text(
              "Results${modelType != null ? ' - $modelType' : ''}",
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Training and Test Metrics Cards
        if (trainMetrics != null && testMetrics != null) ...[
          Row(
            children: [
              Expanded(
                child: _buildMetricsCard(
                  "Training Metrics",
                  trainMetrics!,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricsCard(
                  "Test Metrics",
                  testMetrics!,
                  Colors.orange,
                ),
              ),
            ],
          ),
        ] else if (trainMetrics != null) ...[
          _buildMetricsCard("Training Metrics", trainMetrics!, Colors.green),
        ] else if (testMetrics != null) ...[
          _buildMetricsCard("Test Metrics", testMetrics!, Colors.orange),
        ],

        const SizedBox(height: 16),

        // Sample Predictions
        if (samplePredictions != null && samplePredictions!.isNotEmpty) ...[
          const Text(
            "Sample Predictions:",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade50, Colors.blue.shade100],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "First 10 Predictions:",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  samplePredictions!
                      .map((e) => e is num
                          ? e.toStringAsFixed(4)
                          : e?.toString() ?? 'null')
                      .join(", "),
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'monospace',
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ] else if (samplePredictions != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Text(
              "No predictions available",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
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
      label: Text(label,
          style: const TextStyle(fontSize: 16, color: Colors.white)),
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
            SizedBox(
              height: 48,
              width: 180,
              child: ElevatedButton(
                onPressed: isLoading ? null : submit,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                child: isLoading
                    ? const CircularProgressIndicator(
                        color: Color.fromARGB(255, 13, 92, 156))
                    : const Text("Run Model",
                        style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 3,
                  child: _buildActionButton(
                    onPressed: () => navigateToPage(
                        context, PredictionVisualizationScreen()),
                    icon: Icons.bar_chart,
                    label: "Visualize",
                    backgroundColor: const Color.fromARGB(255, 17, 57, 143),
                    borderRadius: 50,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.home),
                  color: const Color.fromARGB(255, 17, 57, 143),
                  iconSize: 40,
                  onPressed: () => navigateToPage(context, CSVUploader()),
                ),
                Expanded(
                  flex: 3,
                  child: _buildActionButton(
                    onPressed: trainMetrics != null
                        ? () => downloadTrainedModel(context)
                        : null,
                    icon: Icons.download_rounded,
                    label: "Model",
                    backgroundColor: const Color(0xFF2F9E44),
                    borderRadius: 10,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            )
          ],
        ),
      ),
    );
  }
}
