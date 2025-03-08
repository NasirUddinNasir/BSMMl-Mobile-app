import 'dart:async';
import 'package:flutter/material.dart';
import 'package:analysis_app/screens/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key}); // Constructor with key

  @override
  SplashScreenState createState() => SplashScreenState(); // Implement createState()
}

class SplashScreenState extends State<SplashScreen> {
  double _oposity = 0;

  @override
  void initState() {
    super.initState();
  //   // Start a timer to navigate after 3 seconds
  //   Timer(Duration(seconds: 3), () {
  //     if (mounted) { // Ensure the widget is still in the tree before navigation
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(builder: (context) => HomeScreen(title: "Home Screen")),
  //       );
  //     }
  //   });
  

  Future.delayed(Duration(seconds: 2),(){
    setState(() {
      _oposity = 1;
    });
  });

   Future.delayed(Duration(seconds: 5),(){
    setState(() {
      _oposity = 0;
      Navigator.pushReplacement(
         context,
         MaterialPageRoute(builder: (context) => HomeScreen(title: "Home Screen")));
    });
  });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:const Color.fromARGB(255, 27, 79, 192),
      body: Center(
        child: AnimatedOpacity(
          opacity: _oposity,
          duration: Duration(seconds: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset("assets/images/LOGO.png",width: 133,height: 133,),
              SizedBox(height: 28,),
              Text(
                 "Your Data Your Insights",
                 style: TextStyle(fontSize: 41, 
                                  color: Colors.white, 
                                  fontWeight:FontWeight.w500,
                                  letterSpacing: 1.5,
                                  ),
                 textAlign: TextAlign.center,
               ),

            ]
           
           ),
         ),
       ),
    );
  }
}
