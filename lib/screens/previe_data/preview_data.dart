import 'dart:convert';
import 'package:analysis_app/api/base_url.dart';
import 'package:analysis_app/screens/widgets_functions.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DataPreviewScreen extends StatefulWidget {
  const DataPreviewScreen({super.key});

  @override
  State<DataPreviewScreen> createState() => _DataPreviewScreenState();
}

class _DataPreviewScreenState extends State<DataPreviewScreen> {
  final String previewUrl = '$baseUrl/preview-data';
  List<Map<String, dynamic>> previewData = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchPreviewData();
  }

  Future<void> fetchPreviewData() async {
    try {
      final response = await http.get(Uri.parse(previewUrl));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        setState(() {
          previewData =
              List<Map<String, dynamic>>.from(jsonResponse['preview']);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to fetch preview data';
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Error: $e';
          isLoading = false;
        });
      }
    }
  }

  Widget buildTable() {
    if (previewData.isEmpty) {
      return const Center(child: Text('No data to display.'));
    }

    final columns = previewData.first.keys.toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: columns
            .map((col) => DataColumn(
                  label: Text(
                    col.length > 18 ? '${col.substring(0, 15)}...' : col,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ))
            .toList(),
        rows: previewData
            .map((row) => DataRow(
                  cells: columns
                      .map((col) => DataCell(
                            Text('${row[col] ?? ""}'),
                          ))
                      .toList(),
                ))
            .toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview Data', style: TextStyle(fontSize: 20)),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: iconButton(context),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(color: Colors.blue.shade700))
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : Padding(
                  padding: const EdgeInsets.all(12),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: buildTable(),
                  ),
                ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 15),
        child: FloatingActionButton(
          onPressed: () => Navigator.pop(context),
          backgroundColor: const Color.fromARGB(255, 11, 95, 163),
          shape: const CircleBorder(),
          child: const Icon(Icons.keyboard_arrow_down, size: 30,color: Colors.white,),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
