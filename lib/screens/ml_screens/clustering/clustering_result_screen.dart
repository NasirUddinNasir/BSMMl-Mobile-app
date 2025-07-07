import 'package:analysis_app/api/base_url.dart';
import 'package:analysis_app/api/download_pdf.dart';
import 'package:analysis_app/components/image_zooming.dart';
import 'package:analysis_app/screens/previe_data/preview_data.dart';
import 'package:analysis_app/screens/upload_screen.dart';
import 'package:analysis_app/screens/widgets_functions.dart';
import 'package:analysis_app/screens/ml_screens/clustering/clustering_visulation.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

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
    // Extract image URLs
    final images = result["images"] ?? {};
    final mainImagePath = images["main"];
    final imageUrl = mainImagePath != null && mainImagePath.startsWith("/")
        ? "$baseUrl$mainImagePath"
        : "$baseUrl/$mainImagePath";

    // Prepare filtered data for display (excluding images)
    final filteredResult = Map.from(result)..remove("images");

    return Scaffold(
      appBar: AppBar(
        leading: iconButton(context),
        title: Text(
          "$model - Result",
          style: TextStyle(fontSize: 20),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      backgroundColor: Colors.white,
      body: ListView(
        padding: const EdgeInsets.only(left: 16, right: 16, ),
        children: [
          TextButton.icon(
            onPressed: () async {
              await Printing.layoutPdf(
                onLayout: (format) => generateClusteringPDF(
                  model: model,
                  result: result,
                ),
              );
            },
            icon: Icon(Icons.picture_as_pdf, color: const Color.fromARGB(255, 32, 105, 35)),
            label: Text("Download Report", style: TextStyle(color: const Color.fromARGB(255, 32, 105, 35)),),
            
          ),
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
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Icon(Icons.info_outline,
                        color: Colors.blue, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      "Cluster Info",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...filteredResult.entries.take(5).map((entry) {
                  final key = entry.key;
                  final rawValue = entry.value;

                  String displayValue;
                  if (rawValue is num) {
                    displayValue = rawValue.toStringAsFixed(2);
                  } else {
                    final strVal = rawValue.toString();
                    displayValue = strVal.length > 100
                        ? '${strVal.substring(0, 100)}...'
                        : strVal;
                  }
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          key,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: Colors.indigo.shade700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          displayValue,
                          style: const TextStyle(
                              fontSize: 15, color: Colors.black87),
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
          const SizedBox(height: 8),
          if (mainImagePath != null)
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
        ],
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
                  onPressed: () => navigateToPage(
                    context,
                    ClusterVisualizationsScreen(
                      model: model,
                      images: {
                        'pie': images['pie'] ?? '',
                        'bar': images['bar'] ?? '',
                        'hist': images['hist'] ?? '',
                      },
                    ),
                  ),
                  icon: const Icon(Icons.bar_chart),
                  label: Text(
                    "Cluster Insights",
                    style: const TextStyle(fontSize: 17),
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
                icon: Icon(Icons.home),
                color: const Color.fromARGB(255, 17, 57, 143),
                iconSize: 45,
                onPressed: () => navigateToPage(context, CSVUploader()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
