import 'package:bsmml/components/widgets_functions.dart';
import 'package:flutter/material.dart';


Widget customTable({
  required Map<String, dynamic> missingValues,
  required String text,
}) {
  return Column(
    children: [
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
            ),
            Text(
              'Scroll Left',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.blueAccent),
            ),
          ],
        ),
      ),
      Container(
        width: screenWidth,
        margin: EdgeInsets.only(left: 10, right: 10, bottom: 10, top: 3),
        padding: EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 3,
              spreadRadius: 1,
              offset: Offset(0, 4),
            )
          ],
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: (missingValues.length.toDouble()) * 100,
            child: Table(
              border: TableBorder.all(
                color: Colors.blueAccent,
                width: 1.5,
                borderRadius: BorderRadius.circular(10),
              ),
              columnWidths: {
                0: FixedColumnWidth(120),
                1: FixedColumnWidth(120),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withAlpha(20),
                  ),
                  children: missingValues.keys.map((key) {
                    return Padding(
                      padding: EdgeInsets.all(5),
                      child: Text(
                        key,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                ),
                TableRow(
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  children: missingValues.values.map((value) {
                    return Padding(
                      padding: EdgeInsets.all(5),
                      child: Text(
                        value.toString(),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }).toList(),
                )
              ],
            ),
          ),
        ),
      )
    ],
  );
}






// Table for multiple rows and columns
Widget multiplelineTable({
  required BuildContext context,
  required Map<String, dynamic> jsonData,
}) {
  if (jsonData.isEmpty) {
    return Center(child: CircularProgressIndicator());
  }

  List<String> columnNames = jsonData.keys.toList();
  if (columnNames.isEmpty) return Center(child: Text("No data available"));

  List<String> rowLabels = jsonData[columnNames[0]].keys.toList();

  return Expanded(  // Constrains the height properly
    child: Container(
      margin: EdgeInsets.only(left: 10, right: 10, bottom: 20),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 3,
                          spreadRadius: 1,
                          offset: Offset(0, 4),
                        )
                      ],
                    ),

      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            border: TableBorder.all(color: Colors.blue,borderRadius: BorderRadius.circular(15)),
            
            columns: [
              DataColumn(label: Text("Stats", style: TextStyle(fontWeight: FontWeight.bold))),
              ...columnNames.map((col) => DataColumn(label: Text(col))),
            ],
            rows: rowLabels.map((rowLabel) {
              return DataRow(cells: [
                DataCell(Text(rowLabel, style: TextStyle(fontWeight: FontWeight.bold))),
                ...columnNames.map((col) {
                  var value = jsonData[col][rowLabel];
                  return DataCell(Text(value.toString()));
                }),
              ]);
            }).toList(),
          ),
        ),
      ),
    ),
  );
}