import 'dart:convert';
import 'package:bsmml/screens/previe_data/preview_data.dart';
import 'package:bsmml/components/widgets_functions.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../api/base_url.dart';

class RenameColumnScreen extends StatefulWidget {
  const RenameColumnScreen({super.key});

  @override
  State<RenameColumnScreen> createState() => _RenameColumnScreenState();
}

class _RenameColumnScreenState extends State<RenameColumnScreen> {
  Map<String, String> columnTypes = {};
  String? selectedColumn;
  final TextEditingController newNameController = TextEditingController();

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

  Future<void> renameColumn() async {
    final newName = newNameController.text.trim();

    if (selectedColumn == null || newName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Please select column and enter new name.")),
      );
      return;
    }

    final response = await http.post(
      Uri.parse('$baseUrl/change-column-name'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "old_name": selectedColumn,
        "new_name": newName,
      }),
    );

    final resData = jsonDecode(response.body);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(resData["message"] ?? "Unexpected response")),
    );

    if (resData["status"] == "success") {
      newNameController.clear();
      selectedColumn = null;
      fetchAllColumns();
    }
  }

  @override
  void dispose() {
    newNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: iconButton(context),
        title: const Text(
          "Rename Column",
          style: TextStyle(fontSize: 20),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Select a column to rename",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
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
              controller: newNameController,
              decoration: const InputDecoration(
                labelText: "New Column Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: renameColumn,
              icon: const Icon(Icons.edit),
              label: const Text("Change Name"),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 20,),
            ElevatedButton.icon(
              onPressed: () => navigateToPage(context, DataPreviewScreen()),
              icon: Icon(
                Icons.preview,
                color: Colors.white,
              ),
              label: Text(
                'Preview Data',
                style: TextStyle(color: Colors.white, ),
              ),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                padding: EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                backgroundColor: const Color.fromARGB(255, 47, 134, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
