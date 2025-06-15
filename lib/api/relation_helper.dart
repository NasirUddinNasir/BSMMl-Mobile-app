import 'dart:convert';
import 'package:http/http.dart' as http;

class RelationHelper {
  static Future<void> fetchRelationData({
    required String column1,
    required String column2,
    required String backendBaseUrl,
    required Function(bool loading) setLoading,
    required Function(String errorMsg) onError,
    required Function(
      String correlationText,
      String dataType,
      String heatmapUrl,
      String scatterUrl,
      String barplotUrl,
    )
        onSuccess,
  }) async {
    if (column1.isEmpty || column2.isEmpty) {
      onError("Please select both columns.");
      return;
    }

    setLoading(true);

    final url = '$backendBaseUrl/correlate?col1=$column1&col2=$column2';
    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 25)); 

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(response.body);

        String correlationText;
        String dataType = data['type'];
        String heatmapUrl = "";
        String scatterUrl = "";
        String barplotUrl = "";

        if (dataType == 'numeric') {
          correlationText =
              "Co-Relation Value: ${data['correlation'].toStringAsFixed(3)}\nRelation Type: ${data['relationType']}";
          heatmapUrl = '$backendBaseUrl${data['heatmap_url']}';
          scatterUrl = '$backendBaseUrl${data['scatter_url']}';
        } else {
          correlationText = "Non-numeric data. Showing barplot.";
          barplotUrl = '$backendBaseUrl${data['barplot_url']}';
          print(barplotUrl);
        }

        onSuccess(correlationText, dataType, heatmapUrl, scatterUrl, barplotUrl);
      } else {
        onError("Failed to fetch data. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      onError("Error: ${e.toString()}");
    } finally {
      setLoading(false);
    }
  }
}
