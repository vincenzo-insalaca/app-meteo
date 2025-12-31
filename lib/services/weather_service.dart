import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../models/weather_model.dart';

class WeatherService {
  // Cambiamo la BASE_URL per essere solo la radice dell'API
  static const String BASE_URL = 'https://api.openweathermap.org/data/2.5';
  final String apiKey = '71d22c11991246762c8d40fea700f267';

  // Meteo Attuale
  Future<Weather> getWeather(String cityName) async {
    final response = await http.get(
      Uri.parse('$BASE_URL/weather?q=$cityName&appid=$apiKey&units=metric'),
    );

    if (response.statusCode == 200) {
      return Weather.fromJson(jsonDecode(response.body));
    } else {
      // Questo print ti aiuterà a vedere l'errore nel terminale (es. 401 o 404)
      print("Errore Weather: ${response.statusCode} - ${response.body}");
      throw Exception('Errore caricamento meteo attuale');
    }
  }

  // Previsioni 5 Giorni
  Future<List<Forecast>> getForecast(String cityName) async {
    final response = await http.get(
      Uri.parse('$BASE_URL/forecast?q=$cityName&appid=$apiKey&units=metric'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List list = data['list'];

      List<Forecast> forecastList = [];
      // Prendiamo un dato ogni 8 (uno ogni 24 ore circa)
      for (int i = 0; i < list.length; i += 8) {
        forecastList.add(Forecast.fromJson(list[i]));
      }
      return forecastList;
    } else {
      // LOG FONDAMENTALE per capire perché fallisce
      print("Errore Forecast: ${response.statusCode} - ${response.body}");
      throw Exception('Errore caricamento previsioni');
    }
  }

  // 2. Ottieni la città attuale tramite GPS
  Future<String> getCurrentCity() async {
    // Chiedi il permesso
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    // Ottieni la posizione attuale
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // CORREZIONE QUI: Aggiunto /weather dopo BASE_URL
    final response = await http.get(
      Uri.parse(
        '$BASE_URL/weather?lat=${position.latitude}&lon=${position.longitude}&appid=$apiKey&units=metric',
      ),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['name'];
    } else {
      print("Errore Reverse Geocoding: ${response.statusCode}");
      return "Roma"; // Fallback
    }
  }

  // Aggiungi questo metodo nella classe WeatherService
  Future<List<String>> getCitySuggestions(String query) async {
    if (query.length < 3)
      return []; // Cerca solo dopo 3 caratteri per risparmiare API

    final response = await http.get(
      Uri.parse(
        'http://api.openweathermap.org/geo/1.0/direct?q=$query&limit=5&appid=$apiKey',
      ),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((item) {
        final city = item['name'];
        final country = item['country'];
        final state = item['state'] != null ? ", ${item['state']}" : "";
        return "$city$state, $country";
      }).toList();
    } else {
      return [];
    }
  }
}
