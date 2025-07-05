import 'package:analysis_app/api/base_url.dart';
import 'package:analysis_app/components/image_zooming.dart';
import 'package:analysis_app/screens/widgets_functions.dart';
import 'package:analysis_app/screens/ml_screens/clustering/clustering_visulation.dart';
import 'package:flutter/material.dart';

class ClusteringResultScreen extends StatelessWidget {
  final String model;
  final Map result;

  const ClusteringResultScreen({
    super.key,
    required this.model,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final imagePath = result["image"];
    final imageUrl = imagePath != null && imagePath.startsWith("/")
        ? "$baseUrl$imagePath"
        : "$baseUrl/$imagePath";
    final filteredResult = Map.from(result)
      ..remove("image")
      ..remove("bar_image")
      ..remove("pie_image")
      ..remove("hist_image");

    return Scaffold(
      appBar: AppBar(
        leading: iconButton(context),
        title: Text("$model - Result"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      backgroundColor: Colors.white,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Cluster Info",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
                const SizedBox(height: 12),
                ...filteredResult.entries.map((e) {
                  final valueStr = e.value.toString();
                  final displayValue = valueStr.length > 500
                      ? "${valueStr.substring(0, 500)}..."
                      : valueStr;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${e.key}: ",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.blueGrey.shade700,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            displayValue,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Cluster Visualization",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade800,
            ),
          ),
          const SizedBox(height: 12),
          if (imagePath != null)
            Container(
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: zoomableImage(imageUrl),
            )
          else
            const Center(child: Text("No image available")),

          const SizedBox(height: 24),

          // ---- Visualize More Button ----
          ElevatedButton.icon(
            icon: const Icon(Icons.insights_outlined),
            label: const Text("Visualize More"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              padding: const EdgeInsets.symmetric(vertical: 14),
              textStyle: const TextStyle(fontSize: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ClusterVisualizationsScreen(
                    model: model,
                    images: {
                      'pie': result['pie_image'],
                      'bar': result['bar_image'],
                      'hist': result['hist_image'],
                    },
                  ),
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
