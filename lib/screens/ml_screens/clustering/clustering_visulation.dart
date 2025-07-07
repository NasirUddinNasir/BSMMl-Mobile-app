import 'package:flutter/material.dart';
import 'package:analysis_app/components/image_zooming.dart';
import 'package:analysis_app/screens/widgets_functions.dart';
import 'package:analysis_app/api/base_url.dart';

class ClusterVisualizationsScreen extends StatelessWidget {
  final String model;
  final Map<String, String> images;

  const ClusterVisualizationsScreen({
    super.key,
    required this.model,
    required this.images,
  });

  @override
  Widget build(BuildContext context) {
    final pieUrl = "$baseUrl${images['pie']}";
    final histUrl = "$baseUrl${images['hist']}";
    final barUrl = "$baseUrl${images['bar']}";

    return Scaffold(
      appBar: AppBar(
        leading: iconButton(context),
        title: Text("$model - Visualizations",style: TextStyle(fontSize: 20),),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection("Pie Chart: Cluster Distribution", pieUrl),
          const SizedBox(height: 24),
          _buildSection("Histogram: PCA Component 1", histUrl),
          const SizedBox(height: 24),
          _buildSection("Bar Chart: Mean Component Values", barUrl),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String imageUrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.blue.shade800,
            )),
        const SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: zoomableImage(imageUrl),
        ),
      ],
    );
  }
}
