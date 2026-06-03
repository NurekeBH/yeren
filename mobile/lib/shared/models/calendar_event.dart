import 'package:equatable/equatable.dart';

enum ImpactLevel { low, medium, high }

class CalendarEvent extends Equatable {
  const CalendarEvent({
    required this.id,
    required this.name,
    required this.currency,
    required this.impact,
    required this.scheduledAt,
    this.forecast,
    this.previous,
    this.actual,
    this.goldImpactNote,
  });

  final String id;
  final String name;
  final String currency;
  final ImpactLevel impact;
  final DateTime scheduledAt;
  final String? forecast;
  final String? previous;
  final String? actual;
  final String? goldImpactNote;

  Duration get countdown => scheduledAt.difference(DateTime.now());

  @override
  List<Object?> get props => [id, scheduledAt];
}
