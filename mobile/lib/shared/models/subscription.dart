import 'package:equatable/equatable.dart';

enum SubscriptionStatus {
  /// Жазылым жоқ — пайдаланушы әлі төлеген емес.
  inactive,

  /// Чек жүктелді, менеджер растайды.
  pendingReview,

  /// Менеджер растады, белсенді.
  active,

  /// Мерзімі бітті.
  expired,
}

class Subscription extends Equatable {
  const Subscription({required this.status, this.activatedAt, this.expiresAt, this.receiptPath});

  final SubscriptionStatus status;
  final DateTime? activatedAt;
  final DateTime? expiresAt;
  final String? receiptPath;

  bool get isActive => status == SubscriptionStatus.active;

  int? get daysLeft {
    if (expiresAt == null) return null;
    return expiresAt!.difference(DateTime.now()).inDays;
  }

  Subscription copyWith({
    SubscriptionStatus? status,
    DateTime? activatedAt,
    DateTime? expiresAt,
    String? receiptPath,
  }) =>
      Subscription(
        status: status ?? this.status,
        activatedAt: activatedAt ?? this.activatedAt,
        expiresAt: expiresAt ?? this.expiresAt,
        receiptPath: receiptPath ?? this.receiptPath,
      );

  @override
  List<Object?> get props => [status, activatedAt, expiresAt, receiptPath];
}
