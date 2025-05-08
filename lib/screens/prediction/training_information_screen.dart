import 'package:flutter/material.dart';
import 'package:analysis_app/screens/widgets_functions.dart';
import 'package:analysis_app/screens/prediction/model_data.dart';


class TrainingInformationScreen extends StatefulWidget {
  const TrainingInformationScreen({super.key});

  @override
  State<TrainingInformationScreen> createState() => TrainingInformationScreenState();
}

class TrainingInformationScreenState extends State<TrainingInformationScreen> {
  // Dummy data for columns
  final List<String> allColumns = [
    'Age',
    'Income',
    'Experience',
    'Education',
    'Gender',
    'Location',
    'Marital Status',
    'Credit Score'
  ];
  
  // Selected target column
  String? targetColumn;
  
  // Columns selected to be dropped
  final Set<String> columnsToDrop = {};
  
  @override
  Widget build(BuildContext context) {
    // Create a list of available columns for dropping
    // (excluding the target column)
    List<String> availableForDrop = allColumns
        .where((column) => column != targetColumn)
        .toList();
    
    return Scaffold(
      appBar: AppBar(
        leading: iconButton(context),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Target Column',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'please select the column you want to predict',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 16),
              
              // Target column dropdown
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: targetColumn,
                    hint: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text('Column Name'),
                    ),
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    onChanged: (String? newValue) {
                      setState(() {
                        // If the new target was previously selected to drop, remove it
                        if (newValue != null) {
                          columnsToDrop.remove(newValue);
                        }
                        targetColumn = newValue;
                      });
                    },
                    items: allColumns.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Drop columns section
              const Text(
                'Drop columns',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'All selected columns will be dropped and will not use for training the model.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 16),
              
              // Checkboxes for columns to drop
              Expanded(
                child: ListView.builder(
                  itemCount: availableForDrop.length,
                  itemBuilder: (context, index) {
                    final column = availableForDrop[index];
                    return Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black12),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[50],
                      ),
                      margin: const EdgeInsets.only(bottom: 8),
                      child: CheckboxListTile(
                        title: Text(column),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        value: columnsToDrop.contains(column),
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              columnsToDrop.add(column);
                            } else {
                              columnsToDrop.remove(column);
                            }
                          });
                        },
                        controlAffinity: ListTileControlAffinity.trailing,
                      ),
                    );
                  },
                ),
              ),
              
              // Continue button
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: targetColumn != null ? () {
                      // Process selected target and columns to drop
                      print('Target Column: $targetColumn');
                      print('Columns to Drop: $columnsToDrop');
                      navigateToPage(context, PredictionModelDataInput());
                      
                      // Navigate to next screen or process data
                    } : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: customBlueColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}