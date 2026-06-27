import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/locale/locale_controller.dart';
import '../../../core/network/api_service.dart';

/// YouTube URL немесе id-тен видео id шығару (player үшін).
String? ytId(String? url) {
  if (url == null || url.isEmpty) return null;
  final u = url.trim();
  // Таза id (11 таңба)
  final idRe = RegExp(r'^[A-Za-z0-9_-]{11}$');
  if (idRe.hasMatch(u)) return u;
  final patterns = [
    RegExp(r'[?&]v=([A-Za-z0-9_-]{11})'),
    RegExp(r'youtu\.be/([A-Za-z0-9_-]{11})'),
    RegExp(r'youtube\.com/embed/([A-Za-z0-9_-]{11})'),
    RegExp(r'youtube\.com/shorts/([A-Za-z0-9_-]{11})'),
  ];
  for (final re in patterns) {
    final m = re.firstMatch(u);
    if (m != null) return m.group(1);
  }
  return null;
}

class VideoModule {
  VideoModule({required this.title, required this.video, required this.text});
  final String title;
  final String video; // YouTube URL/id
  final String text;
  String? get videoId => ytId(video);
}

/// Видео-курс (админ жасайды): мұқаба + тегін intro видео + видео модульдер.
/// Бонус ұпайымен ашылады (priceBonus); тегін болуы мүмкін.
class VideoCourse {
  VideoCourse({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.coverUrl,
    required this.emoji,
    required this.priceBonus,
    required this.introVideo,
    required this.modules,
  });

  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String? coverUrl;
  final String emoji;
  final int priceBonus;
  final String? introVideo; // тегін intro
  final List<VideoModule> modules;

  bool get isFree => priceBonus <= 0;
  String? get introVideoId => ytId(introVideo);

  /// Мұқаба: айқын URL → intro видеоның YouTube thumbnail-і.
  String? get coverImageUrl {
    if (coverUrl != null && coverUrl!.isNotEmpty) return coverUrl;
    final iv = introVideoId ?? (modules.isNotEmpty ? modules.first.videoId : null);
    return iv == null ? null : 'https://img.youtube.com/vi/$iv/hqdefault.jpg';
  }

  static String _pick(dynamic m, String loc, [String fb = '']) =>
      m is Map ? (m[loc] ?? m['ru'] ?? fb).toString() : fb;

  factory VideoCourse.fromCatalog(Map<String, dynamic> j, String loc) {
    final content = (j['content'] as Map?)?.cast<String, dynamic>() ?? const {};
    final mods = (content['modules'] as List? ?? const [])
        .map((e) => (e as Map).cast<String, dynamic>())
        .map((m) => VideoModule(
              title: (m['title'] ?? '').toString(),
              video: (m['video'] ?? '').toString(),
              text: (m['text'] ?? '').toString(),
            ))
        .toList();
    return VideoCourse(
      id: j['id'].toString(),
      title: _pick(j['title'], loc),
      subtitle: _pick(j['subtitle'], loc),
      description: _pick(j['description'], loc),
      coverUrl: j['cover_url'] as String?,
      emoji: (j['emoji'] ?? '🎬').toString(),
      priceBonus: (j['price_bonus'] as num?)?.toInt() ?? int.tryParse('${j['price_bonus']}') ?? 0,
      introVideo: content['intro_video'] as String?,
      modules: mods,
    );
  }
}

/// Барлық каталог жолдары (curriculum + video бір API шақыруынан).
final courseCatalogRawProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final loc = ref.watch(localeControllerProvider).languageCode;
  final raw = await ref.watch(apiServiceProvider).coursesCatalog(loc);
  return raw.map((e) => (e as Map).cast<String, dynamic>()).toList();
});

bool _isVideo(Map<String, dynamic> j) => (j['content'] as Map?)?['kind'] == 'video';

final videoCoursesProvider = FutureProvider<List<VideoCourse>>((ref) async {
  final loc = ref.watch(localeControllerProvider).languageCode;
  final rows = await ref.watch(courseCatalogRawProvider.future);
  return rows.where(_isVideo).map((j) => VideoCourse.fromCatalog(j, loc)).toList();
});

final videoCourseByIdProvider = FutureProvider.family<VideoCourse?, String>((ref, id) async {
  final list = await ref.watch(videoCoursesProvider.future);
  for (final c in list) {
    if (c.id == id) return c;
  }
  return null;
});
