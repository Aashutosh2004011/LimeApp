import 'package:hive/hive.dart';

part 'alert.g.dart';

enum AlertStatus {
  created,
  acknowledged,
  cleared,
}

enum AlertSeverity {
  low,
  medium,
  high,
  critical,
}

@HiveType(typeId: 4)
class Alert extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String machineId;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final String message;

  @HiveField(4)
  final String severity;

  @HiveField(5)
  String status;

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  String? acknowledgedBy;

  @HiveField(8)
  DateTime? acknowledgedAt;

  @HiveField(9)
  DateTime? clearedAt;

  @HiveField(10)
  final String tenantId;

  @HiveField(11)
  bool isSynced;

  Alert({
    required this.id,
    required this.machineId,
    required this.title,
    required this.message,
    this.severity = 'medium',
    this.status = 'created',
    required this.createdAt,
    this.acknowledgedBy,
    this.acknowledgedAt,
    this.clearedAt,
    required this.tenantId,
    this.isSynced = false,
  });

  AlertStatus get alertStatus {
    switch (status.toLowerCase()) {
      case 'created':
        return AlertStatus.created;
      case 'acknowledged':
        return AlertStatus.acknowledged;
      case 'cleared':
        return AlertStatus.cleared;
      default:
        return AlertStatus.created;
    }
  }

  AlertSeverity get alertSeverity {
    switch (severity.toLowerCase()) {
      case 'low':
        return AlertSeverity.low;
      case 'medium':
        return AlertSeverity.medium;
      case 'high':
        return AlertSeverity.high;
      case 'critical':
        return AlertSeverity.critical;
      default:
        return AlertSeverity.medium;
    }
  }

  Alert copyWith({
    String? id,
    String? machineId,
    String? title,
    String? message,
    String? severity,
    String? status,
    DateTime? createdAt,
    String? acknowledgedBy,
    DateTime? acknowledgedAt,
    DateTime? clearedAt,
    String? tenantId,
    bool? isSynced,
  }) {
    return Alert(
      id: id ?? this.id,
      machineId: machineId ?? this.machineId,
      title: title ?? this.title,
      message: message ?? this.message,
      severity: severity ?? this.severity,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      acknowledgedBy: acknowledgedBy ?? this.acknowledgedBy,
      acknowledgedAt: acknowledgedAt ?? this.acknowledgedAt,
      clearedAt: clearedAt ?? this.clearedAt,
      tenantId: tenantId ?? this.tenantId,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'machineId': machineId,
        'title': title,
        'message': message,
        'severity': severity,
        'status': status,
        'createdAt': createdAt.toIso8601String(),
        'acknowledgedBy': acknowledgedBy,
        'acknowledgedAt': acknowledgedAt?.toIso8601String(),
        'clearedAt': clearedAt?.toIso8601String(),
        'tenantId': tenantId,
        'isSynced': isSynced,
      };

  factory Alert.fromJson(Map<String, dynamic> json) => Alert(
        id: json['id'],
        machineId: json['machineId'],
        title: json['title'],
        message: json['message'],
        severity: json['severity'] ?? 'medium',
        status: json['status'] ?? 'created',
        createdAt: DateTime.parse(json['createdAt']),
        acknowledgedBy: json['acknowledgedBy'],
        acknowledgedAt: json['acknowledgedAt'] != null ? DateTime.parse(json['acknowledgedAt']) : null,
        clearedAt: json['clearedAt'] != null ? DateTime.parse(json['clearedAt']) : null,
        tenantId: json['tenantId'],
        isSynced: json['isSynced'] ?? false,
      );
}