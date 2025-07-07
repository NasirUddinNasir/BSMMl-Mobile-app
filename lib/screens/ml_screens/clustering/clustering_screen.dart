import 'package:analysis_app/api/base_url.dart';
import 'package:analysis_app/screens/previe_data/preview_data.dart';
import 'package:analysis_app/screens/widgets_functions.dart';
import 'package:flutter/material.dart';
import 'clustering_result_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ClusteringScreen extends StatefulWidget {
  const ClusteringScreen({super.key});

  @override
  ClusteringScreenState createState() => ClusteringScreenState();
}

class ClusteringScreenState extends State<ClusteringScreen> {
  final Map<String, String> modelEndpoints = {
    "KMeans": "$baseUrl/cluster/kmeans",
    "DBSCAN": "$baseUrl/cluster/dbscan",
    "Agglomerative": "$baseUrl/cluster/agglomerative",
    "GMM": "$baseUrl/cluster/gmm",
  };

  String? selectedModel;
  Map<String, dynamic> params = {};
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> newFormKey = GlobalKey<FormState>();
  Map<String, dynamic>? latestResult;

  bool isLoading = false;

  void setDefaultParams(String model) {
    switch (model) {
      case "KMeans":
        params = {
          "n_clusters": 3,
          "init": "k-means++",
          "max_iter": 300,
          "random_state": 42,
        };
        break;
      case "DBSCAN":
        params = {
          "eps": 0.5,
          "min_samples": 5,
        };
        break;
      case "Agglomerative":
        params = {
          "n_clusters": 3,
          "linkage": "ward",
        };
        break;
      case "GMM":
        params = {
          "n_components": 3,
          "covariance_type": "full",
          "max_iter": 100,
          "random_state": 42,
        };
        break;
    }
  }

  Future<void> runModel() async {
    if (!newFormKey.currentState!.validate()) return;
    newFormKey.currentState!.save();

    setState(() => isLoading = true);

    final endpoint = modelEndpoints[selectedModel]!;
    final response = await http.post(
      Uri.parse(endpoint),
      headers: {"Content-Type": "application/json"},
      body: json.encode(params),
    );

    setState(() => isLoading = false);

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (!mounted) return;
      latestResult = result;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ClusteringResultScreen(
            model: selectedModel!,
            result: result,
          ),
        ),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${response.reasonPhrase}")),
      );
    }
  }

  Widget buildParamField(String key, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4),
      child: TextFormField(
        key: ValueKey("$selectedModel-$key"),
        initialValue: value.toString(),
        style: TextStyle(fontSize: 16),
        decoration: InputDecoration(
          labelText: key,
          labelStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w400,
              color: Colors.blue.shade700),
          filled: true,
          fillColor: Colors.blue.shade50,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.blue.shade200, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
          ),
        ),
        onSaved: (val) {
          if (val != null) {
            if (value is int) {
              params[key] = int.tryParse(val) ?? value;
            } else if (value is double) {
              params[key] = double.tryParse(val) ?? value;
            } else {
              params[key] = val;
            }
          }
        },
      ),
    );
  }

  Widget buildModelSelection() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: modelEndpoints.keys.map((model) {
        final isSelected = selectedModel == model;
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedModel = model;
              setDefaultParams(model);
              newFormKey.currentState?.reset();
            });
          },
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue.shade500 : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(2, 3),
                ),
              ],
              border: Border.all(
                color: isSelected ? Colors.blue : Colors.grey.shade300,
                width: 2,
              ),
            ),
            child: Text(
              model,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: iconButton(context),
        title: const Text(
          "Clustering Models",
          style: TextStyle(fontSize: 20),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment(-1.05, 0),
                        child: const Text(
                          "Choose a clustering model:",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                      ),
                      const SizedBox(height: 20),
                      buildModelSelection(),
                      if (selectedModel != null) ...[
                        const SizedBox(height: 30),
                        Form(
                          key: newFormKey,
                          child: Column(
                            children: params.keys
                                .map((key) => buildParamField(key, params[key]))
                                .toList(),
                          ),
                        ),
                      ],
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 15, right: 15, bottom: 10),
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
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed:
                      (selectedModel == null || isLoading) ? null : runModel,
                  icon: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: Color.fromARGB(255, 18, 94, 156),
                          ),
                        )
                      : const Icon(Icons.play_arrow),
                  label: Text(
                    isLoading ? "Running..." : "Run Model",
                    style: const TextStyle(fontSize: 17),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 18, 63, 160),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 60,
                height: 48,
                child: ElevatedButton(
                  onPressed: (latestResult != null && selectedModel != null)
                      ? () {
                          navigateToPage(
                            context,
                            ClusteringResultScreen(
                              model: selectedModel!,
                              result: latestResult!,
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 17, 57, 143),
                    padding: EdgeInsets.zero,
                    alignment: Alignment.center,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 25,
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
