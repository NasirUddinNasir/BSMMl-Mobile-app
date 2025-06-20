import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:async';
import "package:analysis_app/global_state.dart";
import "package:analysis_app/api/base_url.dart";

Future<int> uploadCSVFile(File csvFile) async {
  int statusCode = 0;
  try {
    final uri = Uri.parse("$baseUrl/api/upload-csv/");
    final mimeType = lookupMimeType(csvFile.path);

    var request = http.MultipartRequest("POST", uri);
    request.files.add(await http.MultipartFile.fromPath(
      'file',
      csvFile.path,
      contentType: mimeType != null ? MediaType.parse(mimeType) : null,
    ));

    // Add timeout handling
    final streamedResponse = await request.send().timeout(
      Duration(seconds: 10),
      onTimeout: () {
        throw TimeoutException("The connection has timed out!");
      },
    );
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      GlobalStore().csvStats = responseData;
      // print(response.body);
      statusCode = response.statusCode;
    } 
    else {
      statusCode = response.statusCode;
    }
  } on TimeoutException catch (_) {
    statusCode = 408;
  } catch (e) {
    statusCode =1;
  }
  // print("status code returned is: $statusCode");
  return statusCode;
}
