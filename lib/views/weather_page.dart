import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_icons/weather_icons.dart'; // Importa il nuovo pacchetto
import '../models/weather_model.dart';
import '../services/weather_service.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final _weatherService = WeatherService();
  final _searchController = TextEditingController(); // <--- Nuovo controller
  Weather? _weather;
  List<Forecast> _forecast = []; // Sotto la variabile _weather
  bool _isLoading = true;

  // Funzione universale per caricare il meteo (GPS o Ricerca)
  _fetchWeather([String? cityName]) async {
    setState(() => _isLoading = true);
    try {
      // Se cityName è nullo, usa il GPS, altrimenti usa il nome fornito
      final targetCity = cityName ?? await _weatherService.getCurrentCity();
      final weather = await _weatherService.getWeather(targetCity);
      final forecast = await _weatherService.getForecast(targetCity);

      setState(() {
        _weather = weather;
        _forecast = forecast;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Città non trovata o errore di connessione"),
        ),
      );
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  // HELPER: Sceglie il gradiente di sfondo in base al meteo
  List<Color> _getBackgroundColors(String? condition) {
    if (condition == null) return [Colors.grey, Colors.blueGrey];

    switch (condition.toLowerCase()) {
      case 'clear':
        return [
          const Color(0xFF56CCF2),
          const Color(0xFF2F80ED),
        ]; // Azzurro cielo
      case 'clouds':
        return [
          const Color(0xFFBDC3C7),
          const Color(0xFF2C3E50),
        ]; // Grigio nuvoloso
      case 'rain':
      case 'drizzle':
      case 'thunderstorm':
        return [
          const Color(0xFF373B44),
          const Color(0xFF4286f4),
        ]; // Blu scuro pioggia
      case 'snow':
        return [
          const Color(0xFFE6DADA),
          const Color(0xFF274046),
        ]; // Bianco ghiaccio
      default:
        return [
          const Color(0xFF56CCF2),
          const Color(0xFF2F80ED),
        ]; // Default sereno
    }
  }

  // HELPER: Sceglie l'icona giusta (usando il pacchetto weather_icons)
  IconData _getWeatherIcon(String? condition) {
    if (condition == null) return WeatherIcons.na;

    switch (condition.toLowerCase()) {
      case 'clear':
        return WeatherIcons.day_sunny;
      case 'clouds':
        return WeatherIcons.cloudy;
      case 'rain':
        return WeatherIcons.rain;
      case 'drizzle':
        return WeatherIcons.showers;
      case 'thunderstorm':
        return WeatherIcons.thunderstorm;
      case 'snow':
        return WeatherIcons.snow;
      case 'mist':
      case 'fog':
        return WeatherIcons.fog;
      default:
        return WeatherIcons.day_sunny;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColors = _getBackgroundColors(_weather?.mainCondition);
    final currentIcon = _getWeatherIcon(_weather?.mainCondition);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: bgColors,
          ),
        ),
        child: SafeArea(
          child: Column(
            // Rimosso il Center globale per permettere il posizionamento in alto
            children: [
              _buildSearchBar(), // <--- La barra di ricerca in alto

              Expanded(
                // Usa Expanded per centrare il resto del contenuto
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : RefreshIndicator(
                        onRefresh: () async =>
                            await _fetchWeather(_weather?.cityName),
                        child: SingleChildScrollView(
                          // Per evitare errori su schermi piccoli quando esce la tastiera
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 20),
                              // Nome Città
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.location_on_outlined,
                                    color: Colors.white70,
                                    size: 30,
                                  ),
                                  const SizedBox(width: 10),
                                  _weather != null
                                      ? Column(
                                          children: [
                                            Text(
                                              _weather!.cityName.replaceAll(
                                                'Province of ',
                                                '',
                                              ),
                                              style: const TextStyle(
                                                fontSize: 28,
                                                fontWeight: FontWeight.w300,
                                                color: Colors.white,
                                                letterSpacing: 2.0,
                                              ),
                                            ),
                                            Text(
                                              "Oggi, ${DateFormat('EEEE d MMMM').format(DateTime.now())}", // Usa il pacchetto intl
                                              style: TextStyle(
                                                color: Colors.white70,
                                                fontWeight: FontWeight.w300,
                                              ),
                                            ),
                                          ],
                                        )
                                      : const SizedBox.shrink(),
                                ],
                              ),

                              // ... dentro il Column principale ...
                              if (_weather != null) ...[
                                const SizedBox(height: 20),
                                Text(
                                  '${_weather!.temperature.round()}°',
                                  style: const TextStyle(
                                    fontSize: 110,
                                    fontWeight: FontWeight
                                        .w200, // Più sottile = più premium
                                    color: Colors.white,
                                    height: 1,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: ImageFiltered(
                                        imageFilter: ImageFilter.blur(
                                          sigmaX: 0.5,
                                          sigmaY: 0.5,
                                        ),
                                        child: BoxedIcon(
                                          _getWeatherIcon(
                                            _weather?.mainCondition,
                                          ),
                                          size: 50,
                                          color: Colors.white,
                                          // Applichiamo un'ombra soffusa per farla staccare dallo sfondo
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: Text(
                                        _weather!.mainCondition.toUpperCase(),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white70,
                                          letterSpacing:
                                              4, // Spaziatura larga per un look moderno
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                _weather != null &&
                                        _weather!.tempMax != null &&
                                        _weather!.tempMin != null
                                    ? Text(
                                        "Max: ${_weather!.tempMax!.round()}°  Min: ${_weather!.tempMin!.round()}°", // Se hai i dati min/max
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                              ],

                              const SizedBox(height: 30),

                              // I tuoi dettagli extra funzionali
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(30),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                      sigmaX: 10,
                                      sigmaY: 10,
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.all(25),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(30),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.2),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          _buildExtraDetail(
                                            WeatherIcons.humidity,
                                            "Umidità",
                                            "${_weather!.humidity}%",
                                          ),
                                          Container(
                                            width: 1,
                                            height: 30,
                                            color: Colors.white24,
                                          ), // Separatore
                                          _buildExtraDetail(
                                            WeatherIcons.strong_wind,
                                            "Vento",
                                            "${(_weather!.windSpeed * 3.6).toStringAsFixed(1)} km/h",
                                          ),
                                          Container(
                                            width: 1,
                                            height: 30,
                                            color: Colors.white24,
                                          ), // Separatore
                                          _buildExtraDetail(
                                            WeatherIcons.thermometer,
                                            "Percepita",
                                            "${_weather!.feelsLike.round()}°",
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // ... sotto la Row dell'umidità e vento ...
                              const SizedBox(height: 40),

                              // LISTA PREVISIONI 5 GIORNI
                              SizedBox(
                                height: 120,
                                child: _forecast.isEmpty
                                    ? const Center(
                                        child: Text(
                                          "Caricamento previsioni...",
                                          style: TextStyle(
                                            color: Colors.white54,
                                          ),
                                        ),
                                      )
                                    : ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: _forecast.length,
                                        itemBuilder: (context, index) {
                                          final f = _forecast[index];
                                          // Helper per i nomi dei giorni (es. Lun, Mar)
                                          final dayName = [
                                            "Lun",
                                            "Mar",
                                            "Mer",
                                            "Gio",
                                            "Ven",
                                            "Sab",
                                            "Dom",
                                          ][f.date.weekday - 1];

                                          return Container(
                                            width: 70,
                                            margin: const EdgeInsets.only(
                                              left: 15,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(
                                                0.1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                color: Colors.white.withOpacity(
                                                  0.05,
                                                ),
                                              ),
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  dayName,
                                                  style: const TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                BoxedIcon(
                                                  _getWeatherIcon(f.condition),
                                                  size: 22,
                                                  color: Colors.white,
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  "${f.temp.round()}°",
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Piccolo widget per i dettagli extra in fondo
  Widget _buildExtraDetail(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 24),
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
    );
  }

  Widget _buildPremiumCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) async {
                if (textEditingValue.text == '') {
                  return const Iterable<String>.empty();
                }
                // Chiama il servizio per ottenere i suggerimenti
                return await _weatherService.getCitySuggestions(
                  textEditingValue.text,
                );
              },
              onSelected: (String selection) {
                // Prendi solo la parte prima della virgola se presente
                String cleanName = selection.split(',')[0];
                _fetchWeather(cleanName);
                FocusScope.of(context).unfocus();
              },
              fieldViewBuilder:
                  (context, controller, focusNode, onFieldSubmitted) {
                    return TextField(
                      controller: controller,
                      focusNode: focusNode,
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                      decoration: InputDecoration(
                        hintText: "Cerca città...",
                        hintStyle: const TextStyle(
                          color: Colors.white54,
                          fontSize: 15,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.white70,
                          size: 20,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear, color: Colors.white70),
                          onPressed: () => controller.clear(),
                        ),
                      ),
                    );
                  },
              // ... (resta uguale il tuo optionsViewBuilder)
            ),
          ),
        ),
      ),
    );
  }
}
