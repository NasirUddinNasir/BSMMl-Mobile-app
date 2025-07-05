import 'package:flutter/material.dart';
import 'package:analysis_app/screens/widgets_functions.dart';
import 'package:analysis_app/screens/ml_screens/prediction/prediction_target_selection_screen.dart';
import 'package:analysis_app/screens/ml_screens/clustering/clustering_screen.dart';

class MLTypeSelectionScreen extends StatefulWidget {
  const MLTypeSelectionScreen({super.key});

  @override
  State<MLTypeSelectionScreen> createState() => _MLTypeSelectionScreenState();
}

class _MLTypeSelectionScreenState extends State<MLTypeSelectionScreen> {
  String? selectedOption;

  void handleNext() {
    if (selectedOption == 'prediction') {
      navigateToPage(context, const PredictionTargetSelectionScreen());
    } else if (selectedOption == 'clustering') {
      navigateToPage(context, const ClusteringScreen());
    }
  }

  Widget buildOptionCard(String title, String value, IconData icon) {
    final bool isSelected = selectedOption == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedOption = value;
        });
      },
      child: Container(
        width: double.infinity,
        height: 170,
        margin: const EdgeInsets.symmetric(vertical: 15 ,horizontal: 15),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: Colors.blue.shade700),
            const SizedBox(width: 20),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.blue.shade800 : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Feature Selection"),
        backgroundColor: Colors.transparent,
        leading: iconButton(context),
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Choose what you want to do:",
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),
            buildOptionCard("Prediction", "prediction", Icons.auto_graph),
            buildOptionCard("Clustering", "clustering", Icons.scatter_plot),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: selectedOption == null ? null : handleNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 11, 95, 163),
                disabledBackgroundColor: Colors.grey.shade300,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Next",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
