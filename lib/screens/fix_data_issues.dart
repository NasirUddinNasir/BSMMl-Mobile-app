import 'dart:convert';
import 'package:bsmml/screens/change_column_names.dart';
import 'package:bsmml/screens/previe_data/preview_data.dart';
import 'package:bsmml/components/widgets_functions.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../api/base_url.dart';

class ReplaceTextScreen extends StatefulWidget {
  const ReplaceTextScreen({super.key});

  @override
  State<ReplaceTextScreen> createState() => _ReplaceTextScreenState();
}

class _ReplaceTextScreenState extends State<ReplaceTextScreen> {
  final TextEditingController oldTextController = TextEditingController();
  final TextEditingController newTextController = TextEditingController();

  Map<String, String> columnTypes = {};
  String? selectedColumn;
  String? oldText;
  String? newText;

  @override
  void initState() {
    super.initState();
    fetchAllColumns();
  }

  Future<void> fetchAllColumns() async {
    final response = await http.get(Uri.parse('$baseUrl/get-all-columns'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        columnTypes = Map<String, String>.from(data["columns"]);
      });
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load columns")),
      );
    }
  }

  Future<void> replaceText() async {
    if (selectedColumn == null || oldText == null || newText == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    final response = await http.post(
      Uri.parse('$baseUrl/replace-text'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "column_name": selectedColumn,
        "old_text": oldText,
        "new_text": newText,
      }),
    );

    final resData = jsonDecode(response.body);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(resData["message"] ?? "Unexpected response")),
    );
    if (resData["status"] == "success") {
      oldTextController.clear();
      newTextController.clear();
      setState(() {
        oldText = null;
        newText = null;
      });
    }
  }

  @override
  void dispose() {
    oldTextController.dispose();
    newTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: iconButton(context),
          title: const Text(
            "Replace Text in Column",
            style: TextStyle(fontSize: 20),
          )),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Align(
                alignment: Alignment(-1, 0),
                child: Text(
                  "Select column to replace text",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                )),
            SizedBox(
              height: 18,
            ),
            DropdownButton<String>(
              value: selectedColumn,
              isExpanded: true,
              hint: const Text("Select a Column"),
              items: columnTypes.entries
                  .map((entry) => DropdownMenuItem(
                        value: entry.key,
                        child: Text("${entry.key} (${entry.value})"),
                      ))
                  .toList(),
              onChanged: (value) => setState(() => selectedColumn = value),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: oldTextController,
              decoration: const InputDecoration(
                labelText: "Text to Replace",
                border: OutlineInputBorder(),
              ),
              onChanged: (val) => oldText = val,
            ),
            const SizedBox(height: 15),
            TextField(
              controller: newTextController,
              decoration: const InputDecoration(
                labelText: "Replace With",
                border: OutlineInputBorder(),
              ),
              onChanged: (val) => newText = val,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.change_circle, color: Colors.white),
              label: const Text(
                "Replace Text",
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w500),
              ),
              onPressed: replaceText,
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                backgroundColor: Colors.blue.shade900, 
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            SizedBox(
              height: screenHeight * 0.04,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => navigateToPage(context, DataPreviewScreen()),
                  icon: Icon(
                    Icons.preview,
                    color: Colors.white,
                  ),
                  label: Text(
                    'Preview Data',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    backgroundColor: const Color.fromARGB(255, 47, 134, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => navigateToPage(context,RenameColumnScreen()),
                  icon: Icon(
                    Icons.view_column,
                    color: Colors.white,
                  ),
                  label: Text(
                    'Column Names',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    backgroundColor: const Color.fromARGB(255, 204, 126, 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
