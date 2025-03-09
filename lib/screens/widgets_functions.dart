
import 'package:flutter/material.dart';

// Variable for makeing the content responsive
double screenWidth = 0;
double screenHeight = 0;
double sumWH = screenWidth +screenHeight ;
// Text heading size
final double headingTextSize = sumWH*0.019;

// Text Color
const Color smallTextColor =  Color.fromARGB(255, 110, 107, 107);
const Color customBlueColor = Color.fromARGB(255, 27, 79, 192);



void getScreenContext(BuildContext context){
     screenWidth = MediaQuery.of(context).size.width;
     screenHeight = MediaQuery.of(context).size.height;
}

// Fucntion for custom Text
Widget customText({
    required String text,
    double size =19,
    double? lineSpace,
    Color color=Colors.black,
    FontWeight? weight,
    TextAlign? alignText
  }) {
  return Text(
    textAlign: alignText,
    text,
    style: TextStyle(
      fontSize: size,
      height: lineSpace,
      fontWeight: weight,
      color: color,
    ),
  );
}


//This is for custom Eleveted Button
Widget customElevatedButton({
  required String text, // Button text
  required VoidCallback onPressed, // Button action
  Color backgroundColor = customBlueColor, // Background color
  Color textColor= Colors.white, // Text color
  double ypadding = 9,
  double xpadding = 75, // Padding around the button
  double? borderRadius, // Border radius
  double textsize = 21,
  IconData? icon,
}) {
  return ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: backgroundColor, // Background color
      foregroundColor: textColor, // Text color
      padding: EdgeInsets.symmetric(horizontal: xpadding,vertical: ypadding),// Padding
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius ?? 8.0), // Border radius
      ),
    ),
    child: 
      Row(
    mainAxisSize: MainAxisSize.min,
    children: [
    customText(text: text, size: textsize, weight: FontWeight.w200, color: Colors.white),
    
    if (icon != null) ...[
           SizedBox(width: 8), // Space between text and icon
           Icon(icon, size: 30, color: Colors.white),
          ],
         ],
     ),
  );
}


// Icoon button to pop
Widget iconButton(
  BuildContext context,
  
){
  return IconButton(
    onPressed: ()=>Navigator.pop(context), 
    icon: Icon(Icons.arrow_back_ios_new),
    iconSize: 20,
    );
}

// function for Navigating between pages
void navigateToPage(BuildContext context, Widget page) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => page),
  );
}


//outlined button -----reuseable
Widget customOutlinedButton({
  required String text,
  required  onpressed,
  double textSize = 21,
  String? icon,
}){
  return OutlinedButton(

    style: OutlinedButton.styleFrom(
      overlayColor: smallTextColor,
      alignment: Alignment.centerLeft,
      minimumSize: Size(screenWidth*0.89, screenHeight*0.065),
      shape:RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
      side: BorderSide(
        width: 2, 
        color:smallTextColor,
        )
    ),
    onPressed:onpressed,
        child:  Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
          if (icon != null) ...[
            Image.asset(icon, color: customBlueColor,height: 30,width: 30,),         
           SizedBox(width: 15), // Space between text and icon
          ],
          customText(text: text, size: 15, weight: FontWeight.w500, color: customBlueColor,  ),
    
         ],
     ),
  );
}
