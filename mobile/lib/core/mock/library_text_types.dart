/// Кітап/фильм бойынша алдын ала жазылған статик мәтін (summary + негізгі идеялар).
/// Runtime-та генерация жоқ — тікелей файлдан оқылады (өнімділік).
class LibText {
  const LibText(this.summary, this.ideas);

  /// «О чём это» — қысқа мазмұн (2–3 сөйлем, орысша).
  final String summary;

  /// «Основные идеи» — негізгі идеялар (3–5 тармақ).
  final List<String> ideas;
}
