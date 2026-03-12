import 'package:flutter/material.dart';

class WeatherBackground extends StatelessWidget {
  final String? condition;
  final Widget child;

  const WeatherBackground({
    super.key,
    required this.condition,
    required this.child,
  });

  static List<Color> colorsForCondition(String? condition) {
    return switch (condition?.toLowerCase()) {
      'clear' => [const Color(0xFF56CCF2), const Color(0xFF2F80ED)],
      'clouds' => [const Color(0xFFBDC3C7), const Color(0xFF2C3E50)],
      'rain' || 'drizzle' || 'thunderstorm' => [
        const Color(0xFF373B44),
        const Color(0xFF4286f4),
      ],
      'snow' => [const Color(0xFFE6DADA), const Color(0xFF274046)],
      _ => [const Color(0xFF56CCF2), const Color(0xFF2F80ED)],
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = colorsForCondition(condition);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
        ),
      ),
      child: child,
    );
  }
}
