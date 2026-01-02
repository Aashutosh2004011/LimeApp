import 'package:hive/hive.dart';

part 'downtime.g.dart';

@HiveType(typeId: 2)
class Downtime extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String machineId;

  @HiveField(2)
  final String reasonCode;

  @HiveField(3)
  final String? reasonSubCode;

  @HiveField(4)
  final DateTime startTime;

  @HiveField(5)
  DateTime? endTime;

  @HiveField(6)
  final String? photoPath;

  @HiveField(7)
  final String tenantId;

  @HiveField(8)
  bool isSynced;

  @HiveField(9)
  final String operatorEmail;

  Downtime({
    required this.id,
    required this.machineId,
    required this.reasonCode,
    this.reasonSubCode,
    required this.startTime,
    this.endTime,
    this.photoPath,
    required this.tenantId,
    this.isSynced = false,
    required this.operatorEmail,
  });

  int? get durationMinutes {
    if (endTime == null) return null;
    return endTime!.difference(startTime).inMinutes;
  }

  bool get isActive => endTime == null;

  Downtime copyWith({
    String? id,
    String? machineId,
    String? reasonCode,
    String? reasonSubCode,
    DateTime? startTime,
    DateTime? endTime,
    String? photoPath,
    String? tenantId,
    bool? isSynced,
    String? operatorEmail,
  }) {
    return Downtime(
      id: id ?? this.id,
      machineId: machineId ?? this.machineId,
      reasonCode: reasonCode ?? this.reasonCode,
      reasonSubCode: reasonSubCode ?? this.reasonSubCode,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      photoPath: photoPath ?? this.photoPath,
      tenantId: tenantId ?? this.tenantId,
      isSynced: isSynced ?? this.isSynced,
      operatorEmail: operatorEmail ?? this.operatorEmail,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'machineId': machineId,
        'reasonCode': reasonCode,
        'reasonSubCode': reasonSubCode,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime?.toIso8601String(),
        'photoPath': photoPath,
        'tenantId': tenantId,
        'isSynced': isSynced,
        'operatorEmail': operatorEmail,
      };

  factory Downtime.fromJson(Map<String, dynamic> json) => Downtime(
        id: json['id'],
        machineId: json['machineId'],
        reasonCode: json['reasonCode'],
        reasonSubCode: json['reasonSubCode'],
        startTime: DateTime.parse(json['startTime']),
        endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
        photoPath: json['photoPath'],
        tenantId: json['tenantId'],
        isSynced: json['isSynced'] ?? false,
        operatorEmail: json['operatorEmail'],
      );
}