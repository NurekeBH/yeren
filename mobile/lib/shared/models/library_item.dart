import 'package:equatable/equatable.dart';

import 'gallup.dart';

/// Библиотека категориясы. Подкаст = YouTube-видео (приложение ішінде ойнайды).
enum LibraryCategory { book, film, podcast }

extension LibraryCategoryX on LibraryCategory {
  String get emoji {
    switch (this) {
      case LibraryCategory.book:
        return '📖';
      case LibraryCategory.film:
        return '🎬';
      case LibraryCategory.podcast:
        return '▶️';
    }
  }
}

/// Библиотека элементі — кітап / фильм / YouTube-подкаст.
/// Тест жоқ; ашқанда тек жеке summary (+ подкастта in-app плеер) көрсетіледі.
class LibraryItem extends Equatable {
  const LibraryItem({
    required this.id,
    required this.category,
    required this.title,
    required this.author,
    required this.summary,
    this.genre,
    this.ideas = const [],
    this.conclusion,
    this.profile,
    this.topic,
    this.year,
    this.rating,
    this.ratingMax = 5,
    this.ratingSource,
    this.isbn,
    this.coverUrl,
    this.youtubeId,
    this.externalUrl,
    this.lang,
  });

  final String id;
  final LibraryCategory category;

  /// Шығарманың аты (кітап/фильм/видео).
  final String title;

  /// Автор / режиссёр / YouTube-канал.
  final String author;

  /// Локализацияланған қысқаша мазмұн / «О чём это» (ашқанда көрсетіледі).
  final String summary;

  /// Жанр (локализацияланған) — кітап/фильм үшін. Подкастта null.
  final String? genre;

  /// «Негізгі идеялар» — локализацияланған тармақтар (кітап/фильм).
  final List<String> ideas;

  /// «Қорытынды» — локализацияланған бір сөйлем (кітап/фильм).
  final String? conclusion;

  /// Gallup профилі бойынша сүзу үшін (қалауыңызша).
  final GallupProfile? profile;

  /// Тақырыптық категория (мыс. «Классика», «Кризисы») — сұрыптау/топтау үшін.
  final String? topic;

  final int? year;

  /// Рейтинг (book → Goodreads/5, film → IMDb/10). Подкастта null.
  final double? rating;
  final double ratingMax;
  final String? ratingSource;

  /// Кітап мұқабасы үшін ISBN (Open Library covers).
  final String? isbn;

  /// Айқын мұқаба URL-і (қажет болса).
  final String? coverUrl;

  /// Подкаст үшін YouTube video id — приложение ішінде ойнатылады.
  final String? youtubeId;

  /// Сыртқы сілтеме (Goodreads / IMDb / YouTube watch).
  final String? externalUrl;

  /// Мазмұн тілі — подкаст/видео үшін: 'EN' | 'RU' (UI-да белгі көрсетіледі).
  final String? lang;

  bool get isPodcast => category == LibraryCategory.podcast;

  /// Мұқаба суреті: explicit → ISBN (кітап) → YouTube thumbnail (подкаст).
  /// Болмаса null → UI стильді генерацияланған мұқаба көрсетеді.
  String? get coverImageUrl {
    if (coverUrl != null) return coverUrl;
    if (isbn != null) {
      return 'https://covers.openlibrary.org/b/isbn/$isbn-L.jpg?default=false';
    }
    if (youtubeId != null) {
      return 'https://img.youtube.com/vi/$youtubeId/hqdefault.jpg';
    }
    return null;
  }

  @override
  List<Object?> get props => [id];
}
