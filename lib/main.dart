import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:analysis_app/screens/splash_screen.dart';
import 'package:analysis_app/screens/widgets_functions.dart' show getScreenContext;


void main() {
WidgetsFlutterBinding.ensureInitialized();

  // Lock the app in portrait mode
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    getScreenContext(context);
    return MaterialApp(
    
      debugShowCheckedModeBanner: false,
      title: 'Data Analysis',
      theme: ThemeData(
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 193, 183, 207)),
        useMaterial3: true,
      ),
      home:const SplashScreen(),
    );
  }
}

