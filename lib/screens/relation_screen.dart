import 'package:flutter/material.dart';
import 'package:analysis_app/screens/widgets_functions.dart';


class RelationScreen extends StatefulWidget{
  const RelationScreen({super.key});
  
  
  @override
  RelationScreenState createState() => RelationScreenState();
}

class RelationScreenState extends State<RelationScreen>{

  TextEditingController controller = TextEditingController();
  List<String> columnValues = ["1", "2", "3", "4", "5", "6", "7"]; // Example data
  String selectedValue = ""; // Example data
  


  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: iconButton(context),
            ),
            SizedBox(height: 10,),
            customText(text: 'Explore Relaton in Data',size: headingTextSize),
            Align(
              alignment: Alignment.centerLeft,
              child: customText(text: 'Select two columns',size: 17,),
            ),
            customDropDownMenu(
              context: context, 
              controller: controller, 
              columnValues: columnValues, 
              selectedValue: selectedValue, 
              setStateCallback:() {
                setState(() {
                });
              } 
            ),
          customDropDownMenu(
              context: context, 
              controller: controller, 
              columnValues: columnValues, 
              selectedValue: selectedValue, 
              setStateCallback:() {
                setState(() {
                });
              } 
            ),
            
            
          ],
        ),
      ),

    );
  }
}