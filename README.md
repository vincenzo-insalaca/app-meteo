# Meteo 🌤️

App meteo Flutter che mostra il meteo attuale e le previsioni a 5 giorni, con supporto GPS e ricerca città.

## Funzionalità

- Meteo attuale tramite GPS (posizione automatica)
- Ricerca città con autocompletamento
- Previsioni a 5 giorni
- Sfondo animato che cambia in base alle condizioni meteo
- Pull-to-refresh
- Cache in-memory (10 minuti) per ridurre le chiamate di rete

## Stack tecnologico

| Area | Libreria |
|------|----------|
| State Management | `flutter_bloc` + `bloc_concurrency` |
| Navigation | `go_router` |
| HTTP | `dio` + `dio_smart_retry` + `retrofit` |
| DI | `get_it` |
| Connectivity | `internet_connection_checker_plus` |
| Location | `geolocator` |
| Logging | `logger` |

## Prerequisiti

- Flutter SDK ≥ 3.9.2
- Dart SDK ≥ 3.9.2
- Chiave API OpenWeatherMap ([registrati qui](https://openweathermap.org/api))

## Setup

### 1. Clona il repository

```bash
git clone <url-repo>
cd meteo
```

### 2. Installa le dipendenze

```bash
flutter pub get
```

### 3. Genera i file di code generation (Retrofit + json_serializable)

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 4. Avvia l'app passando la chiave API

```bash
flutter run --dart-define=OWM_API_KEY=la_tua_chiave_qui
```

Per Android/iOS in release:

```bash
flutter build apk --dart-define=OWM_API_KEY=la_tua_chiave_qui
flutter build ipa --dart-define=OWM_API_KEY=la_tua_chiave_qui
```

## Architettura

Il progetto segue una clean architecture semplificata organizzata in tre layer:

```
lib/
├── core/          → Costanti, DI (GetIt), errori, network, router
├── data/          → DTOs (json_serializable), client Retrofit, repository impl
├── domain/        → Entities, interfaccia repository
└── presentation/  → BLoC, pagine, widget
```

### Flusso dei dati

```
UI (WeatherPage)
  └── WeatherBloc
        └── WeatherRepository (interfaccia)
              └── WeatherRepositoryImpl
                    ├── WeatherApiClient (Retrofit → Dio)
                    ├── GeoApiClient (Retrofit → Dio)
                    └── Geolocator
```

### Gestione dello stato

`WeatherBloc` gestisce tre eventi (sealed class):
- `WeatherFetchByLocationRequested` — fetch via GPS
- `WeatherFetchByCityRequested` — fetch per nome città
- `WeatherRefreshRequested` — aggiorna la sorgente corrente

Quattro stati (sealed class):
- `WeatherInitial` → `WeatherLoading` → `WeatherLoaded` / `WeatherError`

Gli stati `WeatherLoading` e `WeatherError` mantengono i dati precedenti per mostrare l'UI stale durante il refresh.

## Test

```bash
# Tutti i test
flutter test

# Solo unit test
flutter test test/data/ test/presentation/blocs/

# Solo widget test
flutter test test/presentation/pages/
```

## Permessi

### Android

Il file `AndroidManifest.xml` deve contenere:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```

### iOS

Il file `Info.plist` deve contenere le chiavi:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>L'app usa la posizione per mostrare il meteo della tua zona.</string>
```
