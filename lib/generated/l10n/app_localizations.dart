import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('it'),
  ];

  /// App title
  ///
  /// In it, this message translates to:
  /// **'Meteo'**
  String get appTitle;

  /// Search bar placeholder
  ///
  /// In it, this message translates to:
  /// **'Cerca città...'**
  String get searchHint;

  /// Tooltip for clear search button
  ///
  /// In it, this message translates to:
  /// **'Cancella ricerca'**
  String get clearSearch;

  /// Tooltip for GPS location button
  ///
  /// In it, this message translates to:
  /// **'Usa posizione GPS'**
  String get locationButton;

  /// Tooltip for favorites button
  ///
  /// In it, this message translates to:
  /// **'Preferiti'**
  String get favoritesButton;

  /// Refreshing indicator label
  ///
  /// In it, this message translates to:
  /// **'Aggiornamento in corso...'**
  String get refreshing;

  /// Label for today
  ///
  /// In it, this message translates to:
  /// **'Oggi'**
  String get today;

  /// Feels like label
  ///
  /// In it, this message translates to:
  /// **'Percepita'**
  String get feelsLike;

  /// Humidity label
  ///
  /// In it, this message translates to:
  /// **'Umidità'**
  String get humidity;

  /// Wind label
  ///
  /// In it, this message translates to:
  /// **'Vento'**
  String get wind;

  /// Wind speed with unit
  ///
  /// In it, this message translates to:
  /// **'{speed} km/h'**
  String windUnit(String speed);

  /// Humidity with percent sign
  ///
  /// In it, this message translates to:
  /// **'{value}%'**
  String humidityValue(int value);

  /// Temperature with degree sign
  ///
  /// In it, this message translates to:
  /// **'{temp}°'**
  String temperatureDegree(int temp);

  /// Min max temperatures
  ///
  /// In it, this message translates to:
  /// **'Max: {max}°  Min: {min}°'**
  String minMax(int max, int min);

  /// No internet connection error
  ///
  /// In it, this message translates to:
  /// **'Nessuna connessione internet'**
  String get noConnection;

  /// City not found error
  ///
  /// In it, this message translates to:
  /// **'Città non trovata'**
  String get cityNotFound;

  /// Invalid API key error
  ///
  /// In it, this message translates to:
  /// **'Chiave API non valida'**
  String get invalidApiKey;

  /// Unknown error
  ///
  /// In it, this message translates to:
  /// **'Errore imprevisto'**
  String get unknownError;

  /// Retry button label
  ///
  /// In it, this message translates to:
  /// **'Riprova'**
  String get retry;

  /// Semantic label for location icon
  ///
  /// In it, this message translates to:
  /// **'Posizione'**
  String get locationSemantic;

  /// Favorites page title
  ///
  /// In it, this message translates to:
  /// **'Preferiti'**
  String get favoritesTitle;

  /// Empty favorites message
  ///
  /// In it, this message translates to:
  /// **'Nessuna città salvata'**
  String get noFavorites;

  /// Hint for adding favorites
  ///
  /// In it, this message translates to:
  /// **'Cerca una città e tocca la stella per salvarla'**
  String get noFavoritesHint;

  /// Tooltip to add to favorites
  ///
  /// In it, this message translates to:
  /// **'Aggiungi ai preferiti'**
  String get addToFavorites;

  /// Tooltip to remove from favorites
  ///
  /// In it, this message translates to:
  /// **'Rimuovi dai preferiti'**
  String get removeFromFavorites;

  /// Severe weather notification title
  ///
  /// In it, this message translates to:
  /// **'Allerta meteo'**
  String get severeWeatherTitle;

  /// Severe weather notification body
  ///
  /// In it, this message translates to:
  /// **'Attenzione: {condition} previsto a {city}'**
  String severeWeatherBody(String condition, String city);

  /// Daily summary notification title
  ///
  /// In it, this message translates to:
  /// **'Previsioni del giorno'**
  String get dailySummaryTitle;

  /// Daily summary notification body
  ///
  /// In it, this message translates to:
  /// **'{city}: {temp}°, {condition}'**
  String dailySummaryBody(String city, int temp, String condition);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
