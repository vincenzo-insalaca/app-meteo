import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:weather_icons/weather_icons.dart';

import '../../../../domain/entities/weather.dart';

class WeatherDetailsRow extends StatelessWidget {
  final Weather weather;

  const WeatherDetailsRow({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    final windKmh = (weather.windSpeedMs * 3.6).toStringAsFixed(1);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: RepaintBoundary(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _DetailItem(
                  icon: WeatherIcons.humidity,
                  label: 'Umidità',
                  value: '${weather.humidity}%',
                  semanticLabel: 'Umidità ${weather.humidity}%',
                ),
                Container(width: 1, height: 30, color: Colors.white24),
                _DetailItem(
                  icon: WeatherIcons.strong_wind,
                  label: 'Vento',
                  value: '$windKmh km/h',
                  semanticLabel: 'Vento $windKmh chilometri orari',
                ),
                Container(width: 1, height: 30, color: Colors.white24),
                _DetailItem(
                  icon: WeatherIcons.thermometer,
                  label: 'Percepita',
                  value: '${weather.feelsLike.round()}°',
                  semanticLabel:
                      'Temperatura percepita ${weather.feelsLike.round()} gradi',
                ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String semanticLabel;

  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      child: Column(
        children: [
          ExcludeSemantics(child: Icon(icon, color: Colors.white70, size: 24)),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
