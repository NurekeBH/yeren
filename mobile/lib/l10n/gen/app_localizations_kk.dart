// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kazakh (`kk`).
class AppLocalizationsKk extends AppLocalizations {
  AppLocalizationsKk([String locale = 'kk']) : super(locale);

  @override
  String get appName => 'TraderOS';

  @override
  String get common_continue => 'Жалғастыру';

  @override
  String get common_back => 'Артқа';

  @override
  String get common_cancel => 'Бас тарту';

  @override
  String get common_save => 'Сақтау';

  @override
  String get common_done => 'Дайын';

  @override
  String get common_loading => 'Жүктелуде…';

  @override
  String get common_error => 'Қате';

  @override
  String get common_retry => 'Қайталау';

  @override
  String get common_skip => 'Өткізу';

  @override
  String get common_next => 'Әрі қарай';

  @override
  String get common_finish => 'Аяқтау';

  @override
  String get common_all => 'Барлығы';

  @override
  String get lang_kk => 'Қазақша';

  @override
  String get lang_ru => 'Русский';

  @override
  String get lang_en => 'English';

  @override
  String get auth_login_required => 'Бұл әрекет үшін аккаунт қажет';

  @override
  String get auth_welcome_title => 'TraderOS-қа қош келдіңіз';

  @override
  String get auth_welcome_subtitle =>
      'XAU/USD трейдерлеріне арналған кәсіби платформа';

  @override
  String get auth_phone_title => 'Телефон нөмірін енгізіңіз';

  @override
  String get auth_phone_hint => '+7 700 000 00 00';

  @override
  String get auth_phone_error => 'Дұрыс нөмір енгізіңіз';

  @override
  String get auth_password_title => 'Құпиясөз жасаңыз';

  @override
  String get auth_password_subtitle => 'Кем дегенде 8 таңба';

  @override
  String get auth_password_hint => 'Құпиясөз';

  @override
  String get auth_password_confirm_hint => 'Құпиясөзді қайталаңыз';

  @override
  String get auth_password_mismatch => 'Құпиясөздер сәйкес келмейді';

  @override
  String get auth_password_too_short =>
      'Құпиясөз кем дегенде 8 таңбадан тұруы керек';

  @override
  String get auth_register_button => 'Тіркелу';

  @override
  String get auth_login_button => 'Кіру';

  @override
  String get auth_to_login => 'Аккаунтыңыз бар ма? Кіру';

  @override
  String get auth_to_register => 'Аккаунтыңыз жоқ па? Тіркелу';

  @override
  String get onboarding_title => 'Бірнеше сұрақ';

  @override
  String get onboarding_name_label => 'Атыңыз';

  @override
  String get onboarding_name_hint => 'Қалай атайық сізді?';

  @override
  String get onboarding_city_label => 'Қала';

  @override
  String get onboarding_city_hint => 'Алматы';

  @override
  String get onboarding_style_label => 'Сауда стилі';

  @override
  String get onboarding_bio_label => 'Өзіңіз туралы (қалауыңызша)';

  @override
  String get onboarding_sessions_label => 'Қалаулы сессиялар';

  @override
  String get onboarding_finish => 'Бастау';

  @override
  String get style_smc => 'SMC (Smart Money Concepts)';

  @override
  String get style_ict => 'ICT (Inner Circle Trader)';

  @override
  String get style_snr => 'Support & Resistance';

  @override
  String get style_trendline => 'Trendline / Channel';

  @override
  String get style_price_action => 'Price Action';

  @override
  String get style_breakout => 'Breakout / Momentum';

  @override
  String get style_news => 'News Trading';

  @override
  String get style_scalping => 'Scalping (M1–M5)';

  @override
  String get style_swing => 'Swing (H4–D1)';

  @override
  String get nav_home => 'Басты';

  @override
  String get nav_intel => 'Intel';

  @override
  String get nav_signals => 'Ideas';

  @override
  String get idea_disclaimer =>
      'Бұл тек ұсыныс әрі жеке пікір, қаржылық кеңес емес.';

  @override
  String get alerts_title => 'Баға ескертулері';

  @override
  String get alerts_empty => 'Әзірге белсенді ескерту жоқ';

  @override
  String get alerts_add => 'Ескерту қосу';

  @override
  String get alerts_notify => 'Хабарлау';

  @override
  String get alerts_mode_pips => 'Пипспен';

  @override
  String get alerts_mode_price => 'Бағамен';

  @override
  String get alerts_pips_hint => 'Неше пипс қалғанда хабарлау';

  @override
  String get alerts_price_hint => 'Мақсатты баға';

  @override
  String get alerts_text_hint => 'Хабарлама мәтіні';

  @override
  String get alerts_create => 'Жасау';

  @override
  String get alerts_created => 'Ескерту жасалды';

  @override
  String alerts_default_idea(String pair) {
    return '$pair идеясына баға жақындады';
  }

  @override
  String alerts_default_manual(String pair) {
    return '$pair бағасы мақсатқа жетті';
  }

  @override
  String alerts_cond_pips(String pips, String price) {
    return '$price-ке $pips пипс қалғанда';
  }

  @override
  String alerts_cond_price(String price) {
    return '$price болғанда';
  }

  @override
  String get lib_save => 'Сақтау';

  @override
  String get lib_your_rating => 'Сіздің бағаңыз';

  @override
  String get lib_your_review => 'Сіздің пікіріңіз';

  @override
  String get lib_review_hint => 'Оқыған/көрген болсаңыз, ойыңызбен бөлісіңіз';

  @override
  String get lib_save_review => 'Пікірді сақтау';

  @override
  String get lib_review_saved => 'Пікір сақталды';

  @override
  String get profile_saved => 'Сақталғандар';

  @override
  String get saved_empty => 'Әзірге ештеңе сақталмаған';

  @override
  String get events_title => 'Іс-шаралар';

  @override
  String get events_empty => 'Әзірге іс-шара жоқ';

  @override
  String get event_free => 'Тегін';

  @override
  String get event_apply => 'Өтінім қалдыру';

  @override
  String get event_video => 'Видео-түсіндірме';

  @override
  String get event_about => 'Іс-шара туралы';

  @override
  String get event_type_masterclass => 'Мастер-класс';

  @override
  String get event_type_live => 'Лайв-трейд';

  @override
  String get event_type_webinar => 'Вебинар';

  @override
  String get apply_title => 'Қатысуға өтінім';

  @override
  String get apply_autofill_note =>
      'Деректер профильден алынды — өзгертуге болады';

  @override
  String get apply_name => 'Аты-жөні';

  @override
  String get apply_phone => 'Телефон';

  @override
  String get apply_comment => 'Пікір (міндетті емес)';

  @override
  String get apply_submit => 'Өтінім жіберу';

  @override
  String get apply_sent => 'Өтінім жіберілді';

  @override
  String get home_events => 'Іс-шаралар';

  @override
  String get home_events_sub => 'Мастер-класс, лайв-трейд, вебинар';

  @override
  String get agreement_title => 'Пайдаланушы келісімі';

  @override
  String get agreement_accept => 'Қабылдаймын';

  @override
  String get agreement_checkbox => 'Мен оқыдым әрі қабылдаймын:';

  @override
  String get providers_tab => 'Провайдерлер';

  @override
  String get prov_subscribe => 'Жазылу';

  @override
  String get prov_unsubscribe => 'Жазылдыңыз';

  @override
  String get prov_subscribed_toast => 'Сіз жазылдыңыз';

  @override
  String prov_per_month(String price) {
    return '$price ₸/ай';
  }

  @override
  String get prov_winrate => 'Win Rate';

  @override
  String get prov_rr => 'Орт. RR';

  @override
  String get prov_trades => 'Сделкалар';

  @override
  String get prov_verified => 'Расталған провайдер';

  @override
  String get prov_ideas => 'Провайдер идеялары';

  @override
  String get nav_journal => 'Журнал';

  @override
  String get nav_profile => 'Профиль';

  @override
  String get home_greeting => 'Сәлеметсіз бе';

  @override
  String get home_session_london => 'Лондон сессиясы';

  @override
  String get home_session_ny => 'Нью-Йорк сессиясы';

  @override
  String get home_session_asia => 'Азия сессиясы';

  @override
  String get home_session_overlap => 'NY/Лондон қабаттасуы';

  @override
  String get home_kpi_win_rate => 'Win Rate';

  @override
  String get home_kpi_net_pnl => 'Net P&L';

  @override
  String get home_kpi_active_signals => 'Белсенді сигналдар';

  @override
  String get home_kpi_streak => 'Стрик';

  @override
  String home_streak_days(int days) {
    return '$days күн қатарынан';
  }

  @override
  String get home_equity_title => 'Эквити кривая';

  @override
  String get home_ai_insight_title => 'AI-инсайт күні';

  @override
  String get home_recent_trades => 'Соңғы сделкалар';

  @override
  String get home_next_event => 'Жақын HIGH-оқиға';

  @override
  String get home_dxy_bullish => 'Bullish Gold үшін (DXY төмен)';

  @override
  String get home_dxy_bearish => 'Bearish Gold-қа қысым (DXY жоғары)';

  @override
  String get home_dxy_neutral => 'DXY нейтрал';

  @override
  String home_dxy_logic(String pct) {
    return 'H1 DXY $pct% → Gold кері корреляция (тарихи orт. +0.3–0.8%)';
  }

  @override
  String get home_active_signal_preview => 'Белсенді сигнал';

  @override
  String get home_lesson_preview => 'Күн сабағы';

  @override
  String get home_calendar_button => 'Толық календарь';

  @override
  String get home_intel_module => 'Market Intel';

  @override
  String get home_intel_expand => 'Толығырақ';

  @override
  String get home_intel_open_full => 'Барлығын ашу';

  @override
  String get intel_tab_news => 'Жаңалықтар';

  @override
  String get intel_tab_academy => 'Academy';

  @override
  String get signals_tab_active => 'Белсенді';

  @override
  String get signals_tab_closed => 'Жабық';

  @override
  String get signals_empty => 'Сигнал жоқ';

  @override
  String get signals_pair => 'Валюта жұбы';

  @override
  String get signals_direction_buy => 'BUY';

  @override
  String get signals_direction_sell => 'SELL';

  @override
  String get signals_entry_zone => 'Кіру зонасы';

  @override
  String get signals_tp1 => 'TP1';

  @override
  String get signals_tp2 => 'TP2';

  @override
  String get signals_tp3 => 'TP3';

  @override
  String get signals_sl => 'Stop Loss';

  @override
  String get signals_rr => 'Risk/Reward';

  @override
  String get signals_confidence => 'Сенімділік';

  @override
  String get signals_analysis => 'Талдау';

  @override
  String get signals_status => 'Күй';

  @override
  String get signals_status_active => 'АКТИВТІ';

  @override
  String get signals_status_tp1 => 'ЖАБЫЛДЫ TP1';

  @override
  String get signals_status_tp2 => 'ЖАБЫЛДЫ TP2';

  @override
  String get signals_status_tp3 => 'ЖАБЫЛДЫ TP3';

  @override
  String get signals_status_sl => 'STOP-LOSS';

  @override
  String signals_result_pips(int pips) {
    return '$pips пипс';
  }

  @override
  String get signals_provider_stats => 'Провайдер статистикасы';

  @override
  String get signals_provider_win_rate => 'Win Rate';

  @override
  String get signals_provider_profit_factor => 'Profit Factor';

  @override
  String get signals_provider_avg_rr => 'Орташа RR';

  @override
  String get intel_impact_bullish => 'BULLISH';

  @override
  String get intel_impact_bearish => 'BEARISH';

  @override
  String get intel_impact_neutral => 'NEUTRAL';

  @override
  String get intel_support => 'Support';

  @override
  String get intel_resistance => 'Resistance';

  @override
  String get intel_sl_recommendation => 'SL ұсынылады';

  @override
  String get intel_sentiment => 'Sentiment';

  @override
  String get intel_bears => 'Аюлар';

  @override
  String get intel_bulls => 'Бұқалар';

  @override
  String get calendar_title => 'Экономикалық календарь';

  @override
  String get calendar_filter_all => 'Барлығы';

  @override
  String get calendar_filter_low => 'LOW';

  @override
  String get calendar_filter_medium => 'MEDIUM';

  @override
  String get calendar_filter_high => 'HIGH';

  @override
  String get calendar_forecast => 'Болжам';

  @override
  String get calendar_previous => 'Алдыңғы';

  @override
  String get calendar_actual => 'Нақты';

  @override
  String get calendar_empty => 'Оқиға жоқ';

  @override
  String get journal_empty => 'Сделка жоқ';

  @override
  String get journal_filter_all_brokers => 'Барлық брокерлер';

  @override
  String get journal_emotion_check => 'Эмоция чекин';

  @override
  String get journal_setup_tag => 'Setup';

  @override
  String get journal_session_tag => 'Сессия';

  @override
  String get journal_rr_planned => 'Жоспарлы RR';

  @override
  String get journal_rr_actual => 'Нақты RR';

  @override
  String get journal_add_trade => 'Жаңа сделка';

  @override
  String get journal_instrument => 'Инструмент';

  @override
  String get journal_direction => 'Бағыт';

  @override
  String get journal_lot => 'Лот';

  @override
  String get journal_open_price => 'Кіру бағасы';

  @override
  String get journal_close_price => 'Жабу бағасы';

  @override
  String get journal_pnl => 'P&L (\$)';

  @override
  String get journal_notes => 'Ескертулер (қалауыңызша)';

  @override
  String get journal_saved => 'Сделка сақталды';

  @override
  String get journal_delete => 'Жою';

  @override
  String get journal_logout => 'Шығу';

  @override
  String get journal_link_broker => 'Брокер қосу';

  @override
  String get journal_accounts_title => 'Брокер аккаунттары';

  @override
  String get journal_no_accounts => 'Әлі брокер қосылмаған';

  @override
  String get journal_add_first_broker => 'Бірінші брокерді қос';

  @override
  String get broker_step_choose_broker => 'Брокерді таңда';

  @override
  String get broker_step_choose_platform => 'Платформаны таңда';

  @override
  String get broker_step_credentials => 'Тіркеу деректерін енгіз';

  @override
  String get broker_account_number => 'Аккаунт нөмірі';

  @override
  String get broker_account_number_hint => '85204517';

  @override
  String get broker_server => 'Сервер';

  @override
  String get broker_server_hint => 'Exness-MT5Real8';

  @override
  String get broker_investor_password => 'Investor Password (READ-ONLY)';

  @override
  String get broker_investor_password_hint =>
      'Тек қарау құпиясөзі — сауда мүмкін емес';

  @override
  String get broker_investor_password_help =>
      'Investor Password — терминалда сауданы рұқсат бермейді, тек тарихты оқу үшін. Backend-те AES-256 шифрленеді.';

  @override
  String get broker_link_button => 'Қосу';

  @override
  String get broker_link_ctrader => 'cTrader-ке OAuth арқылы кіру';

  @override
  String get broker_link_ctrader_help =>
      'cTrader аккаунтыңыз арқылы қауіпсіз авторизация — пароль қажет емес.';

  @override
  String get broker_ea_download_help =>
      'MT4/MT5 үшін біздің Expert Advisor-ды (.ex4/.ex5) терминалға орнатыңыз. EA сделкалар тарихын сервер-ге жібереді.';

  @override
  String get broker_ea_download => 'EA файлды жүктеу';

  @override
  String get broker_synced => 'Соңғы синхр.';

  @override
  String get broker_balance => 'Баланс';

  @override
  String get broker_remove => 'Жою';

  @override
  String get broker_sync_now => 'Қазір синхр.';

  @override
  String broker_remove_confirm(String name) {
    return '$name аккаунтын жоямыз ба?';
  }

  @override
  String get broker_exness => 'Exness';

  @override
  String get broker_ic_markets => 'IC Markets';

  @override
  String get broker_xm => 'XM';

  @override
  String get broker_pepperstone => 'Pepperstone';

  @override
  String get broker_oanda => 'OANDA';

  @override
  String get broker_fxpro => 'FxPro';

  @override
  String get broker_other => 'Басқа';

  @override
  String get platform_mt4 => 'MetaTrader 4';

  @override
  String get platform_mt5 => 'MetaTrader 5';

  @override
  String get platform_ctrader => 'cTrader';

  @override
  String get platform_mt_subtitle => 'Investor Password + Сервер';

  @override
  String get platform_ctrader_subtitle => 'OAuth 2.0';

  @override
  String get setup_retest => 'Retest';

  @override
  String get setup_breakout => 'Breakout';

  @override
  String get setup_smc_ob => 'SMC OB';

  @override
  String get setup_reversal => 'Reversal';

  @override
  String get setup_news => 'News';

  @override
  String get setup_fvg => 'FVG';

  @override
  String get subscription_inactive => 'Жазылым белсенді емес';

  @override
  String get subscription_active => 'Жазылым белсенді';

  @override
  String get subscription_pending => 'Менеджер тексерістерде';

  @override
  String subscription_expires_in(int days) {
    return 'Қалды: $days күн';
  }

  @override
  String get subscription_get_access => 'Қол жеткізу — 30 000 ₸';

  @override
  String get subscription_kaspi_button => 'Kaspi арқылы төлеу';

  @override
  String get subscription_upload_receipt => 'Чек жүктеу';

  @override
  String get subscription_receipt_uploaded => 'Чек жіберілді';

  @override
  String get subscription_change_receipt => 'Чекті өзгерту';

  @override
  String get subscription_confirm_submit => 'Менеджерге жіберу';

  @override
  String get subscription_step_1 => 'Kaspi ссылка арқылы 30 000 ₸ төлеңіз';

  @override
  String get subscription_step_2 => 'Төлем чегінің скриншотын жүктеңіз';

  @override
  String get subscription_step_3 => 'Менеджер 24 сағат ішінде растайды';

  @override
  String get subscription_mock_approve => '[Demo] Менеджер растады';

  @override
  String subscription_roi(String roi) {
    return 'ROI: $roi';
  }

  @override
  String get academy_title => 'Edge Academy';

  @override
  String get academy_take_test => 'Трейдингтегі плюс/минустарыңды анықтау';

  @override
  String get academy_take_test_subtitle =>
      '20 сұрақ — күшті жақтарыңыз бен әлсіз тұстарыңызды табамыз';

  @override
  String get academy_library => 'Кітапхана';

  @override
  String get academy_library_subtitle =>
      'Не оқу/көру/тыңдау керек — категория бойынша';

  @override
  String get academy_category_books => 'Кітаптар';

  @override
  String get academy_category_films => 'Фильмдер';

  @override
  String get academy_category_podcasts => 'Подкасттар';

  @override
  String get academy_filter_by_problem => 'Мәселе бойынша';

  @override
  String get academy_filter_all => 'Барлығы';

  @override
  String get academy_open_source => 'Толық қарау';

  @override
  String get tools_title => 'Құралдар';

  @override
  String get tools_position_calc => 'Позиция калькуляторы';

  @override
  String get tools_position_calc_subtitle =>
      'Лот мөлшерін есептеу — risk % + SL негізінде';

  @override
  String get calc_mode_by_pips => 'SL pip арқылы';

  @override
  String get calc_mode_by_price => 'Кіру + SL бағасы арқылы';

  @override
  String get calc_balance => 'Депозит (\$)';

  @override
  String get calc_risk_pct => 'Тәуекел %';

  @override
  String get calc_sl_pips => 'SL қашықтығы (pip)';

  @override
  String get calc_entry => 'Кіру бағасы';

  @override
  String get calc_sl_price => 'SL бағасы';

  @override
  String get calc_tp_price => 'TP бағасы (қалауыңызша)';

  @override
  String get calc_pip_value => 'Pip құны (\$)';

  @override
  String get calc_result_lot => 'Ұсынылатын лот';

  @override
  String get calc_result_risk => 'Тәуекелге қойылған сома';

  @override
  String get calc_result_rr => 'Risk/Reward';

  @override
  String get calc_calculate => 'Есептеу';

  @override
  String get calc_help_pip_xau => 'XAU/USD: 1 lot ≈ \$10/pip';

  @override
  String get academy_continue_test => 'Тестті жалғастыру';

  @override
  String get academy_my_profile => 'Менің профилім';

  @override
  String get academy_lessons_for_you => 'Сізге арналған сабақтар';

  @override
  String get academy_all_lessons => 'Барлық сабақтар';

  @override
  String academy_xp(int xp) {
    return '$xp XP';
  }

  @override
  String academy_streak_days(int days) {
    return '$days күн';
  }

  @override
  String get academy_weekly_progress => 'Аптаның прогресі';

  @override
  String gallup_q_progress(int current, int total) {
    return 'Сұрақ $current / $total';
  }

  @override
  String get gallup_result_title => 'Сіздің профиліңіз';

  @override
  String get gallup_profile_revenge => 'Месть рынку';

  @override
  String get gallup_profile_revenge_desc =>
      'Шығыннан кейін эмоциямен кіресіз. Қаражатты қайтаруға тырысу — ең үлкен қауіп.';

  @override
  String get gallup_profile_risk => 'Бақыланбайтын тәуекел';

  @override
  String get gallup_profile_risk_desc =>
      'Лотты сезіммен таңдайсыз. Жүйелі risk-management жоқ.';

  @override
  String get gallup_profile_hope => 'Үмітпен сауда';

  @override
  String get gallup_profile_hope_desc =>
      'Интуиция жоспардан жоғары. SL кеңейту — таныс әдет.';

  @override
  String get gallup_profile_disciplined => 'Дисциплинаны трейдер';

  @override
  String get gallup_profile_disciplined_desc =>
      'Күшті база. Едж табу — келесі қадам.';

  @override
  String get gallup_view_lessons => 'Сабақтарды көру';

  @override
  String get lesson_source => 'Дереккөз';

  @override
  String get lesson_quote => 'Цитата';

  @override
  String get lesson_explanation => 'Түсіндірме';

  @override
  String get lesson_gold_application => 'XAU/USD-та қалай қолдану';

  @override
  String get lesson_quick_check => 'Тез сұрақ';

  @override
  String get lesson_quick_check_hint => 'Жауабыңызды осында жазыңыз…';

  @override
  String lesson_correct_answer(String answer) {
    return 'Дұрыс жауап: $answer';
  }

  @override
  String get lesson_complete => 'Сабақты аяқтау';

  @override
  String lesson_completed(int xp) {
    return 'Сабақ аяқталды (+$xp XP)';
  }

  @override
  String get library_read_summary => 'Қысқаша мазмұнын оқу';

  @override
  String get library_summary => 'Қысқаша мазмұн';

  @override
  String get library_watch => 'Видеоны көру';

  @override
  String get library_open_youtube => 'YouTube-та ашу';

  @override
  String get library_rating => 'Рейтинг';

  @override
  String get tag_psychology => 'Психология';

  @override
  String get tag_risk => 'Риск';

  @override
  String get tag_strategy => 'Стратегия';

  @override
  String get tag_discipline => 'Дисциплина';

  @override
  String get tag_mindset => 'Мышление';

  @override
  String get profile_avatar_pick => 'Аватарды өзгерту';

  @override
  String get profile_about_me => 'Өзім туралы';

  @override
  String get profile_preferred_sessions => 'Қалаулы сессиялар';

  @override
  String get profile_settings => 'Параметрлер';

  @override
  String get profile_notifications => 'Хабарландырулар';

  @override
  String get notif_title => 'Хабарландырулар';

  @override
  String get notif_signals => 'TraderOS сигналдары';

  @override
  String get notif_signals_desc => 'Жаңа сигнал жарияланғанда push';

  @override
  String get notif_intel => 'Market Intel';

  @override
  String get notif_intel_desc => 'Gold-қа әсер ететін breaking news';

  @override
  String get notif_calendar => 'Экономикалық календарь';

  @override
  String get notif_calendar_desc => 'HIGH-оқиғаға 15 мин қалғанда';

  @override
  String get notif_ideas => 'Trade Ideas';

  @override
  String get notif_ideas_desc => 'Трейдерлерден жаңа идеялар';

  @override
  String get notif_review => 'Market Review';

  @override
  String get notif_review_desc => 'Күнделікті нарық талдауы';

  @override
  String get notif_academy => 'Edge Academy';

  @override
  String get notif_academy_desc => 'Сабаққа еске түсіру';

  @override
  String get notif_broker => 'Брокер синхронизациясы';

  @override
  String get notif_broker_desc => 'Жаңа сделкалар импортталды';

  @override
  String get notif_streak => 'Стрик';

  @override
  String get notif_streak_desc => 'Сериясын жоғалтпа';

  @override
  String get notif_dnd => 'Маза алмаңыз (00:00–07:00)';

  @override
  String get notif_dnd_desc => 'Тек шұғыл хабарландырулар';
}
