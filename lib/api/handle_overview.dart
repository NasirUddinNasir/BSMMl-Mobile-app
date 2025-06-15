import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:analysis_app/global_state.dart';
import 'package:flutter/material.dart';

Future<void> handleOverview(BuildContext context) async {
  try {
    final uri = Uri.parse("http://10.0.2.2:8000/data_overview/");

    final response = await http.post(uri,
      headers: {'Content-Type': 'application/json'},
    ).timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        throw TimeoutException("The connection has timed out!");
      },
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      GlobalStore().csvStats = responseData;
    } else {
      // Show error message for non-200 status codes
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Server error: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  } on TimeoutException catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Request timed out. Please try again. ${e.message}'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  } on http.ClientException catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Network error: ${e.message}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An unexpected error occurred'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}