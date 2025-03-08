import 'package:analysis_app/screens/widgets_functions.dart';
import 'package:flutter/material.dart';

class PredictionScreen extends StatelessWidget {
  const PredictionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Center(
        child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                 customText(text: "Explore your Data or \nmake predictions" ,size: headingTextSize,weight: FontWeight.w500, alignText: TextAlign.center),
                 Image.asset(
                   height:250,
                   width: 250,
                  'assets/images/labeled.png'
                  ),
                  Align(
                    alignment: Alignment(-0.75,0),
                    child: customText(text: 'Select and option to continue:',size: 21),
                  ),

                  customOutlinedButton(
                    icon: 'assets/icons/overview.png',
                    text: 'Overview your data', 
                    onpressed: (){}
                    ),

                  customOutlinedButton(
                    icon: 'assets/icons/prediction.png',
                    text:'Explore Relation in Data', 
                    onpressed:(){}
                    ),    

                  customOutlinedButton(
                    // icon: '4.png',
                    text:'Make Predictions with models', 
                    onpressed: (){}
                    )          
            ],
          ),
      ),
      );
    }
}