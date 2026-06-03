// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'TraderOS';

  @override
  String get common_continue => 'Continue';

  @override
  String get common_back => 'Back';

  @override
  String get common_cancel => 'Cancel';

  @override
  String get common_save => 'Save';

  @override
  String get common_done => 'Done';

  @override
  String get common_loading => 'Loading…';

  @override
  String get common_error => 'Error';

  @override
  String get common_retry => 'Retry';

  @override
  String get common_skip => 'Skip';

  @override
  String get common_next => 'Next';

  @override
  String get common_finish => 'Finish';

  @override
  String get common_all => 'All';

  @override
  String get lang_kk => 'Қазақша';

  @override
  String get lang_ru => 'Русский';

  @override
  String get lang_en => 'English';

  @override
  String get auth_login_required => 'Account required for this action';

  @override
  String get auth_welcome_title => 'Welcome to TraderOS';

  @override
  String get auth_welcome_subtitle =>
      'Professional platform for XAU/USD traders';

  @override
  String get auth_phone_title => 'Enter your phone number';

  @override
  String get auth_phone_hint => '+7 700 000 00 00';

  @override
  String get auth_phone_error => 'Please enter a valid number';

  @override
  String get auth_password_title => 'Create a password';

  @override
  String get auth_password_subtitle => 'At least 8 characters';

  @override
  String get auth_password_hint => 'Password';

  @override
  String get auth_password_confirm_hint => 'Confirm password';

  @override
  String get auth_password_mismatch => 'Passwords do not match';

  @override
  String get auth_password_too_short =>
      'Password must be at least 8 characters';

  @override
  String get auth_register_button => 'Sign up';

  @override
  String get auth_login_button => 'Sign in';

  @override
  String get auth_to_login => 'Already have an account? Sign in';

  @override
  String get auth_to_register => 'No account? Sign up';

  @override
  String get onboarding_title => 'A few questions';

  @override
  String get onboarding_name_label => 'Name';

  @override
  String get onboarding_name_hint => 'What should we call you?';

  @override
  String get onboarding_city_label => 'City';

  @override
  String get onboarding_city_hint => 'Almaty';

  @override
  String get onboarding_style_label => 'Trading style';

  @override
  String get onboarding_bio_label => 'About you (optional)';

  @override
  String get onboarding_sessions_label => 'Preferred sessions';

  @override
  String get onboarding_finish => 'Get started';

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
  String get nav_home => 'Home';

  @override
  String get nav_intel => 'Intel';

  @override
  String get nav_signals => 'Ideas';

  @override
  String get idea_disclaimer =>
      'This is only a recommendation and a personal opinion, not financial advice.';

  @override
  String get alerts_title => 'Price alerts';

  @override
  String get alerts_empty => 'No active alerts yet';

  @override
  String get alerts_add => 'Add alert';

  @override
  String get alerts_notify => 'Notify me';

  @override
  String get alerts_mode_pips => 'By pips';

  @override
  String get alerts_mode_price => 'By price';

  @override
  String get alerts_pips_hint => 'Notify when this many pips away';

  @override
  String get alerts_price_hint => 'Target price';

  @override
  String get alerts_text_hint => 'Notification text';

  @override
  String get alerts_create => 'Create';

  @override
  String get alerts_created => 'Alert created';

  @override
  String alerts_default_idea(String pair) {
    return 'Price approached the $pair idea';
  }

  @override
  String alerts_default_manual(String pair) {
    return '$pair reached the target';
  }

  @override
  String alerts_cond_pips(String pips, String price) {
    return '$pips pips before $price';
  }

  @override
  String alerts_cond_price(String price) {
    return 'at $price';
  }

  @override
  String get lib_save => 'Save';

  @override
  String get lib_your_rating => 'Your rating';

  @override
  String get lib_your_review => 'Your review';

  @override
  String get lib_review_hint =>
      'Share your thoughts if you\'ve read/watched it';

  @override
  String get lib_save_review => 'Save review';

  @override
  String get lib_review_saved => 'Review saved';

  @override
  String get profile_saved => 'Saved';

  @override
  String get saved_empty => 'Nothing saved yet';

  @override
  String get events_title => 'Events';

  @override
  String get events_empty => 'No events yet';

  @override
  String get event_free => 'Free';

  @override
  String get event_apply => 'Apply';

  @override
  String get event_video => 'Video intro';

  @override
  String get event_about => 'About the event';

  @override
  String get event_type_masterclass => 'Masterclass';

  @override
  String get event_type_live => 'Live trade';

  @override
  String get event_type_webinar => 'Webinar';

  @override
  String get apply_title => 'Application';

  @override
  String get apply_autofill_note => 'Filled from your profile — you can edit';

  @override
  String get apply_name => 'Name';

  @override
  String get apply_phone => 'Phone';

  @override
  String get apply_comment => 'Comment (optional)';

  @override
  String get apply_submit => 'Submit application';

  @override
  String get apply_sent => 'Application sent';

  @override
  String get home_events => 'Events';

  @override
  String get home_events_sub => 'Masterclasses, live trades, webinars';

  @override
  String get agreement_title => 'User Agreement';

  @override
  String get agreement_accept => 'I accept';

  @override
  String get agreement_checkbox => 'I have read and accept the';

  @override
  String get providers_tab => 'Providers';

  @override
  String get prov_subscribe => 'Subscribe';

  @override
  String get prov_unsubscribe => 'Subscribed';

  @override
  String get prov_subscribed_toast => 'Subscribed';

  @override
  String prov_per_month(String price) {
    return '$price ₸/mo';
  }

  @override
  String get prov_winrate => 'Win Rate';

  @override
  String get prov_rr => 'Avg RR';

  @override
  String get prov_trades => 'Trades';

  @override
  String get prov_verified => 'Verified provider';

  @override
  String get prov_ideas => 'Provider\'s ideas';

  @override
  String get home_alert_sub => 'Get notified when price hits a level';

  @override
  String get nav_journal => 'Journal';

  @override
  String get nav_profile => 'Profile';

  @override
  String get home_greeting => 'Welcome';

  @override
  String get home_session_london => 'London session';

  @override
  String get home_session_ny => 'New York session';

  @override
  String get home_session_asia => 'Asia session';

  @override
  String get home_session_overlap => 'NY/London overlap';

  @override
  String get home_kpi_win_rate => 'Win Rate';

  @override
  String get home_kpi_net_pnl => 'Net P&L';

  @override
  String get home_kpi_active_signals => 'Active signals';

  @override
  String get home_kpi_streak => 'Streak';

  @override
  String home_streak_days(int days) {
    return '$days days in a row';
  }

  @override
  String get home_equity_title => 'Equity curve';

  @override
  String get home_ai_insight_title => 'AI insight of the day';

  @override
  String get home_recent_trades => 'Recent trades';

  @override
  String get home_next_event => 'Next HIGH event';

  @override
  String get home_dxy_bullish => 'Bullish signal for Gold (DXY down)';

  @override
  String get home_dxy_bearish => 'Bearish pressure on Gold (DXY up)';

  @override
  String get home_dxy_neutral => 'DXY neutral';

  @override
  String home_dxy_logic(String pct) {
    return 'H1 DXY $pct% → inverse correlation to Gold (hist. avg +0.3–0.8%)';
  }

  @override
  String get home_active_signal_preview => 'Active signal';

  @override
  String get home_lesson_preview => 'Lesson of the day';

  @override
  String get home_calendar_button => 'Full calendar';

  @override
  String get home_intel_module => 'Market Intel';

  @override
  String get home_intel_expand => 'Expand';

  @override
  String get home_intel_open_full => 'Open all';

  @override
  String get intel_tab_news => 'News';

  @override
  String get intel_tab_academy => 'Academy';

  @override
  String get signals_tab_active => 'Active';

  @override
  String get signals_tab_closed => 'Closed';

  @override
  String get signals_empty => 'No signals';

  @override
  String get signals_pair => 'Pair';

  @override
  String get signals_direction_buy => 'BUY';

  @override
  String get signals_direction_sell => 'SELL';

  @override
  String get signals_entry_zone => 'Entry zone';

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
  String get signals_confidence => 'Confidence';

  @override
  String get signals_analysis => 'Analysis';

  @override
  String get signals_status => 'Status';

  @override
  String get signals_status_active => 'ACTIVE';

  @override
  String get signals_status_tp1 => 'CLOSED TP1';

  @override
  String get signals_status_tp2 => 'CLOSED TP2';

  @override
  String get signals_status_tp3 => 'CLOSED TP3';

  @override
  String get signals_status_sl => 'STOP-LOSS';

  @override
  String signals_result_pips(int pips) {
    return '$pips pips';
  }

  @override
  String get signals_provider_stats => 'Provider stats';

  @override
  String get signals_provider_win_rate => 'Win Rate';

  @override
  String get signals_provider_profit_factor => 'Profit Factor';

  @override
  String get signals_provider_avg_rr => 'Average RR';

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
  String get intel_sl_recommendation => 'Suggested SL';

  @override
  String get intel_sentiment => 'Sentiment';

  @override
  String get intel_bears => 'Bears';

  @override
  String get intel_bulls => 'Bulls';

  @override
  String get calendar_title => 'Economic calendar';

  @override
  String get calendar_filter_all => 'All';

  @override
  String get calendar_filter_low => 'LOW';

  @override
  String get calendar_filter_medium => 'MEDIUM';

  @override
  String get calendar_filter_high => 'HIGH';

  @override
  String get calendar_forecast => 'Forecast';

  @override
  String get calendar_previous => 'Previous';

  @override
  String get calendar_actual => 'Actual';

  @override
  String get calendar_empty => 'No events';

  @override
  String get journal_empty => 'No trades';

  @override
  String get journal_filter_all_brokers => 'All brokers';

  @override
  String get journal_emotion_check => 'Emotion check-in';

  @override
  String get journal_setup_tag => 'Setup';

  @override
  String get journal_session_tag => 'Session';

  @override
  String get journal_rr_planned => 'Planned RR';

  @override
  String get journal_rr_actual => 'Actual RR';

  @override
  String get journal_add_trade => 'New trade';

  @override
  String get journal_instrument => 'Instrument';

  @override
  String get journal_direction => 'Direction';

  @override
  String get journal_lot => 'Lot';

  @override
  String get journal_open_price => 'Open price';

  @override
  String get journal_close_price => 'Close price';

  @override
  String get journal_pnl => 'P&L (\$)';

  @override
  String get journal_notes => 'Notes (optional)';

  @override
  String get journal_saved => 'Trade saved';

  @override
  String get journal_delete => 'Delete';

  @override
  String get journal_logout => 'Logout';

  @override
  String get journal_link_broker => 'Link broker';

  @override
  String get journal_accounts_title => 'Broker accounts';

  @override
  String get journal_no_accounts => 'No brokers linked yet';

  @override
  String get journal_add_first_broker => 'Link your first broker';

  @override
  String get broker_step_choose_broker => 'Choose broker';

  @override
  String get broker_step_choose_platform => 'Choose platform';

  @override
  String get broker_step_credentials => 'Enter credentials';

  @override
  String get broker_account_number => 'Account number';

  @override
  String get broker_account_number_hint => '85204517';

  @override
  String get broker_server => 'Server';

  @override
  String get broker_server_hint => 'Exness-MT5Real8';

  @override
  String get broker_investor_password => 'Investor Password (READ-ONLY)';

  @override
  String get broker_investor_password_hint =>
      'Read-only password — trading not allowed';

  @override
  String get broker_investor_password_help =>
      'Investor Password doesn\'t allow trading in the terminal, only history import. AES-256 encrypted on the server.';

  @override
  String get broker_link_button => 'Link';

  @override
  String get broker_link_ctrader => 'Sign in via cTrader OAuth';

  @override
  String get broker_link_ctrader_help =>
      'Secure authorization through your cTrader account — no password required.';

  @override
  String get broker_ea_download_help =>
      'For MT4/MT5, install our Expert Advisor (.ex4/.ex5) in your terminal. The EA will send trade history to the server.';

  @override
  String get broker_ea_download => 'Download EA file';

  @override
  String get broker_synced => 'Synced';

  @override
  String get broker_balance => 'Balance';

  @override
  String get broker_remove => 'Remove';

  @override
  String get broker_sync_now => 'Sync now';

  @override
  String broker_remove_confirm(String name) {
    return 'Remove account $name?';
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
  String get broker_other => 'Other';

  @override
  String get platform_mt4 => 'MetaTrader 4';

  @override
  String get platform_mt5 => 'MetaTrader 5';

  @override
  String get platform_ctrader => 'cTrader';

  @override
  String get platform_mt_subtitle => 'Investor Password + Server';

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
  String get subscription_inactive => 'Subscription inactive';

  @override
  String get subscription_active => 'Subscription active';

  @override
  String get subscription_pending => 'Pending manager review';

  @override
  String subscription_expires_in(int days) {
    return '$days days left';
  }

  @override
  String get subscription_get_access => 'Get access — 30 000 ₸';

  @override
  String get subscription_kaspi_button => 'Pay via Kaspi';

  @override
  String get subscription_upload_receipt => 'Upload receipt';

  @override
  String get subscription_receipt_uploaded => 'Receipt submitted';

  @override
  String get subscription_change_receipt => 'Change receipt';

  @override
  String get subscription_confirm_submit => 'Send to manager';

  @override
  String get subscription_step_1 => 'Pay 30 000 ₸ via the Kaspi link';

  @override
  String get subscription_step_2 => 'Upload a screenshot of the receipt';

  @override
  String get subscription_step_3 => 'Manager will confirm within 24 h';

  @override
  String get subscription_mock_approve => '[Demo] Manager approved';

  @override
  String subscription_roi(String roi) {
    return 'ROI: $roi';
  }

  @override
  String get academy_title => 'Edge Academy';

  @override
  String get academy_take_test => 'Find your trading strengths and weaknesses';

  @override
  String get academy_take_test_subtitle =>
      '20 questions — discover your edges and blind spots';

  @override
  String get academy_library => 'Library';

  @override
  String get academy_library_subtitle =>
      'What to read / watch / listen — by category';

  @override
  String get academy_category_books => 'Books';

  @override
  String get academy_category_films => 'Films';

  @override
  String get academy_category_podcasts => 'Podcasts';

  @override
  String get academy_filter_by_problem => 'By problem';

  @override
  String get academy_filter_all => 'All';

  @override
  String get academy_open_source => 'Open';

  @override
  String get tools_title => 'Tools';

  @override
  String get tools_position_calc => 'Position calculator';

  @override
  String get tools_position_calc_subtitle => 'Lot size from risk % + SL';

  @override
  String get calc_mode_by_pips => 'By SL pips';

  @override
  String get calc_mode_by_price => 'By entry + SL price';

  @override
  String get calc_balance => 'Balance (\$)';

  @override
  String get calc_risk_pct => 'Risk %';

  @override
  String get calc_sl_pips => 'SL distance (pips)';

  @override
  String get calc_entry => 'Entry price';

  @override
  String get calc_sl_price => 'SL price';

  @override
  String get calc_tp_price => 'TP price (optional)';

  @override
  String get calc_pip_value => 'Pip value (\$)';

  @override
  String get calc_result_lot => 'Recommended lot';

  @override
  String get calc_result_risk => 'Risked amount';

  @override
  String get calc_result_rr => 'Risk/Reward';

  @override
  String get calc_calculate => 'Calculate';

  @override
  String get calc_help_pip_xau => 'XAU/USD: 1 lot ≈ \$10/pip';

  @override
  String get academy_continue_test => 'Continue the test';

  @override
  String get academy_my_profile => 'My profile';

  @override
  String get academy_lessons_for_you => 'Lessons for you';

  @override
  String get academy_all_lessons => 'All lessons';

  @override
  String academy_xp(int xp) {
    return '$xp XP';
  }

  @override
  String academy_streak_days(int days) {
    return '$days d';
  }

  @override
  String get academy_weekly_progress => 'Weekly progress';

  @override
  String gallup_q_progress(int current, int total) {
    return 'Question $current / $total';
  }

  @override
  String get gallup_result_title => 'Your profile';

  @override
  String get gallup_profile_revenge => 'Revenge trading';

  @override
  String get gallup_profile_revenge_desc =>
      'You enter trades emotionally after losses. Trying to win it back is the main risk.';

  @override
  String get gallup_profile_risk => 'Uncontrolled risk';

  @override
  String get gallup_profile_risk_desc =>
      'Lot size by feel — no systematic risk management.';

  @override
  String get gallup_profile_hope => 'Hope trading';

  @override
  String get gallup_profile_hope_desc =>
      'Intuition beats the plan. Widening SL is a habit.';

  @override
  String get gallup_profile_disciplined => 'Disciplined trader';

  @override
  String get gallup_profile_disciplined_desc =>
      'Strong foundation. The next step is finding your edge.';

  @override
  String get gallup_view_lessons => 'View lessons';

  @override
  String get lesson_source => 'Source';

  @override
  String get lesson_quote => 'Quote';

  @override
  String get lesson_explanation => 'Explanation';

  @override
  String get lesson_gold_application => 'Apply to XAU/USD';

  @override
  String get lesson_quick_check => 'Quick check';

  @override
  String get lesson_quick_check_hint => 'Write your answer here…';

  @override
  String lesson_correct_answer(String answer) {
    return 'Correct answer: $answer';
  }

  @override
  String get lesson_complete => 'Complete lesson';

  @override
  String lesson_completed(int xp) {
    return 'Lesson completed (+$xp XP)';
  }

  @override
  String get library_read_summary => 'Read summary';

  @override
  String get library_summary => 'Summary';

  @override
  String get library_watch => 'Watch video';

  @override
  String get library_open_youtube => 'Open in YouTube';

  @override
  String get library_rating => 'Rating';

  @override
  String get tag_psychology => 'Psychology';

  @override
  String get tag_risk => 'Risk';

  @override
  String get tag_strategy => 'Strategy';

  @override
  String get tag_discipline => 'Discipline';

  @override
  String get tag_mindset => 'Mindset';

  @override
  String get profile_avatar_pick => 'Change avatar';

  @override
  String get profile_about_me => 'About me';

  @override
  String get profile_preferred_sessions => 'Preferred sessions';

  @override
  String get profile_settings => 'Settings';

  @override
  String get profile_notifications => 'Notifications';

  @override
  String get notif_title => 'Notifications';

  @override
  String get notif_signals => 'TraderOS signals';

  @override
  String get notif_signals_desc => 'Push when a new signal is published';

  @override
  String get notif_intel => 'Market Intel';

  @override
  String get notif_intel_desc => 'Breaking news affecting Gold';

  @override
  String get notif_calendar => 'Economic calendar';

  @override
  String get notif_calendar_desc => '15 min before HIGH events';

  @override
  String get notif_ideas => 'Trade Ideas';

  @override
  String get notif_ideas_desc => 'New ideas from traders';

  @override
  String get notif_review => 'Market Review';

  @override
  String get notif_review_desc => 'Daily market overview';

  @override
  String get notif_academy => 'Edge Academy';

  @override
  String get notif_academy_desc => 'Lesson reminder';

  @override
  String get notif_broker => 'Broker sync';

  @override
  String get notif_broker_desc => 'New trades imported';

  @override
  String get notif_streak => 'Streak';

  @override
  String get notif_streak_desc => 'Don\'t lose your streak';

  @override
  String get notif_dnd => 'Do not disturb (00:00–07:00)';

  @override
  String get notif_dnd_desc => 'Only urgent notifications';
}
