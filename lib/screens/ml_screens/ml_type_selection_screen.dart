import 'package:bsmml/screens/previe_data/preview_data.dart';
import 'package:bsmml/screens/upload_screen.dart';
import 'package:flutter/material.dart';
import 'package:bsmml/components/widgets_functions.dart';
import 'package:bsmml/screens/ml_screens/prediction/prediction_target_selection_screen.dart';
import 'package:bsmml/screens/ml_screens/clustering/clustering_screen.dart';

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
        margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
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
        title: const Text("Prediction  |  Clustering",style: TextStyle(fontSize: 20)),
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
              "Choose what you want to do",
              style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            buildOptionCard("Prediction", "prediction", Icons.auto_graph),
            buildOptionCard("Clustering", "clustering", Icons.scatter_plot),
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
                  onPressed: selectedOption == null ? null : handleNext,
                  icon: const Icon(Icons.arrow_forward),
                  label: Text(
                    "Next",
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
