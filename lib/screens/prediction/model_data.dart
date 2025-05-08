import 'package:analysis_app/screens/widgets_functions.dart';
import 'package:flutter/material.dart';

class PredictionModelDataInput extends StatefulWidget {
  const PredictionModelDataInput({super.key});

  @override
  State<PredictionModelDataInput> createState() =>
      PredictionModelDataInputState();
}

class PredictionModelDataInputState extends State<PredictionModelDataInput> {
  // Define the columns
  final List<String> columns = [
    'Age',
    'Income',
    'Experience',
    'Education',
    'Gender',
    'Location',
    'Marital Status',
    'Credit Score'
  ];

  // Map to store user input values for each column (using Strings)
  final Map<String, String> columnValues = {
    'Age': '',
    'Income': '',
    'Experience': '',
    'Education': '',
    'Gender': '',
    'Location': '',
    'Marital Status': '',
    'Credit Score': ''
  };

  // Controllers for input fields
  final Map<String, TextEditingController> controllers = {};

  // Track if prediction has been made
  bool hasPredicted = false;
  String predictedValue = '';
  double accuracy = 0.0;

  @override
  void initState() {
    super.initState();

    // Initialize controllers for each column
    for (String column in columns) {
      controllers[column] = TextEditingController();
    }
  }

  @override
  void dispose() {
    // Clean up controllers
    for (var controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  // Method to make prediction
  void makePrediction() {
    // Save all input values to the map
    for (String column in columns) {
      columnValues[column] = controllers[column]?.text ?? '';
    }

    // In a real app, you would send these values to your model
    // For demo purposes, we'll just generate a simple prediction
    setState(() {
      hasPredicted = true;

      // Simple mock prediction - in a real app this would come from model
      // Here we're just creating a dummy prediction for demonstration
      predictedValue = '70'; // Fixed prediction value matching the screenshot
      accuracy = 0.85; // Mock accuracy
    });

    // Print values for debugging
    print('Column Values:');
    columnValues.forEach((key, value) {
      print('$key: $value');
    });
    print('Predicted Value: $predictedValue');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: iconButton(context),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment(-1, 0),
                child: const Text(
                  'Model Trained',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment(-1, 0),
                child: const Text(
                  'Model trained on the provided data:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 8),
              const Text(
                'Provide the following information and make prediction.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 24),

              // Input fields for columns
              Expanded(
                child: ListView.builder(
                  itemCount: columns.length,
                  itemBuilder: (context, index) {
                    final column = columns[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 120,
                            child: Text(
                              '$column:',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: SizedBox(
                              height: 40,
                              child: TextField(
                                controller: controllers[column],
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide:
                                        const BorderSide(color: Colors.grey),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide:
                                        const BorderSide(color: Colors.grey),
                                  ),
                                ),
                                keyboardType: TextInputType.text,
                                onChanged: (value) {
                                  columnValues[column] = value;
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Prediction button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: makePrediction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0A3C85),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Predict Value',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              // Prediction results
              if (hasPredicted) ...[
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Text(
                      'Predicted Value: ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      predictedValue,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text(
                      'Accuracy: ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${(accuracy * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
