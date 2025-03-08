import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:analysis_app/screens/widgets_functions.dart';
import 'package:analysis_app/screens/prediction_screen.dart';


class CSVUploader extends StatefulWidget {
  const CSVUploader({super.key,});

  @override
  CSVUploaderState createState() => CSVUploaderState();
}

class CSVUploaderState extends State<CSVUploader> {

  //Datatype selection control variables
   String selectDatatype = ""; 
   File? csvFile;
   String fileLastName = '';

  Future<void> _pickCSVFile() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.any, // Allow all file types
    withData: true, // Ensure we get file data
  );

  if (result != null) {
    PlatformFile file = result.files.first;

    // Check if the selected file has a .csv extension
    if (file.extension == "csv") {
      File pickedCSVFile = File(file.path!);
      String lastName = File(file.path!).uri.pathSegments.last;
      fileLastName = lastName;

      setState(() {
        csvFile = pickedCSVFile;
      });

      // ✅ Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("CSV File Selected: ${csvFile!.path}"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      // ❌ Show error if not CSV
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Invalid file type. Please select a CSV file."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  } else {
    // 🟠 Show message when user cancels file selection
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("File selection canceled"),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }
}
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      body: Center(
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children:[

            SizedBox(height: screenHeight*0.055),

            Align(
              alignment: Alignment.centerLeft,
              child: iconButton(context),
            ),

            SizedBox(height: screenHeight*0.010),

            customText(text: 'Upload a CSV file', size: headingTextSize,weight:FontWeight.w500,),

            SizedBox(height: 30),

            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                color: const Color.fromARGB(255, 250, 248, 248)
              ),
              
              child: 
              Padding(
                padding: EdgeInsets.all(sumWH*0.04),
                child: Image.asset(
                  height:155,
                  width: 155,
                  "assets/images/upload.png"
                  ),
              ),
            ),
            
            SizedBox(height: 20),

            customElevatedButton(
              xpadding: screenWidth*0.21,
              ypadding: screenHeight*0.0118,
              text: "Upload File", 
              onPressed: _pickCSVFile,
              icon: Icons.upload
              ),
            
             SizedBox(height: 10,),
            if (csvFile !=null )...[
              customText(text: 'Selected File:  $fileLastName',color: const Color.fromARGB(255, 47, 131, 49),size: 14)
            ]
            else...[
             customText(text: 'No CSV file Uploaded',size: 14)
            ],

            // Text(
            //   csvFile != null ? 'Selected File: $fileLastName' :'',
            //   style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500,),

            // ),

            SizedBox(height: 25),
            
            // padding for the selection option/ label or unlabel data
            Padding(
              padding: EdgeInsets.only(left: 17),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                // mainAxisAlignment: MainAxisAlignme
                children: [
                  
                  customText(text: "Select what you want to do:", size: 20, weight: FontWeight.w500),

                  RadioListTile(
                  fillColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
                                         if (states.contains(WidgetState.selected)) {
                                            return Colors.blue; // Selected color
                                          }
                                          return smallTextColor; // Default (unselected)
                                        },
                                      ),// Change fill color of the circle
                    // contentPadding: EdgeInsets.symmetric(horizontal: 20), // Reduce space between circle & text
                    visualDensity: VisualDensity(horizontal: -4, vertical: -4), 
                    title: customText(text:'Make predictions',color: smallTextColor,weight: FontWeight.w500,size: 17),
                    value: 'Make predictions', 
                    groupValue: selectDatatype, 
                    onChanged: (newvalue)=>setState(() {
                    selectDatatype = newvalue as String;
                    })
                  ),
                   
                  Transform.translate(
                    offset: Offset(0, -6), // Move the second radio button up
                    child: RadioListTile(
                            visualDensity: VisualDensity(horizontal: -4,vertical: -1), 
                             fillColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
                                         if (states.contains(WidgetState.selected)) {
                                            return Colors.blue; // Selected color
                                          }
                                          return smallTextColor; // Default (unselected)
                                        },
                                      ),// Change fill color of the circle
                            // contentPadding: EdgeInsets.symmetric(horizontal: -10), // Reduce space between circle & text
                            title: customText(text:"Make Clusters", color: smallTextColor,weight: FontWeight.w500,size: 17),
                            value: 'Make Clusters',
                            groupValue: selectDatatype,
                            onChanged: (newvalue) => setState(() {
                            selectDatatype = newvalue as String;
                            }),     
                       ),
                  ),
                ],
              )
            ),

            SizedBox(height: 10,),

            customElevatedButton(
              xpadding: screenWidth*0.273,
              ypadding: screenHeight*0.012,
              text: "Continue", 
              onPressed: ()=>navigateToPage(context,PredictionScreen())
      
            ),
          ],
        ),
      ),
    );
  }
}
