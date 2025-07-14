import 'package:analysis_app/screens/ml_screens/prediction/custom_prediction.dart';
import 'package:flutter/material.dart';
import 'package:analysis_app/screens/upload_screen.dart';
import 'package:analysis_app/screens/widgets_functions.dart';
import 'package:analysis_app/screens/ml_screens/prediction/prediction_visualization_screen.dart';
import 'package:analysis_app/api/download_train_model.dart';

class ResultsScreen extends StatelessWidget {
  final String modelName;
  final String? modelType;
  final Map<String, dynamic>? trainMetrics;
  final Map<String, dynamic>? testMetrics;
  final List<dynamic>? samplePredictions;

  const ResultsScreen({
    super.key,
    required this.modelName,
    this.modelType,
    this.trainMetrics,
    this.testMetrics,
    this.samplePredictions,
  });

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
        title: Text('Model Perfermance', style: TextStyle(fontSize: 20)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          padding: const EdgeInsets.only(bottom: 150),
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.analytics, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  "Results${modelType != null ? ' - $modelType' : ''}",
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Check if we have any results to display
            if (trainMetrics == null &&
                testMetrics == null &&
                samplePredictions == null) ...[
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "No results available",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Run the model first to see results here",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
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
                _buildMetricsCard(
                    "Training Metrics", trainMetrics!, Colors.green),
              ] else if (testMetrics != null) ...[
                _buildMetricsCard("Test Metrics", testMetrics!, Colors.orange),
              ],

              const SizedBox(height: 20),

              if (samplePredictions != null &&
                  samplePredictions!.isNotEmpty) ...[
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
                        "First 20 Predictions:",
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
                        maxLines: 8,
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
            SizedBox(height: sumWH*0.04,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36.0),
              child: ElevatedButton.icon(
                onPressed: () => navigateToPage(context, CustomPrediction()),
                icon: const Icon(Icons.arrow_forward),
                label: const Text(
                  'Custom Prediction',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                  backgroundColor: Colors.orange.shade400, 
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),

                ),
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 3,
              child: _buildActionButton(
                onPressed: () =>
                    navigateToPage(context, PredictionVisualizationScreen()),
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
            SizedBox(
              width: 4,
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
                borderRadius: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
