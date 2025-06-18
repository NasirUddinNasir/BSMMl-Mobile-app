import 'dart:io';
import 'package:analysis_app/screens/explore_screen.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:analysis_app/screens/widgets_functions.dart';
import 'package:analysis_app/api/upload.dart';
import 'package:analysis_app/api/handle_overview.dart';
import 'package:analysis_app/global_state.dart';

class CSVUploader extends StatefulWidget {
  const CSVUploader({super.key});

  @override
  CSVUploaderState createState() => CSVUploaderState();
}

class CSVUploaderState extends State<CSVUploader> {
  File? csvFile;
  String fileLastName = '';
  bool isUploading = false;

  Future<void> _pickCSVFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        withData: true,
      );

      if (result != null) {
        PlatformFile file = result.files.first;

        if (file.extension == "csv") {
          File pickedCSVFile = File(file.path!);
          String lastName = File(file.path!).uri.pathSegments.last;

          setState(() {
            isUploading = true;
          });

          int statusCode = await uploadCSVFile(pickedCSVFile);
          setState(() {
            isUploading = false;
          });

          if (mounted) {
            if (statusCode == 200) {
              setState(() {
                csvFile = pickedCSVFile;
                fileLastName = lastName;
              });
              customSnackBar(
                context,
                message: 'File selected successfully',
                backgroundColor: Colors.green,
              );
            } else if (statusCode == 408) {
              customSnackBar(
                context,
                message: 'Time out, check your internet!',
                backgroundColor: Colors.red,
              );
            } else {
              customSnackBar(
                context,
                message: 'Upload failed with status code $statusCode',
                backgroundColor: Colors.red,
              );
            }
          }
        } else {
          if (mounted) {
            customSnackBar(
              context,
              message: 'Invalid file type. Please select a CSV file',
              backgroundColor: Colors.red,
            );
          }
        }
      } else {
        if (mounted) {
          customSnackBar(
            context,
            message: 'No file selected',
            backgroundColor: Colors.orange,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        customSnackBar(
          context,
          message: 'An error occurred. Please try again',
          backgroundColor: Colors.red,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                SizedBox(height: screenHeight * 0.018),
                Align(
                  alignment: Alignment.centerLeft,
                  child: iconButton(context),
                ),
                SizedBox(height: screenHeight * 0.010),

                // 🔹 App Info Card
                Card(
                  margin: EdgeInsets.symmetric(horizontal: 19),
                  elevation: 1,
                  color: const Color.fromARGB(255, 250, 253, 252),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: sumWH * 0.02, vertical: sumWH * 0.02),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        customText(
                          text: "📊    B S M M L",
                          size: 19,
                          weight: FontWeight.w600,
                        ),
                        SizedBox(height: 6),
                        customText(
                          text:
                              "Upload your CSV dataset to begin exploring, cleaning, and analyzing your data on your mobile phone.",
                          size: 14,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 35),
                Card(
                  elevation: 2,
                  color: const Color.fromARGB(255, 250, 253, 252),
                  child: Column(children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: sumWH * 0.08, vertical: sumWH * 0.04),
                      child: Image.asset(
                          height: 150, width: 155, "assets/images/upload.png"),
                    ),
                    if (isUploading) ...[
                      CircularProgressIndicator(),
                    ] else if (csvFile != null) ...[
                      customText(
                          text: 'Selected File:  $fileLastName',
                          color: const Color.fromARGB(255, 47, 131, 49),
                          size: 14)
                    ] else ...[
                      customText(text: 'No CSV file Uploaded', size: 14)
                    ],
                    SizedBox(height: 5),
                    customElevatedButton(
                      textColor: smallTextColor,
                      xpadding: screenWidth * 0.08,
                      ypadding: screenHeight * 0.01,
                      text: "Upload CSV file",
                      onPressed: _pickCSVFile,
                      icon: Icons.upload,
                      backgroundColor: const Color.fromARGB(255, 52, 159, 173),
                    ),
                    SizedBox(height: 15),
                  ]),
                ),
                SizedBox(height: screenHeight * 0.05),
                customElevatedButton(
                  xpadding: screenWidth * 0.260,
                  ypadding: screenHeight * 0.012,
                  text: "Proceed ➝",
                  textsize: 20,
                  onPressed: () {
                    if (csvFile != null) {
                      handleOverview(context);
                      navigateToPage(context, ExploreScreen());
                    } else {
                      customSnackBar(
                        context,
                        message: 'Please upload a CSV file to continue',
                        backgroundColor: Colors.orange,
                      );
                    }
                  },
                ),
                IconButton(onPressed: ()=>print(GlobalStore().csvStats['duplicate_rows_count']), icon: Icon(Icons.arrow_back))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
