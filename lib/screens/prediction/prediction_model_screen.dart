import 'package:analysis_app/screens/widgets_functions.dart';
import 'package:flutter/material.dart';
import 'package:analysis_app/screens/prediction/training_information_screen.dart';
import 'package:analysis_app/global_state.dart';

class PredictionModelScreen extends StatefulWidget {
  const PredictionModelScreen({super.key});

  @override
  State<PredictionModelScreen> createState() => PredictionModelScreenState();
}

class PredictionModelScreenState extends State<PredictionModelScreen> {
  String? selectedClassificationModel;
  String? selectedRegressionModel;

  final List<String> classificationModels = [
    'Logistic Regression',
    'Random Forest',
    'Support Vector Machine',
    'Decision Tree',
  ];

  final List<String> regressionModels = [
    'Linear Regression',
    'Random Forest',
    'Decision Tree',
    'Neural Network',
    'Polynomial Regression',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color(0xFFE8E9FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: iconButton(context),
        title: const Text('', style: TextStyle(color: Colors.black)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'Model Selection',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Classification',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Models for discrete target values',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: classificationModels.map((model) {
                  final isSelected = model == selectedClassificationModel;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedClassificationModel = model;
                        GlobalStore().selectedPredictionModel = model;
                        selectedRegressionModel = null; // Clear other selection
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 9),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.black26,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        model,
                        style: TextStyle(
                          fontSize: 15,
                          color: isSelected ? Colors.white : Colors.black54,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              const Text(
                'Regression',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Models for continuous target values',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: regressionModels.map((model) {
                  final isSelected = model == selectedRegressionModel;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedRegressionModel = model;
                        selectedClassificationModel = null; 
                        GlobalStore().selectedPredictionModel = model;

                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 9),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.black26,
                          width: 1  ,
                        ),
                      ),
                      child: Text(
                        model,
                        style: TextStyle(
                          fontSize: 15,
                          color: isSelected ? Colors.white : Colors.black54,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (selectedClassificationModel != null ||
                          selectedRegressionModel != null)
                      ? () {
                          // final selectedModel = selectedClassificationModel ?? selectedRegressionModel;
                          navigateToPage(context, TrainingInformationScreen());
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0A3578),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              )
            ],
          ),
        ),
      ),
    );
  }
}
