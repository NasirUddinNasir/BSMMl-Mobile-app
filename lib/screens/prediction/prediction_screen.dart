import 'package:analysis_app/screens/overview_screen.dart';
import 'package:analysis_app/screens/relation_screen.dart';
import 'package:analysis_app/screens/widgets_functions.dart';
import 'package:flutter/material.dart';
import 'package:analysis_app/screens/prediction/prediction_model_screen.dart';

class PredictionScreen extends StatelessWidget {
  const PredictionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Center(
        child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                 SizedBox(height: screenHeight*0.045),

                 Align(
                    alignment: Alignment.centerLeft,
                    child: iconButton(context),
                  ),

                 SizedBox(height: 5,),

                 customText(text: "Explore your Data or \nmake predictions" ,size: headingTextSize,weight: FontWeight.w500, alignText: TextAlign.center),
                 Image.asset(
                   height:screenHeight*0.35,
                   width: screenWidth*0.8,
                  'assets/images/prediction.png'
                  ),
                  Align(
                    alignment: Alignment(-0.65,0),
                    child: customText(text: 'Select an option to continue:',size: 18),
                  ),

                  SizedBox(height: 20),


                  customOutlinedButton(
                    icon: 'assets/images/overview_icon.png',
                    text: 'Overview your data', 
                    onpressed: () => navigateToPage(context, OverviewScreen())
                    ),
                     
                  SizedBox(height: 18),

                  customOutlinedButton(
                    icon: 'assets/images/Relationship_icon.png',
                    text:'Explore Relation in Data', 
                    onpressed:()=>navigateToPage(context, RelationScreen())
                    ),   

                   SizedBox(height: 18), 

                  customOutlinedButton(
                    icon: 'assets/images/Prediction_icon.png',
                    text:'Make Predictions with models', 
                    onpressed: ()=> navigateToPage(context, PredictionModelScreen())
                    )          
            ],
          ),
      ),
      );
    }
}