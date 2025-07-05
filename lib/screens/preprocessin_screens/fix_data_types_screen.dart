import 'dart:convert';
import 'package:analysis_app/api/base_url.dart';
import 'package:analysis_app/screens/preprocessin_screens/encoding_screen.dart';
import 'package:analysis_app/screens/previe_data/preview_data.dart';
import 'package:analysis_app/screens/widgets_functions.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FixDataTypesScreen extends StatefulWidget {
  const FixDataTypesScreen({super.key});

  @override
  State<FixDataTypesScreen> createState() => _FixDataTypesScreenState();
}

class _FixDataTypesScreenState extends State<FixDataTypesScreen> {
  final String getTypesUrl = '$baseUrl/get-data-types';
  final String fixTypesUrl = '$baseUrl/fix-data-types';

  Map<String, String> currentTypes = {};
  Map<String, String> selectedTypes = {};
  bool isLoading = true;
  String error = '';
  bool applyEnabled = false;

  final List<String> typeOptions = [
    'int',
    'float',
    'bool',
    'string',
    'datetime'
  ];

  @override
  void initState() {
    super.initState();
    fetchDataTypes();
  }

  Future<void> fetchDataTypes() async {
    try {
      final response = await http.get(Uri.parse(getTypesUrl));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final Map<String, dynamic> types = jsonResponse['data_types'];

        setState(() {
          currentTypes =
              types.map((key, value) => MapEntry(key, value.toString()));
          selectedTypes = currentTypes
              .map((key, value) => MapEntry(key, mapPandasTypeToBasic(value)));
          isLoading = false;
          applyEnabled = false;
        });
      } else {
        setState(() {
          error = 'Failed to fetch data types';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error: $e';
        isLoading = false;
      });
    }
  }

  Future<void> applyFixes() async {
    final Map<String, String> changed = {};
    selectedTypes.forEach((key, value) {
      if (value != mapPandasTypeToBasic(currentTypes[key]!)) {
        changed[key] = value;
      }
    });

    if (changed.isEmpty) return;

    try {
      final response = await http.post(
        Uri.parse(fixTypesUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'type_map': changed}),
      );

      if (!mounted) return;

      final jsonResponse = jsonDecode(response.body);
      final String? message = jsonResponse['message'];
      final Map<String, dynamic>? errors = jsonResponse['errors'];

      if (response.statusCode == 200) {
        if (message == "Data types updated successfully.") {
          await fetchDataTypes();
        }
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Fix Data Types'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (message != null) Text(message),
                const SizedBox(height: 8),
                if (errors != null && errors.isNotEmpty) ...[
                  const Text('Errors:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  ...errors.entries.map((e) => Text('${e.key}: ${e.value}')),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: ${message ?? 'Unknown error'}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error occurred: $e')),
      );
    }
  }

  String mapPandasTypeToBasic(String pandasType) {
    if (pandasType.contains('int')) return 'int';
    if (pandasType.contains('float')) return 'float';
    if (pandasType.contains('bool')) return 'bool';
    if (pandasType.contains('datetime')) return 'datetime';
    return 'string';
  }

  bool hasChanges() {
    for (var key in currentTypes.keys) {
      if (selectedTypes[key] != mapPandasTypeToBasic(currentTypes[key]!)) {
        return true;
      }
    }
    return false;
  }

  Widget buildColumnWidget(String column, String originalType) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: Colors.blue.shade50,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: Text(
                  column,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 7),
              Text(
                'Current data Type: ${mapPandasTypeToBasic(originalType)}',
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 8),
          DropdownButton<String>(
            value: selectedTypes[column],
            isExpanded: true,
            items: typeOptions
                .map((type) => DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                selectedTypes[column] = value!;
                applyEnabled = hasChanges();
              });
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Fix Data Types',
          style: TextStyle(fontSize: 20),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        leading: iconButton(context),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.blue.shade700))
          : error.isNotEmpty
              ? Center(child: Text(error))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: ListView(
                    children: [
                      const Text(
                        'Select Correct Data Types for Each Column',
                        style:
                            TextStyle(fontSize: 17,fontWeight:FontWeight.w500),
                      ),
                      const SizedBox(height: 20),
                      ...currentTypes.entries.map(
                          (entry) => buildColumnWidget(entry.key, entry.value)),
                    ],
                  ),
                ),
      bottomNavigationBar: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.4,
                child: ElevatedButton(
                  onPressed: applyEnabled ? applyFixes : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 2, 143, 93),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Apply Fixes",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 15),
              child: Row(
                children: [
                  SizedBox(
                    width: 60,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        navigateToPage(context, DataPreviewScreen());
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
                      onPressed: () {
                        navigateToPage(context, EncodeScreen());
                      },
                      icon: const Icon(Icons.arrow_forward, size: 22),
                      label: const Text(
                        "Next, Encoding",
                        style: TextStyle(fontSize: 18),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
