
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


// custom snakebar messanger
void customSnackBar(
  BuildContext context, 
  {
  required String message, 
  Color backgroundColor = Colors.red,
  Color textColor = Colors.white,
  }){
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: customText(text: message, size: 15, color: textColor),
      backgroundColor: backgroundColor,
    ),
  );
}


// Custom Dropdown Menu

Widget customDropDownMenu({
  required BuildContext context,
  required TextEditingController controller,
  required List<String> columnValues,
  required String selectedValue,
  required VoidCallback setStateCallback,
}){
  GlobalKey textFieldKey = GlobalKey(); // Unique key for positioning
  return TextField(
  key: textFieldKey, // Assign the key to the TextField
  controller: controller,
  readOnly: true,
  decoration: InputDecoration(
    labelText: "Select Column",
    suffixIcon: Icon(Icons.arrow_drop_down),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
    ),
  ),
  onTap: () {
    // Get the position of the TextField
    RenderBox renderBox = textFieldKey.currentContext!.findRenderObject() as RenderBox;
    Offset offset = renderBox.localToGlobal(Offset.zero); 
    double width = renderBox.size.width;
    double height = renderBox.size.height;


    showMenu(
      color: Colors.white,
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx, // Left position (same as TextField)
        offset.dy + height, // Appear directly below TextField
        offset.dx + width, // Match width with TextField
        offset.dy + height + 200, // Keep it within screen bounds
      ),
      items: columnValues.map((name) {
        return PopupMenuItem<String>(
          value: name,
          child: Container(
            width: width-20 , // Match width with TextField
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            decoration: BoxDecoration(

              color: Colors.blue.withValues(alpha: 0.2), // Light blue background
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              name,
              style: TextStyle(
                color: smallTextColor.withValues(alpha: 0.7), 
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }).toList(),
    ).then((selectedName) {
      if (selectedName != null) {
        setStateCallback();
          controller.text = selectedName;
          selectedValue= selectedName;
  }
  }
  );
      }
);
}