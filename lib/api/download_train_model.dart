import 'dart:io';
import 'package:analysis_app/api/base_url.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';

Future<bool> requestStoragePermission() async {
  if (Platform.isAndroid) {
    if (await Permission.storage.isGranted) return true;

    var status = await Permission.storage.request();
    if (status.isGranted) return true;

    if (await Permission.manageExternalStorage.isGranted) return true;

    var manageStatus = await Permission.manageExternalStorage.request();
    return manageStatus.isGranted;
  }
  return true;
}

Future<void> downloadTrainedModel(BuildContext context) async {
  final url = "$baseUrl/download-trained-model";
  final dio = Dio();

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

    final dir = Directory('/storage/emulated/0/Download');
    final now = DateTime.now();
    final formatted = DateFormat('yyyyMMdd_HHmmss').format(now);
    final filePath = "${dir.path}/trained_model_$formatted.pkl";

    int received = 0;
    int total = 0;

    late void Function(void Function()) setDialogState;

    if (!context.mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            setDialogState = setState;
            return AlertDialog(
              title: Text("Downloading Trained Model"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LinearProgressIndicator(
                    value: total > 0 ? received / total : null,
                  ),
                  SizedBox(height: 10),
                  Text(total > 0
                      ? "${(received / 1024).toStringAsFixed(1)} KB"
                          " / ${(total / 1024).toStringAsFixed(1)} KB"
                      : "Starting download..."),
                ],
              ),
            );
          },
        );
      },
    );

    await dio.download(
      url,
      filePath,
      onReceiveProgress: (rec, tot) {
        received = rec;
        total = tot;
        if (context.mounted) {
          setDialogState(() {});
        }
      },
    );

    if (context.mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Trained model downloaded to: $filePath")),
      );
    }
  } catch (e) {
    if (context.mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Download failed: $e")),
      );
    }
  }
}
