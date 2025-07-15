import 'package:bsmml/screens/overview_screen.dart';
import 'package:bsmml/screens/preprocessin_screens/feature_selection_screen.dart';
import 'package:bsmml/screens/relation_screen.dart';
import 'package:bsmml/components/widgets_functions.dart';
import 'package:flutter/material.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: screenHeight * 0.055),
            Align(
              alignment: Alignment.centerLeft,
              child: iconButton(context),
            ),
            customText(
                text:"Data at Your Fingertips",
                size: headingTextSize,
                weight: FontWeight.w500,
                alignText: TextAlign.center),
            SizedBox(
              height: 20,
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 12),
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(8), // Slight rounding
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 15,
                    spreadRadius: 0.5,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/images/explore_data.jpg',
                  height: screenHeight * 0.29, // 
                  width: screenWidth *0.86,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(
              height: 25,
            ),
            Align(
              alignment: Alignment(-0.9, 0),
              child:
                  customText(text: 'Options:', size: 18),
            ),
            SizedBox(height: 20),
            customOutlinedButton(
                icon: 'assets/images/overview_icon.png',
                text: 'Data Overview',
                onpressed: () => navigateToPage(context, OverviewScreen())),
            SizedBox(height: 18),
            customOutlinedButton(
                icon: 'assets/images/Relationship_icon.png',
                text: 'Explore Relation in Data',
                onpressed: () => navigateToPage(context, RelationScreen())),
            SizedBox(height: 18),
            customOutlinedButton(
                icon: 'assets/images/pre_processing.png',
                text: 'Data Pre-Processing',
                onpressed: () =>
                    navigateToPage(context, FeatureSelectionScreen()))
          ],
        ),
      ),
    );
  }
}
