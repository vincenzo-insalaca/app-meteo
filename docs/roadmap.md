# Roadmap Migliorie — App Meteo Flutter

> Basata sull'analisi `analisi_best_practice.md` del 2026-03-12
> Le fasi sono ordinate per priorità: prima si risolve ciò che è critico/rischioso,
> poi si migliora architettura e qualità, infine si aggiungono funzionalità.

---

## Stack tecnologico scelto

| Area | Libreria |
|------|----------|
| State Management | `flutter_bloc` + `bloc` + `bloc_concurrency` + `equatable` |
| Navigation | `go_router` |
| HTTP Client | `dio` + `dio_smart_retry` |
| API Type-safe | `retrofit` + `json_annotation` + `json_serializable` + `build_runner` |
| Dependency Injection | `get_it` |
| Connectivity | `internet_connection_checker_plus` |
| Logging | `logger` |

---

## Fase 1 — Fix Critici e Sicurezza ✅ COMPLETATA

### 1.1 API key rimossa dal codice sorgente ✅
- Spostata in `String.fromEnvironment('OWM_API_KEY')` in `core/constants/api_constants.dart`
- Per eseguire: `flutter run --dart-define=OWM_API_KEY=tua_chiave`

### 1.2 Fix `mounted` check dopo operazioni asincrone ✅
- Non più necessario: il BLoC gestisce la logica asincrona, la UI reagisce via `BlocConsumer`

### 1.3 Fix URL HTTP → HTTPS ✅
- Tutti gli URL usano HTTPS nei client Retrofit

---

## Fase 2 — Stabilità e Qualità del Codice ✅ COMPLETATA (nel refactoring architetturale)

### 2.1 Gestione completa dei permessi di localizzazione ✅
- `deniedForever` gestito in `WeatherRepositoryImpl._getPosition()`
- Lancia `LocationFailure` con messaggio chiaro, propagato al BLoC → UI

### 2.2 Timeout HTTP ✅
- `connectTimeout` e `receiveTimeout` impostati a 10s in `DioClient`
- `dio_smart_retry` esegue fino a 3 retry con backoff esponenziale

### 2.3 API deprecate aggiornate ✅
- `desiredAccuracy` → `locationSettings` con `LocationSettings`
- `.withOpacity()` → `.withValues(alpha:)` ovunque

### 2.4 Codice morto rimosso ✅
- `_searchController` eliminato
- `_buildPremiumCard` non duplicato (widget estratti)
- Commenti di scaffolding rimossi

### 2.5 Logging strutturato ✅
- Package `logger` usato in `WeatherBloc` e `WeatherRepositoryImpl`
- Zero `print()` nel codice

### 2.6 Cleanup ✅
- Nomi giorni via `DateFormat('EEE', 'it_IT')`
- Logica di business spostata nel repository
- `cupertino_icons` rimosso da `pubspec.yaml`
- Chiamate API parallele con `Future` avviati prima degli `await`

---

## Fase 3 — Testing

Costruire una base di test solida.

### 3.1 Unit test per i modelli DTO
- Scrivere test per `WeatherResponseDto.fromJson()` con payload valido
- Scrivere test per `ForecastResponseDto.fromJson()`
- Scrivere test per `GeoLocationDto.fromJson()`

### 3.2 Unit test per `WeatherRepositoryImpl`
- Mockare `WeatherApiClient` e `GeoApiClient` con `mocktail`
- Testare `fetchWeatherByCity` con risposta valida
- Testare gestione errori (`DioException`, `LocationFailure`)
- Testare `searchCities` con query corta (< 3 char)

### 3.3 Unit test per `WeatherBloc`
- Usare `bloc_test` per testare la sequenza di stati
- Testare `WeatherFetchByLocationRequested` con connectivity = false
- Testare `WeatherFetchByCityRequested` → `WeatherLoading` → `WeatherLoaded`
- Testare `WeatherRefreshRequested` con source GPS e con source search

### 3.4 Widget test per `WeatherPage`
- Testare stato di loading (CircularProgressIndicator visibile)
- Testare visualizzazione dati (mockando il BLoC con `MockWeatherBloc`)
- Testare pulsante "Riprova" nell'`_ErrorView`

---

## Fase 4 — Refactoring Architetturale ✅ COMPLETATA

L'intera architettura è stata riscritta nella sessione del 2026-03-12.

### Struttura implementata

```
lib/
├── main.dart                                  ← Bootstrap (GetIt + intl + runApp)
├── app.dart                                   ← MeteoApp con BlocProvider + GoRouter
├── core/
│   ├── constants/api_constants.dart           ← Costanti API (key via dart-define)
│   ├── di/service_locator.dart               ← GetIt wiring completo
│   ├── error/failures.dart                   ← Sealed class Failure hierarchy
│   ├── network/
│   │   ├── auth_interceptor.dart             ← Inietta appid/units/lang su ogni req
│   │   ├── connectivity_service.dart         ← Wrapper internet_connection_checker_plus
│   │   └── dio_client.dart                   ← Factory Dio (weather + geo)
│   └── router/app_router.dart               ← GoRouter
├── data/
│   ├── models/
│   │   ├── weather_response_dto.dart         ← DTO + json_serializable
│   │   ├── forecast_response_dto.dart
│   │   └── geo_location_dto.dart
│   ├── remote/
│   │   ├── weather_api_client.dart           ← Retrofit client /data/2.5
│   │   └── geo_api_client.dart              ← Retrofit client /geo/1.0
│   └── repositories/weather_repository_impl.dart
├── domain/
│   ├── entities/
│   │   ├── weather.dart
│   │   ├── forecast_day.dart
│   │   └── city_suggestion.dart
│   └── repositories/weather_repository.dart  ← Interfaccia astratta
└── presentation/
    ├── blocs/
    │   ├── weather/
    │   │   ├── weather_bloc.dart             ← Gestisce fetch GPS, city, refresh
    │   │   ├── weather_event.dart            ← Sealed events
    │   │   └── weather_state.dart            ← Sealed states con stale data
    │   └── search/search_cubit.dart          ← Suggerimenti autocompletamento
    ├── blocs/
    │   ├── weather/ ...
    │   ├── search/search_cubit.dart
    │   └── favorites/
    │       ├── favorites_cubit.dart          ← Toggle + load preferiti
    │       └── favorites_state.dart
    └── pages/
        ├── weather/
        │   ├── weather_page.dart             ← BlocConsumer + TopBar con GPS/stella/preferiti
        │   └── widgets/ ...
        └── favorites/
            └── favorites_page.dart           ← Lista Dismissible con tap-to-load
```

---

## Fase 5 — Performance ✅ COMPLETATA

### 5.1 Cache in-memory con TTL ✅
- Cache implementata nel repository con TTL 10 minuti
- Chiavi: `'city:${cityName}'` e `'location'`

### 5.2 Ottimizzare i `BackdropFilter` ✅
- `RepaintBoundary` aggiunto su `WeatherDetailsRow` e `SearchBarWidget`

---

## Fase 6 — Accessibilità e UX ✅ COMPLETATA

- Etichette semantiche sulle icone: ✅
- `toUpperCase()` separato dalla semantica (`Semantics` + `ExcludeSemantics`): ✅
- `Tooltip` sul bottone clear e pulsanti GPS/preferiti: ✅
- `optionsViewBuilder` glassmorphism implementato: ✅
- `Semantics(container: true)` su `CurrentWeatherCard` con label computata: ✅
- Semantics su ogni card del forecast: ✅
- Semantics su ogni dettaglio meteo (umidità, vento, percepita): ✅

---

## Fase 7 — Documentazione e Developer Experience ✅ COMPLETATA

### 7.1 README aggiornato ✅
### 7.2 `analysis_options.yaml` personalizzato ✅
### 7.3 Commenti dartdoc sulle classi pubbliche ✅

---

## Fase 8 — Funzionalità Future ✅ COMPLETATA

### 8.1 Localizzazione completa ✅
- `flutter_localizations` + `flutter gen-l10n` con file ARB (it + en)
- Estensione `context.l10n` su `BuildContext`
- Tutte le stringhe UI estratte (25+ chiavi)
- File generati in `lib/generated/l10n/`

### 8.2 Persistenza locale ✅
- `shared_preferences` per salvare ultima sorgente + ultima città
- `LocalStorageService` (abstract + impl)
- `WeatherInitializeRequested`: al riavvio ripristina l'ultima ricerca

### 8.3 Città preferite ✅
- `FavoritesRepository` + `FavoritesRepositoryImpl` (SharedPrefs)
- `FavoritesCubit` (singleton GetIt) + `FavoritesState`
- `FavoritesPage` con `Dismissible` swipe-to-delete e tap-to-load
- Pulsante stella ⭐ in `_WeatherContent` (toggle preferito)
- Route `/favorites` in GoRouter
- Navigazione da header WeatherPage

### 8.4 Notifiche meteo ✅
- `flutter_local_notifications` v18
- `NotificationService` (abstract + impl)
- Alert immediato per Rain/Thunderstorm/Snow
- Riepilogo giornaliero periodico (`RepeatInterval.daily`)
- Inizializzazione richiesta permessi Android 13+

---

## Riepilogo fasi

| Fase | Descrizione | Stato |
|------|-------------|-------|
| 1 | Fix critici e sicurezza | ✅ Completata |
| 2 | Stabilità e qualità | ✅ Completata |
| 3 | Testing (31 test) | ✅ Completata |
| 4 | Refactoring architetturale | ✅ Completata |
| 5 | Performance | ✅ Completata |
| 6 | Accessibilità e UX | ✅ Completata |
| 7 | Documentazione e DX | ✅ Completata |
| 8 | Funzionalità future | ✅ Completata |

---

## Comandi utili

```bash
# Avvio app con chiave API
flutter run --dart-define=OWM_API_KEY=tua_chiave_qui

# Rigenera file .g.dart dopo modifiche ai DTO o ai client Retrofit
dart run build_runner build --delete-conflicting-outputs

# Rigenera file l10n dopo modifiche agli ARB
flutter gen-l10n

# Analisi statica
flutter analyze

# Esegui test
flutter test

# Build release
flutter build apk --dart-define=OWM_API_KEY=tua_chiave_qui
```
