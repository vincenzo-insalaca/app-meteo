import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_icons/weather_icons.dart';

import '../../../../domain/entities/weather.dart';

class CurrentWeatherCard extends StatelessWidget {
  final Weather weather;

  const CurrentWeatherCard({super.key, required this.weather});

  static IconData iconForCondition(String? condition) {
    return switch (condition?.toLowerCase()) {
      'clear' => WeatherIcons.day_sunny,
      'clouds' => WeatherIcons.cloudy,
      'rain' => WeatherIcons.rain,
      'drizzle' => WeatherIcons.showers,
      'thunderstorm' => WeatherIcons.thunderstorm,
      'snow' => WeatherIcons.snow,
      'mist' || 'fog' || 'haze' => WeatherIcons.fog,
      _ => WeatherIcons.day_sunny,
    };
  }

  String _buildSemanticLabel() {
    final dateStr = DateFormat('EEEE d MMMM', 'it_IT').format(DateTime.now());
    return '${weather.cityName}. Oggi $dateStr. '
        '${weather.temperature.round()} gradi. '
        '${weather.conditionDescription}. '
        'Massima ${weather.tempMax.round()}, minima ${weather.tempMin.round()}.';
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: _buildSemanticLabel(),
      child: ExcludeSemantics(
        child: Column(
      children: [
        // Città + data
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.location_on_outlined,
              color: Colors.white70,
              size: 30,
              semanticLabel: 'Posizione',
            ),
            const SizedBox(width: 10),
            Column(
              children: [
                Text(
                  weather.cityName,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w300,
                    color: Colors.white,
                    letterSpacing: 2.0,
                  ),
                ),
                Text(
                  'Oggi, ${DateFormat('EEEE d MMMM', 'it_IT').format(DateTime.now())}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Temperatura principale
        Text(
          '${weather.temperature.round()}°',
          style: const TextStyle(
            fontSize: 110,
            fontWeight: FontWeight.w200,
            color: Colors.white,
            height: 1,
          ),
        ),

        // Icona condizione + label (uppercase solo visivo, non per screen reader)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: ExcludeSemantics(
                child: BoxedIcon(
                  iconForCondition(weather.condition),
                  size: 50,
                  color: Colors.white,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Semantics(
                label: weather.conditionDescription,
                child: ExcludeSemantics(
                  child: Text(
                    weather.condition.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                      letterSpacing: 4,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Min / Max
        Text(
          'Max: ${weather.tempMax.round()}°  Min: ${weather.tempMin.round()}°',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
        ),
      ),
    );
  }
}
