import 'dart:convert';
import 'package:analysis_app/api/base_url.dart';
import 'package:analysis_app/screens/widgets_functions.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:analysis_app/screens/preprocessin_screens/fix_data_types_screen.dart';

class RemoveDuplicatesScreen extends StatefulWidget {
  const RemoveDuplicatesScreen({super.key});

  @override
  State<RemoveDuplicatesScreen> createState() => _RemoveDuplicatesScreenState();
}

class _RemoveDuplicatesScreenState extends State<RemoveDuplicatesScreen> {
  final String apiUrl = '$baseUrl/remove-duplicates';
  List<Map<String, dynamic>> previewData = [];
  bool isLoading = true;
  String message = '';

  Future<void> fetchCleanedData() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        setState(() {
          previewData = List<Map<String, dynamic>>.from(jsonResponse['preview']);
          message = jsonResponse['message'];
          isLoading = false;
        });
      } else {
        setState(() {
          message = 'Failed to remove duplicates';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        message = 'Error: $e';
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCleanedData();
  }

  Widget buildDataTable() {
    if (previewData.isEmpty) {
      return const Text("No data to preview.");
    }

    final columns = previewData[0].keys.toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(Colors.blue.shade100),
          columns: columns.map((key) => DataColumn(label: Text(key))).toList(),
          rows: previewData.map((row) {
            return DataRow(
              cells: columns.map((col) => DataCell(Text('${row[col]}'))).toList(),
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Remove Duplicates', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: iconButton(context),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.blue.shade600))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  color: Colors.blue.shade50,
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    message,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 0, 82, 150),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    "Data Preview",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 0, 82, 150),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: buildDataTable(),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12.0, left: 15, right: 15),
          child: ElevatedButton(
            onPressed: () {
              navigateToPage(context, FixDataTypesScreen());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 11, 95, 163),
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(11),
              ),
            ),
            child: const Text(
              "Next, Fix Data Types",
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
