import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:bsmml/api/base_url.dart';
import 'package:bsmml/components/image_zooming.dart';
import 'package:bsmml/components/widgets_functions.dart';

class PredictionVisualizationScreen extends StatefulWidget {
  const PredictionVisualizationScreen({super.key});

  @override
  State<PredictionVisualizationScreen> createState() =>
      _PredictionVisualizationScreenState();
}

class _PredictionVisualizationScreenState
    extends State<PredictionVisualizationScreen> {
  bool isLoading = true;
  String? taskType;
  String? trainImageUrl;
  String? testImageUrl;

  @override
  void initState() {
    super.initState();
    fetchPredictionVisualization();
  }

  Future<void> fetchPredictionVisualization() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/predict-visualization'));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          taskType = data['type'];
          trainImageUrl = "$baseUrl${data['train_plot']}";
          testImageUrl = "$baseUrl${data['test_plot']}";
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        debugPrint('Failed to fetch visualization');
      }
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint('Error fetching visualization: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: iconButton(context),
        title: const Text("Model Visualization"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : trainImageUrl == null || testImageUrl == null
              ? const Center(child: Text("No images available"))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: ListView(
                    children: [
                      Text(
                        "Train ${taskType == 'classification' ? 'Confusion Matrix' : 'Scatter Plot'}",
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: zoomableImage(trainImageUrl!),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Test ${taskType == 'classification' ? 'Confusion Matrix' : 'Scatter Plot'}",
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: zoomableImage(testImageUrl!),
                      ),
                    ],
                  )),
    );
  }
}
