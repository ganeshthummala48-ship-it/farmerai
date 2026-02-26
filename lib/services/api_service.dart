import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // 🔑 YOUR API KEYS
  static const String marketApiKey =
      '579b464db66ec23bdd000001f5b1cddc55b948ae5f23f72870cde25e';
  static const String weatherApiKey =
      '2254ffc3bbd3014aec24a3f9463afebc';

  // 📊 MARKET PRICE API
  static Future<List<dynamic>> fetchMarketPrices({
    required String state,
    required String district,
    required String commodity,
  }) async {
    final url = Uri.parse(
      'https://api.data.gov.in/resource/9ef84268-d588-465a-a308-a864a43d0070'
      '?api-key=$marketApiKey'
      '&format=json'
      '&filters[state]=$state'
      '&filters[district]=$district'
      '&filters[commodity]=$commodity'
      '&limit=5',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['records'];
    } else {
      throw Exception('Failed to load market prices');
    }
  }

  // ☁️ WEATHER API
  static Future<Map<String, dynamic>> fetchWeather(String city) async {
    final url = Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather'
      '?q=$city&appid=$weatherApiKey',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load weather data');
    }
  }
}
