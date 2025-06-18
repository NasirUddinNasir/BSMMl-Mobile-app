import 'package:analysis_app/screens/widgets_functions.dart';
import 'package:flutter/material.dart';
import 'package:analysis_app/components/table.dart';
import 'package:analysis_app/global_state.dart';

class OverviewScreen extends StatefulWidget {
  const OverviewScreen({super.key});

  @override
  OverviewScreenState createState() => OverviewScreenState();
}

class OverviewScreenState extends State<OverviewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: GlobalStore().csvStats.isEmpty
          ? const CircularProgressIndicator()
          : Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(height: screenHeight * 0.040),

                Align(
                  alignment: Alignment.centerLeft,
                  child: iconButton(context),
                ),

                customText(
                    text: 'Data Overview',
                    size: headingTextSize,
                    weight: FontWeight.w500),

                SizedBox(
                  height: 8,
                ),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 2,
                  margin: EdgeInsets.only(right: 10, left: 10),
                  color: Colors.white,
                  child: Padding(
                    padding: EdgeInsets.only(
                        right: 80, left: 25, top: 14, bottom: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        customText(
                            text:
                                'Total Missing values: ${GlobalStore().csvStats['missing_values']}',
                            size: 15,
                            weight: FontWeight.w500),
                        customText(
                            text:
                                'Total rows: ${GlobalStore().csvStats['rows']}',
                            size: 15,
                            weight: FontWeight.w500),
                        customText(
                            text:
                                'Total columns: ${GlobalStore().csvStats['columns_length']}',
                            size: 15,
                            weight: FontWeight.w500),
                        customText(
                            text:
                               'Total Duplicate values: ${GlobalStore().csvStats['duplicate_rows_count']}',
                            size: 15,
                            weight: FontWeight.w500),
                      ],
                    ),
                  ),
                ),

                // ),
                SizedBox(
                  height: 12,
                ),

                customTable(
                    missingValues:
                        GlobalStore().csvStats["missing_values_per_column"],
                    text: 'Missing values in columns'),
                SizedBox(height: 12),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Descriptive Statistics',
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        'Scroll',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.blueAccent),
                      ),
                    ],
                  ),
                ),
                multiplelineTable(
                    context: context,
                    jsonData: GlobalStore().csvStats["column_statistics"])
              ],
            ),
    ));
  }
}
