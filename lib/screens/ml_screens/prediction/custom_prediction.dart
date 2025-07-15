import 'dart:convert';
import 'package:bsmml/components/widgets_functions.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:bsmml/api/base_url.dart';
import 'package:bsmml/global_state.dart';

class CustomPrediction extends StatefulWidget {
  const CustomPrediction({super.key});

  @override
  State<CustomPrediction> createState() => _CustomPredictionState();
}

class _CustomPredictionState extends State<CustomPrediction> {
  
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, GlobalKey> _fieldKeys = {};
  bool isLoading = false;
  String? predictionResult;

  @override
  void initState() {
    super.initState();
    GlobalStore().columnsWithTypes.forEach((column, _) {
      _controllers[column] = TextEditingController();
      _fieldKeys[column] = GlobalKey();
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
          setState(() => predictionResult = responseBody['predicted_value']);
          if (!mounted) return;
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              backgroundColor: Colors.blue.shade100,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              title: const Text(
                "Prediction Result",
                style: TextStyle(fontSize: 20),
              ),
              content: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "Predicted ${responseBody["target_column"]}: \n $predictionResult",
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w400),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "OK",
                    style: TextStyle(color: Color.fromARGB(255, 7, 59, 118)),
                  ),
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
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: iconButton(context),
        title: const Text(
          "Custom Prediction",
          style: TextStyle(fontSize: 20),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: columnsWithTypes.isEmpty
          ? const Center(child: Text("No columns available for input"))
          : SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade50, Colors.blue.shade100],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        "Enter values for prediction",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...columnsWithTypes.entries.map((entry) {
                      final column = entry.key;
                      final type = entry.value;

                      return Padding(
                        key: _fieldKeys[column],
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextFormField(
                          controller: _controllers[column],
                          keyboardType: (type.toLowerCase() == 'int' ||
                                  type.toLowerCase() == 'integer' ||
                                  type.toLowerCase() == 'float' ||
                                  type.toLowerCase() == 'double')
                              ? TextInputType.number
                              : TextInputType.text,
                          onTap: () {
                            Future.delayed(const Duration(milliseconds: 300),
                                () {
                              final keyContext =
                                  _fieldKeys[column]?.currentContext;
                              if (keyContext != null) {
                                if(!keyContext.mounted) return;
                                Scrollable.ensureVisible(keyContext,
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.easeInOut,
                                    alignment: 0.5);
                              }
                            });
                          },
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Enter value for $column';
                            }
                            final lowerType = type.toLowerCase();
                            if ((lowerType == 'int' ||
                                    lowerType == 'integer') &&
                                int.tryParse(value) == null) {
                              return 'Enter valid integer';
                            }
                            if ((lowerType == 'float' ||
                                    lowerType == 'double') &&
                                double.tryParse(value) == null) {
                              return 'Enter valid number';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: "$column  ($type)",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: Colors.blue, width: 2),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 200,
                      child: ElevatedButton.icon(
                        icon: isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  color: Color.fromARGB(255, 6, 76, 134),
                                ),
                              )
                            : const Icon(Icons.send),
                        label: const Text("Predict"),
                        onPressed: isLoading ? null : sendPredictionRequest,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor:
                              const Color.fromARGB(255, 212, 166, 1),
                          foregroundColor: Colors.white,
                          textStyle: const TextStyle(fontSize: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
    );
  }
}
