import 'package:equatable/equatable.dart';

enum ReservationStatus {
  pending('PENDING'),
  confirmed('CONFIRMED'),
  declined('DECLINED'),
  cancelled('CANCELLED'),
  completed('COMPLETED');

  const ReservationStatus(this.wire);

  final String wire;

  static ReservationStatus fromJson(String? value) =>
      ReservationStatus.values.firstWhere(
        (s) => s.wire == value,
        orElse: () => ReservationStatus.pending,
      );

  /// Whether the booking can still be cancelled.
  bool get isActive =>
      this == ReservationStatus.pending || this == ReservationStatus.confirmed;
}

/// A table booking.
///
/// v1's booking screens rendered "Sorry, Service Not Availabe For Now (:".
class Reservation extends Equatable {
  const Reservation({
    required this.id,
    required this.reference,
    required this.date,
    required this.time,
    required this.partySize,
    required this.status,
    required this.contactName,
    required this.contactPhone,
    required this.cafeId,
    required this.cafeSlug,
    required this.cafeName,
    required this.createdAt,
    this.note,
    this.declineReason,
    this.cafeImage,
    this.cafePhone,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    final cafe = json['cafe'] as Map<String, dynamic>? ?? const {};

    return Reservation(
      id: json['id'] as String,
      reference: json['reference'] as String,
      // The API sends a calendar date with no timezone.
      date: DateTime.parse(json['date'] as String),
      time: json['time'] as String,
      partySize: json['partySize'] as int,
      status: ReservationStatus.fromJson(json['status'] as String?),
      note: json['note'] as String?,
      declineReason: json['declineReason'] as String?,
      contactName: json['contactName'] as String? ?? '',
      contactPhone: json['contactPhone'] as String? ?? '',
      cafeId: cafe['id'] as String? ?? '',
      cafeSlug: cafe['slug'] as String? ?? '',
      cafeName: cafe['name'] as String? ?? '',
      cafeImage: cafe['coverImage'] as String?,
      cafePhone: cafe['phone'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  final String id;
  final String reference;
  final DateTime date;
  final String time;
  final int partySize;
  final ReservationStatus status;
  final String? note;
  final String? declineReason;
  final String contactName;
  final String contactPhone;
  final String cafeId;
  final String cafeSlug;
  final String cafeName;
  final String? cafeImage;
  final String? cafePhone;
  final DateTime createdAt;

  bool get isUpcoming =>
      status.isActive && !date.isBefore(DateTime.now().dateOnly);

  @override
  List<Object?> get props => [id, status, date, time];
}

/// One bookable slot from the availability endpoint.
class TimeSlot extends Equatable {
  const TimeSlot({
    required this.time,
    required this.available,
    required this.seatsLeft,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) => TimeSlot(
        time: json['time'] as String,
        available: json['available'] as bool? ?? false,
        seatsLeft: json['seatsLeft'] as int? ?? 0,
      );

  final String time;
  final bool available;
  final int seatsLeft;

  @override
  List<Object?> get props => [time, available, seatsLeft];
}

class Availability extends Equatable {
  const Availability({
    required this.date,
    required this.isClosed,
    required this.slots,
    this.capacity,
  });

  factory Availability.fromJson(Map<String, dynamic> json) => Availability(
        date: json['date'] as String,
        isClosed: json['isClosed'] as bool? ?? false,
        capacity: json['capacity'] as int?,
        slots: (json['slots'] as List<dynamic>? ?? [])
            .map((s) => TimeSlot.fromJson(s as Map<String, dynamic>))
            .toList(),
      );

  final String date;
  final bool isClosed;
  final int? capacity;
  final List<TimeSlot> slots;

  bool get hasAnyAvailable => slots.any((s) => s.available);

  @override
  List<Object?> get props => [date, isClosed, slots];
}

extension DateOnly on DateTime {
  /// Midnight of the same calendar day, for comparing dates without times.
  DateTime get dateOnly => DateTime(year, month, day);
}
