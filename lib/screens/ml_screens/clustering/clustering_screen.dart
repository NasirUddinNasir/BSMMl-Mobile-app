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
    "MeanShift": "$baseUrl/cluster/meanshift",
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
          "tol": 0.0001,
          "n_init": "auto",
          "algorithm": "lloyd",
          "random_state": 42,
        };
        break;
      case "DBSCAN":
        params = {
          "eps": 0.5,
          "min_samples": 5,
          "metric": "euclidean",
          "algorithm": "auto",
          "leaf_size": 30,
          "p": "",
          "n_jobs": "",
        };
        break;
      case "Agglomerative":
        params = {
          "n_clusters": 3,
          "linkage": "ward",
          "metric": "euclidean",
          "memory": "",
          "connectivity": "",
          "compute_full_tree": "true",
          "distance_threshold": "",
        };
        break;
      case "GMM":
        params = {
          "n_components": 3,
          "covariance_type": "full",
          "max_iter": 100,
          "n_init": 1,
          "init_params": "kmeans",
          "tol": 0.001,
          "reg_covar": 0.000001,
          "weights_init": "",
          "means_init": "",
          "precisions_init": "",
          "random_state": 42,
        };
        break;
      case "MeanShift":
        params = {
          "bandwidth": "",
          "seeds": "",
          "bin_seeding": "false",
          "min_bin_freq": 1,
          "cluster_all": "true",
          "n_jobs": "",
          "max_iter": 300,
        };
        break;
    }
  }

  Future<void> runModel() async {
    if (!newFormKey.currentState!.validate()) return;
    newFormKey.currentState!.save();

    // Apply parameter constraints
    if (selectedModel == "Agglomerative") {
      // If distance_threshold is set, n_clusters must be null
      if (params["distance_threshold"] != null && params["distance_threshold"].toString().isNotEmpty) {
        params["n_clusters"] = null;
        params["compute_full_tree"] = true;
      }
    }

    // Clean up parameters - convert empty strings to null and parse types
    Map<String, dynamic> cleanedParams = {};
    params.forEach((key, value) {
      if (value != null && value.toString().isNotEmpty) {
        // Try to parse as appropriate type
        if (value is String) {
          if (value.toLowerCase() == 'true') {
            cleanedParams[key] = true;
          } else if (value.toLowerCase() == 'false') {
            cleanedParams[key] = false;
          } else if (int.tryParse(value) != null) {
            cleanedParams[key] = int.parse(value);
          } else if (double.tryParse(value) != null) {
            cleanedParams[key] = double.parse(value);
          } else {
            cleanedParams[key] = value;
          }
        } else {
          cleanedParams[key] = value;
        }
      }
    });

    setState(() => isLoading = true);

    final endpoint = modelEndpoints[selectedModel]!;
    final response = await http.post(
      Uri.parse(endpoint),
      headers: {"Content-Type": "application/json"},
      body: json.encode(cleanedParams),
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

  Widget buildParamField(String key, dynamic value, {List<String>? dropdownOptions}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4),
      child: dropdownOptions != null
          ? DropdownButtonFormField<String>(
              key: ValueKey("$selectedModel-$key"),
              value: dropdownOptions.contains(value?.toString()) ? value?.toString() : dropdownOptions.first,
              style: TextStyle(fontSize: 16, color: Colors.black87),
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
              items: dropdownOptions.map((option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(option),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    params[key] = val;
                  });
                }
              },
              onSaved: (val) {
                if (val != null) {
                  params[key] = val;
                }
              },
            )
          : TextFormField(
              key: ValueKey("$selectedModel-$key"),
              initialValue: value?.toString() ?? "",
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
              validator: (val) {
                if (key == "n_clusters" && selectedModel == "Agglomerative") {
                  if (params["distance_threshold"] != null && 
                      params["distance_threshold"].toString().isNotEmpty && 
                      val != null && val.isNotEmpty) {
                    return "n_clusters must be empty when distance_threshold is set";
                  }
                }
                return null;
              },
              onSaved: (val) {
                if (val != null && val.isNotEmpty) {
                  params[key] = val;
                } else {
                  params[key] = "";
                }
              },
            ),
    );
  }

  List<Widget> buildParamFields() {
    List<Widget> fields = [];
    
    switch (selectedModel) {
      case "KMeans":
        fields.add(buildParamField("n_clusters", params["n_clusters"]));
        fields.add(buildParamField("init", params["init"], 
            dropdownOptions: ["k-means++", "random"]));
        fields.add(buildParamField("max_iter", params["max_iter"]));
        fields.add(buildParamField("tol", params["tol"]));
        fields.add(buildParamField("n_init", params["n_init"]));
        fields.add(buildParamField("algorithm", params["algorithm"], 
            dropdownOptions: ["lloyd", "elkan"]));
        fields.add(buildParamField("random_state", params["random_state"]));
        break;
        
      case "DBSCAN":
        fields.add(buildParamField("eps", params["eps"]));
        fields.add(buildParamField("min_samples", params["min_samples"]));
        fields.add(buildParamField("metric", params["metric"], 
            dropdownOptions: ["euclidean", "manhattan", "chebyshev", "minkowski"]));
        fields.add(buildParamField("algorithm", params["algorithm"], 
            dropdownOptions: ["auto", "ball_tree", "kd_tree", "brute"]));
        fields.add(buildParamField("leaf_size", params["leaf_size"]));
        if (params["metric"] == "minkowski") {
          fields.add(buildParamField("p", params["p"]=2));
        }
        fields.add(buildParamField("n_jobs", params["n_jobs"]));
        break;
        
      case "Agglomerative":
        // Show n_clusters only if distance_threshold is empty
        if (params["distance_threshold"] == null || params["distance_threshold"].toString().isEmpty) {
          fields.add(buildParamField("n_clusters", params["n_clusters"]));
        }
        fields.add(buildParamField("linkage", params["linkage"], 
            dropdownOptions: ["ward", "complete", "average", "single"]));
        
        if(params["linkage"]=="ward"){
          fields.add(buildParamField("metric", params["metric"], 
            dropdownOptions: ["euclidean"]));
        }else{
          fields.add(buildParamField("metric", params["metric"], 
            dropdownOptions: ["euclidean", "manhattan", "cosine"]));
        } 
        fields.add(buildParamField("compute_full_tree", params["compute_full_tree"]));
        fields.add(buildParamField("distance_threshold", params["distance_threshold"]));
        break;
        
      case "GMM":
        fields.add(buildParamField("n_components", params["n_components"]));
        fields.add(buildParamField("covariance_type", params["covariance_type"], 
            dropdownOptions: ["full", "tied", "diag", "spherical"]));
        fields.add(buildParamField("max_iter", params["max_iter"]));
        fields.add(buildParamField("n_init", params["n_init"]));
        fields.add(buildParamField("init_params", params["init_params"], 
            dropdownOptions: ["kmeans", "random"]));
        fields.add(buildParamField("tol", params["tol"]));
        fields.add(buildParamField("reg_covar", params["reg_covar"]));
        fields.add(buildParamField("random_state", params["random_state"]));
        break;
        
      case "MeanShift":
        fields.add(buildParamField("bandwidth", params["bandwidth"]));
        fields.add(buildParamField("bin_seeding", params["bin_seeding"]));
        fields.add(buildParamField("min_bin_freq", params["min_bin_freq"]));
        fields.add(buildParamField("cluster_all", params["cluster_all"]));
        fields.add(buildParamField("n_jobs", params["n_jobs"]));
        fields.add(buildParamField("max_iter", params["max_iter"]));
        break;
    }
    
    return fields;
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
                            children: buildParamFields(),
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