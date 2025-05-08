import 'package:analysis_app/screens/clustering/cluster_result.dart';
import 'package:analysis_app/screens/widgets_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ClusteringModelsScreen extends StatefulWidget {
  const ClusteringModelsScreen({super.key});

  @override
  State<ClusteringModelsScreen> createState() => ClusteringModelsScreenState();
}

class ClusteringModelsScreenState extends State<ClusteringModelsScreen> {
  // List of available clustering algorithms
  final List<String> algorithms = [
    'K-Mean Clustering',
    'Mean Shift',
    'DBSCAN',
    'GMM'
  ];
  
  // Currently selected algorithm
  String? selectedAlgorithm;
  
  // Map of algorithm parameters (will be populated based on selection)
  Map<String, dynamic> modelParameters = {};
  
  // Controllers for parameter input fields
  Map<String, TextEditingController> controllers = {};
  
  // Define only the most important parameters for each algorithm (max 4)
  final Map<String, Map<String, dynamic>> algorithmDefaultParams = {
    'K-Mean Clustering': {
      'n_clusters': 8,
      'max_iterations': 300,
      'init': 'k-means++',
      'n_init': 10,
    },
    'Mean Shift': {
      'bandwidth': 2.0,
      'bin_seeding': false,
      'min_bin_freq': 1,
      'cluster_all': true,
    },
    'DBSCAN': {
      'eps': 0.5,
      'min_samples': 5,
      'metric': 'euclidean',
      'leaf_size': 30,
    },
    'GMM': {
      'n_components': 1,
      'covariance_type': 'full',
      'reg_covar': 1e-6,
      'max_iterations': 100,
    },
  };
  
  // Parameter descriptions for the most important parameters
  final Map<String, String> paramDescriptions = {
    'n_clusters': 'Number of clusters to form',
    'max_iterations': 'Maximum number of iterations',
    'init': 'Method for initialization',
    'n_init': 'Number of times to run with different seeds',
    'bandwidth': 'Bandwidth used in the RBF kernel',
    'bin_seeding': 'Use bins for seeding',
    'min_bin_freq': 'Minimum frequency for a bin to be used',
    'cluster_all': 'Cluster all points or only core points',
    'eps': 'Maximum distance between two samples',
    'min_samples': 'Minimum samples in a neighborhood for a core point',
    'metric': 'Metric to use for distance calculation',
    'leaf_size': 'Leaf size for BallTree or KDTree',
    'n_components': 'Number of mixture components',
    'covariance_type': 'Type of covariance parameters',
    'reg_covar': 'Regularization added to covariance',
  };
  
  @override
  void initState() {
    super.initState();
  }
  
  @override
  void dispose() {
    // Dispose all controllers
    for (var controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
  
  // Initialize parameters when an algorithm is selected
  void initializeParameters(String algorithm) {
    // Clear existing controllers
    for (var controller in controllers.values) {
      controller.dispose();
    }
    controllers.clear();
    
    // Set model parameters to default values
    modelParameters = Map.from(algorithmDefaultParams[algorithm]!);
    
    // Create controllers for each parameter
    modelParameters.forEach((key, value) {
      controllers[key] = TextEditingController(text: value.toString());
    });
  }
  
  // Get parameter input widget based on parameter type
  Widget getParameterWidget(String param, dynamic value) {
    final description = paramDescriptions[param] ?? 'Parameter';
    
    // For boolean parameters
    if (value is bool) {
      return Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  param,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: (newValue) {
              setState(() {
                modelParameters[param] = newValue;
              });
            },
          ),
        ],
      );
    }
    // For string parameters with predefined options
    else if (param == 'init' && selectedAlgorithm == 'K-Mean Clustering') {
      List<String> options = ['k-means++', 'random'];
      
      return Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  param,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          DropdownButton<String>(
            value: value as String,
            onChanged: (newValue) {
              if (newValue != null) {
                setState(() {
                  modelParameters[param] = newValue;
                  controllers[param]!.text = newValue;
                });
              }
            },
            items: options.map((option) {
              return DropdownMenuItem<String>(
                value: option,
                child: Text(option),
              );
            }).toList(),
          ),
        ],
      );
    }
    // For covariance_type in GMM
    else if (param == 'covariance_type' && selectedAlgorithm == 'GMM') {
      List<String> options = ['full', 'tied', 'diag', 'spherical'];
      
      return Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  param,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          DropdownButton<String>(
            value: value as String,
            onChanged: (newValue) {
              if (newValue != null) {
                setState(() {
                  modelParameters[param] = newValue;
                  controllers[param]!.text = newValue;
                });
              }
            },
            items: options.map((option) {
              return DropdownMenuItem<String>(
                value: option,
                child: Text(option),
              );
            }).toList(),
          ),
        ],
      );
    }
    // For metric in DBSCAN
    else if (param == 'metric' && selectedAlgorithm == 'DBSCAN') {
      List<String> options = ['euclidean', 'manhattan', 'chebyshev', 'minkowski'];
      
      return Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  param,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          DropdownButton<String>(
            value: value as String,
            onChanged: (newValue) {
              if (newValue != null) {
                setState(() {
                  modelParameters[param] = newValue;
                  controllers[param]!.text = newValue;
                });
              }
            },
            items: options.map((option) {
              return DropdownMenuItem<String>(
                value: option,
                child: Text(option),
              );
            }).toList(),
          ),
        ],
      );
    }
    // For numeric parameters
    else {
      return Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  param,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 100,
            child: TextField(
              controller: controllers[param],
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                param.contains('_iterations') || param.contains('_samples') || param == 'n_clusters' || param == 'n_components' || param == 'min_bin_freq' || param == 'n_init' || param == 'leaf_size'
                    ? FilteringTextInputFormatter.digitsOnly
                    : FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              onChanged: (value) {
                if (value.isNotEmpty) {
                  if (value.contains('.')) {
                    modelParameters[param] = double.tryParse(value) ?? modelParameters[param];
                  } else {
                    if (param.contains('_iterations') || param.contains('_samples') || param == 'n_clusters' || param == 'n_components' || param == 'min_bin_freq' || param == 'n_init' || param == 'leaf_size') {
                      modelParameters[param] = int.tryParse(value) ?? modelParameters[param];
                    } else {
                      modelParameters[param] = double.tryParse(value) ?? modelParameters[param];
                    }
                  }
                }
              },
            ),
          ),
        ],
      );
    }
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
      body: Container(
        color: Colors.white,
        margin: const EdgeInsets.all(8),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 2),
                const Text(
                  'Clustering Models',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Select an algorithm of your choice:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Algorithm selection buttons
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: algorithms.map((algorithm) {
                    bool isSelected = selectedAlgorithm == algorithm;
                    return InkWell(
                      onTap: () {
                        setState(() {
                          selectedAlgorithm = algorithm;
                          initializeParameters(algorithm);
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected ? Colors.blue : Colors.grey[300]!,
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.white,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Text(
                          algorithm,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                
                const SizedBox(height: 24),
                
                // Model parameters section
                if (selectedAlgorithm != null) ...[
                  const Text(
                    'Model Parameters:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Parameter input fields
                  Expanded(
                    child: ListView(
                      children: modelParameters.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: getParameterWidget(entry.key, entry.value),
                        );
                      }).toList(),
                    ),
                  ),
                ] else ...[
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Please select an algorithm to view its parameters',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
                
                // Continue button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: selectedAlgorithm != null
                        ? () {
                            // Process selected algorithm and parameters
                            print('Selected Algorithm: $selectedAlgorithm');
                            print('Parameters: $modelParameters');
                            
                           navigateToPage(context, ClusteringResult());
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0A3C85),
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
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}