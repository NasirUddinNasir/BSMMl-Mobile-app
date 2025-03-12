import 'package:analysis_app/screens/widgets_functions.dart';
import 'package:flutter/material.dart';
import 'package:analysis_app/screens/table.dart';
import 'dart:convert';

class OverviewScreen extends StatefulWidget{
  const OverviewScreen({super.key});


  @override
  OverviewScreenState createState() => OverviewScreenState();


}

class OverviewScreenState extends State<OverviewScreen>{
 Map<String, dynamic> jsonData = {};

  @override
  void initState() {
    super.initState();
    loadJsonData();
  }

  void loadJsonData() {
    // JSON data
    String jsonString = '''
    {
      "location": {
        "count": 3976.0,
        "mean": 2181.4957243461,
        "std": 1297.0296565787,
        "min": 0.0,
        "25%": 1058.75,
        "50%": 2098.5,
        "75%": 3342.25,
        "max": 4408.0
      },
      "Price": {
        "count": 3976.0,
        "mean": 72432.5286720322,
        "std": 52207.6509476425,
        "min": 7990.0,
        "25%": 39873.25,
        "50%": 58990.0,
        "75%": 84990.0,
        "max": 503890.0

    },
     "Area": {
        "count": 6976.0,
        "mean": 82432.5286720322,
        "std": 58207.6509476425,
        "min": 7990.0,
        "25%": 39873.25,
        "50%": 58890.0,
        "75%": 84990.0,
        "max": 503890.0
      },
       "Distance": {
        "count": 3976.0,
        "mean": 2181.4957243461,
        "std": 1297.0296565787,
        "min": 0.0,
        "25%": 1058.75,
        "50%": 2098.5,
        "75%": 3342.25,
        "max": 4408.0
      }
    }
    ''';

    setState(() {
      jsonData = json.decode(jsonString);
    });
  }

   
   @override
    Widget build(BuildContext context){
      Map<String,dynamic>  missingValues = {
        'Column' : 'Values',
        'Column 1' : 10,
        'Column 2' : 10,
        'Column 3' : 10,
        'Column 4' : 10,
        'Column 5' : 10,
        'Column 6' : 10,
        'Column 7' : 10,
        'Column 8' : 10,
        'Column 9' : 109,
        'Column 10' : 100,
        'Column 11' : 108,
        'Column 12' : 106,
        'Column 13' : 104,
        'Column 14' : 102,
      };

      Map<String,dynamic>  duplicateValues = {
        'Columns' : 'Values',
        'Column 1' : 10,
        'Column 2' : 10,
        'Column 3' : 10,
        'Column 4' : 10,
        'Column 5' : 10,
        'Column 6' : 10,
        'Column 7' : 10,
        'Column 8' : 10,
        'Column 9' : 109,
        'Column 10' : 100,
        'Column 11' : 108,
        'Column 12' : 106,
        'Column 13' : 104,
        'Column 14' : 102,
      };

      return Scaffold(
          body:Center(
            child: Column(
                children: [

                  SizedBox(height: screenHeight*0.040),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: iconButton(context),
                  ),
                  
                  
                  customText(text:'Data Overview',size: headingTextSize,weight: FontWeight.w500),

                  SizedBox(height: 8,),
                   Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 2,
                        margin: EdgeInsets.only(right: 10, left: 10),
                        color: Colors.white,
                        child: Padding(
                          padding:  EdgeInsets.only(right: 80, left: 25, top: 14, bottom: 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              customText(text: 'Total rows: 1000', size: 15,weight: FontWeight.w500),
                              customText(text: 'Total columns: 10', size: 15,weight: FontWeight.w500),
                              customText(text: 'Total missing values in Data: 5000', size: 15,weight: FontWeight.w500),
                            ],
                          ),
                        ),
                      ),
                    
                  // ),
                  SizedBox(height: 12,),

                  customTable(missingValues: missingValues, text: 'Missing values in columns'),                
                  SizedBox(height: 12),
                  customTable(missingValues: duplicateValues, text: 'Duplicate values in columns'),
                  SizedBox(height: 12),
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child:Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Descriptive Statistics', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),),
                        Text('Scroll', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.blueAccent),),
                      ],
                    ),  
                      ),
                  multiplelineTable(context: context, jsonData: jsonData)
                ],
              ) ,
          )
      );
    }
    
}