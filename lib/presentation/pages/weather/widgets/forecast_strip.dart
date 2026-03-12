import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_icons/weather_icons.dart';

import '../../../../domain/entities/forecast_day.dart';
import 'current_weather_card.dart';

class ForecastStrip extends StatelessWidget {
  final List<ForecastDay> forecast;

  const ForecastStrip({super.key, required this.forecast});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: forecast.length,
        padding: const EdgeInsets.only(left: 15),
        itemBuilder: (context, index) {
          final day = forecast[index];
          final dayName = DateFormat('EEE', 'it_IT').format(day.date);
          final temp = day.temperature.round();

          return Semantics(
            label: '$dayName: $temp gradi, ${day.condition}',
            child: Container(
              width: 70,
              margin: const EdgeInsets.only(right: 15),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dayName,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  ExcludeSemantics(
                    child: BoxedIcon(
                      CurrentWeatherCard.iconForCondition(day.condition),
                      size: 22,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$temp°',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
