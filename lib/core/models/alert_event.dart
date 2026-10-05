import 'package:hive/hive.dart';

part 'alert_event.g.dart';

@HiveType(typeId: 2)
enum AlertStatus {
  @HiveField(0)
  active,
  @HiveField(1)
  resolved,
}

@HiveType(typeId: 1)
class AlertEvent {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime createdAt;

  @HiveField(2)
  final double latitude;

  @HiveField(3)
  final double longitude;

  @HiveField(4)
  final int? batteryPercent;

  @HiveField(5)
  final String shareMessage;

  @HiveField(6)
  final AlertStatus status;

  @HiveField(7)
  final DateTime? resolvedAt;

  AlertEvent({
    required this.id,
    required this.createdAt,
    required this.latitude,
    required this.longitude,
    this.batteryPercent,
    required this.shareMessage,
    this.status = AlertStatus.active,
    this.resolvedAt,
  });

  String get mapsUrl => 'https://maps.google.com/?q=$latitude,$longitude';

  String get locationSnippet =>
      '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';

  bool get isResolved => status == AlertStatus.resolved;

  bool get isActive => status == AlertStatus.active;

  AlertEvent copyWith({
    String? id,
    DateTime? createdAt,
    double? latitude,
    double? longitude,
    int? batteryPercent,
    String? shareMessage,
    AlertStatus? status,
    DateTime? resolvedAt,
  }) {
    return AlertEvent(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      batteryPercent: batteryPercent ?? this.batteryPercent,
      shareMessage: shareMessage ?? this.shareMessage,
      status: status ?? this.status,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }

  AlertEvent resolve() {
    return copyWith(
      status: AlertStatus.resolved,
      resolvedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'batteryPercent': batteryPercent,
      'shareMessage': shareMessage,
      'status': status.name,
      'resolvedAt': resolvedAt?.toIso8601String(),
    };
  }

  factory AlertEvent.fromJson(Map<String, dynamic> json) {
    return AlertEvent(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      batteryPercent: json['batteryPercent'] as int?,
      shareMessage: json['shareMessage'] as String,
      status: AlertStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => AlertStatus.active,
      ),
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.parse(json['resolvedAt'] as String)
          : null,
    );
  }
}
