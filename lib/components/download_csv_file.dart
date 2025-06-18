import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';


Future<void> downloadCleanedCSV(BuildContext context) async {
  final url = "http://10.0.2.2:8000/download-cleaned-data";
  final dio = Dio();

  try {
    // Ask for permission
    var status = await Permission.storage.request();
    if (!status.isGranted) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Storage permission denied")),
        );
      }
      return;
    }

    // Get app directory
    final dir = await getExternalStorageDirectory();
    final filePath = "${dir!.path}/cleaned_data.csv";

    // Download file
    await dio.download(url, filePath);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Downloaded to $filePath")),
      );
    }
  } catch (e) {
    debugPrint("Error while downloading: $e");
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Download failed")),
      );
    }
  }
}

