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

      switch (type) {
        case 'int':
          inputData[column] = int.tryParse(value);
          break;
        case 'float':
          inputData[column] = double.tryParse(value);
          break;
        case 'bool':
          inputData[column] = value.toLowerCase() == 'true';
          break;
        default:
          inputData[column] = value;
      }
    });

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/predict-custom'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'input_data': inputData}),
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() => predictionResult = responseBody['prediction'].toString());
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Prediction Result"),
            content: Text("Predicted value: $predictionResult"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              )
            ],
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${responseBody['error'] ?? 'Unknown error'}")),
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
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    ...columnsWithTypes.entries.map((entry) {
                      final column = entry.key;
                      final type = entry.value;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextFormField(
                          controller: _controllers[column],
                          keyboardType: type == 'int' || type == 'float'
                              ? TextInputType.number
                              : TextInputType.text,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Enter value for $column';
                            }
                            if ((type == 'int' && int.tryParse(value) == null) ||
                                (type == 'float' && double.tryParse(value) == null)) {
                              return 'Enter valid $type';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: "$column  ($type)",
                            border: OutlineInputBorder(),
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
                          backgroundColor: const Color.fromARGB(255, 11, 95, 163),
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
}
