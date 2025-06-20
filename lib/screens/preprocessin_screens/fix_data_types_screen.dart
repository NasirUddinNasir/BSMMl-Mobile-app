import 'dart:convert';
import 'package:analysis_app/api/base_url.dart';
import 'package:analysis_app/screens/preprocessin_screens/encoding_screen.dart';
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
          // Refresh types to reflect new changes
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
                width: MediaQuery.of(context).size.width *0.9, // 50% of screen width
                child: Text(
                  column,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 7,),
              Text(
                'Current data Type: ${mapPandasTypeToBasic(originalType)}',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.black54),
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
          ? Center(
              child: CircularProgressIndicator(color: Colors.blue.shade700))
          : error.isNotEmpty
              ? Center(child: Text(error))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: ListView(
                    children: [
                      const Text(
                        'Select Correct Data Types for Each Column',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      ...currentTypes.entries.map(
                          (entry) => buildColumnWidget(entry.key, entry.value)),
                    ],
                  ),
                ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: ElevatedButton(
                    onPressed: () {
                      applyFixes();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 2, 143, 93),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Apply Data Type Fixes",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: ElevatedButton(
                    onPressed: () {
                      navigateToPage(context, EncodeScreen());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 11, 95, 163),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Next, Encoding",
                      style: TextStyle(fontSize: 18, color: Colors.white),
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
