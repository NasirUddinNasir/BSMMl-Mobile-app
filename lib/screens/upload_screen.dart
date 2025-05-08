import 'dart:io';
import 'package:analysis_app/screens/prediction/training_information_screen.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:analysis_app/screens/widgets_functions.dart';
import 'package:analysis_app/screens/prediction/prediction_screen.dart';
import 'package:analysis_app/screens/clustering/cluster_screen.dart';


class CSVUploader extends StatefulWidget {
  const CSVUploader({super.key,});

  @override
  CSVUploaderState createState() => CSVUploaderState();
}

class CSVUploaderState extends State<CSVUploader> {

  //Datatype selection control variables
   String? predictORcluster; 
   File? csvFile;
   String fileLastName = '';

 Future<void> _pickCSVFile() async {
  try {
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
          customSnackBar(context, 
          message: 'File selected successfully',
          backgroundColor: Colors.green,
          );
        }
      } else {
        // ❌ Show error if not CSV
        if (mounted) {
          customSnackBar(
            context, 
            message: 'Invalid file type. Please select a CSV file',
            backgroundColor: Colors.red,
          );
        }
      }
    } else {
      // 🟠 Show message when user cancels file selection
      if (mounted) {
        customSnackBar(
          context, 
          message: 'No file selected',
          backgroundColor: Colors.orange,
          );
      }
    }
  } catch (e) {
    // 🔴 Handle unexpected errors
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

                        // padding for the selection option/ label or unlabel data
            Card(
                margin: EdgeInsets.symmetric(horizontal: 19),
                elevation: 1,
                color: const Color.fromARGB(255, 250, 253, 252),
              child: Padding(
                  padding: EdgeInsets.symmetric(horizontal:sumWH*0.02,vertical: sumWH*0.01),
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
                      contentPadding: EdgeInsets.symmetric(horizontal: 28), // Reduce space between circle & text
                      visualDensity: VisualDensity(horizontal: -4, vertical: -4), 
                      title: customText(text:'Make Predictions',color: smallTextColor,weight: FontWeight.w500,size: 18),
                      value: 'Make Predictions', 
                      groupValue: predictORcluster, 
                      onChanged: (newvalue)=>setState(() {
                      predictORcluster = newvalue as String;
                      })
                    ),
                     
                    Transform.translate(
                      offset: Offset(0, -4), // Move the second radio button up
                      child: RadioListTile(
                              visualDensity: VisualDensity(horizontal: -4,vertical: -1), 
                               fillColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
                                           if (states.contains(WidgetState.selected)) {
                                              return Colors.blue; // Selected color
                                            }
                                            return smallTextColor; // Default (unselected)
                                          },
                                        ),
                              contentPadding: EdgeInsets.symmetric(horizontal: 28), // Reduce space between circle & text
                              title: customText(text:"Make Clusters", color: smallTextColor,weight: FontWeight.w500,size: 18),
                              value: 'Make Clusters',
                              groupValue: predictORcluster,
                              onChanged: (newvalue) => setState(() {
                              predictORcluster = newvalue as String;
                              }),     
                         ),
                    ),
                  ],
                ),
              )
            ),

            SizedBox(height: 35),

            // customText(text: 'Upload your CSV file', size: 19,weight:FontWeight.w500,),

            SizedBox(height: 5),

            Card(
              elevation: 2,
              color:const Color.fromARGB(255, 250, 253, 252),
              
              child: Column(
                children:[
                  Padding(
                  padding: EdgeInsets.symmetric(horizontal:sumWH*0.08,vertical: sumWH*0.04),
                  child: Image.asset(
                    height:155,
                    width: 155,
                    "assets/images/upload.png"
                    ),
                ),
                 
                 if (csvFile !=null )...[
                    customText(text: 'Selected File:  $fileLastName',color: const Color.fromARGB(255, 47, 131, 49),size: 14)
                  ]
                  else...[
                  customText(text: 'No CSV file Uploaded',size: 14)
                  ],

                  SizedBox(height: 5),

                  customElevatedButton(
                    textColor:smallTextColor,
                    xpadding: screenWidth*0.08,
                    ypadding: screenHeight*0.01,
                    text: "Upload csv file", 
                    onPressed: _pickCSVFile,
                    icon: Icons.upload,
                    backgroundColor: const Color.fromARGB(255, 52, 159, 173),
                   ),
                  
                  SizedBox(height: 15,),

                ]
              ),
            ),
            
           
            SizedBox(height: screenHeight*0.05,),

            customElevatedButton(
              xpadding: screenWidth*0.273,
              ypadding: screenHeight*0.012,
              text: "Continue", 
              onPressed: (){
                if(csvFile != null && predictORcluster == 'Make Predictions'){
                  navigateToPage(context, PredictionScreen());
                }
                else if(csvFile != null && predictORcluster == 'Make Clusters'){
                  navigateToPage(context, ClusterScreen());
                }
                else{
                  if(predictORcluster==null){
                    customSnackBar(
                      context, 
                      message: 'Please select an option fist',
                      backgroundColor: Colors.orange,
                      );
                  }
                  else{
                    customSnackBar(
                      context, 
                      message: 'Please upload a CSV file to Continue',
                      backgroundColor: Colors.orange,
                      );
                  }
                }
              }
            ),
          // This button is just to navigate and will be removed
          IconButton(
            onPressed: (){
              navigateToPage(context, TrainingInformationScreen());
            }, 
            icon: Icon(Icons.arrow_forward),
            )
          ],
        ),
      ),
    );
  }
}
