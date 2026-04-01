import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('ru'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In ru, this message translates to:
  /// **'Хиромантия'**
  String get appTitle;

  /// No description provided for @tabScanner.
  ///
  /// In ru, this message translates to:
  /// **'Сканер'**
  String get tabScanner;

  /// No description provided for @tabHistory.
  ///
  /// In ru, this message translates to:
  /// **'История'**
  String get tabHistory;

  /// No description provided for @tabReference.
  ///
  /// In ru, this message translates to:
  /// **'Справочник'**
  String get tabReference;

  /// No description provided for @tabSettings.
  ///
  /// In ru, this message translates to:
  /// **'Настройки'**
  String get tabSettings;

  /// No description provided for @scanHand.
  ///
  /// In ru, this message translates to:
  /// **'Сканировать'**
  String get scanHand;

  /// No description provided for @leftHand.
  ///
  /// In ru, this message translates to:
  /// **'Левая рука'**
  String get leftHand;

  /// No description provided for @rightHand.
  ///
  /// In ru, this message translates to:
  /// **'Правая рука'**
  String get rightHand;

  /// No description provided for @placeHandInFrame.
  ///
  /// In ru, this message translates to:
  /// **'Расположите ладонь в рамке'**
  String get placeHandInFrame;

  /// No description provided for @handDetected.
  ///
  /// In ru, this message translates to:
  /// **'Рука найдена'**
  String get handDetected;

  /// No description provided for @processing.
  ///
  /// In ru, this message translates to:
  /// **'Анализируем ладонь...'**
  String get processing;

  /// No description provided for @editLines.
  ///
  /// In ru, this message translates to:
  /// **'Редактор линий'**
  String get editLines;

  /// No description provided for @heartLine.
  ///
  /// In ru, this message translates to:
  /// **'Линия сердца'**
  String get heartLine;

  /// No description provided for @headLine.
  ///
  /// In ru, this message translates to:
  /// **'Линия головы'**
  String get headLine;

  /// No description provided for @lifeLine.
  ///
  /// In ru, this message translates to:
  /// **'Линия жизни'**
  String get lifeLine;

  /// No description provided for @fateLine.
  ///
  /// In ru, this message translates to:
  /// **'Линия судьбы'**
  String get fateLine;

  /// No description provided for @addLine.
  ///
  /// In ru, this message translates to:
  /// **'Добавить линию'**
  String get addLine;

  /// No description provided for @deleteLine.
  ///
  /// In ru, this message translates to:
  /// **'Удалить'**
  String get deleteLine;

  /// No description provided for @next.
  ///
  /// In ru, this message translates to:
  /// **'Далее'**
  String get next;

  /// No description provided for @result.
  ///
  /// In ru, this message translates to:
  /// **'Результат'**
  String get result;

  /// No description provided for @overview.
  ///
  /// In ru, this message translates to:
  /// **'Общий портрет'**
  String get overview;

  /// No description provided for @personality.
  ///
  /// In ru, this message translates to:
  /// **'Характер'**
  String get personality;

  /// No description provided for @relationships.
  ///
  /// In ru, this message translates to:
  /// **'Отношения'**
  String get relationships;

  /// No description provided for @career.
  ///
  /// In ru, this message translates to:
  /// **'Карьера'**
  String get career;

  /// No description provided for @health.
  ///
  /// In ru, this message translates to:
  /// **'Здоровье'**
  String get health;

  /// No description provided for @askQuestion.
  ///
  /// In ru, this message translates to:
  /// **'Задать вопрос'**
  String get askQuestion;

  /// No description provided for @save.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить'**
  String get save;

  /// No description provided for @history.
  ///
  /// In ru, this message translates to:
  /// **'История'**
  String get history;

  /// No description provided for @noScansYet.
  ///
  /// In ru, this message translates to:
  /// **'Сканирований пока нет'**
  String get noScansYet;

  /// No description provided for @settings.
  ///
  /// In ru, this message translates to:
  /// **'Настройки'**
  String get settings;

  /// No description provided for @about.
  ///
  /// In ru, this message translates to:
  /// **'О приложении'**
  String get about;

  /// No description provided for @loading.
  ///
  /// In ru, this message translates to:
  /// **'Загрузка...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка'**
  String get error;

  /// No description provided for @retry.
  ///
  /// In ru, this message translates to:
  /// **'Повторить'**
  String get retry;

  /// No description provided for @fromCamera.
  ///
  /// In ru, this message translates to:
  /// **'Камера'**
  String get fromCamera;

  /// No description provided for @fromGallery.
  ///
  /// In ru, this message translates to:
  /// **'Галерея'**
  String get fromGallery;
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
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
