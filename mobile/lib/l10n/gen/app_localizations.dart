import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_kk.dart';
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
/// import 'gen/app_localizations.dart';
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
    Locale('kk'),
    Locale('ru'),
  ];

  /// No description provided for @appName.
  ///
  /// In kk, this message translates to:
  /// **'TraderOS'**
  String get appName;

  /// No description provided for @common_continue.
  ///
  /// In kk, this message translates to:
  /// **'Жалғастыру'**
  String get common_continue;

  /// No description provided for @common_back.
  ///
  /// In kk, this message translates to:
  /// **'Артқа'**
  String get common_back;

  /// No description provided for @common_cancel.
  ///
  /// In kk, this message translates to:
  /// **'Бас тарту'**
  String get common_cancel;

  /// No description provided for @common_save.
  ///
  /// In kk, this message translates to:
  /// **'Сақтау'**
  String get common_save;

  /// No description provided for @common_done.
  ///
  /// In kk, this message translates to:
  /// **'Дайын'**
  String get common_done;

  /// No description provided for @common_loading.
  ///
  /// In kk, this message translates to:
  /// **'Жүктелуде…'**
  String get common_loading;

  /// No description provided for @common_error.
  ///
  /// In kk, this message translates to:
  /// **'Қате'**
  String get common_error;

  /// No description provided for @common_retry.
  ///
  /// In kk, this message translates to:
  /// **'Қайталау'**
  String get common_retry;

  /// No description provided for @common_skip.
  ///
  /// In kk, this message translates to:
  /// **'Өткізу'**
  String get common_skip;

  /// No description provided for @common_next.
  ///
  /// In kk, this message translates to:
  /// **'Әрі қарай'**
  String get common_next;

  /// No description provided for @common_finish.
  ///
  /// In kk, this message translates to:
  /// **'Аяқтау'**
  String get common_finish;

  /// No description provided for @common_all.
  ///
  /// In kk, this message translates to:
  /// **'Барлығы'**
  String get common_all;

  /// No description provided for @lang_kk.
  ///
  /// In kk, this message translates to:
  /// **'Қазақша'**
  String get lang_kk;

  /// No description provided for @lang_ru.
  ///
  /// In kk, this message translates to:
  /// **'Русский'**
  String get lang_ru;

  /// No description provided for @lang_en.
  ///
  /// In kk, this message translates to:
  /// **'English'**
  String get lang_en;

  /// No description provided for @auth_login_required.
  ///
  /// In kk, this message translates to:
  /// **'Бұл әрекет үшін аккаунт қажет'**
  String get auth_login_required;

  /// No description provided for @auth_welcome_title.
  ///
  /// In kk, this message translates to:
  /// **'TraderOS-қа қош келдіңіз'**
  String get auth_welcome_title;

  /// No description provided for @auth_welcome_subtitle.
  ///
  /// In kk, this message translates to:
  /// **'XAU/USD трейдерлеріне арналған кәсіби платформа'**
  String get auth_welcome_subtitle;

  /// No description provided for @auth_phone_title.
  ///
  /// In kk, this message translates to:
  /// **'Телефон нөмірін енгізіңіз'**
  String get auth_phone_title;

  /// No description provided for @auth_phone_hint.
  ///
  /// In kk, this message translates to:
  /// **'+7 700 000 00 00'**
  String get auth_phone_hint;

  /// No description provided for @auth_phone_error.
  ///
  /// In kk, this message translates to:
  /// **'Дұрыс нөмір енгізіңіз'**
  String get auth_phone_error;

  /// No description provided for @auth_password_title.
  ///
  /// In kk, this message translates to:
  /// **'Құпиясөз жасаңыз'**
  String get auth_password_title;

  /// No description provided for @auth_password_subtitle.
  ///
  /// In kk, this message translates to:
  /// **'Кем дегенде 8 таңба'**
  String get auth_password_subtitle;

  /// No description provided for @auth_password_hint.
  ///
  /// In kk, this message translates to:
  /// **'Құпиясөз'**
  String get auth_password_hint;

  /// No description provided for @auth_password_confirm_hint.
  ///
  /// In kk, this message translates to:
  /// **'Құпиясөзді қайталаңыз'**
  String get auth_password_confirm_hint;

  /// No description provided for @auth_password_mismatch.
  ///
  /// In kk, this message translates to:
  /// **'Құпиясөздер сәйкес келмейді'**
  String get auth_password_mismatch;

  /// No description provided for @auth_password_too_short.
  ///
  /// In kk, this message translates to:
  /// **'Құпиясөз кем дегенде 8 таңбадан тұруы керек'**
  String get auth_password_too_short;

  /// No description provided for @auth_register_button.
  ///
  /// In kk, this message translates to:
  /// **'Тіркелу'**
  String get auth_register_button;

  /// No description provided for @auth_login_button.
  ///
  /// In kk, this message translates to:
  /// **'Кіру'**
  String get auth_login_button;

  /// No description provided for @auth_to_login.
  ///
  /// In kk, this message translates to:
  /// **'Аккаунтыңыз бар ма? Кіру'**
  String get auth_to_login;

  /// No description provided for @auth_to_register.
  ///
  /// In kk, this message translates to:
  /// **'Аккаунтыңыз жоқ па? Тіркелу'**
  String get auth_to_register;

  /// No description provided for @onboarding_title.
  ///
  /// In kk, this message translates to:
  /// **'Бірнеше сұрақ'**
  String get onboarding_title;

  /// No description provided for @onboarding_name_label.
  ///
  /// In kk, this message translates to:
  /// **'Атыңыз'**
  String get onboarding_name_label;

  /// No description provided for @onboarding_name_hint.
  ///
  /// In kk, this message translates to:
  /// **'Қалай атайық сізді?'**
  String get onboarding_name_hint;

  /// No description provided for @onboarding_city_label.
  ///
  /// In kk, this message translates to:
  /// **'Қала'**
  String get onboarding_city_label;

  /// No description provided for @onboarding_city_hint.
  ///
  /// In kk, this message translates to:
  /// **'Алматы'**
  String get onboarding_city_hint;

  /// No description provided for @onboarding_style_label.
  ///
  /// In kk, this message translates to:
  /// **'Сауда стилі'**
  String get onboarding_style_label;

  /// No description provided for @onboarding_bio_label.
  ///
  /// In kk, this message translates to:
  /// **'Өзіңіз туралы (қалауыңызша)'**
  String get onboarding_bio_label;

  /// No description provided for @onboarding_sessions_label.
  ///
  /// In kk, this message translates to:
  /// **'Қалаулы сессиялар'**
  String get onboarding_sessions_label;

  /// No description provided for @onboarding_finish.
  ///
  /// In kk, this message translates to:
  /// **'Бастау'**
  String get onboarding_finish;

  /// No description provided for @splash_tagline.
  ///
  /// In kk, this message translates to:
  /// **'Алтын трейдинг платформасы'**
  String get splash_tagline;

  /// No description provided for @intro_skip.
  ///
  /// In kk, this message translates to:
  /// **'Өткізу'**
  String get intro_skip;

  /// No description provided for @intro_next.
  ///
  /// In kk, this message translates to:
  /// **'Әрі қарай'**
  String get intro_next;

  /// No description provided for @intro_start.
  ///
  /// In kk, this message translates to:
  /// **'Бастау'**
  String get intro_start;

  /// No description provided for @intro_s1_title.
  ///
  /// In kk, this message translates to:
  /// **'Алтын — нақты уақытта'**
  String get intro_s1_title;

  /// No description provided for @intro_s1_text.
  ///
  /// In kk, this message translates to:
  /// **'XAU/USD тірі бағасы, DXY және экономикалық календарь — бәрі бір экранда.'**
  String get intro_s1_text;

  /// No description provided for @intro_s2_title.
  ///
  /// In kk, this message translates to:
  /// **'Трейдерлердің идеялары'**
  String get intro_s2_title;

  /// No description provided for @intro_s2_text.
  ///
  /// In kk, this message translates to:
  /// **'Расталған трейдерлердің сигналдары: кіру, TP, SL, Win Rate және рейтинг.'**
  String get intro_s2_text;

  /// No description provided for @intro_s3_title.
  ///
  /// In kk, this message translates to:
  /// **'Оқу және журнал'**
  String get intro_s3_title;

  /// No description provided for @intro_s3_text.
  ///
  /// In kk, this message translates to:
  /// **'Edge Academy, баға ескертулері және сауда журналы — өсуіңіз үшін.'**
  String get intro_s3_text;

  /// No description provided for @style_smc.
  ///
  /// In kk, this message translates to:
  /// **'SMC (Smart Money Concepts)'**
  String get style_smc;

  /// No description provided for @style_ict.
  ///
  /// In kk, this message translates to:
  /// **'ICT (Inner Circle Trader)'**
  String get style_ict;

  /// No description provided for @style_snr.
  ///
  /// In kk, this message translates to:
  /// **'Support & Resistance'**
  String get style_snr;

  /// No description provided for @style_trendline.
  ///
  /// In kk, this message translates to:
  /// **'Trendline / Channel'**
  String get style_trendline;

  /// No description provided for @style_price_action.
  ///
  /// In kk, this message translates to:
  /// **'Price Action'**
  String get style_price_action;

  /// No description provided for @style_breakout.
  ///
  /// In kk, this message translates to:
  /// **'Breakout / Momentum'**
  String get style_breakout;

  /// No description provided for @style_news.
  ///
  /// In kk, this message translates to:
  /// **'News Trading'**
  String get style_news;

  /// No description provided for @style_scalping.
  ///
  /// In kk, this message translates to:
  /// **'Scalping (M1–M5)'**
  String get style_scalping;

  /// No description provided for @style_swing.
  ///
  /// In kk, this message translates to:
  /// **'Swing (H4–D1)'**
  String get style_swing;

  /// No description provided for @nav_home.
  ///
  /// In kk, this message translates to:
  /// **'Басты'**
  String get nav_home;

  /// No description provided for @nav_intel.
  ///
  /// In kk, this message translates to:
  /// **'Intel'**
  String get nav_intel;

  /// No description provided for @nav_signals.
  ///
  /// In kk, this message translates to:
  /// **'Ideas'**
  String get nav_signals;

  /// No description provided for @idea_disclaimer.
  ///
  /// In kk, this message translates to:
  /// **'Бұл тек ұсыныс әрі жеке пікір, қаржылық кеңес емес.'**
  String get idea_disclaimer;

  /// No description provided for @alerts_title.
  ///
  /// In kk, this message translates to:
  /// **'Баға ескертулері'**
  String get alerts_title;

  /// No description provided for @alerts_empty.
  ///
  /// In kk, this message translates to:
  /// **'Әзірге белсенді ескерту жоқ'**
  String get alerts_empty;

  /// No description provided for @alerts_add.
  ///
  /// In kk, this message translates to:
  /// **'Ескерту қосу'**
  String get alerts_add;

  /// No description provided for @alerts_notify.
  ///
  /// In kk, this message translates to:
  /// **'Хабарлау'**
  String get alerts_notify;

  /// No description provided for @alerts_mode_pips.
  ///
  /// In kk, this message translates to:
  /// **'Пипспен'**
  String get alerts_mode_pips;

  /// No description provided for @alerts_mode_price.
  ///
  /// In kk, this message translates to:
  /// **'Бағамен'**
  String get alerts_mode_price;

  /// No description provided for @alerts_pips_hint.
  ///
  /// In kk, this message translates to:
  /// **'Неше пипс қалғанда хабарлау'**
  String get alerts_pips_hint;

  /// No description provided for @alerts_price_hint.
  ///
  /// In kk, this message translates to:
  /// **'Мақсатты баға'**
  String get alerts_price_hint;

  /// No description provided for @alerts_text_hint.
  ///
  /// In kk, this message translates to:
  /// **'Хабарлама мәтіні'**
  String get alerts_text_hint;

  /// No description provided for @alerts_create.
  ///
  /// In kk, this message translates to:
  /// **'Жасау'**
  String get alerts_create;

  /// No description provided for @alerts_created.
  ///
  /// In kk, this message translates to:
  /// **'Ескерту жасалды'**
  String get alerts_created;

  /// No description provided for @alerts_default_idea.
  ///
  /// In kk, this message translates to:
  /// **'{pair} идеясына баға жақындады'**
  String alerts_default_idea(String pair);

  /// No description provided for @alerts_default_manual.
  ///
  /// In kk, this message translates to:
  /// **'{pair} бағасы мақсатқа жетті'**
  String alerts_default_manual(String pair);

  /// No description provided for @alerts_cond_pips.
  ///
  /// In kk, this message translates to:
  /// **'{price}-ке {pips} пипс қалғанда'**
  String alerts_cond_pips(String pips, String price);

  /// No description provided for @alerts_cond_price.
  ///
  /// In kk, this message translates to:
  /// **'{price} болғанда'**
  String alerts_cond_price(String price);

  /// No description provided for @lib_podcast_translate.
  ///
  /// In kk, this message translates to:
  /// **'Видеоны орысша да, ағылшынша да көруге болады — YouTube-та авто-аударылған субтитр/дубляжды қосыңыз.'**
  String get lib_podcast_translate;

  /// No description provided for @lib_save.
  ///
  /// In kk, this message translates to:
  /// **'Сақтау'**
  String get lib_save;

  /// No description provided for @lib_your_rating.
  ///
  /// In kk, this message translates to:
  /// **'Сіздің бағаңыз'**
  String get lib_your_rating;

  /// No description provided for @lib_your_review.
  ///
  /// In kk, this message translates to:
  /// **'Сіздің пікіріңіз'**
  String get lib_your_review;

  /// No description provided for @lib_review_hint.
  ///
  /// In kk, this message translates to:
  /// **'Оқыған/көрген болсаңыз, ойыңызбен бөлісіңіз'**
  String get lib_review_hint;

  /// No description provided for @lib_save_review.
  ///
  /// In kk, this message translates to:
  /// **'Пікірді сақтау'**
  String get lib_save_review;

  /// No description provided for @lib_review_saved.
  ///
  /// In kk, this message translates to:
  /// **'Пікір сақталды'**
  String get lib_review_saved;

  /// No description provided for @profile_saved.
  ///
  /// In kk, this message translates to:
  /// **'Сақталғандар'**
  String get profile_saved;

  /// No description provided for @saved_empty.
  ///
  /// In kk, this message translates to:
  /// **'Әзірге ештеңе сақталмаған'**
  String get saved_empty;

  /// No description provided for @events_title.
  ///
  /// In kk, this message translates to:
  /// **'Іс-шаралар'**
  String get events_title;

  /// No description provided for @events_empty.
  ///
  /// In kk, this message translates to:
  /// **'Әзірге іс-шара жоқ'**
  String get events_empty;

  /// No description provided for @event_free.
  ///
  /// In kk, this message translates to:
  /// **'Тегін'**
  String get event_free;

  /// No description provided for @event_apply.
  ///
  /// In kk, this message translates to:
  /// **'Өтінім қалдыру'**
  String get event_apply;

  /// No description provided for @event_video.
  ///
  /// In kk, this message translates to:
  /// **'Видео-түсіндірме'**
  String get event_video;

  /// No description provided for @event_about.
  ///
  /// In kk, this message translates to:
  /// **'Іс-шара туралы'**
  String get event_about;

  /// No description provided for @event_type_masterclass.
  ///
  /// In kk, this message translates to:
  /// **'Мастер-класс'**
  String get event_type_masterclass;

  /// No description provided for @event_type_live.
  ///
  /// In kk, this message translates to:
  /// **'Лайв-трейд'**
  String get event_type_live;

  /// No description provided for @event_type_webinar.
  ///
  /// In kk, this message translates to:
  /// **'Вебинар'**
  String get event_type_webinar;

  /// No description provided for @apply_title.
  ///
  /// In kk, this message translates to:
  /// **'Қатысуға өтінім'**
  String get apply_title;

  /// No description provided for @apply_autofill_note.
  ///
  /// In kk, this message translates to:
  /// **'Деректер профильден алынды — өзгертуге болады'**
  String get apply_autofill_note;

  /// No description provided for @apply_name.
  ///
  /// In kk, this message translates to:
  /// **'Аты-жөні'**
  String get apply_name;

  /// No description provided for @apply_phone.
  ///
  /// In kk, this message translates to:
  /// **'Телефон'**
  String get apply_phone;

  /// No description provided for @apply_comment.
  ///
  /// In kk, this message translates to:
  /// **'Пікір (міндетті емес)'**
  String get apply_comment;

  /// No description provided for @apply_submit.
  ///
  /// In kk, this message translates to:
  /// **'Өтінім жіберу'**
  String get apply_submit;

  /// No description provided for @apply_sent.
  ///
  /// In kk, this message translates to:
  /// **'Өтінім жіберілді'**
  String get apply_sent;

  /// No description provided for @home_events.
  ///
  /// In kk, this message translates to:
  /// **'Іс-шаралар'**
  String get home_events;

  /// No description provided for @home_qa_alerts.
  ///
  /// In kk, this message translates to:
  /// **'Ескертулер'**
  String get home_qa_alerts;

  /// No description provided for @home_qa_calc.
  ///
  /// In kk, this message translates to:
  /// **'Калькулятор'**
  String get home_qa_calc;

  /// No description provided for @home_qa_events.
  ///
  /// In kk, this message translates to:
  /// **'Іс-шаралар'**
  String get home_qa_events;

  /// No description provided for @home_events_sub.
  ///
  /// In kk, this message translates to:
  /// **'Мастер-класс, лайв-трейд, вебинар'**
  String get home_events_sub;

  /// No description provided for @agreement_title.
  ///
  /// In kk, this message translates to:
  /// **'Пайдаланушы келісімі'**
  String get agreement_title;

  /// No description provided for @agreement_accept.
  ///
  /// In kk, this message translates to:
  /// **'Қабылдаймын'**
  String get agreement_accept;

  /// No description provided for @agreement_checkbox.
  ///
  /// In kk, this message translates to:
  /// **'Мен оқыдым әрі қабылдаймын:'**
  String get agreement_checkbox;

  /// No description provided for @providers_tab.
  ///
  /// In kk, this message translates to:
  /// **'Провайдерлер'**
  String get providers_tab;

  /// No description provided for @prov_subscribe.
  ///
  /// In kk, this message translates to:
  /// **'Жазылу'**
  String get prov_subscribe;

  /// No description provided for @prov_unsubscribe.
  ///
  /// In kk, this message translates to:
  /// **'Жазылдыңыз'**
  String get prov_unsubscribe;

  /// No description provided for @prov_subscribed_toast.
  ///
  /// In kk, this message translates to:
  /// **'Сіз жазылдыңыз'**
  String get prov_subscribed_toast;

  /// No description provided for @prov_per_month.
  ///
  /// In kk, this message translates to:
  /// **'{price} ₸/ай'**
  String prov_per_month(String price);

  /// No description provided for @prov_winrate.
  ///
  /// In kk, this message translates to:
  /// **'Win Rate'**
  String get prov_winrate;

  /// No description provided for @prov_rr.
  ///
  /// In kk, this message translates to:
  /// **'Орт. RR'**
  String get prov_rr;

  /// No description provided for @prov_trades.
  ///
  /// In kk, this message translates to:
  /// **'Сделкалар'**
  String get prov_trades;

  /// No description provided for @prov_verified.
  ///
  /// In kk, this message translates to:
  /// **'Расталған провайдер'**
  String get prov_verified;

  /// No description provided for @prov_ideas.
  ///
  /// In kk, this message translates to:
  /// **'Провайдер идеялары'**
  String get prov_ideas;

  /// No description provided for @prov_active_ideas.
  ///
  /// In kk, this message translates to:
  /// **'Белсенді идеялар'**
  String get prov_active_ideas;

  /// No description provided for @prov_past_signals.
  ///
  /// In kk, this message translates to:
  /// **'Өткен сигналдар'**
  String get prov_past_signals;

  /// No description provided for @prov_no_past_signals.
  ///
  /// In kk, this message translates to:
  /// **'Жабылған сигналдар әзірге жоқ'**
  String get prov_no_past_signals;

  /// No description provided for @prov_follow.
  ///
  /// In kk, this message translates to:
  /// **'Бақылау'**
  String get prov_follow;

  /// No description provided for @prov_following.
  ///
  /// In kk, this message translates to:
  /// **'Бақылаудасыз'**
  String get prov_following;

  /// No description provided for @prov_follow_toast.
  ///
  /// In kk, this message translates to:
  /// **'Трейдерді бақылайсыз (тегін)'**
  String get prov_follow_toast;

  /// No description provided for @posts_published.
  ///
  /// In kk, this message translates to:
  /// **'Жарияланған идеялар'**
  String get posts_published;

  /// No description provided for @posts_empty.
  ///
  /// In kk, this message translates to:
  /// **'Әзірге жарияланым жоқ'**
  String get posts_empty;

  /// No description provided for @posts_comments_title.
  ///
  /// In kk, this message translates to:
  /// **'Пікірлер'**
  String get posts_comments_title;

  /// No description provided for @posts_comment_hint.
  ///
  /// In kk, this message translates to:
  /// **'Пікір жазу…'**
  String get posts_comment_hint;

  /// No description provided for @posts_send.
  ///
  /// In kk, this message translates to:
  /// **'Жіберу'**
  String get posts_send;

  /// No description provided for @posts_you.
  ///
  /// In kk, this message translates to:
  /// **'Сіз'**
  String get posts_you;

  /// No description provided for @posts_comments_count.
  ///
  /// In kk, this message translates to:
  /// **'{count, plural, =0{Пікір жоқ} other{{count} пікір}}'**
  String posts_comments_count(int count);

  /// No description provided for @home_alert_sub.
  ///
  /// In kk, this message translates to:
  /// **'Баға деңгейіне жеткенде хабарлау'**
  String get home_alert_sub;

  /// No description provided for @nav_journal.
  ///
  /// In kk, this message translates to:
  /// **'Журнал'**
  String get nav_journal;

  /// No description provided for @nav_profile.
  ///
  /// In kk, this message translates to:
  /// **'Профиль'**
  String get nav_profile;

  /// No description provided for @home_greeting.
  ///
  /// In kk, this message translates to:
  /// **'Сәлеметсіз бе'**
  String get home_greeting;

  /// No description provided for @home_session_london.
  ///
  /// In kk, this message translates to:
  /// **'Лондон сессиясы'**
  String get home_session_london;

  /// No description provided for @home_session_ny.
  ///
  /// In kk, this message translates to:
  /// **'Нью-Йорк сессиясы'**
  String get home_session_ny;

  /// No description provided for @home_session_asia.
  ///
  /// In kk, this message translates to:
  /// **'Азия сессиясы'**
  String get home_session_asia;

  /// No description provided for @home_session_overlap.
  ///
  /// In kk, this message translates to:
  /// **'NY/Лондон қабаттасуы'**
  String get home_session_overlap;

  /// No description provided for @home_kpi_win_rate.
  ///
  /// In kk, this message translates to:
  /// **'Win Rate'**
  String get home_kpi_win_rate;

  /// No description provided for @home_kpi_net_pnl.
  ///
  /// In kk, this message translates to:
  /// **'Net P&L'**
  String get home_kpi_net_pnl;

  /// No description provided for @home_kpi_active_signals.
  ///
  /// In kk, this message translates to:
  /// **'Белсенді сигналдар'**
  String get home_kpi_active_signals;

  /// No description provided for @home_kpi_streak.
  ///
  /// In kk, this message translates to:
  /// **'Стрик'**
  String get home_kpi_streak;

  /// No description provided for @home_streak_days.
  ///
  /// In kk, this message translates to:
  /// **'{days} күн қатарынан'**
  String home_streak_days(int days);

  /// No description provided for @home_equity_title.
  ///
  /// In kk, this message translates to:
  /// **'Эквити кривая'**
  String get home_equity_title;

  /// No description provided for @home_ai_insight_title.
  ///
  /// In kk, this message translates to:
  /// **'AI-инсайт күні'**
  String get home_ai_insight_title;

  /// No description provided for @home_recent_trades.
  ///
  /// In kk, this message translates to:
  /// **'Соңғы сделкалар'**
  String get home_recent_trades;

  /// No description provided for @home_next_event.
  ///
  /// In kk, this message translates to:
  /// **'Жақын HIGH-оқиға'**
  String get home_next_event;

  /// No description provided for @home_dxy_bullish.
  ///
  /// In kk, this message translates to:
  /// **'Bullish Gold үшін (DXY төмен)'**
  String get home_dxy_bullish;

  /// No description provided for @home_dxy_bearish.
  ///
  /// In kk, this message translates to:
  /// **'Bearish Gold-қа қысым (DXY жоғары)'**
  String get home_dxy_bearish;

  /// No description provided for @home_dxy_neutral.
  ///
  /// In kk, this message translates to:
  /// **'DXY нейтрал'**
  String get home_dxy_neutral;

  /// No description provided for @home_dxy_logic.
  ///
  /// In kk, this message translates to:
  /// **'H1 DXY {pct}% → Gold кері корреляция (тарихи orт. +0.3–0.8%)'**
  String home_dxy_logic(String pct);

  /// No description provided for @home_active_signal_preview.
  ///
  /// In kk, this message translates to:
  /// **'Белсенді сигнал'**
  String get home_active_signal_preview;

  /// No description provided for @home_lesson_preview.
  ///
  /// In kk, this message translates to:
  /// **'Күн сабағы'**
  String get home_lesson_preview;

  /// No description provided for @home_calendar_button.
  ///
  /// In kk, this message translates to:
  /// **'Толық календарь'**
  String get home_calendar_button;

  /// No description provided for @home_intel_module.
  ///
  /// In kk, this message translates to:
  /// **'Market Intel'**
  String get home_intel_module;

  /// No description provided for @home_intel_expand.
  ///
  /// In kk, this message translates to:
  /// **'Толығырақ'**
  String get home_intel_expand;

  /// No description provided for @home_intel_open_full.
  ///
  /// In kk, this message translates to:
  /// **'Барлығын ашу'**
  String get home_intel_open_full;

  /// No description provided for @intel_tab_news.
  ///
  /// In kk, this message translates to:
  /// **'Жаңалықтар'**
  String get intel_tab_news;

  /// No description provided for @intel_tab_academy.
  ///
  /// In kk, this message translates to:
  /// **'Academy'**
  String get intel_tab_academy;

  /// No description provided for @signals_tab_active.
  ///
  /// In kk, this message translates to:
  /// **'Белсенді'**
  String get signals_tab_active;

  /// No description provided for @signals_tab_closed.
  ///
  /// In kk, this message translates to:
  /// **'Жабық'**
  String get signals_tab_closed;

  /// No description provided for @signals_empty.
  ///
  /// In kk, this message translates to:
  /// **'Сигнал жоқ'**
  String get signals_empty;

  /// No description provided for @signals_pair.
  ///
  /// In kk, this message translates to:
  /// **'Валюта жұбы'**
  String get signals_pair;

  /// No description provided for @signals_direction_buy.
  ///
  /// In kk, this message translates to:
  /// **'BUY'**
  String get signals_direction_buy;

  /// No description provided for @signals_direction_sell.
  ///
  /// In kk, this message translates to:
  /// **'SELL'**
  String get signals_direction_sell;

  /// No description provided for @signals_entry_zone.
  ///
  /// In kk, this message translates to:
  /// **'Кіру зонасы'**
  String get signals_entry_zone;

  /// No description provided for @signals_tp1.
  ///
  /// In kk, this message translates to:
  /// **'TP1'**
  String get signals_tp1;

  /// No description provided for @signals_tp2.
  ///
  /// In kk, this message translates to:
  /// **'TP2'**
  String get signals_tp2;

  /// No description provided for @signals_tp3.
  ///
  /// In kk, this message translates to:
  /// **'TP3'**
  String get signals_tp3;

  /// No description provided for @signals_sl.
  ///
  /// In kk, this message translates to:
  /// **'Stop Loss'**
  String get signals_sl;

  /// No description provided for @signals_rr.
  ///
  /// In kk, this message translates to:
  /// **'Risk/Reward'**
  String get signals_rr;

  /// No description provided for @signals_confidence.
  ///
  /// In kk, this message translates to:
  /// **'Сенімділік'**
  String get signals_confidence;

  /// No description provided for @signals_risk.
  ///
  /// In kk, this message translates to:
  /// **'Тәуекел'**
  String get signals_risk;

  /// No description provided for @signals_risk_low.
  ///
  /// In kk, this message translates to:
  /// **'Төмен тәуекел'**
  String get signals_risk_low;

  /// No description provided for @signals_risk_medium.
  ///
  /// In kk, this message translates to:
  /// **'Орташа тәуекел'**
  String get signals_risk_medium;

  /// No description provided for @signals_risk_high.
  ///
  /// In kk, this message translates to:
  /// **'Жоғары тәуекел'**
  String get signals_risk_high;

  /// No description provided for @signals_risk_low_short.
  ///
  /// In kk, this message translates to:
  /// **'Төмен'**
  String get signals_risk_low_short;

  /// No description provided for @signals_risk_medium_short.
  ///
  /// In kk, this message translates to:
  /// **'Орташа'**
  String get signals_risk_medium_short;

  /// No description provided for @signals_risk_high_short.
  ///
  /// In kk, this message translates to:
  /// **'Жоғары'**
  String get signals_risk_high_short;

  /// No description provided for @signals_analysis.
  ///
  /// In kk, this message translates to:
  /// **'Талдау'**
  String get signals_analysis;

  /// No description provided for @signals_status.
  ///
  /// In kk, this message translates to:
  /// **'Күй'**
  String get signals_status;

  /// No description provided for @signals_status_active.
  ///
  /// In kk, this message translates to:
  /// **'АКТИВТІ'**
  String get signals_status_active;

  /// No description provided for @signals_status_tp1.
  ///
  /// In kk, this message translates to:
  /// **'ЖАБЫЛДЫ TP1'**
  String get signals_status_tp1;

  /// No description provided for @signals_status_tp2.
  ///
  /// In kk, this message translates to:
  /// **'ЖАБЫЛДЫ TP2'**
  String get signals_status_tp2;

  /// No description provided for @signals_status_tp3.
  ///
  /// In kk, this message translates to:
  /// **'ЖАБЫЛДЫ TP3'**
  String get signals_status_tp3;

  /// No description provided for @signals_status_sl.
  ///
  /// In kk, this message translates to:
  /// **'STOP-LOSS'**
  String get signals_status_sl;

  /// No description provided for @signals_result_pips.
  ///
  /// In kk, this message translates to:
  /// **'{pips} пипс'**
  String signals_result_pips(int pips);

  /// No description provided for @signals_wr_short.
  ///
  /// In kk, this message translates to:
  /// **'WR'**
  String get signals_wr_short;

  /// No description provided for @signals_free_badge.
  ///
  /// In kk, this message translates to:
  /// **'Тегін'**
  String get signals_free_badge;

  /// No description provided for @signals_potential.
  ///
  /// In kk, this message translates to:
  /// **'Әлеует'**
  String get signals_potential;

  /// No description provided for @signals_paid_idea.
  ///
  /// In kk, this message translates to:
  /// **'Ақылы идея'**
  String get signals_paid_idea;

  /// No description provided for @signals_screenshot_locked.
  ///
  /// In kk, this message translates to:
  /// **'Скриншот төлемнен кейін'**
  String get signals_screenshot_locked;

  /// No description provided for @signals_unlocked_badge.
  ///
  /// In kk, this message translates to:
  /// **'Ашық'**
  String get signals_unlocked_badge;

  /// No description provided for @signals_locked_title.
  ///
  /// In kk, this message translates to:
  /// **'Идея жабық'**
  String get signals_locked_title;

  /// No description provided for @signals_locked_desc.
  ///
  /// In kk, this message translates to:
  /// **'Скриншот, кіру зонасы, TP, SL және толық талдауды көру үшін идеяны ашыңыз.'**
  String get signals_locked_desc;

  /// No description provided for @signals_unlock_title.
  ///
  /// In kk, this message translates to:
  /// **'Идеяны ашу'**
  String get signals_unlock_title;

  /// No description provided for @signals_unlock_desc.
  ///
  /// In kk, this message translates to:
  /// **'График скриншоты, толық кіру/TP/SL деңгейлері және трейдер талдауы.'**
  String get signals_unlock_desc;

  /// No description provided for @signals_price_label.
  ///
  /// In kk, this message translates to:
  /// **'Баға'**
  String get signals_price_label;

  /// No description provided for @signals_tp_pips.
  ///
  /// In kk, this message translates to:
  /// **'TP {pips} пипс'**
  String signals_tp_pips(int pips);

  /// No description provided for @signals_price_tg.
  ///
  /// In kk, this message translates to:
  /// **'{price} ₸'**
  String signals_price_tg(int price);

  /// No description provided for @signals_unlock_for.
  ///
  /// In kk, this message translates to:
  /// **'{price} ₸-ге ашу'**
  String signals_unlock_for(int price);

  /// No description provided for @signals_pay_kaspi.
  ///
  /// In kk, this message translates to:
  /// **'Kaspi-мен {price} ₸ төлеу'**
  String signals_pay_kaspi(int price);

  /// No description provided for @signals_paying.
  ///
  /// In kk, this message translates to:
  /// **'Төленуде…'**
  String get signals_paying;

  /// No description provided for @signals_pay_secure.
  ///
  /// In kk, this message translates to:
  /// **'Қауіпсіз төлем · Kaspi Pay'**
  String get signals_pay_secure;

  /// No description provided for @signals_unlock_success.
  ///
  /// In kk, this message translates to:
  /// **'Идея ашылды!'**
  String get signals_unlock_success;

  /// No description provided for @signals_publish.
  ///
  /// In kk, this message translates to:
  /// **'Идея жариялау'**
  String get signals_publish;

  /// No description provided for @signals_publish_title.
  ///
  /// In kk, this message translates to:
  /// **'Жаңа идея жариялау'**
  String get signals_publish_title;

  /// No description provided for @signals_published.
  ///
  /// In kk, this message translates to:
  /// **'Идея жарияланды!'**
  String get signals_published;

  /// No description provided for @signals_publish_add_photo.
  ///
  /// In kk, this message translates to:
  /// **'График фотосын қосу'**
  String get signals_publish_add_photo;

  /// No description provided for @signals_publish_text.
  ///
  /// In kk, this message translates to:
  /// **'Идея мәтіні'**
  String get signals_publish_text;

  /// No description provided for @signals_publish_text_hint.
  ///
  /// In kk, this message translates to:
  /// **'Мыс: BUY 2400, TP 2410/2420, SL 2390 — қысқа негіздеме'**
  String get signals_publish_text_hint;

  /// No description provided for @signals_publish_need_text.
  ///
  /// In kk, this message translates to:
  /// **'Идея мәтінін жазыңыз'**
  String get signals_publish_need_text;

  /// No description provided for @signals_entry_from.
  ///
  /// In kk, this message translates to:
  /// **'Кіру (бастап)'**
  String get signals_entry_from;

  /// No description provided for @signals_entry_to.
  ///
  /// In kk, this message translates to:
  /// **'Кіру (дейін)'**
  String get signals_entry_to;

  /// No description provided for @signals_free_idea.
  ///
  /// In kk, this message translates to:
  /// **'Тегін идея'**
  String get signals_free_idea;

  /// No description provided for @signals_free_idea_desc.
  ///
  /// In kk, this message translates to:
  /// **'Қосылса — paywall жоқ, бәріне ашық'**
  String get signals_free_idea_desc;

  /// No description provided for @signals_set_result.
  ///
  /// In kk, this message translates to:
  /// **'Нәтижені қою'**
  String get signals_set_result;

  /// No description provided for @signals_set_result_desc.
  ///
  /// In kk, this message translates to:
  /// **'Идея қай деңгейде жабылғанын белгілеңіз'**
  String get signals_set_result_desc;

  /// No description provided for @signals_result_set.
  ///
  /// In kk, this message translates to:
  /// **'Нәтиже сақталды, идея жабылды'**
  String get signals_result_set;

  /// No description provided for @signals_vote_title.
  ///
  /// In kk, this message translates to:
  /// **'Нәтижеге дауыс беру'**
  String get signals_vote_title;

  /// No description provided for @signals_vote_desc.
  ///
  /// In kk, this message translates to:
  /// **'Сіздің болжамыңыз: қай деңгейге жетеді?'**
  String get signals_vote_desc;

  /// No description provided for @signals_verify_title.
  ///
  /// In kk, this message translates to:
  /// **'Нәтижені растау'**
  String get signals_verify_title;

  /// No description provided for @signals_verify_desc.
  ///
  /// In kk, this message translates to:
  /// **'Шынымен солай болды ма? Не болғанын дауыспен растаңыз.'**
  String get signals_verify_desc;

  /// No description provided for @signals_trader_marked.
  ///
  /// In kk, this message translates to:
  /// **'Трейдер белгіледі: {result}'**
  String signals_trader_marked(String result);

  /// No description provided for @signals_trader_claim.
  ///
  /// In kk, this message translates to:
  /// **'трейдер мәлімдемесі'**
  String get signals_trader_claim;

  /// No description provided for @signals_updates_title.
  ///
  /// In kk, this message translates to:
  /// **'Трейдер апдейттері'**
  String get signals_updates_title;

  /// No description provided for @signals_updates_empty.
  ///
  /// In kk, this message translates to:
  /// **'Әзірге апдейт жоқ.'**
  String get signals_updates_empty;

  /// No description provided for @signals_update_hint.
  ///
  /// In kk, this message translates to:
  /// **'Апдейт қосу (мыс. «TP3 күтемін»)…'**
  String get signals_update_hint;

  /// No description provided for @signals_verify_confirmed.
  ///
  /// In kk, this message translates to:
  /// **'Қоғам растайды ({pct}%)'**
  String signals_verify_confirmed(int pct);

  /// No description provided for @signals_verify_disputed.
  ///
  /// In kk, this message translates to:
  /// **'Дауланған — көбі {result} дейді'**
  String signals_verify_disputed(String result);

  /// No description provided for @prov_tab_active.
  ///
  /// In kk, this message translates to:
  /// **'Белсенді'**
  String get prov_tab_active;

  /// No description provided for @prov_tab_past.
  ///
  /// In kk, this message translates to:
  /// **'Өткен'**
  String get prov_tab_past;

  /// No description provided for @prov_tab_posts.
  ///
  /// In kk, this message translates to:
  /// **'Посттар'**
  String get prov_tab_posts;

  /// No description provided for @profile_trader_mode.
  ///
  /// In kk, this message translates to:
  /// **'Трейдер режимі'**
  String get profile_trader_mode;

  /// No description provided for @profile_trader_mode_desc.
  ///
  /// In kk, this message translates to:
  /// **'Идея жариялау және басқару'**
  String get profile_trader_mode_desc;

  /// No description provided for @profile_become_trader.
  ///
  /// In kk, this message translates to:
  /// **'Расталған трейдер болу'**
  String get profile_become_trader;

  /// No description provided for @profile_verified_trader.
  ///
  /// In kk, this message translates to:
  /// **'Расталған трейдер ✓'**
  String get profile_verified_trader;

  /// No description provided for @profile_verified_trader_desc.
  ///
  /// In kk, this message translates to:
  /// **'Идеяларды Ideas бетінен жариялайсыз'**
  String get profile_verified_trader_desc;

  /// No description provided for @profile_support.
  ///
  /// In kk, this message translates to:
  /// **'Қолдау / Әкімшілік'**
  String get profile_support;

  /// No description provided for @support_title.
  ///
  /// In kk, this message translates to:
  /// **'Қолдау қызметі'**
  String get support_title;

  /// No description provided for @support_desc.
  ///
  /// In kk, this message translates to:
  /// **'Сұрақ, верификация немесе серіктестік туралы жазыңыз — хабарыңыз командаға жетеді.'**
  String get support_desc;

  /// No description provided for @support_message_hint.
  ///
  /// In kk, this message translates to:
  /// **'Хабарыңызды жазыңыз…'**
  String get support_message_hint;

  /// No description provided for @support_send.
  ///
  /// In kk, this message translates to:
  /// **'Жіберу'**
  String get support_send;

  /// No description provided for @support_sent.
  ///
  /// In kk, this message translates to:
  /// **'Хабар жіберілді! Жақын арада жауап береміз.'**
  String get support_sent;

  /// No description provided for @trader_apply_title.
  ///
  /// In kk, this message translates to:
  /// **'Расталған трейдерге өтінім'**
  String get trader_apply_title;

  /// No description provided for @trader_apply_desc.
  ///
  /// In kk, this message translates to:
  /// **'Команда тексеруі үшін өзіңіз туралы ақпарат жіберіңіз.'**
  String get trader_apply_desc;

  /// No description provided for @trader_apply_years.
  ///
  /// In kk, this message translates to:
  /// **'Трейдинг тәжірибесі (жыл)'**
  String get trader_apply_years;

  /// No description provided for @trader_apply_about.
  ///
  /// In kk, this message translates to:
  /// **'Өзіңіз туралы / стратегияңыз'**
  String get trader_apply_about;

  /// No description provided for @trader_apply_about_hint.
  ///
  /// In kk, this message translates to:
  /// **'Стиль, нарықтар, нәтижелер…'**
  String get trader_apply_about_hint;

  /// No description provided for @trader_apply_proof.
  ///
  /// In kk, this message translates to:
  /// **'Дәлел сілтемесі (қалауыңша)'**
  String get trader_apply_proof;

  /// No description provided for @trader_apply_proof_hint.
  ///
  /// In kk, this message translates to:
  /// **'MyFxBook, есеп, Telegram/Instagram…'**
  String get trader_apply_proof_hint;

  /// No description provided for @trader_apply_tip.
  ///
  /// In kk, this message translates to:
  /// **'Сенімге ие болудың ең жақсы жолы — алдымен 3 ТЕГІН сигнал жариялау. Сонда команда мен қолданушылар сіздің edge-іңізді көреді.'**
  String get trader_apply_tip;

  /// No description provided for @trader_apply_send.
  ///
  /// In kk, this message translates to:
  /// **'Өтінім жіберу'**
  String get trader_apply_send;

  /// No description provided for @trader_apply_sent.
  ///
  /// In kk, this message translates to:
  /// **'Өтінім жіберілді! (демо: трейдер режимі қосылды)'**
  String get trader_apply_sent;

  /// No description provided for @signals_provider_stats.
  ///
  /// In kk, this message translates to:
  /// **'Провайдер статистикасы'**
  String get signals_provider_stats;

  /// No description provided for @signals_provider_win_rate.
  ///
  /// In kk, this message translates to:
  /// **'Win Rate'**
  String get signals_provider_win_rate;

  /// No description provided for @signals_provider_profit_factor.
  ///
  /// In kk, this message translates to:
  /// **'Profit Factor'**
  String get signals_provider_profit_factor;

  /// No description provided for @signals_provider_avg_rr.
  ///
  /// In kk, this message translates to:
  /// **'Орташа RR'**
  String get signals_provider_avg_rr;

  /// No description provided for @intel_impact_bullish.
  ///
  /// In kk, this message translates to:
  /// **'BULLISH'**
  String get intel_impact_bullish;

  /// No description provided for @intel_impact_bearish.
  ///
  /// In kk, this message translates to:
  /// **'BEARISH'**
  String get intel_impact_bearish;

  /// No description provided for @intel_impact_neutral.
  ///
  /// In kk, this message translates to:
  /// **'NEUTRAL'**
  String get intel_impact_neutral;

  /// No description provided for @intel_support.
  ///
  /// In kk, this message translates to:
  /// **'Support'**
  String get intel_support;

  /// No description provided for @intel_resistance.
  ///
  /// In kk, this message translates to:
  /// **'Resistance'**
  String get intel_resistance;

  /// No description provided for @intel_sl_recommendation.
  ///
  /// In kk, this message translates to:
  /// **'SL ұсынылады'**
  String get intel_sl_recommendation;

  /// No description provided for @intel_sentiment.
  ///
  /// In kk, this message translates to:
  /// **'Sentiment'**
  String get intel_sentiment;

  /// No description provided for @intel_bears.
  ///
  /// In kk, this message translates to:
  /// **'Аюлар'**
  String get intel_bears;

  /// No description provided for @intel_bulls.
  ///
  /// In kk, this message translates to:
  /// **'Бұқалар'**
  String get intel_bulls;

  /// No description provided for @calendar_title.
  ///
  /// In kk, this message translates to:
  /// **'Экономикалық календарь'**
  String get calendar_title;

  /// No description provided for @calendar_filter_all.
  ///
  /// In kk, this message translates to:
  /// **'Барлығы'**
  String get calendar_filter_all;

  /// No description provided for @calendar_filter_low.
  ///
  /// In kk, this message translates to:
  /// **'LOW'**
  String get calendar_filter_low;

  /// No description provided for @calendar_filter_medium.
  ///
  /// In kk, this message translates to:
  /// **'MEDIUM'**
  String get calendar_filter_medium;

  /// No description provided for @calendar_filter_high.
  ///
  /// In kk, this message translates to:
  /// **'HIGH'**
  String get calendar_filter_high;

  /// No description provided for @calendar_forecast.
  ///
  /// In kk, this message translates to:
  /// **'Болжам'**
  String get calendar_forecast;

  /// No description provided for @calendar_previous.
  ///
  /// In kk, this message translates to:
  /// **'Алдыңғы'**
  String get calendar_previous;

  /// No description provided for @calendar_actual.
  ///
  /// In kk, this message translates to:
  /// **'Нақты'**
  String get calendar_actual;

  /// No description provided for @calendar_empty.
  ///
  /// In kk, this message translates to:
  /// **'Оқиға жоқ'**
  String get calendar_empty;

  /// No description provided for @calendar_in_h.
  ///
  /// In kk, this message translates to:
  /// **'{h} сағаттан кейін'**
  String calendar_in_h(int h);

  /// No description provided for @calendar_in_m.
  ///
  /// In kk, this message translates to:
  /// **'{m} минуттан кейін'**
  String calendar_in_m(int m);

  /// No description provided for @calendar_soon.
  ///
  /// In kk, this message translates to:
  /// **'жақында'**
  String get calendar_soon;

  /// No description provided for @calendar_today.
  ///
  /// In kk, this message translates to:
  /// **'Бүгін'**
  String get calendar_today;

  /// No description provided for @calendar_tomorrow.
  ///
  /// In kk, this message translates to:
  /// **'Ертең'**
  String get calendar_tomorrow;

  /// No description provided for @calendar_previous_short.
  ///
  /// In kk, this message translates to:
  /// **'АЛДЫҢҒЫ'**
  String get calendar_previous_short;

  /// No description provided for @calendar_forecast_short.
  ///
  /// In kk, this message translates to:
  /// **'БОЛЖАМ'**
  String get calendar_forecast_short;

  /// No description provided for @calendar_actual_short.
  ///
  /// In kk, this message translates to:
  /// **'НАҚТЫ'**
  String get calendar_actual_short;

  /// No description provided for @calendar_released.
  ///
  /// In kk, this message translates to:
  /// **'жарияланды'**
  String get calendar_released;

  /// No description provided for @journal_empty.
  ///
  /// In kk, this message translates to:
  /// **'Сделка жоқ'**
  String get journal_empty;

  /// No description provided for @journal_filter_all_brokers.
  ///
  /// In kk, this message translates to:
  /// **'Барлық брокерлер'**
  String get journal_filter_all_brokers;

  /// No description provided for @journal_emotion_check.
  ///
  /// In kk, this message translates to:
  /// **'Эмоция чекин'**
  String get journal_emotion_check;

  /// No description provided for @journal_setup_tag.
  ///
  /// In kk, this message translates to:
  /// **'Setup'**
  String get journal_setup_tag;

  /// No description provided for @journal_session_tag.
  ///
  /// In kk, this message translates to:
  /// **'Сессия'**
  String get journal_session_tag;

  /// No description provided for @journal_rr_planned.
  ///
  /// In kk, this message translates to:
  /// **'Жоспарлы RR'**
  String get journal_rr_planned;

  /// No description provided for @journal_rr_actual.
  ///
  /// In kk, this message translates to:
  /// **'Нақты RR'**
  String get journal_rr_actual;

  /// No description provided for @journal_add_trade.
  ///
  /// In kk, this message translates to:
  /// **'Жаңа сделка'**
  String get journal_add_trade;

  /// No description provided for @journal_instrument.
  ///
  /// In kk, this message translates to:
  /// **'Инструмент'**
  String get journal_instrument;

  /// No description provided for @journal_direction.
  ///
  /// In kk, this message translates to:
  /// **'Бағыт'**
  String get journal_direction;

  /// No description provided for @journal_lot.
  ///
  /// In kk, this message translates to:
  /// **'Лот'**
  String get journal_lot;

  /// No description provided for @journal_sl_opt.
  ///
  /// In kk, this message translates to:
  /// **'SL (қалауыңша)'**
  String get journal_sl_opt;

  /// No description provided for @journal_fees_opt.
  ///
  /// In kk, this message translates to:
  /// **'Комиссия (\$)'**
  String get journal_fees_opt;

  /// No description provided for @journal_grade.
  ///
  /// In kk, this message translates to:
  /// **'Сделка бағасы'**
  String get journal_grade;

  /// No description provided for @journal_open_price.
  ///
  /// In kk, this message translates to:
  /// **'Кіру бағасы'**
  String get journal_open_price;

  /// No description provided for @journal_close_price.
  ///
  /// In kk, this message translates to:
  /// **'Жабу бағасы'**
  String get journal_close_price;

  /// No description provided for @journal_pnl.
  ///
  /// In kk, this message translates to:
  /// **'P&L (\$)'**
  String get journal_pnl;

  /// No description provided for @journal_notes.
  ///
  /// In kk, this message translates to:
  /// **'Ескертулер (қалауыңызша)'**
  String get journal_notes;

  /// No description provided for @journal_saved.
  ///
  /// In kk, this message translates to:
  /// **'Сделка сақталды'**
  String get journal_saved;

  /// No description provided for @journal_delete.
  ///
  /// In kk, this message translates to:
  /// **'Жою'**
  String get journal_delete;

  /// No description provided for @journal_logout.
  ///
  /// In kk, this message translates to:
  /// **'Шығу'**
  String get journal_logout;

  /// No description provided for @journal_link_broker.
  ///
  /// In kk, this message translates to:
  /// **'Брокер қосу'**
  String get journal_link_broker;

  /// No description provided for @journal_accounts_title.
  ///
  /// In kk, this message translates to:
  /// **'Брокер аккаунттары'**
  String get journal_accounts_title;

  /// No description provided for @journal_no_accounts.
  ///
  /// In kk, this message translates to:
  /// **'Әлі брокер қосылмаған'**
  String get journal_no_accounts;

  /// No description provided for @journal_add_first_broker.
  ///
  /// In kk, this message translates to:
  /// **'Бірінші брокерді қос'**
  String get journal_add_first_broker;

  /// No description provided for @broker_step_choose_broker.
  ///
  /// In kk, this message translates to:
  /// **'Брокерді таңда'**
  String get broker_step_choose_broker;

  /// No description provided for @broker_step_choose_platform.
  ///
  /// In kk, this message translates to:
  /// **'Платформаны таңда'**
  String get broker_step_choose_platform;

  /// No description provided for @broker_step_credentials.
  ///
  /// In kk, this message translates to:
  /// **'Тіркеу деректерін енгіз'**
  String get broker_step_credentials;

  /// No description provided for @broker_account_number.
  ///
  /// In kk, this message translates to:
  /// **'Аккаунт нөмірі'**
  String get broker_account_number;

  /// No description provided for @broker_account_number_hint.
  ///
  /// In kk, this message translates to:
  /// **'85204517'**
  String get broker_account_number_hint;

  /// No description provided for @broker_server.
  ///
  /// In kk, this message translates to:
  /// **'Сервер'**
  String get broker_server;

  /// No description provided for @broker_server_hint.
  ///
  /// In kk, this message translates to:
  /// **'Exness-MT5Real8'**
  String get broker_server_hint;

  /// No description provided for @broker_investor_password.
  ///
  /// In kk, this message translates to:
  /// **'Investor Password (READ-ONLY)'**
  String get broker_investor_password;

  /// No description provided for @broker_investor_password_hint.
  ///
  /// In kk, this message translates to:
  /// **'Тек қарау құпиясөзі — сауда мүмкін емес'**
  String get broker_investor_password_hint;

  /// No description provided for @broker_investor_password_help.
  ///
  /// In kk, this message translates to:
  /// **'Investor Password — терминалда сауданы рұқсат бермейді, тек тарихты оқу үшін. Backend-те AES-256 шифрленеді.'**
  String get broker_investor_password_help;

  /// No description provided for @broker_link_button.
  ///
  /// In kk, this message translates to:
  /// **'Қосу'**
  String get broker_link_button;

  /// No description provided for @broker_link_ctrader.
  ///
  /// In kk, this message translates to:
  /// **'cTrader-ке OAuth арқылы кіру'**
  String get broker_link_ctrader;

  /// No description provided for @broker_link_ctrader_help.
  ///
  /// In kk, this message translates to:
  /// **'cTrader аккаунтыңыз арқылы қауіпсіз авторизация — пароль қажет емес.'**
  String get broker_link_ctrader_help;

  /// No description provided for @broker_ea_download_help.
  ///
  /// In kk, this message translates to:
  /// **'MT4/MT5 үшін біздің Expert Advisor-ды (.ex4/.ex5) терминалға орнатыңыз. EA сделкалар тарихын сервер-ге жібереді.'**
  String get broker_ea_download_help;

  /// No description provided for @broker_ea_download.
  ///
  /// In kk, this message translates to:
  /// **'EA файлды жүктеу'**
  String get broker_ea_download;

  /// No description provided for @broker_synced.
  ///
  /// In kk, this message translates to:
  /// **'Соңғы синхр.'**
  String get broker_synced;

  /// No description provided for @broker_balance.
  ///
  /// In kk, this message translates to:
  /// **'Баланс'**
  String get broker_balance;

  /// No description provided for @broker_remove.
  ///
  /// In kk, this message translates to:
  /// **'Жою'**
  String get broker_remove;

  /// No description provided for @broker_sync_now.
  ///
  /// In kk, this message translates to:
  /// **'Қазір синхр.'**
  String get broker_sync_now;

  /// No description provided for @broker_remove_confirm.
  ///
  /// In kk, this message translates to:
  /// **'{name} аккаунтын жоямыз ба?'**
  String broker_remove_confirm(String name);

  /// No description provided for @broker_exness.
  ///
  /// In kk, this message translates to:
  /// **'Exness'**
  String get broker_exness;

  /// No description provided for @broker_ic_markets.
  ///
  /// In kk, this message translates to:
  /// **'IC Markets'**
  String get broker_ic_markets;

  /// No description provided for @broker_xm.
  ///
  /// In kk, this message translates to:
  /// **'XM'**
  String get broker_xm;

  /// No description provided for @broker_pepperstone.
  ///
  /// In kk, this message translates to:
  /// **'Pepperstone'**
  String get broker_pepperstone;

  /// No description provided for @broker_oanda.
  ///
  /// In kk, this message translates to:
  /// **'OANDA'**
  String get broker_oanda;

  /// No description provided for @broker_fxpro.
  ///
  /// In kk, this message translates to:
  /// **'FxPro'**
  String get broker_fxpro;

  /// No description provided for @broker_other.
  ///
  /// In kk, this message translates to:
  /// **'Басқа'**
  String get broker_other;

  /// No description provided for @platform_mt4.
  ///
  /// In kk, this message translates to:
  /// **'MetaTrader 4'**
  String get platform_mt4;

  /// No description provided for @platform_mt5.
  ///
  /// In kk, this message translates to:
  /// **'MetaTrader 5'**
  String get platform_mt5;

  /// No description provided for @platform_ctrader.
  ///
  /// In kk, this message translates to:
  /// **'cTrader'**
  String get platform_ctrader;

  /// No description provided for @platform_mt_subtitle.
  ///
  /// In kk, this message translates to:
  /// **'Investor Password + Сервер'**
  String get platform_mt_subtitle;

  /// No description provided for @platform_ctrader_subtitle.
  ///
  /// In kk, this message translates to:
  /// **'OAuth 2.0'**
  String get platform_ctrader_subtitle;

  /// No description provided for @setup_retest.
  ///
  /// In kk, this message translates to:
  /// **'Retest'**
  String get setup_retest;

  /// No description provided for @setup_breakout.
  ///
  /// In kk, this message translates to:
  /// **'Breakout'**
  String get setup_breakout;

  /// No description provided for @setup_smc_ob.
  ///
  /// In kk, this message translates to:
  /// **'SMC OB'**
  String get setup_smc_ob;

  /// No description provided for @setup_reversal.
  ///
  /// In kk, this message translates to:
  /// **'Reversal'**
  String get setup_reversal;

  /// No description provided for @setup_news.
  ///
  /// In kk, this message translates to:
  /// **'News'**
  String get setup_news;

  /// No description provided for @setup_fvg.
  ///
  /// In kk, this message translates to:
  /// **'FVG'**
  String get setup_fvg;

  /// No description provided for @subscription_inactive.
  ///
  /// In kk, this message translates to:
  /// **'Жазылым белсенді емес'**
  String get subscription_inactive;

  /// No description provided for @subscription_active.
  ///
  /// In kk, this message translates to:
  /// **'Жазылым белсенді'**
  String get subscription_active;

  /// No description provided for @subscription_pending.
  ///
  /// In kk, this message translates to:
  /// **'Менеджер тексерістерде'**
  String get subscription_pending;

  /// No description provided for @subscription_expires_in.
  ///
  /// In kk, this message translates to:
  /// **'Қалды: {days} күн'**
  String subscription_expires_in(int days);

  /// No description provided for @subscription_get_access.
  ///
  /// In kk, this message translates to:
  /// **'Қол жеткізу — 30 000 ₸'**
  String get subscription_get_access;

  /// No description provided for @subscription_kaspi_button.
  ///
  /// In kk, this message translates to:
  /// **'Kaspi арқылы төлеу'**
  String get subscription_kaspi_button;

  /// No description provided for @subscription_upload_receipt.
  ///
  /// In kk, this message translates to:
  /// **'Чек жүктеу'**
  String get subscription_upload_receipt;

  /// No description provided for @subscription_receipt_uploaded.
  ///
  /// In kk, this message translates to:
  /// **'Чек жіберілді'**
  String get subscription_receipt_uploaded;

  /// No description provided for @subscription_change_receipt.
  ///
  /// In kk, this message translates to:
  /// **'Чекті өзгерту'**
  String get subscription_change_receipt;

  /// No description provided for @subscription_confirm_submit.
  ///
  /// In kk, this message translates to:
  /// **'Менеджерге жіберу'**
  String get subscription_confirm_submit;

  /// No description provided for @subscription_step_1.
  ///
  /// In kk, this message translates to:
  /// **'Kaspi ссылка арқылы 30 000 ₸ төлеңіз'**
  String get subscription_step_1;

  /// No description provided for @subscription_step_2.
  ///
  /// In kk, this message translates to:
  /// **'Төлем чегінің скриншотын жүктеңіз'**
  String get subscription_step_2;

  /// No description provided for @subscription_step_3.
  ///
  /// In kk, this message translates to:
  /// **'Менеджер 24 сағат ішінде растайды'**
  String get subscription_step_3;

  /// No description provided for @subscription_mock_approve.
  ///
  /// In kk, this message translates to:
  /// **'[Demo] Менеджер растады'**
  String get subscription_mock_approve;

  /// No description provided for @subscription_roi.
  ///
  /// In kk, this message translates to:
  /// **'ROI: {roi}'**
  String subscription_roi(String roi);

  /// No description provided for @academy_title.
  ///
  /// In kk, this message translates to:
  /// **'Edge Academy'**
  String get academy_title;

  /// No description provided for @academy_take_test.
  ///
  /// In kk, this message translates to:
  /// **'Трейдингтегі плюс/минустарыңды анықтау'**
  String get academy_take_test;

  /// No description provided for @academy_take_test_subtitle.
  ///
  /// In kk, this message translates to:
  /// **'20 сұрақ — күшті жақтарыңыз бен әлсіз тұстарыңызды табамыз'**
  String get academy_take_test_subtitle;

  /// No description provided for @academy_library.
  ///
  /// In kk, this message translates to:
  /// **'Кітапхана'**
  String get academy_library;

  /// No description provided for @academy_library_subtitle.
  ///
  /// In kk, this message translates to:
  /// **'Не оқу/көру/тыңдау керек — категория бойынша'**
  String get academy_library_subtitle;

  /// No description provided for @academy_category_books.
  ///
  /// In kk, this message translates to:
  /// **'Кітаптар'**
  String get academy_category_books;

  /// No description provided for @academy_category_films.
  ///
  /// In kk, this message translates to:
  /// **'Фильмдер'**
  String get academy_category_films;

  /// No description provided for @academy_category_podcasts.
  ///
  /// In kk, this message translates to:
  /// **'Подкасттар'**
  String get academy_category_podcasts;

  /// No description provided for @academy_filter_by_problem.
  ///
  /// In kk, this message translates to:
  /// **'Мәселе бойынша'**
  String get academy_filter_by_problem;

  /// No description provided for @academy_filter_all.
  ///
  /// In kk, this message translates to:
  /// **'Барлығы'**
  String get academy_filter_all;

  /// No description provided for @academy_open_source.
  ///
  /// In kk, this message translates to:
  /// **'Толық қарау'**
  String get academy_open_source;

  /// No description provided for @tools_title.
  ///
  /// In kk, this message translates to:
  /// **'Құралдар'**
  String get tools_title;

  /// No description provided for @tools_position_calc.
  ///
  /// In kk, this message translates to:
  /// **'Позиция калькуляторы'**
  String get tools_position_calc;

  /// No description provided for @tools_position_calc_subtitle.
  ///
  /// In kk, this message translates to:
  /// **'Лот мөлшерін есептеу — risk % + SL негізінде'**
  String get tools_position_calc_subtitle;

  /// No description provided for @calc_mode_by_pips.
  ///
  /// In kk, this message translates to:
  /// **'SL pip арқылы'**
  String get calc_mode_by_pips;

  /// No description provided for @calc_mode_by_price.
  ///
  /// In kk, this message translates to:
  /// **'Кіру + SL бағасы арқылы'**
  String get calc_mode_by_price;

  /// No description provided for @calc_balance.
  ///
  /// In kk, this message translates to:
  /// **'Депозит (\$)'**
  String get calc_balance;

  /// No description provided for @calc_risk_pct.
  ///
  /// In kk, this message translates to:
  /// **'Тәуекел %'**
  String get calc_risk_pct;

  /// No description provided for @calc_sl_pips.
  ///
  /// In kk, this message translates to:
  /// **'SL қашықтығы (pip)'**
  String get calc_sl_pips;

  /// No description provided for @calc_entry.
  ///
  /// In kk, this message translates to:
  /// **'Кіру бағасы'**
  String get calc_entry;

  /// No description provided for @calc_sl_price.
  ///
  /// In kk, this message translates to:
  /// **'SL бағасы'**
  String get calc_sl_price;

  /// No description provided for @calc_tp_price.
  ///
  /// In kk, this message translates to:
  /// **'TP бағасы (қалауыңызша)'**
  String get calc_tp_price;

  /// No description provided for @calc_pip_value.
  ///
  /// In kk, this message translates to:
  /// **'Pip құны (\$)'**
  String get calc_pip_value;

  /// No description provided for @calc_result_lot.
  ///
  /// In kk, this message translates to:
  /// **'Ұсынылатын лот'**
  String get calc_result_lot;

  /// No description provided for @calc_result_risk.
  ///
  /// In kk, this message translates to:
  /// **'Тәуекелге қойылған сома'**
  String get calc_result_risk;

  /// No description provided for @calc_result_rr.
  ///
  /// In kk, this message translates to:
  /// **'Risk/Reward'**
  String get calc_result_rr;

  /// No description provided for @calc_calculate.
  ///
  /// In kk, this message translates to:
  /// **'Есептеу'**
  String get calc_calculate;

  /// No description provided for @calc_help_pip_xau.
  ///
  /// In kk, this message translates to:
  /// **'XAU/USD: 1 lot ≈ \$10/pip'**
  String get calc_help_pip_xau;

  /// No description provided for @academy_continue_test.
  ///
  /// In kk, this message translates to:
  /// **'Тестті жалғастыру'**
  String get academy_continue_test;

  /// No description provided for @academy_my_profile.
  ///
  /// In kk, this message translates to:
  /// **'Менің профилім'**
  String get academy_my_profile;

  /// No description provided for @academy_lessons_for_you.
  ///
  /// In kk, this message translates to:
  /// **'Сізге арналған сабақтар'**
  String get academy_lessons_for_you;

  /// No description provided for @academy_all_lessons.
  ///
  /// In kk, this message translates to:
  /// **'Барлық сабақтар'**
  String get academy_all_lessons;

  /// No description provided for @academy_xp.
  ///
  /// In kk, this message translates to:
  /// **'{xp} XP'**
  String academy_xp(int xp);

  /// No description provided for @academy_streak_days.
  ///
  /// In kk, this message translates to:
  /// **'{days} күн'**
  String academy_streak_days(int days);

  /// No description provided for @academy_weekly_progress.
  ///
  /// In kk, this message translates to:
  /// **'Аптаның прогресі'**
  String get academy_weekly_progress;

  /// No description provided for @gallup_q_progress.
  ///
  /// In kk, this message translates to:
  /// **'Сұрақ {current} / {total}'**
  String gallup_q_progress(int current, int total);

  /// No description provided for @gallup_result_title.
  ///
  /// In kk, this message translates to:
  /// **'Сіздің профиліңіз'**
  String get gallup_result_title;

  /// No description provided for @gallup_profile_revenge.
  ///
  /// In kk, this message translates to:
  /// **'Месть рынку'**
  String get gallup_profile_revenge;

  /// No description provided for @gallup_profile_revenge_desc.
  ///
  /// In kk, this message translates to:
  /// **'Шығыннан кейін эмоциямен кіресіз. Қаражатты қайтаруға тырысу — ең үлкен қауіп.'**
  String get gallup_profile_revenge_desc;

  /// No description provided for @gallup_profile_risk.
  ///
  /// In kk, this message translates to:
  /// **'Бақыланбайтын тәуекел'**
  String get gallup_profile_risk;

  /// No description provided for @gallup_profile_risk_desc.
  ///
  /// In kk, this message translates to:
  /// **'Лотты сезіммен таңдайсыз. Жүйелі risk-management жоқ.'**
  String get gallup_profile_risk_desc;

  /// No description provided for @gallup_profile_hope.
  ///
  /// In kk, this message translates to:
  /// **'Үмітпен сауда'**
  String get gallup_profile_hope;

  /// No description provided for @gallup_profile_hope_desc.
  ///
  /// In kk, this message translates to:
  /// **'Интуиция жоспардан жоғары. SL кеңейту — таныс әдет.'**
  String get gallup_profile_hope_desc;

  /// No description provided for @gallup_profile_disciplined.
  ///
  /// In kk, this message translates to:
  /// **'Дисциплинаны трейдер'**
  String get gallup_profile_disciplined;

  /// No description provided for @gallup_profile_disciplined_desc.
  ///
  /// In kk, this message translates to:
  /// **'Күшті база. Едж табу — келесі қадам.'**
  String get gallup_profile_disciplined_desc;

  /// No description provided for @gallup_view_lessons.
  ///
  /// In kk, this message translates to:
  /// **'Сабақтарды көру'**
  String get gallup_view_lessons;

  /// No description provided for @lesson_source.
  ///
  /// In kk, this message translates to:
  /// **'Дереккөз'**
  String get lesson_source;

  /// No description provided for @lesson_quote.
  ///
  /// In kk, this message translates to:
  /// **'Цитата'**
  String get lesson_quote;

  /// No description provided for @lesson_explanation.
  ///
  /// In kk, this message translates to:
  /// **'Түсіндірме'**
  String get lesson_explanation;

  /// No description provided for @lesson_gold_application.
  ///
  /// In kk, this message translates to:
  /// **'XAU/USD-та қалай қолдану'**
  String get lesson_gold_application;

  /// No description provided for @lesson_quick_check.
  ///
  /// In kk, this message translates to:
  /// **'Тез сұрақ'**
  String get lesson_quick_check;

  /// No description provided for @lesson_quick_check_hint.
  ///
  /// In kk, this message translates to:
  /// **'Жауабыңызды осында жазыңыз…'**
  String get lesson_quick_check_hint;

  /// No description provided for @lesson_correct_answer.
  ///
  /// In kk, this message translates to:
  /// **'Дұрыс жауап: {answer}'**
  String lesson_correct_answer(String answer);

  /// No description provided for @lesson_complete.
  ///
  /// In kk, this message translates to:
  /// **'Сабақты аяқтау'**
  String get lesson_complete;

  /// No description provided for @lesson_completed.
  ///
  /// In kk, this message translates to:
  /// **'Сабақ аяқталды (+{xp} XP)'**
  String lesson_completed(int xp);

  /// No description provided for @library_read_summary.
  ///
  /// In kk, this message translates to:
  /// **'Қысқаша мазмұнын оқу'**
  String get library_read_summary;

  /// No description provided for @library_summary.
  ///
  /// In kk, this message translates to:
  /// **'Қысқаша мазмұн'**
  String get library_summary;

  /// No description provided for @library_about.
  ///
  /// In kk, this message translates to:
  /// **'Не туралы'**
  String get library_about;

  /// No description provided for @library_key_ideas.
  ///
  /// In kk, this message translates to:
  /// **'Негізгі идеялар'**
  String get library_key_ideas;

  /// No description provided for @library_conclusion.
  ///
  /// In kk, this message translates to:
  /// **'Қорытынды'**
  String get library_conclusion;

  /// No description provided for @library_watch.
  ///
  /// In kk, this message translates to:
  /// **'Видеоны көру'**
  String get library_watch;

  /// No description provided for @library_open_youtube.
  ///
  /// In kk, this message translates to:
  /// **'YouTube-та ашу'**
  String get library_open_youtube;

  /// No description provided for @library_rating.
  ///
  /// In kk, this message translates to:
  /// **'Рейтинг'**
  String get library_rating;

  /// No description provided for @tag_psychology.
  ///
  /// In kk, this message translates to:
  /// **'Психология'**
  String get tag_psychology;

  /// No description provided for @tag_risk.
  ///
  /// In kk, this message translates to:
  /// **'Риск'**
  String get tag_risk;

  /// No description provided for @tag_strategy.
  ///
  /// In kk, this message translates to:
  /// **'Стратегия'**
  String get tag_strategy;

  /// No description provided for @tag_discipline.
  ///
  /// In kk, this message translates to:
  /// **'Дисциплина'**
  String get tag_discipline;

  /// No description provided for @tag_mindset.
  ///
  /// In kk, this message translates to:
  /// **'Мышление'**
  String get tag_mindset;

  /// No description provided for @profile_avatar_pick.
  ///
  /// In kk, this message translates to:
  /// **'Аватарды өзгерту'**
  String get profile_avatar_pick;

  /// No description provided for @profile_edit.
  ///
  /// In kk, this message translates to:
  /// **'Профильді өңдеу'**
  String get profile_edit;

  /// No description provided for @profile_saved_toast.
  ///
  /// In kk, this message translates to:
  /// **'Профиль сақталды'**
  String get profile_saved_toast;

  /// No description provided for @profile_about_me.
  ///
  /// In kk, this message translates to:
  /// **'Өзім туралы'**
  String get profile_about_me;

  /// No description provided for @profile_preferred_sessions.
  ///
  /// In kk, this message translates to:
  /// **'Қалаулы сессиялар'**
  String get profile_preferred_sessions;

  /// No description provided for @profile_settings.
  ///
  /// In kk, this message translates to:
  /// **'Параметрлер'**
  String get profile_settings;

  /// No description provided for @profile_notifications.
  ///
  /// In kk, this message translates to:
  /// **'Хабарландырулар'**
  String get profile_notifications;

  /// No description provided for @notif_title.
  ///
  /// In kk, this message translates to:
  /// **'Хабарландырулар'**
  String get notif_title;

  /// No description provided for @notif_signals.
  ///
  /// In kk, this message translates to:
  /// **'TraderOS сигналдары'**
  String get notif_signals;

  /// No description provided for @notif_signals_desc.
  ///
  /// In kk, this message translates to:
  /// **'Жаңа сигнал жарияланғанда push'**
  String get notif_signals_desc;

  /// No description provided for @notif_intel.
  ///
  /// In kk, this message translates to:
  /// **'Market Intel'**
  String get notif_intel;

  /// No description provided for @notif_intel_desc.
  ///
  /// In kk, this message translates to:
  /// **'Gold-қа әсер ететін breaking news'**
  String get notif_intel_desc;

  /// No description provided for @notif_calendar.
  ///
  /// In kk, this message translates to:
  /// **'Экономикалық календарь'**
  String get notif_calendar;

  /// No description provided for @notif_calendar_desc.
  ///
  /// In kk, this message translates to:
  /// **'HIGH-оқиғаға 15 мин қалғанда'**
  String get notif_calendar_desc;

  /// No description provided for @notif_ideas.
  ///
  /// In kk, this message translates to:
  /// **'Trade Ideas'**
  String get notif_ideas;

  /// No description provided for @notif_ideas_desc.
  ///
  /// In kk, this message translates to:
  /// **'Трейдерлерден жаңа идеялар'**
  String get notif_ideas_desc;

  /// No description provided for @notif_review.
  ///
  /// In kk, this message translates to:
  /// **'Market Review'**
  String get notif_review;

  /// No description provided for @notif_review_desc.
  ///
  /// In kk, this message translates to:
  /// **'Күнделікті нарық талдауы'**
  String get notif_review_desc;

  /// No description provided for @notif_academy.
  ///
  /// In kk, this message translates to:
  /// **'Edge Academy'**
  String get notif_academy;

  /// No description provided for @notif_academy_desc.
  ///
  /// In kk, this message translates to:
  /// **'Сабаққа еске түсіру'**
  String get notif_academy_desc;

  /// No description provided for @notif_broker.
  ///
  /// In kk, this message translates to:
  /// **'Брокер синхронизациясы'**
  String get notif_broker;

  /// No description provided for @notif_broker_desc.
  ///
  /// In kk, this message translates to:
  /// **'Жаңа сделкалар импортталды'**
  String get notif_broker_desc;

  /// No description provided for @notif_streak.
  ///
  /// In kk, this message translates to:
  /// **'Стрик'**
  String get notif_streak;

  /// No description provided for @notif_streak_desc.
  ///
  /// In kk, this message translates to:
  /// **'Сериясын жоғалтпа'**
  String get notif_streak_desc;

  /// No description provided for @notif_dnd.
  ///
  /// In kk, this message translates to:
  /// **'Маза алмаңыз (00:00–07:00)'**
  String get notif_dnd;

  /// No description provided for @notif_dnd_desc.
  ///
  /// In kk, this message translates to:
  /// **'Тек шұғыл хабарландырулар'**
  String get notif_dnd_desc;
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
      <String>['en', 'kk', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'kk':
      return AppLocalizationsKk();
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
