# Analisi Best Practice — App Meteo Flutter

> Data analisi: 2026-03-12
> Versione Flutter target: 3.x / Dart 3.x
> Stato branch: `master`

---

## Indice

1. [Panoramica generale](#1-panoramica-generale)
2. [Architettura e struttura](#2-architettura-e-struttura)
3. [Sicurezza](#3-sicurezza)
4. [Qualità del codice](#4-qualità-del-codice)
5. [Gestione degli errori](#5-gestione-degli-errori)
6. [Performance](#6-performance)
7. [Testing](#7-testing)
8. [Accessibilità](#8-accessibilità)
9. [Localizzazione](#9-localizzazione)
10. [Dipendenze](#10-dipendenze)
11. [Documentazione](#11-documentazione)
12. [Riepilogo severità](#12-riepilogo-severità)

---

## 1. Panoramica generale

L'app è una semplice applicazione meteo che:
- Ottiene la posizione GPS dell'utente e ne ricava il meteo attuale
- Permette la ricerca di città con autocompletamento
- Mostra previsioni a 5 giorni

La struttura di partenza è corretta (models / services / views), ma molti aspetti richiedono intervento per essere conformi alle best practice Flutter/Dart moderne.

---

## 2. Architettura e struttura

### 2.1 God Widget — CRITICO

**File:** `lib/views/weather_page.dart` (504 righe)

`WeatherPage` e il suo `State` svolgono troppe responsabilità:
- Chiama direttamente il servizio (`WeatherService`)
- Contiene logica di business (parsing del nome città, conversione m/s → km/h)
- Gestisce lo stato applicativo con `setState`
- Costruisce l'intera UI (search bar, dettagli, previsioni)

In Flutter moderno, questo viola il principio di **Single Responsibility** e rende il codice difficile da testare e manutenere.

**Soluzione attesa:** Introdurre un layer di state management (Riverpod, Bloc/Cubit) e separare la logica UI dai dati.

### 2.2 Nessun Dependency Injection

**File:** `lib/views/weather_page.dart`, riga 17

```dart
final _weatherService = WeatherService(); // costruito direttamente nel widget
```

`WeatherService` viene istanziato direttamente nel widget. Questo rende impossibile iniettare un mock in fase di test e crea accoppiamento forte.

**Soluzione attesa:** Usare `get_it` o il provider del package di state management scelto.

### 2.3 Metodo `_buildPremiumCard` definito ma mai usato

**File:** `lib/views/weather_page.dart`, righe 422–438

Il metodo `_buildPremiumCard` esiste ma non viene mai chiamato all'interno di `build()`. Il card degli extra dettagli (umidità, vento, percepita) duplica manualmente la stessa struttura glassmorphism invece di riutilizzare questo helper.

**Impatto:** Dead code + duplicazione logica.

### 2.4 `optionsViewBuilder` non implementato nell'Autocomplete

**File:** `lib/views/weather_page.dart`, riga 497

```dart
// ... (resta uguale il tuo optionsViewBuilder)
```

Il commento indica un `optionsViewBuilder` personalizzato mai implementato. Il dropdown dei suggerimenti usa lo stile Material di default, che non è coerente con il design glassmorphism dell'app.

---

## 3. Sicurezza

### 3.1 API Key esposta nel codice sorgente — CRITICO

**File:** `lib/services/weather_service.dart`, riga 9

```dart
final String apiKey = '71d22c11991246762c8d40fea700f267';
```

La chiave API è hardcoded nel codice. Chiunque acceda al repository (o al binary compilato con `strings`) può estrarre e abusare della chiave.

**Soluzione attesa:** Usare variabili d'ambiente tramite `--dart-define` al momento del build, o il package `flutter_dotenv`. La chiave non deve mai entrare nel controllo di versione.

```bash
# Esempio con --dart-define
flutter run --dart-define=OWM_API_KEY=xxxxx
```

```dart
// Nel codice
static const String apiKey = String.fromEnvironment('OWM_API_KEY');
```

### 3.2 URL HTTP non sicuro in `getCitySuggestions`

**File:** `lib/services/weather_service.dart`, riga nel metodo `getCitySuggestions`

```dart
Uri.parse('http://api.openweathermap.org/geo/1.0/direct?...')
//         ^^^^^ HTTP, non HTTPS
```

Tutte le altre chiamate usano `https`, ma questa usa `http`. Su Android 9+ il traffico HTTP in chiaro è bloccato di default dalla Network Security Policy. Questo può causare crash silenti o errori di rete su alcuni dispositivi.

**Soluzione attesa:** Cambiare in `https`.

---

## 4. Qualità del codice

### 4.1 `mounted` check assente dopo operazione asincrona — CRITICO

**File:** `lib/views/weather_page.dart`, righe 37–45

```dart
} catch (e) {
  setState(() => _isLoading = false);
  ScaffoldMessenger.of(context).showSnackBar(...); // ← usa context dopo await
  print(e);
}
```

Dopo un `await`, il widget potrebbe essere stato rimosso dall'albero. Usare `context` (o `setState`) senza verificare `mounted` causa il warning *"Do not use BuildContext across async gaps"* ed è un'eccezione runtime in debug mode con Flutter 3.x.

**Soluzione attesa:**

```dart
} catch (e) {
  if (!mounted) return;
  setState(() => _isLoading = false);
  ScaffoldMessenger.of(context).showSnackBar(...);
}
```

### 4.2 `_searchController` creato ma mai usato e mai disposto

**File:** `lib/views/weather_page.dart`, riga 18

```dart
final _searchController = TextEditingController(); // mai usato
```

Il `TextEditingController` è creato (allocando memoria), non viene mai passato a nessun widget, e non viene mai chiamato `dispose()`. Questo causa un memory leak (il controller non viene mai rilasciato).

**Soluzione attesa:** Rimuoverlo completamente. Il controller interno di `Autocomplete` è sufficiente.

### 4.3 `print()` in produzione

**File:** `lib/views/weather_page.dart` riga 44, `lib/services/weather_service.dart` righe varie

```dart
print(e);
print("Errore Weather: ${response.statusCode} - ${response.body}");
```

`print()` non va mai usato in produzione: non è filtrabile per livello, non può essere disabilitato con flag di build, e in alcune configurazioni Android causa overhead.

**Soluzione attesa:** Usare il package `logging` o `logger` con livelli (`debug`, `warning`, `error`). In alternativa, wrappare con `kDebugMode`:

```dart
if (kDebugMode) print(e);
```

### 4.4 `.withOpacity()` deprecato in Flutter 3.x

**File:** `lib/views/weather_page.dart`, più occorrenze

```dart
Colors.white.withOpacity(0.1)
Colors.white.withOpacity(0.2)
// ecc.
```

`Color.withOpacity()` è deprecato a partire da Flutter 3.27. Il metodo sostitutivo è `.withValues(alpha: x)`:

```dart
Colors.white.withValues(alpha: 0.1)
```

**Impatto:** Compiler warning su tutta la UI.

### 4.5 Return type mancante su `_fetchWeather`

**File:** `lib/views/weather_page.dart`, riga 24

```dart
_fetchWeather([String? cityName]) async { // manca Future<void>
```

Senza tipo di ritorno esplicito, il metodo inferisce `Future<dynamic>`. In Dart 3 con `strict-casts` abilitato questo causa warning. Meglio esplicitare:

```dart
Future<void> _fetchWeather([String? cityName]) async {
```

### 4.6 Nomi dei giorni hardcoded invece di usare `intl`

**File:** `lib/views/weather_page.dart`, righe 330–338

```dart
final dayName = [
  "Lun", "Mar", "Mer", "Gio", "Ven", "Sab", "Dom"
][f.date.weekday - 1];
```

Il package `intl` è già importato e usato per la data odierna. Usare `DateFormat('E', 'it_IT').format(f.date)` sarebbe coerente, locale-aware, e non richiederebbe un array manuale.

### 4.7 Null check ridondante all'interno di un blocco già guardato

**File:** `lib/views/weather_page.dart`, righe 238–248

```dart
if (_weather != null) ...[
  // ...
  _weather != null &&           // ← ridondante: già in un if (_weather != null)
  _weather!.tempMax != null &&
  _weather!.tempMin != null
    ? Text(...) : const SizedBox.shrink(),
]
```

La seconda verifica `_weather != null` è superflua.

### 4.8 Commenti di sviluppo non rimossi

**File:** `lib/views/weather_page.dart`, riga 18

```dart
final _searchController = TextEditingController(); // <--- Nuovo controller
```

Commenti di scaffolding come `// <--- Nuovo controller` o `// Sotto la variabile _weather` sono note di sviluppo, non documentazione. Non devono rimanere nel codice produttivo.

### 4.9 Logica di business nella View

**File:** `lib/views/weather_page.dart`, riga 164 e riga 465

```dart
_weather!.cityName.replaceAll('Province of ', '') // ← trasformazione dati nella View
String cleanName = selection.split(',')[0];        // ← parsing nella View
```

Queste trasformazioni appartengono al layer model/service, non alla UI.

---

## 5. Gestione degli errori

### 5.1 Nessun timeout sulle chiamate HTTP

**File:** `lib/services/weather_service.dart`

Le chiamate `http.get()` non hanno timeout. Se il server non risponde, l'app rimane bloccata in loading indefinitamente.

**Soluzione attesa:**

```dart
final response = await http.get(uri).timeout(const Duration(seconds: 10));
```

### 5.2 `LocationPermission.deniedForever` non gestito

**File:** `lib/services/weather_service.dart`, metodo `getCurrentCity`

```dart
if (permission == LocationPermission.denied) {
  permission = await Geolocator.requestPermission();
}
// Non gestisce deniedForever: l'app andrà in crash o rimarrà bloccata
```

Se l'utente nega definitivamente la localizzazione, la chiamata successiva a `getCurrentPosition` lancia un'eccezione non gestita.

### 5.3 Fallback città hardcoded

**File:** `lib/services/weather_service.dart`

```dart
return "Roma"; // Fallback
```

Il fallback a "Roma" è arbitrario. L'errore dovrebbe essere propagato al chiamante, che può mostrare un messaggio appropriato all'utente.

### 5.4 `desiredAccuracy` deprecato in Geolocator 10+

**File:** `lib/services/weather_service.dart`

```dart
await Geolocator.getCurrentPosition(
  desiredAccuracy: LocationAccuracy.high, // ← API deprecata
);
```

Dalla versione 10 di `geolocator`, il parametro corretto è `locationSettings`:

```dart
await Geolocator.getCurrentPosition(
  locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
);
```

---

## 6. Performance

### 6.1 Nessuna cache dei dati meteo

Ad ogni apertura dell'app (o refresh) vengono effettuate almeno 2 chiamate di rete (meteo + previsioni). Non c'è nessun meccanismo di cache locale (neanche in-memory con TTL) per evitare chiamate ridondanti a breve distanza di tempo.

### 6.2 Due chiamate API sequenziali invece di parallele

**File:** `lib/views/weather_page.dart`, righe 29–30

```dart
final weather = await _weatherService.getWeather(targetCity);   // attende
final forecast = await _weatherService.getForecast(targetCity); // poi parte
```

Le due chiamate sono indipendenti e potrebbero partire in parallelo con `Future.wait`, riducendo il tempo di caricamento:

```dart
final results = await Future.wait([
  _weatherService.getWeather(targetCity),
  _weatherService.getForecast(targetCity),
]);
```

### 6.3 `BackdropFilter` usato più volte senza ottimizzazione

`BackdropFilter` è uno dei widget più costosi in Flutter (forza un repaint dell'intero layer sottostante). Nell'app è usato 3 volte (search bar, card dettagli, card previsioni). Non c'è `RepaintBoundary` per isolare le zone di repaint.

### 6.4 `_getBackgroundColors` e `_getWeatherIcon` chiamati più volte per lo stesso dato

Nel metodo `build()`, `_getWeatherIcon` viene chiamato due volte per la stessa condizione (riga 117 e poi di nuovo riga 213). Il risultato dovrebbe essere calcolato una sola volta e riutilizzato.

---

## 7. Testing

### 7.1 Test esistente completamente non correlato all'app

**File:** `test/widget_test.dart`

Il test testa un "Counter" che non esiste nell'app. È il test template di default di Flutter, non è mai stato aggiornato. Se eseguito, fallisce.

### 7.2 Zero unit test per i modelli

`Weather.fromJson()` e `Forecast.fromJson()` non hanno alcun test. Eventuali cambiamenti alla struttura JSON dell'API non verrebbero rilevati.

### 7.3 Zero unit test per `WeatherService`

Nessun test verifica il comportamento di `WeatherService` in caso di risposta valida, errore HTTP, o risposta malformata.

### 7.4 Zero widget test per `WeatherPage`

Nessun test verifica che la UI si comporti correttamente (stato di loading, dati mostrati, errori).

---

## 8. Accessibilità

### 8.1 Nessuna etichetta semantica sulle icone

Tutte le icone meteo (umidità, vento, temperatura percepita, icona condizione) non hanno `semanticLabel`. I lettori di schermo (TalkBack/VoiceOver) non sapranno cosa rappresentano.

```dart
// Esempio corretto
Icon(Icons.location_on_outlined, semanticLabel: 'Posizione')
```

### 8.2 `toUpperCase()` sulla condizione rompe i lettori di schermo

```dart
_weather!.mainCondition.toUpperCase() // "CLEAR", "RAIN"...
```

I lettori di schermo leggono le stringhe uppercase lettera per lettera ("C-L-E-A-R"). Meglio usare la trasformazione CSS-like (`text-transform`) a livello di stile, non sui dati.

### 8.3 Nessun `Tooltip` sui bottoni icona

Il bottone "clear" (×) nella search bar non ha tooltip, rendendo il suo scopo non comunicabile agli utenti con tecnologie assistive.

---

## 9. Localizzazione

### 9.1 Stringhe UI hardcoded in italiano

Tutte le stringhe UI (`"Cerca città..."`, `"Città non trovata o errore di connessione"`, `"Caricamento previsioni..."`, `"Oggi,"`, `"Umidità"`, `"Vento"`, `"Percepita"`, `"Max:"`, `"Min:"`) sono hardcoded in italiano.

Non è usato alcun sistema di localizzazione (`flutter_localizations`, `AppLocalizations`, o simili). L'app non può essere tradotta senza modificare il codice sorgente.

### 9.2 Commenti misti italiano/inglese

I commenti nel codice alternano italiano e inglese senza criterio. Scegliere una sola lingua per i commenti è una buona pratica per la manutenibilità del team.

---

## 10. Dipendenze

### 10.1 `cupertino_icons` non usato

**File:** `pubspec.yaml`

```yaml
cupertino_icons: ^1.0.8
```

Il package è dichiarato come dipendenza ma non viene mai importato nel codice. È peso morto nel bundle.

### 10.2 Nessun package di logging

Come evidenziato nel punto 4.3, non c'è un package di logging strutturato. Consigliato: `logger` o il package standard `logging`.

### 10.3 Nessun state management strutturato

L'app usa esclusivamente `setState` in un unico widget. Con l'aggiunta di funzionalità (preferiti, impostazioni, cache) questo approccio diventerà ingestibile rapidamente. Consigliato valutare `flutter_riverpod` per la sua semplicità e compatibilità con Dart 3.

---

## 11. Documentazione

### 11.1 README non aggiornato

**File:** `README.md`

Il README è il template di default di Flutter. Non descrive l'app, le API usate, come configurare la chiave API, o come avviare il progetto.

### 11.2 Nessun commento dartdoc

Nessuna classe, metodo o proprietà pubblica ha documentazione `///`. In Dart, la convenienza è usare `///` per i dartdoc, non `//`.

### 11.3 `analysis_options.yaml` non personalizzato

Il file usa solo il default di `flutter_lints`. Non sono abilitate regole aggiuntive utili come `avoid_print`, `prefer_const_constructors`, o `use_build_context_synchronously` (già inclusa in `flutter_lints` ma vale la pena renderla esplicita).

---

## 12. Riepilogo severità

| # | Problema | Area | Severità |
|---|----------|------|----------|
| 3.1 | API key hardcoded nel sorgente | Sicurezza | 🔴 Critico |
| 4.1 | `context` usato dopo `await` senza `mounted` | Qualità | 🔴 Critico |
| 2.1 | God Widget — logica, stato e UI mescolati | Architettura | 🟠 Alto |
| 2.2 | Nessuna Dependency Injection | Architettura | 🟠 Alto |
| 5.1 | Nessun timeout HTTP | Error Handling | 🟠 Alto |
| 5.2 | `LocationPermission.deniedForever` non gestito | Error Handling | 🟠 Alto |
| 7.1 | Test esistente non correlato all'app | Testing | 🟠 Alto |
| 3.2 | URL HTTP invece di HTTPS in geocoding | Sicurezza | 🟡 Medio |
| 4.2 | `TextEditingController` non usato e non disposto | Qualità | 🟡 Medio |
| 4.3 | `print()` in produzione | Qualità | 🟡 Medio |
| 4.4 | `.withOpacity()` deprecato | Qualità | 🟡 Medio |
| 4.5 | Return type mancante su `_fetchWeather` | Qualità | 🟡 Medio |
| 5.4 | `desiredAccuracy` deprecato in Geolocator 10+ | Qualità | 🟡 Medio |
| 6.2 | Chiamate API sequenziali invece di parallele | Performance | 🟡 Medio |
| 2.3 | `_buildPremiumCard` definito ma mai usato | Qualità | 🟢 Basso |
| 2.4 | `optionsViewBuilder` non implementato | UI/UX | 🟢 Basso |
| 4.6 | Nomi giorni hardcoded invece di usare `intl` | Qualità | 🟢 Basso |
| 4.7 | Null check ridondante in `if (_weather != null)` | Qualità | 🟢 Basso |
| 4.8 | Commenti di scaffolding non rimossi | Qualità | 🟢 Basso |
| 4.9 | Logica di business nella View | Architettura | 🟢 Basso |
| 5.3 | Fallback città hardcoded a "Roma" | Error Handling | 🟢 Basso |
| 6.1 | Nessuna cache dati meteo | Performance | 🟢 Basso |
| 6.3 | `BackdropFilter` multiplo senza `RepaintBoundary` | Performance | 🟢 Basso |
| 6.4 | Helper chiamati più volte per lo stesso dato | Performance | 🟢 Basso |
| 7.2 | Zero unit test per i modelli | Testing | 🟡 Medio |
| 7.3 | Zero unit test per `WeatherService` | Testing | 🟡 Medio |
| 7.4 | Zero widget test per `WeatherPage` | Testing | 🟡 Medio |
| 8.1 | Nessuna etichetta semantica sulle icone | Accessibilità | 🟡 Medio |
| 8.2 | `toUpperCase()` rompe lettori di schermo | Accessibilità | 🟡 Medio |
| 8.3 | Nessun `Tooltip` sui bottoni icona | Accessibilità | 🟢 Basso |
| 9.1 | Stringhe UI hardcoded in italiano | Localizzazione | 🟢 Basso |
| 9.2 | Commenti misti italiano/inglese | Qualità | 🟢 Basso |
| 10.1 | `cupertino_icons` non usato | Dipendenze | 🟢 Basso |
| 10.2 | Nessun package di logging | Qualità | 🟡 Medio |
| 10.3 | Nessuno state management strutturato | Architettura | 🟠 Alto |
| 11.1 | README non aggiornato | Documentazione | 🟢 Basso |
| 11.2 | Nessun dartdoc | Documentazione | 🟢 Basso |
| 11.3 | `analysis_options.yaml` non personalizzato | Qualità | 🟢 Basso |

**Totale problemi rilevati: 38**
- 🔴 Critici: 2
- 🟠 Alti: 6
- 🟡 Medi: 12
- 🟢 Bassi: 18
