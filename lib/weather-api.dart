import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherAPI {
  final String _baseUrl = "https://api.openweathermap.org";

  Future<dynamic> getData(String endpoint) async {
    final response = await http.get(Uri.parse(_baseUrl + endpoint));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }
}