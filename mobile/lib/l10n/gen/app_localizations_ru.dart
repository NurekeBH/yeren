// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'TraderOS';

  @override
  String get common_continue => 'Продолжить';

  @override
  String get common_back => 'Назад';

  @override
  String get common_cancel => 'Отмена';

  @override
  String get common_save => 'Сохранить';

  @override
  String get common_done => 'Готово';

  @override
  String get common_loading => 'Загрузка…';

  @override
  String get common_error => 'Ошибка';

  @override
  String get common_retry => 'Повторить';

  @override
  String get common_skip => 'Пропустить';

  @override
  String get common_next => 'Далее';

  @override
  String get common_finish => 'Завершить';

  @override
  String get common_all => 'Все';

  @override
  String get lang_kk => 'Қазақша';

  @override
  String get lang_ru => 'Русский';

  @override
  String get lang_en => 'English';

  @override
  String get auth_login_required => 'Для этого действия нужен аккаунт';

  @override
  String get auth_welcome_title => 'Добро пожаловать в TraderOS';

  @override
  String get auth_welcome_subtitle =>
      'Профессиональная платформа для трейдеров XAU/USD';

  @override
  String get auth_phone_title => 'Введите номер телефона';

  @override
  String get auth_phone_hint => '+7 700 000 00 00';

  @override
  String get auth_phone_error => 'Введите корректный номер';

  @override
  String get auth_password_title => 'Создайте пароль';

  @override
  String get auth_password_subtitle => 'Минимум 8 символов';

  @override
  String get auth_password_hint => 'Пароль';

  @override
  String get auth_password_confirm_hint => 'Повторите пароль';

  @override
  String get auth_password_mismatch => 'Пароли не совпадают';

  @override
  String get auth_password_too_short =>
      'Пароль должен быть не менее 8 символов';

  @override
  String get auth_register_button => 'Зарегистрироваться';

  @override
  String get auth_login_button => 'Войти';

  @override
  String get auth_to_login => 'Уже есть аккаунт? Войти';

  @override
  String get auth_to_register => 'Нет аккаунта? Зарегистрироваться';

  @override
  String get onboarding_title => 'Несколько вопросов';

  @override
  String get onboarding_name_label => 'Имя';

  @override
  String get onboarding_name_hint => 'Как к вам обращаться?';

  @override
  String get onboarding_city_label => 'Город';

  @override
  String get onboarding_city_hint => 'Алматы';

  @override
  String get onboarding_style_label => 'Стиль торговли';

  @override
  String get onboarding_bio_label => 'О себе (необязательно)';

  @override
  String get onboarding_sessions_label => 'Предпочитаемые сессии';

  @override
  String get onboarding_finish => 'Начать';

  @override
  String get splash_tagline => 'Платформа для трейдинга золотом';

  @override
  String get intro_skip => 'Пропустить';

  @override
  String get intro_next => 'Далее';

  @override
  String get intro_start => 'Начать';

  @override
  String get intro_s1_title => 'Золото — в реальном времени';

  @override
  String get intro_s1_text =>
      'Живая цена XAU/USD, DXY и экономический календарь — всё на одном экране.';

  @override
  String get intro_s2_title => 'Идеи от трейдеров';

  @override
  String get intro_s2_text =>
      'Сигналы проверенных трейдеров: вход, TP, SL, Win Rate и рейтинг.';

  @override
  String get intro_s3_title => 'Обучение и журнал';

  @override
  String get intro_s3_text =>
      'Edge Academy, ценовые уведомления и торговый журнал — для вашего роста.';

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
  String get nav_home => 'Главная';

  @override
  String get nav_intel => 'Intel';

  @override
  String get nav_signals => 'Ideas';

  @override
  String get idea_disclaimer =>
      'Это только рекомендация и личное мнение, а не финансовый совет.';

  @override
  String get alerts_title => 'Ценовые уведомления';

  @override
  String get alerts_empty => 'Пока нет активных уведомлений';

  @override
  String get alerts_add => 'Добавить уведомление';

  @override
  String get alerts_notify => 'Уведомить';

  @override
  String get alerts_mode_pips => 'По пунктам';

  @override
  String get alerts_mode_price => 'По цене';

  @override
  String get alerts_pips_hint => 'За сколько пунктов уведомить';

  @override
  String get alerts_price_hint => 'Целевая цена';

  @override
  String get alerts_text_hint => 'Текст уведомления';

  @override
  String get alerts_create => 'Создать';

  @override
  String get alerts_created => 'Уведомление создано';

  @override
  String alerts_default_idea(String pair) {
    return 'Цена приблизилась к идее $pair';
  }

  @override
  String alerts_default_manual(String pair) {
    return 'Цена $pair достигла цели';
  }

  @override
  String alerts_cond_pips(String pips, String price) {
    return 'за $pips п. до $price';
  }

  @override
  String alerts_cond_price(String price) {
    return 'при $price';
  }

  @override
  String get lib_podcast_translate =>
      'Видео можно смотреть на русском или английском — включите авто-перевод субтитров/озвучки в YouTube.';

  @override
  String get lib_save => 'Сохранить';

  @override
  String get lib_your_rating => 'Ваша оценка';

  @override
  String get lib_your_review => 'Ваш отзыв';

  @override
  String get lib_review_hint => 'Поделитесь мнением, если читали/смотрели';

  @override
  String get lib_save_review => 'Сохранить отзыв';

  @override
  String get lib_review_saved => 'Отзыв сохранён';

  @override
  String get profile_saved => 'Сохранённые';

  @override
  String get saved_empty => 'Пока ничего не сохранено';

  @override
  String get events_title => 'События';

  @override
  String get events_empty => 'Пока нет событий';

  @override
  String get event_free => 'Бесплатно';

  @override
  String get event_apply => 'Оставить заявку';

  @override
  String get event_video => 'Видео-описание';

  @override
  String get event_about => 'О событии';

  @override
  String get event_type_masterclass => 'Мастер-класс';

  @override
  String get event_type_live => 'Лайв-трейд';

  @override
  String get event_type_webinar => 'Вебинар';

  @override
  String get apply_title => 'Заявка на участие';

  @override
  String get apply_autofill_note =>
      'Данные заполнены из профиля — можно изменить';

  @override
  String get apply_name => 'Имя';

  @override
  String get apply_phone => 'Телефон';

  @override
  String get apply_comment => 'Комментарий (необязательно)';

  @override
  String get apply_submit => 'Отправить заявку';

  @override
  String get apply_sent => 'Заявка отправлена';

  @override
  String get event_publish => 'Опубликовать событие';

  @override
  String get event_publish_title => 'Новое событие';

  @override
  String get event_published => 'Событие опубликовано!';

  @override
  String get event_need_title => 'Введите название';

  @override
  String get event_field_title => 'Название';

  @override
  String get event_field_date => 'Дата и время';

  @override
  String get event_field_online => 'Онлайн';

  @override
  String get event_field_city => 'Город / место';

  @override
  String get event_field_price => 'Цена (₸)';

  @override
  String get event_field_price_help => '0 = бесплатно';

  @override
  String get event_field_desc => 'Описание';

  @override
  String get home_events => 'События';

  @override
  String get home_qa_alerts => 'Уведомления';

  @override
  String get home_qa_calc => 'Калькулятор';

  @override
  String get home_qa_events => 'События';

  @override
  String get home_events_sub => 'Мастер-классы, лайв-трейды, вебинары';

  @override
  String get agreement_title => 'Пользовательское соглашение';

  @override
  String get agreement_accept => 'Принимаю';

  @override
  String get agreement_checkbox => 'Я прочитал(а) и принимаю:';

  @override
  String get providers_tab => 'Провайдеры';

  @override
  String get prov_subscribe => 'Подписаться';

  @override
  String get prov_unsubscribe => 'Вы подписаны';

  @override
  String get prov_subscribed_toast => 'Вы подписались';

  @override
  String prov_per_month(String price) {
    return '$price ₸/мес';
  }

  @override
  String get prov_winrate => 'Win Rate';

  @override
  String get prov_rr => 'Ср. RR';

  @override
  String get prov_trades => 'Сделок';

  @override
  String get prov_verified => 'Проверенный провайдер';

  @override
  String get prov_ideas => 'Идеи провайдера';

  @override
  String get prov_active_ideas => 'Активные идеи';

  @override
  String get prov_past_signals => 'История сигналов';

  @override
  String get prov_no_past_signals => 'Пока нет закрытых сигналов';

  @override
  String get prov_follow => 'Отслеживать';

  @override
  String get prov_following => 'Вы отслеживаете';

  @override
  String get prov_follow_toast => 'Вы отслеживаете трейдера (бесплатно)';

  @override
  String get posts_published => 'Опубликованные идеи';

  @override
  String get posts_empty => 'Пока нет публикаций';

  @override
  String get posts_comments_title => 'Комментарии';

  @override
  String get posts_comment_hint => 'Написать комментарий…';

  @override
  String get posts_send => 'Отправить';

  @override
  String get posts_you => 'Вы';

  @override
  String posts_comments_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count комментариев',
      few: '$count комментария',
      one: '$count комментарий',
      zero: 'Нет комментариев',
    );
    return '$_temp0';
  }

  @override
  String get home_alert_sub => 'Уведомить при достижении уровня цены';

  @override
  String get nav_journal => 'Журнал';

  @override
  String get nav_profile => 'Профиль';

  @override
  String get home_greeting => 'Добро пожаловать';

  @override
  String get home_session_london => 'Лондонская сессия';

  @override
  String get home_session_ny => 'Нью-Йоркская сессия';

  @override
  String get home_session_asia => 'Азиатская сессия';

  @override
  String get home_session_overlap => 'Перекрытие NY/Лондон';

  @override
  String get home_kpi_win_rate => 'Win Rate';

  @override
  String get home_kpi_net_pnl => 'Net P&L';

  @override
  String get home_kpi_active_signals => 'Активные сигналы';

  @override
  String get home_kpi_streak => 'Стрик';

  @override
  String home_streak_days(int days) {
    return '$days дней подряд';
  }

  @override
  String get home_equity_title => 'Эквити кривая';

  @override
  String get home_ai_insight_title => 'AI-инсайт дня';

  @override
  String get home_recent_trades => 'Последние сделки';

  @override
  String get home_next_event => 'Ближайшее HIGH-событие';

  @override
  String get home_dxy_bullish => 'Bullish для Gold (DXY вниз)';

  @override
  String get home_dxy_bearish => 'Bearish давление на Gold (DXY вверх)';

  @override
  String get home_dxy_neutral => 'DXY нейтрален';

  @override
  String home_dxy_logic(String pct) {
    return 'H1 DXY $pct% → обратная корреляция к Gold (истор. ср. +0.3–0.8%)';
  }

  @override
  String get home_active_signal_preview => 'Активный сигнал';

  @override
  String get home_lesson_preview => 'Урок дня';

  @override
  String get home_calendar_button => 'Полный календарь';

  @override
  String get home_intel_module => 'Market Intel';

  @override
  String get home_intel_expand => 'Подробнее';

  @override
  String get home_intel_open_full => 'Открыть всё';

  @override
  String get intel_tab_news => 'Новости';

  @override
  String get intel_tab_academy => 'Academy';

  @override
  String get signals_tab_active => 'Активные';

  @override
  String get signals_tab_closed => 'Закрытые';

  @override
  String get signals_empty => 'Сигналов нет';

  @override
  String get signals_pair => 'Пара';

  @override
  String get signals_direction_buy => 'BUY';

  @override
  String get signals_direction_sell => 'SELL';

  @override
  String get signals_entry_zone => 'Зона входа';

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
  String get signals_confidence => 'Уверенность';

  @override
  String get signals_risk => 'Риск';

  @override
  String get signals_risk_low => 'Низкий риск';

  @override
  String get signals_risk_medium => 'Средний риск';

  @override
  String get signals_risk_high => 'Высокий риск';

  @override
  String get signals_risk_low_short => 'Низкий';

  @override
  String get signals_risk_medium_short => 'Средний';

  @override
  String get signals_risk_high_short => 'Высокий';

  @override
  String get signals_analysis => 'Анализ';

  @override
  String get signals_status => 'Статус';

  @override
  String get signals_status_active => 'АКТИВНЫЙ';

  @override
  String get signals_status_tp1 => 'ЗАКРЫТ TP1';

  @override
  String get signals_status_tp2 => 'ЗАКРЫТ TP2';

  @override
  String get signals_status_tp3 => 'ЗАКРЫТ TP3';

  @override
  String get signals_status_sl => 'STOP-LOSS';

  @override
  String signals_result_pips(int pips) {
    return '$pips пипс';
  }

  @override
  String get signals_wr_short => 'WR';

  @override
  String get signals_free_badge => 'Бесплатно';

  @override
  String get signals_potential => 'Потенциал';

  @override
  String get signals_paid_idea => 'Платная идея';

  @override
  String get signals_screenshot_locked => 'Скриншот после оплаты';

  @override
  String get signals_unlocked_badge => 'Открыта';

  @override
  String get signals_locked_title => 'Идея закрыта';

  @override
  String get signals_locked_desc =>
      'Разблокируйте идею, чтобы увидеть скриншот, зону входа, TP, SL и полный анализ.';

  @override
  String get signals_unlock_title => 'Разблокировать идею';

  @override
  String get signals_unlock_desc =>
      'Скриншот графика, полные уровни входа/TP/SL и анализ трейдера.';

  @override
  String get signals_price_label => 'Цена';

  @override
  String signals_tp_pips(int pips) {
    return 'TP $pips пипс';
  }

  @override
  String signals_price_tg(int price) {
    return '$price ₸';
  }

  @override
  String signals_unlock_for(int price) {
    return 'Открыть за $price ₸';
  }

  @override
  String signals_pay_kaspi(int price) {
    return 'Оплатить $price ₸ через Kaspi';
  }

  @override
  String get signals_paying => 'Оплата…';

  @override
  String get signals_pay_secure => 'Безопасная оплата · Kaspi Pay';

  @override
  String get signals_unlock_success => 'Идея разблокирована!';

  @override
  String get signals_publish => 'Опубликовать идею';

  @override
  String get signals_publish_title => 'Новая торговая идея';

  @override
  String get signals_published => 'Идея опубликована!';

  @override
  String get signals_publish_add_photo => 'Добавить фото графика';

  @override
  String get signals_publish_text => 'Текст идеи';

  @override
  String get signals_publish_text_hint =>
      'Напр.: BUY 2400, TP 2410/2420, SL 2390 — кратко обоснование';

  @override
  String get signals_publish_need_text => 'Напишите текст идеи';

  @override
  String get signals_entry_from => 'Вход (от)';

  @override
  String get signals_entry_to => 'Вход (до)';

  @override
  String get signals_free_idea => 'Бесплатная идея';

  @override
  String get signals_free_idea_desc =>
      'Если включено — без paywall, доступна всем';

  @override
  String get signals_set_result => 'Указать результат';

  @override
  String get signals_set_result_desc =>
      'Отметьте, на каком уровне закрылась идея';

  @override
  String get signals_result_set => 'Результат сохранён, идея закрыта';

  @override
  String get signals_vote_title => 'Голосование за результат';

  @override
  String get signals_vote_desc => 'Ваш прогноз: какого уровня достигнет?';

  @override
  String get signals_verify_title => 'Проверка результата';

  @override
  String get signals_verify_desc =>
      'Так ли это на самом деле? Проголосуйте, что произошло.';

  @override
  String signals_trader_marked(String result) {
    return 'Трейдер отметил: $result';
  }

  @override
  String get signals_trader_claim => 'заявка трейдера';

  @override
  String get signals_updates_title => 'Обновления трейдера';

  @override
  String get signals_updates_empty => 'Пока нет обновлений.';

  @override
  String get signals_update_hint => 'Добавить обновление (напр. «жду TP3»)…';

  @override
  String signals_verify_confirmed(int pct) {
    return 'Сообщество подтверждает ($pct%)';
  }

  @override
  String signals_verify_disputed(String result) {
    return 'Оспаривается — большинство за $result';
  }

  @override
  String get prov_tab_active => 'Активные';

  @override
  String get prov_tab_past => 'Прошлые';

  @override
  String get prov_tab_posts => 'Посты';

  @override
  String get profile_trader_mode => 'Режим трейдера';

  @override
  String get profile_trader_mode_desc => 'Публикация и управление идеями';

  @override
  String get profile_become_trader => 'Стать верифицированным трейдером';

  @override
  String get profile_verified_trader => 'Верифицированный трейдер ✓';

  @override
  String get profile_verified_trader_desc =>
      'Публикуйте идеи на странице Ideas';

  @override
  String get profile_support => 'Поддержка / Администрация';

  @override
  String get support_title => 'Служба поддержки';

  @override
  String get support_desc =>
      'Напишите нам по вопросам, верификации или сотрудничеству — сообщение придёт команде.';

  @override
  String get support_message_hint => 'Напишите сообщение…';

  @override
  String get support_send => 'Отправить';

  @override
  String get support_sent => 'Сообщение отправлено! Мы скоро ответим.';

  @override
  String get trader_apply_title => 'Заявка на верификацию трейдера';

  @override
  String get trader_apply_desc =>
      'Отправьте информацию о себе, чтобы команда могла проверить вас.';

  @override
  String get trader_apply_years => 'Опыт в трейдинге (лет)';

  @override
  String get trader_apply_about => 'О себе / ваша стратегия';

  @override
  String get trader_apply_about_hint => 'Стиль, рынки, результаты…';

  @override
  String get trader_apply_proof => 'Ссылка-доказательство (необязательно)';

  @override
  String get trader_apply_proof_hint => 'MyFxBook, отчёт, Telegram/Instagram…';

  @override
  String get trader_apply_tip =>
      'Лучший способ заслужить доверие — сначала опубликовать 3 БЕСПЛАТНЫЕ идеи. Так команда и пользователи увидят ваш edge.';

  @override
  String get trader_apply_send => 'Отправить заявку';

  @override
  String get trader_apply_sent =>
      'Заявка отправлена! (демо: режим трейдера включён)';

  @override
  String get signals_provider_stats => 'Статистика провайдера';

  @override
  String get signals_provider_win_rate => 'Win Rate';

  @override
  String get signals_provider_profit_factor => 'Profit Factor';

  @override
  String get signals_provider_avg_rr => 'Средний RR';

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
  String get intel_sl_recommendation => 'Рек. SL';

  @override
  String get intel_sentiment => 'Sentiment';

  @override
  String get intel_bears => 'Медведи';

  @override
  String get intel_bulls => 'Быки';

  @override
  String get calendar_title => 'Экономический календарь';

  @override
  String get calendar_filter_all => 'Все';

  @override
  String get calendar_filter_low => 'LOW';

  @override
  String get calendar_filter_medium => 'MEDIUM';

  @override
  String get calendar_filter_high => 'HIGH';

  @override
  String get calendar_forecast => 'Прогноз';

  @override
  String get calendar_previous => 'Предыдущее';

  @override
  String get calendar_actual => 'Фактическое';

  @override
  String get calendar_empty => 'Событий нет';

  @override
  String calendar_in_h(int h) {
    return 'через $h ч';
  }

  @override
  String calendar_in_m(int m) {
    return 'через $m мин';
  }

  @override
  String get calendar_soon => 'скоро';

  @override
  String get calendar_today => 'Сегодня';

  @override
  String get calendar_tomorrow => 'Завтра';

  @override
  String get calendar_previous_short => 'ПРЕД';

  @override
  String get calendar_forecast_short => 'ПРОГНОЗ';

  @override
  String get calendar_actual_short => 'ФАКТ';

  @override
  String get calendar_released => 'вышло';

  @override
  String get journal_empty => 'Сделок нет';

  @override
  String get journal_filter_all_brokers => 'Все брокеры';

  @override
  String get journal_emotion_check => 'Эмоция чекин';

  @override
  String get journal_setup_tag => 'Setup';

  @override
  String get journal_session_tag => 'Сессия';

  @override
  String get journal_rr_planned => 'Плановый RR';

  @override
  String get journal_rr_actual => 'Фактический RR';

  @override
  String get journal_add_trade => 'Новая сделка';

  @override
  String get journal_instrument => 'Инструмент';

  @override
  String get journal_direction => 'Направление';

  @override
  String get journal_lot => 'Лот';

  @override
  String get journal_sl_opt => 'SL (необяз.)';

  @override
  String get journal_fees_opt => 'Комиссия (\$)';

  @override
  String get journal_grade => 'Оценка сделки';

  @override
  String get journal_open_price => 'Цена входа';

  @override
  String get journal_close_price => 'Цена закрытия';

  @override
  String get journal_pnl => 'P&L (\$)';

  @override
  String get journal_notes => 'Заметки (необязательно)';

  @override
  String get journal_saved => 'Сделка сохранена';

  @override
  String get journal_delete => 'Удалить';

  @override
  String get journal_logout => 'Выйти';

  @override
  String get journal_link_broker => 'Привязать брокера';

  @override
  String get journal_accounts_title => 'Брокерские аккаунты';

  @override
  String get journal_no_accounts => 'Брокеры ещё не привязаны';

  @override
  String get journal_add_first_broker => 'Привязать первого';

  @override
  String get broker_step_choose_broker => 'Выберите брокера';

  @override
  String get broker_step_choose_platform => 'Выберите платформу';

  @override
  String get broker_step_credentials => 'Введите данные доступа';

  @override
  String get broker_account_number => 'Номер счёта';

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
      'Пароль только для чтения — торговля невозможна';

  @override
  String get broker_investor_password_help =>
      'Investor Password не даёт права на торговлю в терминале, только для импорта истории. На сервере шифруется AES-256.';

  @override
  String get broker_link_button => 'Привязать';

  @override
  String get broker_link_ctrader => 'Войти через OAuth cTrader';

  @override
  String get broker_link_ctrader_help =>
      'Безопасная авторизация через ваш cTrader-аккаунт — пароль не нужен.';

  @override
  String get broker_ea_download_help =>
      'Для MT4/MT5 установите наш Expert Advisor (.ex4/.ex5) в терминал. EA отправит историю сделок на сервер.';

  @override
  String get broker_ea_download => 'Скачать EA-файл';

  @override
  String get broker_synced => 'Синхр.';

  @override
  String get broker_balance => 'Баланс';

  @override
  String get broker_remove => 'Удалить';

  @override
  String get broker_sync_now => 'Синхр. сейчас';

  @override
  String broker_remove_confirm(String name) {
    return 'Удалить аккаунт $name?';
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
  String get broker_other => 'Другой';

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
  String get subscription_inactive => 'Подписка неактивна';

  @override
  String get subscription_active => 'Подписка активна';

  @override
  String get subscription_pending => 'На проверке у менеджера';

  @override
  String subscription_expires_in(int days) {
    return 'Осталось: $days дн.';
  }

  @override
  String get subscription_get_access => 'Получить доступ — 30 000 ₸';

  @override
  String get subscription_kaspi_button => 'Оплатить через Kaspi';

  @override
  String get subscription_upload_receipt => 'Загрузить чек';

  @override
  String get subscription_receipt_uploaded => 'Чек отправлен';

  @override
  String get subscription_change_receipt => 'Изменить чек';

  @override
  String get subscription_confirm_submit => 'Отправить менеджеру';

  @override
  String get subscription_step_1 => 'Оплатите 30 000 ₸ по ссылке Kaspi';

  @override
  String get subscription_step_2 => 'Загрузите скриншот чека';

  @override
  String get subscription_step_3 => 'Менеджер подтвердит в течение 24 ч';

  @override
  String get subscription_mock_approve => '[Demo] Менеджер подтвердил';

  @override
  String subscription_roi(String roi) {
    return 'ROI: $roi';
  }

  @override
  String get academy_title => 'Edge Academy';

  @override
  String get academy_take_test => 'Определите свои сильные и слабые стороны';

  @override
  String get academy_take_test_subtitle =>
      '20 вопросов — найдём ваши сильные стороны и зоны роста';

  @override
  String get academy_library => 'Библиотека';

  @override
  String get academy_library_subtitle =>
      'Что читать / смотреть / слушать — по категориям';

  @override
  String get academy_category_books => 'Книги';

  @override
  String get academy_category_films => 'Фильмы';

  @override
  String get academy_category_podcasts => 'Подкасты';

  @override
  String get academy_filter_by_problem => 'По проблеме';

  @override
  String get academy_filter_all => 'Все';

  @override
  String get academy_open_source => 'Открыть';

  @override
  String get tools_title => 'Инструменты';

  @override
  String get tools_position_calc => 'Калькулятор позиции';

  @override
  String get tools_position_calc_subtitle => 'Расчёт лота — risk % + SL';

  @override
  String get calc_mode_by_pips => 'По SL в пипсах';

  @override
  String get calc_mode_by_price => 'По цене входа + SL';

  @override
  String get calc_balance => 'Баланс (\$)';

  @override
  String get calc_risk_pct => 'Риск %';

  @override
  String get calc_sl_pips => 'Расстояние SL (пипсы)';

  @override
  String get calc_entry => 'Цена входа';

  @override
  String get calc_sl_price => 'Цена SL';

  @override
  String get calc_tp_price => 'Цена TP (опционально)';

  @override
  String get calc_pip_value => 'Стоимость пипа (\$)';

  @override
  String get calc_result_lot => 'Рекомендуемый лот';

  @override
  String get calc_result_risk => 'Сумма риска';

  @override
  String get calc_result_rr => 'Risk/Reward';

  @override
  String get calc_calculate => 'Рассчитать';

  @override
  String get calc_help_pip_xau => 'XAU/USD: 1 lot ≈ \$10/pip';

  @override
  String get academy_continue_test => 'Продолжить тест';

  @override
  String get academy_my_profile => 'Мой профиль';

  @override
  String get academy_lessons_for_you => 'Уроки для вас';

  @override
  String get academy_all_lessons => 'Все уроки';

  @override
  String academy_xp(int xp) {
    return '$xp XP';
  }

  @override
  String academy_streak_days(int days) {
    return '$days дн.';
  }

  @override
  String get academy_weekly_progress => 'Прогресс недели';

  @override
  String gallup_q_progress(int current, int total) {
    return 'Вопрос $current / $total';
  }

  @override
  String get gallup_result_title => 'Ваш профиль';

  @override
  String get gallup_profile_revenge => 'Месть рынку';

  @override
  String get gallup_profile_revenge_desc =>
      'После убытка входите на эмоциях. Попытка отыграться — главный риск.';

  @override
  String get gallup_profile_risk => 'Неконтролируемый риск';

  @override
  String get gallup_profile_risk_desc =>
      'Лот выбирается по ощущениям, нет системного риск-менеджмента.';

  @override
  String get gallup_profile_hope => 'Торговля надеждой';

  @override
  String get gallup_profile_hope_desc =>
      'Интуиция выше плана. Расширение SL — привычка.';

  @override
  String get gallup_profile_disciplined => 'Дисциплинированный трейдер';

  @override
  String get gallup_profile_disciplined_desc =>
      'Сильная база. Следующий шаг — поиск эджа.';

  @override
  String get gallup_view_lessons => 'Перейти к урокам';

  @override
  String get lesson_source => 'Источник';

  @override
  String get lesson_quote => 'Цитата';

  @override
  String get lesson_explanation => 'Объяснение';

  @override
  String get lesson_gold_application => 'Применение на XAU/USD';

  @override
  String get lesson_quick_check => 'Быстрый вопрос';

  @override
  String get lesson_quick_check_hint => 'Напишите ответ здесь…';

  @override
  String lesson_correct_answer(String answer) {
    return 'Правильный ответ: $answer';
  }

  @override
  String get lesson_complete => 'Завершить урок';

  @override
  String lesson_completed(int xp) {
    return 'Урок завершён (+$xp XP)';
  }

  @override
  String get library_read_summary => 'Читать краткое содержание';

  @override
  String get library_summary => 'Краткое содержание';

  @override
  String get library_about => 'О чём это';

  @override
  String get library_key_ideas => 'Основные идеи';

  @override
  String get library_conclusion => 'Заключение';

  @override
  String get library_watch => 'Смотреть видео';

  @override
  String get library_open_youtube => 'Открыть в YouTube';

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
  String get profile_avatar_pick => 'Сменить аватар';

  @override
  String get profile_edit => 'Редактировать профиль';

  @override
  String get profile_saved_toast => 'Профиль сохранён';

  @override
  String get profile_about_me => 'О себе';

  @override
  String get profile_preferred_sessions => 'Предпочитаемые сессии';

  @override
  String get profile_settings => 'Настройки';

  @override
  String get profile_notifications => 'Уведомления';

  @override
  String get notif_title => 'Уведомления';

  @override
  String get notif_signals => 'Сигналы TraderOS';

  @override
  String get notif_signals_desc => 'Push при публикации нового сигнала';

  @override
  String get notif_intel => 'Market Intel';

  @override
  String get notif_intel_desc => 'Breaking news влияющие на Gold';

  @override
  String get notif_calendar => 'Экономический календарь';

  @override
  String get notif_calendar_desc => 'За 15 мин до HIGH-события';

  @override
  String get notif_ideas => 'Trade Ideas';

  @override
  String get notif_ideas_desc => 'Новые идеи от трейдеров';

  @override
  String get notif_review => 'Market Review';

  @override
  String get notif_review_desc => 'Ежедневный разбор рынка';

  @override
  String get notif_academy => 'Edge Academy';

  @override
  String get notif_academy_desc => 'Напоминание об уроке';

  @override
  String get notif_broker => 'Синхронизация брокера';

  @override
  String get notif_broker_desc => 'Новые сделки импортированы';

  @override
  String get notif_streak => 'Стрик';

  @override
  String get notif_streak_desc => 'Не потеряй серию';

  @override
  String get notif_dnd => 'Не беспокоить (00:00–07:00)';

  @override
  String get notif_dnd_desc => 'Только срочные уведомления';

  @override
  String get promo_field_label => 'Промокод (необязательно)';

  @override
  String get promo_field_hint => 'Промокод трейдера';

  @override
  String promo_field_help(int bonus) {
    return 'Зарегистрируйтесь по промокоду — $bonus бонусов';
  }

  @override
  String promo_applied(int bonus) {
    return 'Промокод применён! +$bonus бонусов';
  }

  @override
  String get promo_already_used => 'Промокод уже использован';

  @override
  String get promo_invalid => 'Неверный промокод';

  @override
  String get promo_own_code => 'Нельзя использовать свой промокод';

  @override
  String get promo_bonus_balance => 'Бонусный баланс';

  @override
  String get promo_bonus_balance_desc =>
      'Применяется автоматически при открытии идеи';

  @override
  String get promo_my_bonuses => 'Мои бонусы';

  @override
  String promo_bonus_amount(int count) {
    return '$count бонусов';
  }

  @override
  String get promo_my_code_title => 'Мой промокод';

  @override
  String promo_my_code_desc(int bonus) {
    return 'Новый пользователь получает $bonus бонусов при регистрации по вашему коду';
  }

  @override
  String promo_my_code_earn(int bonus) {
    return 'За каждую регистрацию вы получаете +$bonus бонусов';
  }

  @override
  String promo_how_it_works(int referrer, int invitee) {
    return 'Как заработать бонусы: делитесь промокодом — за каждую регистрацию +$referrer бонусов; зарегистрируйтесь по коду друга — +$invitee бонусов. Бонусами можно открывать торговые идеи.';
  }

  @override
  String get promo_copy => 'Копировать';

  @override
  String get promo_copied => 'Промокод скопирован';

  @override
  String promo_referrals(int count) {
    return '$count регистраций по вашему коду';
  }

  @override
  String get promo_enter_title => 'Ввести промокод';

  @override
  String promo_enter_desc(int bonus) {
    return 'Получите $bonus бонусов';
  }

  @override
  String get promo_apply => 'Применить';

  @override
  String get signals_to_pay => 'К оплате';

  @override
  String get signals_unlock_with_bonus => 'Открыть бонусом';

  @override
  String get promo_share => 'Поделиться промокодом';

  @override
  String promo_share_message(String code, int bonus) {
    return '🎁 Мой промокод ALTYN: $code. Получи $bonus бонусов при регистрации! ALTYN — платформа для трейдинга золотом (XAU/USD).';
  }
}
