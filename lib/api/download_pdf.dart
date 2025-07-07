import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:http/http.dart' as http;
import 'package:analysis_app/api/base_url.dart';

Future<Uint8List> generateClusteringPDF({
  required String model,
  required Map result,
}) async {
  final pdf = pw.Document();

  // Load custom fonts
  final poppinsRegular = pw.Font.ttf(
    await rootBundle.load('assets/fonts/Poppins-Regular.ttf'),
  );
  final poppinsBold = pw.Font.ttf(
    await rootBundle.load('assets/fonts/Poppins-Bold.ttf'),
  );

  // Fetch images
  final images = result["images"] ?? {};
  final mainImage = await _fetchImage("$baseUrl${images['main']}");
  final pieImage = await _fetchImage("$baseUrl${images['pie']}");
  final barImage = await _fetchImage("$baseUrl${images['bar']}");
  final histImage = await _fetchImage("$baseUrl${images['hist']}");

  final filtered = Map<String, dynamic>.from(result)..remove("images");

  // First Page – Cluster Summary
  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      theme: pw.ThemeData.withFont(
        base: poppinsRegular,
        bold: poppinsBold,
      ),
      build: (context) => [
        pw.Header(
          level: 0,
          child: pw.Text('Clustering Report - $model',
              style: pw.TextStyle(fontSize: 24)),
        ),
        pw.SizedBox(height: 12),
        pw.Text('Cluster Summary:',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            )),
        pw.SizedBox(height: 10),
        ...filtered.entries.take(15).map(
              (e) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 6),
                child: pw.Text("${e.key}: ${e.value}"),
              ),
            ),
      ],
    ),
  );

  // Second Page – Better Image Layout
  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      theme: pw.ThemeData.withFont(
        base: poppinsRegular,
        bold: poppinsBold,
      ),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Visualizations',
              style: pw.TextStyle(
                  fontSize: 20, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 12),

          // First Row
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              if (mainImage != null)
                _buildExpandedImageBox(
                    'Main Cluster Visualization', mainImage),
              if (pieImage != null)
                _buildExpandedImageBox('Pie Chart (Cluster Sizes)', pieImage),
            ],
          ),

          pw.SizedBox(height: 20),

          // Second Row
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              if (barImage != null)
                _buildExpandedImageBox('Bar Chart (Mean PCA)', barImage),
              if (histImage != null)
                _buildExpandedImageBox('Histogram', histImage),
            ],
          ),
        ],
      ),
    ),
  );

  return pdf.save();
}

pw.Widget _buildExpandedImageBox(String title, pw.ImageProvider image) {
  return pw.Expanded(
    child: pw.Container(
      margin: const pw.EdgeInsets.symmetric(horizontal: 5),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style:
                pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 5),
          pw.Image(image, height: 200), // You can increase this if needed
        ],
      ),
    ),
  );
}

Future<pw.ImageProvider?> _fetchImage(String url) async {
  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return pw.MemoryImage(response.bodyBytes);
    }
  } catch (_) {}
  return null;
}