import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = "http://127.0.0.1:8000/api/";

  /// Common function for POST requests with optional token
  static Future<Map<String, dynamic>?> post(
      String endpoint, Map<String, dynamic> body, {String? token}) async {
    final url = Uri.parse("$baseUrl$endpoint");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    print(token);
    try {

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          if (token != null) "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );
       print(body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        print(response.body);
        return jsonDecode(response.body);
      } else {
        print("Error: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Exception: $e");
      return null;
    }
  }

  static Future<Map<String, dynamic>?> get(String endpoint) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final response = await http.get(
        Uri.parse("$baseUrl$endpoint"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        print(response.body);
        return jsonDecode(response.body);
      } else {
        print("GET $endpoint failed: ${response.body}");
        return null;
      }
    } catch (e) {
      print("GET $endpoint error: $e");
      return null;
    }
  }

}
