import 'package:flutter/material.dart';
import 'package:analysis_app/screens/widgets_functions.dart';

class ClusteringResult extends StatefulWidget {
  const ClusteringResult({super.key});

  @override
  ClusteringResultState createState() => ClusteringResultState();
}

class ClusteringResultState extends State<ClusteringResult> {
  String imageUrl = 'http://<your-ip>:8000/plot'; // Replace with real backend URL

  int predictedValue = 70;
  double accuracy = 0.0;
  int numberOfClusters = 3;
  double daviesBouldinIndex = 0.58;
  Map<String, int> clusterDistribution = {
    'Cluster 0': 25,
    'Cluster 1': 38,
    'Cluster 2': 17,
  };
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchClusteringData();
  }

  Future<void> fetchClusteringData() async {
    // TODO: Replace with real HTTP call to FastAPI
    await Future.delayed(const Duration(seconds: 1)); // Simulate delay

    setState(() {
      predictedValue = 70;
      accuracy = 89.5; // Will display in the UI when available
      numberOfClusters = 3;
      daviesBouldinIndex = 0.58;
      clusterDistribution = {
        'Cluster 0': 25,
        'Cluster 1': 38,
        'Cluster 2': 17,
      };
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: iconButton(context),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Clustering Result',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Select an algorithm of your choice:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Scatter plot from backend or local placeholder
                  Container(
                    width: double.infinity,
                    height: 250,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => 
                          const Center(child: Text("Failed to load scatter plot")),
                      loadingBuilder: (context, child, progress) =>
                          progress == null ? child : const Center(child: CircularProgressIndicator()),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Predicted Value
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Colors.black, fontSize: 16),
                      children: [
                        const TextSpan(
                          text: 'Predicted Value: ',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        TextSpan(text: '$predictedValue'),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Accuracy field
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Colors.black, fontSize: 16),
                      children: [
                        const TextSpan(
                          text: 'Accuracy: ',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        TextSpan(
                          text: accuracy > 0 ? '${accuracy.toStringAsFixed(1)}%' : '',
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Number of Clusters
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Colors.black, fontSize: 16),
                      children: [
                        const TextSpan(
                          text: 'Number of Clusters: ',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        TextSpan(text: '$numberOfClusters'),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Davies-Bouldin Index (clustering quality metric)
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Colors.black, fontSize: 16),
                      children: [
                        const TextSpan(
                          text: 'Clustering Quality: ',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        TextSpan(
                          text: daviesBouldinIndex < 0.7 ? 'Good' : 'Average',
                          style: TextStyle(
                            color: daviesBouldinIndex < 0.7 ? Colors.green : Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Export Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Implement export functionality
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0A3779),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Export Result',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}