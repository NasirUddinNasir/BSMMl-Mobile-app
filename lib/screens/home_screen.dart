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
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const SizedBox(height: 30),

                      // Title
                      Text(
                        "BSMML",
                        style: TextStyle(
                          fontSize: headingTextSize,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "(Basic Statistics & Models for Machine Learning)",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 25),

                      // Image with Shadow Box
                      Container(
                        height: screenHeight * 0.28,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          // boxShadow: const [
                          //   BoxShadow(
                          //     color: Colors.black26,
                          //     blurRadius: 10,
                          //     spreadRadius: 0.5,
                          //     offset: Offset(0, 1),
                          //   ),
                          // ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            "assets/images/data_preprocessing.png",
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Description Text
                      customText(
                        weight: FontWeight.w400,
                        alignText: TextAlign.justify,
                        size: 16,
                        color: const Color.fromARGB(255, 110, 107, 107),
                        text:
                            "BSMML helps you explore datasets, uncover insights, and train ML models – perfect for students and beginners in data science.",
                      ),

                      const SizedBox(height: 12),

                      // Features
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          customText(
                            weight: FontWeight.w400,
                            color: const Color.fromARGB(255, 110, 107, 107),
                            size: 15,
                            lineSpace: 1.3,
                            text: '✨ Upload CSV datasets',
                          ),
                          const SizedBox(height: 6),
                          customText(
                            weight: FontWeight.w400,
                            color: const Color.fromARGB(255, 110, 107, 107),
                            size: 15,
                            lineSpace: 1.3,
                            text: '📊 View descriptive statistics',
                          ),
                          const SizedBox(height: 6),
                          customText(
                            weight: FontWeight.w400,
                            color: const Color.fromARGB(255, 110, 107, 107),
                            size: 15,
                            lineSpace: 1.3,
                            text: '📈 Visualize trends and correlations',
                          ),
                          const SizedBox(height: 6),
                          customText(
                            weight: FontWeight.w400,
                            color: const Color.fromARGB(255, 110, 107, 107),
                            size: 15,
                            lineSpace: 1.3,
                            text: '🔍 Perform clustering on unlabeled data',
                          ),
                          const SizedBox(height: 6),
                          customText(
                            weight: FontWeight.w400,
                            color: const Color.fromARGB(255, 110, 107, 107),
                            size: 15,
                            lineSpace: 1.3,
                            text: '🤖 Train models & make predictions',
                          ),
                          const SizedBox(height: 6),
                          customText(
                            weight: FontWeight.w400,
                            color: const Color.fromARGB(255, 110, 107, 107),
                            size: 15,
                            lineSpace: 1.3,
                            text: '⚙️ Adjust ML parameters for better results',
                          ),
                        ],
                      ),
                      const Spacer(),

                      // Get Started Button
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: customElevatedButton(
                          xpadding: screenWidth * 0.25,
                          ypadding: screenHeight * 0.015,
                          text: "Get Started",
                          onPressed: () =>
                              navigateToPage(context, CSVUploader()),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
