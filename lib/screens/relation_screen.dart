import 'package:flutter/material.dart';
import 'package:analysis_app/screens/widgets_functions.dart';


class RelationScreen extends StatefulWidget{
  const RelationScreen({super.key});
  
  
  @override
  RelationScreenState createState() => RelationScreenState();
}

class RelationScreenState extends State<RelationScreen>{
    List<String> columnValues = ["nasir", "ahmad", "hasnain", "jawad", "5", "6", "7"];

  TextEditingController controller = TextEditingController();
   TextEditingController controller2 = TextEditingController();


  String column1 = ""; 
   String column2 = ""; 
  


  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SizedBox(height: screenHeight*0.04),
            Align(
              alignment: Alignment.centerLeft,
              child: iconButton(context),
            ),
            customText(text: 'Explore Relaton in Data',size: headingTextSize-1,weight:FontWeight.w500),
            SizedBox(height: 7,),
              Align(
                alignment: Alignment(-0.82, 0),
                child: customText(text: 'Select two columns',size: 17, weight: FontWeight.w400,color: const Color.fromARGB(255, 80, 75, 75)),
              ),

            SizedBox(height: 6,),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              mainAxisSize: MainAxisSize.min,
              children: [

                  customDropDownMenu(
                    label: 'Column1',
                    context: context, 
                    controller: controller, 
                    columnValues: columnValues, 
                    onValueSelected: (value)=>setState(() {
                            column1 = value;
                            })
                ),
                SizedBox(width: 15,),
                  customDropDownMenu(
                    label: 'Column2',
                    context: context, 
                    controller: controller2, 
                    columnValues: columnValues, 
                    onValueSelected: (value)=>setState(() {
                            column1 = value;
                            })
                  ),
              ],  
            ),
            SizedBox(height: 12,),
            customElevatedButton(
              text: 'Show Relation', 
              ypadding: screenHeight*0.013,
              xpadding: screenWidth* 0.237,
              textsize: 18,
              textWeight: FontWeight.w500,
              onPressed: (){}
              ),
              SizedBox(height: 15,),

            Align(
              alignment: Alignment(-0.82, 0),
              child: customText(
                text: 'Co-Relation Result:  0.766 \nRelation Type:  Positive',
                size: 14, 
                weight: FontWeight.w500,
                color:smallTextColor,
                lineSpace:2 ,
                ),
            ),
            SizedBox(height: 10,),

          Align(
              alignment: Alignment(-0.86, 0),
              child: customText(text: 'Virtualazation',size: 17, weight: FontWeight.w500),
              
           ),

         SizedBox(height: 7,),

          Align(
              alignment: Alignment(-0.86, 0),
              child: customText(text: 'Scatter Plot',size: 15, weight: FontWeight.w500,color: smallTextColor),
              
           ),
          Image.asset(
                height: 120,
                width: 250,
                'assets/images/relation1.png'
            ),
           SizedBox(height: 15,),

          Align(
              alignment: Alignment(-0.86, 0),
              child: customText(text: 'Heat Map',size: 15, weight: FontWeight.w500,color: smallTextColor),
              
           ),
          Image.asset(
                height: 150,
                width: 300,
                'assets/images/relation2.png'

           ),

          SizedBox(height: 7,),
            customElevatedButton(
              text: 'Explore More', 
              ypadding: screenHeight*0.0132,
              xpadding: screenWidth* 0.24,
              textsize: 18,
              textWeight: FontWeight.w500,
              onPressed: (){}
          ),

          SizedBox(height:screenHeight*0.05,)


          ],
        ),
      ),

    );
  }
}