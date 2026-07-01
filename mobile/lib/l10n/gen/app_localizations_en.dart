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
  String get error_network => 'Check your internet connection';

  @override
  String get error_generic => 'Something went wrong. Please try again later';

  @override
  String get error_server =>
      'Something went wrong on our side. We\'re on it — try again later';

  @override
  String get validation_required => 'This field is required';

  @override
  String validation_min_chars(int n) {
    return 'At least $n characters';
  }

  @override
  String get upload_too_large => 'File too large. Max 5 MB';

  @override
  String get upload_bad_format =>
      'Wrong format. Please choose an image (PNG, JPG)';

  @override
  String get upload_failed =>
      'Couldn\'t upload the photo. Check your connection and retry';

  @override
  String get err_invalid_credentials => 'Incorrect phone or password';

  @override
  String get err_phone_already_registered =>
      'This number is already registered. Please sign in.';

  @override
  String get err_account_blocked => 'Account is blocked';

  @override
  String get err_bad_request => 'Please check the entered data';

  @override
  String get err_not_found => 'Not found';

  @override
  String get err_locked => 'Locked — purchase first';

  @override
  String get err_insufficient_bonus => 'Not enough bonuses';

  @override
  String get err_invalid_code => 'Invalid promo code';

  @override
  String get err_already_used => 'Promo code already used';

  @override
  String get err_own_code => 'You can\'t use your own promo code';

  @override
  String get err_not_owner => 'No access';

  @override
  String get common_undo => 'Undo';

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
  String get splash_tagline => 'Gold trading platform';

  @override
  String get intro_skip => 'Skip';

  @override
  String get intro_next => 'Next';

  @override
  String get intro_start => 'Start free';

  @override
  String get intro_social_proof => '🔥 5,000+ traders already with us';

  @override
  String get intro_s1_title => 'Stop blowing your account';

  @override
  String get intro_s1_text =>
      'Precise gold signals from traders who actually make money.';

  @override
  String get intro_s2_title => 'Signals you can trust';

  @override
  String get intro_s2_text =>
      'Entry, targets and stop — with win rate and author rating. Fully transparent.';

  @override
  String get intro_s3_title => 'Grow as a trader';

  @override
  String get intro_s3_text =>
      'Academy, trade journal and breakdowns — the discipline that pays off.';

  @override
  String get intro_s4_title => 'You\'re on the team with the best';

  @override
  String get intro_s4_text =>
      'Thousands of traders already earn with Altyn. Join free.';

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
  String get alerts_deleted => 'Alert deleted';

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
  String get lib_podcast_translate =>
      'Watch in Russian or English — turn on YouTube auto-translated subtitles/dubbing in the video.';

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
  String get events_empty =>
      'Trading events — masterclasses, webinars and live sessions — will appear here. Coming soon!';

  @override
  String get events_none_match => 'No events match the filter';

  @override
  String get events_filter_all => 'All';

  @override
  String get events_filter_online => 'Online';

  @override
  String get events_filter_offline => 'Offline';

  @override
  String get events_filter_free => 'Free';

  @override
  String get events_filter_paid => 'Paid';

  @override
  String get events_filter_city => 'City';

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
  String get event_publish => 'Publish event';

  @override
  String get event_publish_title => 'New event';

  @override
  String get event_published => 'Event published!';

  @override
  String get event_need_title => 'Enter a title';

  @override
  String get event_field_title => 'Title';

  @override
  String get event_field_date => 'Date & time';

  @override
  String get event_field_online => 'Online';

  @override
  String get event_field_city => 'City / venue';

  @override
  String get event_field_price => 'Price (₸)';

  @override
  String get event_field_price_help => '0 = free';

  @override
  String get event_field_desc => 'Description';

  @override
  String get home_events => 'Events';

  @override
  String get home_qa_alerts => 'Alerts';

  @override
  String get home_qa_calc => 'Calculator';

  @override
  String get home_qa_events => 'Events';

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
  String get prov_active_ideas => 'Active ideas';

  @override
  String get prov_past_signals => 'Past signals';

  @override
  String get prov_no_past_signals => 'No closed signals yet';

  @override
  String get prov_follow => 'Follow';

  @override
  String get prov_following => 'Following';

  @override
  String get prov_follow_toast => 'You follow this provider (free)';

  @override
  String get prov_follow_note => 'We\'ll notify you when they post a new idea';

  @override
  String get posts_published => 'Published Ideas';

  @override
  String get posts_empty => 'No posts yet';

  @override
  String get posts_comments_title => 'Comments';

  @override
  String get posts_comment_hint => 'Write a comment…';

  @override
  String get posts_send => 'Send';

  @override
  String get posts_you => 'You';

  @override
  String get post_report => 'Report';

  @override
  String get post_reported => 'Report sent';

  @override
  String get post_report_sexual => 'Sexual content';

  @override
  String get post_report_harmful => 'Harmful/dangerous content';

  @override
  String get post_report_spam => 'Spam or ads';

  @override
  String get post_report_harassment => 'Harassment/bullying';

  @override
  String get post_report_misinfo => 'Misinformation';

  @override
  String get post_report_other => 'Other';

  @override
  String posts_comments_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count comments',
      one: '$count comment',
      zero: 'No comments',
    );
    return '$_temp0';
  }

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
  String get signals_empty => 'No ideas yet';

  @override
  String get my_publications => 'My publications';

  @override
  String get my_pub_posts => 'Posts';

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
  String get signals_risk => 'Risk';

  @override
  String get signals_risk_low => 'Low risk';

  @override
  String get signals_risk_medium => 'Medium risk';

  @override
  String get signals_risk_high => 'High risk';

  @override
  String get signals_risk_low_short => 'Low';

  @override
  String get signals_risk_medium_short => 'Medium';

  @override
  String get signals_risk_high_short => 'High';

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
  String get signals_wr_short => 'WR';

  @override
  String get signals_free_badge => 'Free';

  @override
  String get signals_potential => 'Potential';

  @override
  String get signals_paid_idea => 'Paid idea';

  @override
  String get signals_screenshot_locked => 'Screenshot after payment';

  @override
  String get signals_unlocked_badge => 'Unlocked';

  @override
  String get signals_locked_title => 'Idea locked';

  @override
  String get signals_locked_desc =>
      'Unlock this idea to see the screenshot, entry zone, TP, SL and full analysis.';

  @override
  String get signals_unlock_title => 'Unlock idea';

  @override
  String get signals_unlock_desc =>
      'Chart screenshot, full entry/TP/SL levels and the trader\'s analysis.';

  @override
  String get signals_price_label => 'Price';

  @override
  String signals_tp_pips(int pips) {
    return 'TP $pips pips';
  }

  @override
  String signals_price_tg(int price) {
    return '$price ₸';
  }

  @override
  String signals_unlock_for(int price) {
    return 'See the full idea · $price bonus';
  }

  @override
  String get signals_unlock_scarcity =>
      '🔒 Exclusive breakdown · one-time access';

  @override
  String signals_fomo_opened(int count) {
    return '$count already opened';
  }

  @override
  String get signals_fomo_fresh => 'Fresh entry';

  @override
  String get signals_fomo_first => 'Be the first';

  @override
  String get signals_your_balance => 'Your balance';

  @override
  String signals_not_enough(int count) {
    return 'Need $count more bonus — invite friends';
  }

  @override
  String signals_pay_kaspi(int price) {
    return 'Pay $price ₸ with Kaspi';
  }

  @override
  String get signals_paying => 'Paying…';

  @override
  String get signals_pay_secure => 'Secure payment · Kaspi Pay';

  @override
  String get signals_unlock_success => 'Idea unlocked!';

  @override
  String get signals_publish => 'Publish idea';

  @override
  String get signals_publish_title => 'New trade idea';

  @override
  String get signals_published => 'Idea published!';

  @override
  String get signals_publish_add_photo => 'Add chart photo';

  @override
  String get signals_publish_text => 'Idea text';

  @override
  String get signals_publish_text_hint =>
      'e.g. BUY 2400, TP 2410/2420, SL 2390 — short reasoning';

  @override
  String get signals_publish_need_text => 'Please write the idea text';

  @override
  String get signals_publish_need_levels => 'Fill in entry zone, TP1 and Stop';

  @override
  String get signals_entry_from => 'Entry (from)';

  @override
  String get signals_entry_to => 'Entry (to)';

  @override
  String get signals_free_idea => 'Free idea';

  @override
  String get signals_free_idea_desc => 'If on — no paywall, open to everyone';

  @override
  String get signals_set_result => 'Set result';

  @override
  String get signals_set_result_desc => 'Mark which level the idea closed at';

  @override
  String get signals_result_set => 'Result saved, idea closed';

  @override
  String get signals_vote_title => 'Vote on the outcome';

  @override
  String get signals_vote_desc => 'Your prediction: which level will it reach?';

  @override
  String get signals_verify_title => 'Verify the result';

  @override
  String get signals_verify_desc =>
      'Did it really? Vote what actually happened.';

  @override
  String signals_trader_marked(String result) {
    return 'Trader marked: $result';
  }

  @override
  String get signals_trader_claim => 'trader\'s claim';

  @override
  String get signals_updates_title => 'Trader updates';

  @override
  String get signals_updates_empty => 'No updates yet.';

  @override
  String get signals_update_hint => 'Add an update (e.g. \"waiting for TP3\")…';

  @override
  String signals_verify_confirmed(int pct) {
    return 'Community confirms ($pct%)';
  }

  @override
  String signals_verify_disputed(String result) {
    return 'Disputed — most say $result';
  }

  @override
  String get prov_tab_active => 'Active';

  @override
  String get prov_tab_past => 'Past';

  @override
  String get prov_tab_posts => 'Posts';

  @override
  String get profile_trader_mode => 'Provider mode';

  @override
  String get profile_trader_mode_desc => 'Publish and manage ideas';

  @override
  String get profile_become_trader => 'Become a provider';

  @override
  String get profile_verified_trader => 'Provider ✓';

  @override
  String get profile_verified_trader_desc => 'Publish signals and ideas';

  @override
  String get profile_support => 'Support / Admin';

  @override
  String get profile_delete_account => 'Delete account';

  @override
  String get profile_delete_account_warning =>
      'Your account and all data will be permanently deleted. This action cannot be undone.';

  @override
  String get profile_delete_account_confirm => 'Delete';

  @override
  String get support_title => 'Support';

  @override
  String get support_desc =>
      'Message us about questions, verification or partnership — it reaches the team.';

  @override
  String get support_message_hint => 'Write your message…';

  @override
  String get support_send => 'Send';

  @override
  String get support_sent => 'Message sent! We\'ll get back to you soon.';

  @override
  String get trader_apply_title => 'Provider application';

  @override
  String get trader_apply_desc =>
      'Send some info about yourself so the team can verify you.';

  @override
  String get trader_apply_years => 'Years of trading experience';

  @override
  String get trader_apply_about => 'About you / your strategy';

  @override
  String get trader_apply_about_hint => 'Style, markets, track record…';

  @override
  String get trader_apply_proof => 'Proof link (optional)';

  @override
  String get trader_apply_proof_hint =>
      'MyFxBook, statement, Telegram/Instagram…';

  @override
  String get trader_apply_tip =>
      'The best way to earn trust is to publish 3 FREE signals first, so the team and users can see your edge.';

  @override
  String get trader_apply_send => 'Send application';

  @override
  String get trader_apply_sent => 'Application sent!';

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
  String get intel_empty =>
      'No news yet. It will show up here as soon as the market moves.';

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
  String calendar_in_h(int h) {
    return 'in ${h}h';
  }

  @override
  String calendar_in_m(int m) {
    return 'in ${m}m';
  }

  @override
  String get calendar_soon => 'soon';

  @override
  String get calendar_today => 'Today';

  @override
  String get calendar_tomorrow => 'Tomorrow';

  @override
  String get calendar_previous_short => 'PREV';

  @override
  String get calendar_forecast_short => 'FORE';

  @override
  String get calendar_actual_short => 'ACT';

  @override
  String get calendar_released => 'released';

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
  String get journal_sl_opt => 'SL (optional)';

  @override
  String get journal_fees_opt => 'Fees (\$)';

  @override
  String get journal_grade => 'Trade grade';

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
  String get journal_tab_trades => 'Trades';

  @override
  String get journal_tab_analytics => 'Analytics';

  @override
  String get journal_import => 'Import statement';

  @override
  String get journal_import_hint => 'MT4/MT5 statement (.html or .csv)';

  @override
  String get journal_sync => 'Sync';

  @override
  String get journal_all_accounts => 'All accounts';

  @override
  String get journal_analytics_empty => 'No closed trades to analyze yet';

  @override
  String get journal_calendar_title => 'P&L calendar';

  @override
  String get journal_emotions_title => 'Emotions & profit';

  @override
  String get journal_setups_title => 'Setups';

  @override
  String get journal_sessions_title => 'Sessions';

  @override
  String get journal_correlation => 'Emotion↔P&L correlation';

  @override
  String get journal_link_account => 'Link account';

  @override
  String get journal_no_credentials => 'No password for sync';

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
  String get calc_risk_amount => 'Risk amount, \$';

  @override
  String get calc_entry_from => 'Entry price (from)';

  @override
  String get calc_entry_to => 'Entry price (to) — optional';

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
  String get calc_from_idea => 'Calculate lot from this idea';

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
  String get library_about => 'What it\'s about';

  @override
  String get library_key_ideas => 'Key ideas';

  @override
  String get library_conclusion => 'Conclusion';

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
  String get profile_edit => 'Edit profile';

  @override
  String get profile_avatar_updated => 'Profile photo updated';

  @override
  String get profile_saved_toast => 'Profile saved';

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
  String get notif_signals => 'Trade ideas';

  @override
  String get notif_signals_desc => 'Push when a new trade idea is published';

  @override
  String get notif_events => 'Events';

  @override
  String get notif_events_desc => 'Push when a new event is added';

  @override
  String get notif_events_filter => 'Event filter (narrow if you wish)';

  @override
  String get notif_events_filter_hint => 'Empty — push for all new events';

  @override
  String get notif_events_type => 'Type';

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

  @override
  String get promo_field_label => 'Promo code (optional)';

  @override
  String get promo_field_hint => 'Trader\'s promo code';

  @override
  String promo_field_help(int bonus) {
    return 'Register with a promo code — get $bonus bonus';
  }

  @override
  String promo_applied(int bonus) {
    return 'Promo code applied! +$bonus bonus';
  }

  @override
  String referral_auto_bonus(int bonus) {
    return '🎁 You\'ve earned $bonus bonus from an invite!';
  }

  @override
  String get referral_auto_sub =>
      'Promo code applied automatically — bonus arrives after you register.';

  @override
  String streak_reward(int bonus) {
    return '🔥 Streak! +$bonus bonus for daily check-ins';
  }

  @override
  String streak_days(int days) {
    return '$days-day streak';
  }

  @override
  String get promo_signal_badge => '🎁 Promo access from a top trader';

  @override
  String get promo_signal_free => 'Free';

  @override
  String get retention_title => 'Before you go…';

  @override
  String get retention_q => 'Why are you leaving?';

  @override
  String get retention_r_expensive => 'Too expensive';

  @override
  String get retention_r_useless => 'Not useful';

  @override
  String get retention_r_notime => 'No time';

  @override
  String get retention_r_other => 'Other';

  @override
  String retention_offer(int bonus) {
    return '🎁 Stay — grab $bonus bonus for free!';
  }

  @override
  String get retention_stay => 'Grab bonus & stay';

  @override
  String get retention_leave => 'Leave anyway';

  @override
  String retention_thanks(int bonus) {
    return 'Thanks for staying! +$bonus bonus';
  }

  @override
  String get tilt_title => 'The market is choppy right now';

  @override
  String get tilt_body =>
      'You\'ve had 2 losses in a row — that\'s normal. Take a 2-hour break and protect your capital. We\'ll push you when things stabilize.';

  @override
  String get tilt_break => 'Take a break';

  @override
  String get celebrate_title => 'Great trade! 🎉';

  @override
  String celebrate_body(int points) {
    return '+$points points to your discipline jar. Today\'s plan is done.';
  }

  @override
  String get celebrate_stop => 'Call it for today';

  @override
  String get celebrate_more => 'See one more promo signal';

  @override
  String get psyche_title => 'How do you like to work?';

  @override
  String get psyche_freq => 'Frequency';

  @override
  String get psyche_freq_every => 'Every signal';

  @override
  String get psyche_freq_summary => 'Daily summary only';

  @override
  String get psyche_style => 'Style';

  @override
  String get psyche_style_direct => 'Direct instructions';

  @override
  String get psyche_style_gamified => 'Gamified with bonuses';

  @override
  String get psyche_focus => 'Do not disturb at night (22:00–08:00)';

  @override
  String get psyche_saved => 'Preferences saved';

  @override
  String get signal_of_hour => 'Best signal right now';

  @override
  String get signal_of_hour_cta => 'View in 5 minutes';

  @override
  String get promo_already_used => 'Promo code already used';

  @override
  String get promo_invalid => 'Invalid promo code';

  @override
  String get promo_own_code => 'You can\'t use your own promo code';

  @override
  String get promo_bonus_balance => 'Bonus balance';

  @override
  String get promo_bonus_balance_desc =>
      'Applied automatically when unlocking an idea';

  @override
  String get promo_my_bonuses => 'My bonuses';

  @override
  String get promo_bonus_tile_sub => 'Promo code · bonus · top up';

  @override
  String promo_bonus_amount(int count) {
    return '$count bonus';
  }

  @override
  String get promo_my_code_title => 'My promo code';

  @override
  String promo_my_code_desc(int bonus) {
    return 'A new user gets $bonus bonus when they register with your code';
  }

  @override
  String promo_my_code_earn(int bonus) {
    return 'You get +$bonus bonus per sign-up';
  }

  @override
  String promo_how_it_works(int referrer, int invitee) {
    return 'Share your promo code: when a user registers with it, they get $invitee bonus and you get $referrer bonus. Spend bonus to unlock trade ideas.';
  }

  @override
  String get promo_copy => 'Copy';

  @override
  String get promo_copied => 'Promo code copied';

  @override
  String promo_referrals(int count) {
    return '$count sign-ups with your code';
  }

  @override
  String get promo_enter_title => 'Enter promo code';

  @override
  String promo_enter_desc(int bonus) {
    return 'Get $bonus bonus';
  }

  @override
  String get promo_apply => 'Apply';

  @override
  String get signals_to_pay => 'To pay';

  @override
  String get signals_unlock_with_bonus => 'Unlock with bonus';

  @override
  String get promo_share => 'Share promo code';

  @override
  String promo_share_message(String code, int bonus) {
    return '🎁 My ALTYN promo code: $code. Get $bonus bonus when you sign up! ALTYN — gold (XAU/USD) trading platform.';
  }

  @override
  String get bonus_topup_title => 'Top up bonus';

  @override
  String get bonus_topup_desc => 'Choose a pack — pay with Kaspi';

  @override
  String get bonus_topup => 'Top up bonus with Kaspi';

  @override
  String bonus_topup_success(int amount) {
    return 'Balance topped up: +$amount bonus';
  }

  @override
  String get bonus_topup_soon => 'Top-up will be available soon';

  @override
  String get academy_courses => 'Courses';

  @override
  String get academy_courses_subtitle =>
      'Deep premium courses — theory, examples, interactive and a test';

  @override
  String get academy_premium_badge => 'PREMIUM';

  @override
  String course_modules_count(int count) {
    return '$count modules';
  }

  @override
  String course_lessons_count(int count) {
    return '$count lessons';
  }

  @override
  String get course_what_inside => 'What\'s inside';

  @override
  String course_unlock_for(int count) {
    return 'Unlock for $count bonus';
  }

  @override
  String get course_unlocked => 'Course unlocked';

  @override
  String get course_locked_hint => 'Unlock the course to access the lessons';

  @override
  String course_module_label(int n) {
    return 'MODULE $n';
  }

  @override
  String course_progress(int done, int total) {
    return '$done/$total lessons done';
  }

  @override
  String get course_start => 'Start';

  @override
  String get course_continue => 'Continue';

  @override
  String get course_completed_all => 'Course fully completed 🎉';

  @override
  String get lesson_quiz_title => 'Test yourself';

  @override
  String get lesson_quiz_check => 'Submit';

  @override
  String get lesson_quiz_correct => 'Correct!';

  @override
  String get lesson_quiz_wrong => 'Wrong';

  @override
  String get lesson_done_badge => 'Completed';

  @override
  String get lesson_next => 'Next lesson';

  @override
  String get course_unlock_title => 'Unlock course';

  @override
  String get course_unlock_balance => 'Your balance';

  @override
  String get course_back_to_lessons => 'Back to lessons';

  @override
  String get course_module_lessons => 'Module lessons';

  @override
  String get course_next => 'Next';

  @override
  String get course_prev => 'Back';

  @override
  String get course_finish_lesson => 'Finish lesson';

  @override
  String get quiz_answer_cta => 'Answer the question';

  @override
  String get quiz_try_again => 'Try again';

  @override
  String course_solved(int done, int total) {
    return 'Solved $done/$total';
  }

  @override
  String lesson_minutes(int count) {
    return '$count min';
  }

  @override
  String get course_secrets_intro => 'Worth knowing';

  @override
  String get academy_cta_title => 'Trader Academy';

  @override
  String get academy_cta_sub =>
      'Fundamentals decide everything. 90% lose their deposit not from strategy, but from gaps in the basics.';

  @override
  String get academy_cta_button => 'Open courses →';

  @override
  String get course_sell_headline => 'An investment in yourself that pays off';

  @override
  String get course_sell_b1 =>
      '10 modules, 49 lessons — from the nature of money to the anatomy of crises';

  @override
  String get course_sell_b2 => 'Interactive simulators instead of dry theory';

  @override
  String get course_sell_b3 => 'A test after every lesson — knowledge sticks';

  @override
  String get course_sell_b4 => 'Lifetime access';

  @override
  String get course_sell_footer =>
      'One well-informed trade can pay for the course many times over.';

  @override
  String get course_locked_lesson_title => 'Lesson locked';

  @override
  String get course_locked_lesson_desc =>
      'This lesson is part of the premium course. Unlock it to continue.';

  @override
  String get course_preview_label => 'What\'s inside (preview)';

  @override
  String get course_locked_screen_hint =>
      'Unlock the course first to open this lesson.';

  @override
  String get exam_title => 'Final exam';

  @override
  String get exam_intro_sub => 'Test yourself on the whole course';

  @override
  String exam_questions_count(int count) {
    return '$count questions';
  }

  @override
  String get exam_start => 'Start exam';

  @override
  String exam_question_progress(int n, int total) {
    return 'Question $n/$total';
  }

  @override
  String get exam_finish => 'Finish exam';

  @override
  String get exam_passed => 'Exam passed!';

  @override
  String get exam_failed => 'Almost there';

  @override
  String get exam_your_score => 'Your score';

  @override
  String get exam_advice_title => 'What to review';

  @override
  String get exam_advice_all_good =>
      'Great result! You\'ve got a solid grasp of the material.';

  @override
  String get exam_retake => 'Retake';

  @override
  String get exam_back_to_course => 'Back to course';

  @override
  String exam_last_result(int score, int total) {
    return 'Last result: $score/$total';
  }

  @override
  String get exam_locked_hint => 'The exam unlocks after you open the course';
}
