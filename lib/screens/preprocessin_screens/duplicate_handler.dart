import 'dart:convert';
import 'package:bsmml/api/base_url.dart';
import 'package:bsmml/screens/upload_screen.dart';
import 'package:bsmml/components/widgets_functions.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:bsmml/screens/preprocessin_screens/fix_data_types_screen.dart';
import 'package:bsmml/screens/previe_data/preview_data.dart';

class RemoveDuplicatesScreen extends StatefulWidget {
  const RemoveDuplicatesScreen({super.key});

  @override
  State<RemoveDuplicatesScreen> createState() => _RemoveDuplicatesScreenState();
}

class _RemoveDuplicatesScreenState extends State<RemoveDuplicatesScreen> {
  final String apiUrl = '$baseUrl/remove-duplicates';
  bool isLoading = true;
  String message = '';

  Future<void> fetchCleanedData() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        setState(() {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Remove Duplicates',
          style: TextStyle(
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: iconButton(context),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(color: Colors.blue.shade600),
            )
          : Center(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      message,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 0, 60, 120),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      message.contains('No duplicates found')
                          ? "Great news! Your dataset has no duplicate rows, ensuring clean and consistent data."
                          : "Your dataset has been scanned for identical rows and removed any duplicates found.",
                      textAlign: TextAlign.center,
                      style:
                          const TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Next",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 0, 82, 150),
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      "You can now preview the cleaned dataset or proceed to fix incorrect data types.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 15, bottom: 17),
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
                  navigateToPage(context, FixDataTypesScreen());
                },
                icon: const Icon(Icons.arrow_forward, size: 22),
                label: const Text(
                  "Fix Data Types",
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
             IconButton(
          icon: Icon(Icons.home),
          color: const Color.fromARGB(255, 17, 57, 143),
          iconSize: 45,
          onPressed: () => navigateToPage(context, CSVUploader()),
        ),
          ],
        ),
      ),
    );
  }
}
