import 'library_text_b1.dart';
import 'library_text_b2.dart';
import 'library_text_b3.dart';
import 'library_text_f.dart';
import 'library_text_types.dart';

/// Барлық кітап/фильм summary + негізгі идеялары (350 элемент), бір картаға біріктірілген.
/// catalog_books_*/catalog_films _b()/_f() осыдан summary мен ideas-ты алады.
final Map<String, LibText> kLibraryText = {
  ...kLibTextB1,
  ...kLibTextB2,
  ...kLibTextB3,
  ...kLibTextF,
};
