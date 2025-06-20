import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:analysis_app/api/base_url.dart';

/// Request storage permissions for Android (handles Android 11+)
Future<bool> requestStoragePermission() async {
  if (Platform.isAndroid) {
    if (await Permission.storage.isGranted) return true;

    var status = await Permission.storage.request();
    if (status.isGranted) return true;

    // Handle Android 11+ with MANAGE_EXTERNAL_STORAGE
    if (await Permission.manageExternalStorage.isGranted) return true;

    var manageStatus = await Permission.manageExternalStorage.request();
    return manageStatus.isGranted;
  }
  return true; // Assume iOS and others are okay
}

Future<void> downloadCleanedCSV(BuildContext context) async {
  final url = "$baseUrl/download-cleaned-data";
  final dio = Dio();
  dio.interceptors.add(LogInterceptor(responseBody: true));

  try {
    bool permissionGranted = await requestStoragePermission();
    if (!permissionGranted) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Storage permission denied")),
        );
      }
      return;
    }

    final dir = await getApplicationDocumentsDirectory(); 
    final filePath = "${dir.path}/cleaned_data.csv";
    debugPrint("Saving to: $filePath");

    Response response = await dio.download(url, filePath);
    debugPrint("Download status: ${response.statusCode}");

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

