import 'package:analysis_app/screens/upload_screen.dart';
import 'package:flutter/material.dart';
import 'package:analysis_app/global_state.dart';
import 'package:analysis_app/screens/widgets_functions.dart';
import 'package:analysis_app/api/relation_helper.dart';
import 'package:analysis_app/components/image_zooming.dart';
import 'package:analysis_app/api/base_url.dart';

class RelationScreen extends StatefulWidget {
  const RelationScreen({super.key});

  @override
  RelationScreenState createState() => RelationScreenState();
}

class RelationScreenState extends State<RelationScreen> {
  TextEditingController controller = TextEditingController();
  TextEditingController controller2 = TextEditingController();

  String column1 = "";
  String column2 = "";

  String correlationText = "";
  String dataType = "";
  String heatmapUrl = "";
  String scatterUrl = "";
  String barplotUrl = "";
  bool isLoading = false;

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  void handleShowRelation() {
    RelationHelper.fetchRelationData(
      column1: column1,
      column2: column2,
      backendBaseUrl: baseUrl,
      setLoading: (value) => setState(() => isLoading = value),
      onError: (message) {
        setState(() => correlationText = "");
        showSnackBar(message);
      },
      onSuccess: (text, type, heat, scatter, barplot) {
        setState(() {
          correlationText = text;
          dataType = type;
          heatmapUrl = heat;
          scatterUrl = scatter;
          barplotUrl = barplot;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment(-1.11, 0),
                    child: iconButton(context),
                  ),
                  customText(
                      text: 'Explore relationship',
                      size: headingTextSize,
                      weight: FontWeight.w500),
                  SizedBox(
                    height: 8,
                  ),
                  const SizedBox(height: 7),
                  customText(
                    text: 'Select two columns',
                    size: 17,
                    weight: FontWeight.w400,
                    color: const Color.fromARGB(255, 80, 75, 75),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: customDropDownMenu(
                          label: 'Column1',
                          context: context,
                          controller: controller,
                          columnValues: List<String>.from(
                              GlobalStore().csvStats['columns']),
                          onValueSelected: (value) =>
                              setState(() => column1 = value),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: customDropDownMenu(
                          label: 'Column2',
                          context: context,
                          controller: controller2,
                          columnValues: List<String>.from(
                              GlobalStore().csvStats['columns']),
                          onValueSelected: (value) =>
                              setState(() => column2 = value),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: customElevatedButton(
                      text: 'Show Relation',
                      ypadding: screenHeight * 0.013,
                      xpadding: screenWidth * 0.20,
                      textsize: 18,
                      textWeight: FontWeight.w500,
                      onPressed: handleShowRelation,
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Body for Graphs and Results
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (correlationText.isNotEmpty)
                      customText(
                        text: correlationText,
                        size: 15,
                        weight: FontWeight.w500,
                        color: smallTextColor,
                        lineSpace: 2,
                      ),
                    const SizedBox(height: 16),
                    if (dataType == 'numeric') ...[
                      customText(
                        text: 'Scatter Plot',
                        size: 16,
                        weight: FontWeight.w600,
                        color: smallTextColor,
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 280,
                        width: double.infinity,
                        child: zoomableImage(scatterUrl),
                      ),
                      const SizedBox(height: 20),
                      customText(
                        text: 'Heat Map',
                        size: 16,
                        weight: FontWeight.w600,
                        color: smallTextColor,
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 280,
                        width: double.infinity,
                        child: zoomableImage(heatmapUrl),
                      ),
                    ] else if (dataType == 'categorical') ...[
                      customText(
                        text: 'Bar Plot',
                        size: 16,
                        weight: FontWeight.w600,
                        color: smallTextColor,
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 280,
                        width: double.infinity,
                        child: zoomableImage(barplotUrl),
                      ),
                    ],
                    if (!isLoading && !correlationText.isNotEmpty) ...[
                      Center(
                          child: Padding(
                              padding:
                                  EdgeInsets.only(top: screenHeight * 0.15),
                              child:
                                  Text("Please select two columns to begin")))
                    ]
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // Bottom Button
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: IconButton(
          icon: Icon(Icons.home),
          color: const Color.fromARGB(255, 17, 57, 143),
          iconSize: 35,
          onPressed: () => navigateToPage(context, CSVUploader()),
        ),
      ),
    );
  }
}
