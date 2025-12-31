class Weather {
  final String cityName;
  final double temperature;
  final String mainCondition;
  final int? humidity; // <--- Nuovo
  final double windSpeed; // <--- Nuovo
  final double feelsLike; // <--- Nuovo
  final double? tempMin; // <--- Nuovo
  final double? tempMax; // <--- Nuovo

  Weather({
    required this.cityName,
    required this.temperature,
    required this.mainCondition,
    required this.humidity,
    required this.windSpeed,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      cityName: json['name'],
      temperature: json['main']['temp'].toDouble(),
      mainCondition: json['weather'][0]['main'],
      humidity: json['main']['humidity'], // Mappato dal JSON
      windSpeed: json['wind']['speed'].toDouble(), // Mappato dal JSON
      feelsLike: json['main']['feels_like'].toDouble(), // Mappato dal JSON
      tempMin: json['main']['temp_min'].toDouble(), // Mappato dal JSON
      tempMax: json['main']['temp_max'].toDouble(), // Mappato dal JSON
    );
  }
}

class Forecast {
  final DateTime date;
  final double temp;
  final String condition;

  Forecast({required this.date, required this.temp, required this.condition});

  factory Forecast.fromJson(Map<String, dynamic> json) {
    return Forecast(
      date: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      // Usiamo .toDouble() su un cast num per evitare crash se il numero è intero
      temp: (json['main']['temp'] as num).toDouble(),
      condition: (json['weather'] != null && json['weather'].isNotEmpty)
          ? json['weather'][0]['main']
          : "Clear",
    );
  }
}
