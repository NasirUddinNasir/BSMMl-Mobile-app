import 'dart:io';
import 'package:bsmml/screens/explore_screen.dart';
import 'package:bsmml/screens/fix_data_issues.dart';
import 'package:bsmml/screens/previe_data/preview_data.dart';
import 'package:bsmml/screens/user_mannual.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:bsmml/components/widgets_functions.dart';
import 'package:bsmml/api/upload.dart';

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
                SizedBox(height: screenHeight * 0.030),
                Card(
                  margin: EdgeInsets.symmetric(horizontal: 19),
                  elevation: 1,
                  color: const Color.fromARGB(255, 238, 251, 246),
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
                          color: const Color.fromARGB(255, 138, 136, 136),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Card(
                  elevation: 1,
                  color: const Color.fromARGB(255, 238, 251, 246),
                  child: Column(children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: sumWH * 0.09, vertical: sumWH * 0.03),
                      child: Image.asset(
                          height: 135, width: 135, "assets/images/upload.png"),
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
                SizedBox(height: screenHeight * 0.03),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: csvFile == null
                          ? null
                          : () => navigateToPage(context, DataPreviewScreen()),
                      icon: Icon(
                        Icons.preview,
                        color: Colors.white,
                      ),
                      label: Text(
                        'Preview Data',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        padding:
                            EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        backgroundColor: const Color.fromARGB(255, 47, 134, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: csvFile == null
                          ? null
                          : () => navigateToPage(context, ReplaceTextScreen()),
                      icon: Icon(
                        Icons.build,
                        color: Colors.white,
                      ),
                      label: Text(
                        'Fix Data Issues',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        padding:
                            EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        backgroundColor:
                            const Color.fromARGB(255, 204, 126, 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.03),
                GestureDetector(
                  onTap: () => navigateToPage(context, UserManualScreen()),
                  child: Text(
                    '📖 Read Out User Manual',
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.blue,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(
                  height: 25,
                ),
                customElevatedButton(
                  xpadding: screenWidth * 0.260,
                  ypadding: screenHeight * 0.012,
                  text: "Proceed ➝",
                  textsize: 20,
                  onPressed: () {
                    if (csvFile != null) {
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
