import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:analysis_app/api/base_url.dart';
import 'package:analysis_app/global_state.dart';

class CustomPrediction extends StatefulWidget {
  const CustomPrediction({super.key});

  @override
  State<CustomPrediction> createState() => _CustomPredictionState();
}

class _CustomPredictionState extends State<CustomPrediction> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  bool isLoading = false;
  String? predictionResult;

  @override
  void initState() {
    super.initState();

    // Initialize controllers based on columnsWithTypes
    GlobalStore().columnsWithTypes.forEach((column, _) {
      _controllers[column] = TextEditingController();
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> sendPredictionRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    // Convert input values to correct types
    final Map<String, dynamic> inputData = {};
    GlobalStore().columnsWithTypes.forEach((column, type) {
      final value = _controllers[column]!.text.trim();

      switch (type.toLowerCase()) {
        case 'int':
        case 'integer':
          inputData[column] = int.tryParse(value) ?? 0;
          break;
        case 'float':
        case 'double':
          inputData[column] = double.tryParse(value) ?? 0.0;
          break;
        case 'bool':
        case 'boolean':
          inputData[column] = value.toLowerCase() == 'true';
          break;
        case 'str':
        case 'string':
        case 'categorical':
        case 'category':
        case 'object':
        default:
          // For string/categorical variables, keep original case and as string
          inputData[column] = value; // This will be properly quoted in JSON
          break;
      }
    });

    try { 
      final jsonPayload = jsonEncode({'input_data': inputData});      
      final response = await http.post(
        Uri.parse('$baseUrl/predict-custom'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonPayload,
      );

      if (response.statusCode == 200) {
        try {
          final responseBody = jsonDecode(response.body);
          setState(() => predictionResult =
              responseBody['predicted_value']);
          if (!mounted) return;
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text("Prediction Result"),
              content: Text(
                  "Predicted \n ${responseBody["target_column"]} : $predictionResult"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK"),
                )
              ],
            ),
          );
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error parsing response: $e")),
          );
        }
      } else {
        // Handle error responses
        String errorMessage = "Server Error (${response.statusCode})";
        
        try {
          final responseBody = jsonDecode(response.body);
          errorMessage = responseBody['error'] ?? errorMessage;
        } catch (e) {
          // If response is not JSON (like HTML error page), use the raw response
          errorMessage = "Server Error: ${response.body}";
        }
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final columnsWithTypes = GlobalStore().columnsWithTypes;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Custom Prediction"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: columnsWithTypes.isEmpty
          ? const Center(child: Text("No columns available for input"))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    const Text(
                      "Enter values for prediction:",
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    ...columnsWithTypes.entries.map((entry) {
                      final column = entry.key;
                      final type = entry.value;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextFormField(
                          controller: _controllers[column],
                          keyboardType: (type.toLowerCase() == 'int' || 
                                       type.toLowerCase() == 'integer' ||
                                       type.toLowerCase() == 'float' || 
                                       type.toLowerCase() == 'double')
                              ? TextInputType.number
                              : TextInputType.text,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Enter value for $column';
                            }
                            final lowerType = type.toLowerCase();
                            if ((lowerType == 'int' || lowerType == 'integer') &&
                                int.tryParse(value) == null) {
                              return 'Enter valid integer';
                            }
                            if ((lowerType == 'float' || lowerType == 'double') &&
                                double.tryParse(value) == null) {
                              return 'Enter valid number';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: "$column  ($type)",
                            border: OutlineInputBorder(),
                            hintText: _getHintText(type),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.send),
                        label: const Text("Predict"),
                        onPressed: isLoading ? null : sendPredictionRequest,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor:
                              const Color.fromARGB(255, 11, 95, 163),
                          foregroundColor: Colors.white,
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  String _getHintText(String type) {
    switch (type.toLowerCase()) {
      case 'int':
      case 'integer':
        return 'Enter a whole number';
      case 'float':
      case 'double':
        return 'Enter a decimal number';
      case 'bool':
      case 'boolean':
        return 'Enter true or false';
      case 'str':
      case 'string':
      case 'categorical':
      case 'category':
      case 'object':
        return 'Enter text/category';
      default:
        return 'Enter value';
    }
  }
}