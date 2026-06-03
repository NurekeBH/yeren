import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../shared/models/library_item.dart';

/// Библиотека элементінің мұқабасы.
/// Кітап → Open Library суреті, подкаст → YouTube thumbnail,
/// басқасы (немесе сурет жүктелмесе) → стильді генерацияланған градиент мұқаба.
class LibraryCover extends StatelessWidget {
  const LibraryCover({super.key, required this.item, this.radius = 12});

  final LibraryItem item;
  final double radius;

  static const _palettes = <List<Color>>[
    [Color(0xFF22324F), Color(0xFF3E5C8A)],
    [Color(0xFF4A2C5A), Color(0xFF7A4C8F)],
    [Color(0xFF1F4D3F), Color(0xFF2F7D63)],
    [Color(0xFF5A3A1E), Color(0xFF9A6B33)],
    [Color(0xFF3A2140), Color(0xFF5E3A6E)],
    [Color(0xFF103B4A), Color(0xFF1E6B82)],
    [Color(0xFF4A1F2B), Color(0xFF8A3A4E)],
  ];

  List<Color> get _palette => _palettes[item.id.hashCode.abs() % _palettes.length];

  @override
  Widget build(BuildContext context) {
    final url = item.coverImageUrl;
    final br = BorderRadius.circular(radius);
    final image = url == null
        ? _fallback()
        : CachedNetworkImage(
            imageUrl: url,
            fit: BoxFit.cover,
            placeholder: (_, _) => _fallback(loading: true),
            errorWidget: (_, _, _) => _fallback(),
          );

    return ClipRRect(
      borderRadius: br,
      child: Stack(
        fit: StackFit.expand,
        children: [
          image,
          if (item.isPodcast) const _PlayBadge(),
          if (item.lang != null)
            Positioned(top: 6, left: 6, child: LangChip(lang: item.lang!)),
        ],
      ),
    );
  }

  Widget _fallback({bool loading = false}) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _palette,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.category.emoji, style: const TextStyle(fontSize: 22)),
            const Spacer(),
            Text(
              item.title,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.author,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.78), fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

/// Мазмұн тілінің белгісі — подкаст видеосы қай тілде екенін көрсетеді.
class LangChip extends StatelessWidget {
  const LangChip({super.key, required this.lang, this.onCover = true});

  final String lang;
  final bool onCover;

  @override
  Widget build(BuildContext context) {
    final flag = lang == 'RU' ? '🇷🇺' : '🇬🇧';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: onCover ? Colors.black.withValues(alpha: 0.62) : const Color(0xFF6B3FA0).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$flag $lang',
        style: TextStyle(
          color: onCover ? Colors.white : const Color(0xFF6B3FA0),
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _PlayBadge extends StatelessWidget {
  const _PlayBadge();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.55),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.9), width: 1.5),
        ),
        child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28),
      ),
    );
  }
}
