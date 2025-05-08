import 'package:flutter/material.dart';
import 'package:analysis_app/screens/widgets_functions.dart';
import 'package:analysis_app/screens/upload_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});


  final String title;

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
        body: Center(

            child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      //crossAxisAlignment: CrossAxisAlignment.center,

      children: [
        SizedBox(height: screenHeight*0.08),

        Text(
            style: TextStyle(
                fontSize: headingTextSize, fontWeight: FontWeight.w500, color: Colors.black),
            textAlign: TextAlign.center,
            "Analyse, Virtualize & \n Clusterering"
            ),

        

        Image.asset(
          "assets/images/homeimg.png",
          height: screenHeight*0.34,
          width:  screenHeight*0.34,
        ),

        Padding(
            padding: const EdgeInsets.only(left: 30, right: 30),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  customText(
                      weight:FontWeight.w300,
                      alignText: TextAlign.justify,
                      size: 15,
                      color: const Color.fromARGB(255, 110, 107, 107),
                      text:
                          "Discover patterns and insights hidden in your data.Visualize trends, group information, and predict outcomes effortlessly. Simplify complex data analysis with easy-to-understand visuals. Make smarter decisions with clarity and confidence."
                  ),
                  SizedBox(height: 12,),
                  customText(
                    weight:FontWeight.w400,
                    color: const Color.fromARGB(255, 110, 107, 107),
                    lineSpace: 1.5,
                    size: 15,
                    text:
                    '* Analyse your data\n'
                    '* Make Clusters\n'
                    '* Train Model and Make Prediction\n' 
                    '* Get Statical summaries'
                  )

                ],
              )
          ),

        SizedBox(
            height: 40,
          ),

          customElevatedButton(
            xpadding: screenWidth*0.244,
            ypadding: screenHeight*0.012,
            text: "Get Started", 
            onPressed: ()=>navigateToPage(context,CSVUploader())
  
        ),

       SizedBox(height:screenHeight*0.06,)

      ],
    )
   )
  );
  }
}
