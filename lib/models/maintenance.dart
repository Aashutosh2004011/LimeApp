import 'package:hive/hive.dart';

part 'maintenance.g.dart';

enum MaintenanceStatus {
  due,
  overdue,
  done,
}

@HiveType(typeId: 3)
class MaintenanceTask extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String machineId;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final String description;

  @HiveField(4)
  final DateTime dueDate;

  @HiveField(5)
  String status;

  @HiveField(6)
  String? completionNote;

  @HiveField(7)
  DateTime? completedAt;

  @HiveField(8)
  String? completedBy;

  @HiveField(9)
  final String tenantId;

  @HiveField(10)
  bool isSynced;

  MaintenanceTask({
    required this.id,
    required this.machineId,
    required this.title,
    required this.description,
    required this.dueDate,
    this.status = 'due',
    this.completionNote,
    this.completedAt,
    this.completedBy,
    required this.tenantId,
    this.isSynced = false,
  });

  MaintenanceStatus get maintenanceStatus {
    if (status == 'done') return MaintenanceStatus.done;
    if (DateTime.now().isAfter(dueDate)) return MaintenanceStatus.overdue;
    return MaintenanceStatus.due;
  }

  MaintenanceTask copyWith({
    String? id,
    String? machineId,
    String? title,
    String? description,
    DateTime? dueDate,
    String? status,
    String? completionNote,
    DateTime? completedAt,
    String? completedBy,
    String? tenantId,
    bool? isSynced,
  }) {
    return MaintenanceTask(
      id: id ?? this.id,
      machineId: machineId ?? this.machineId,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      completionNote: completionNote ?? this.completionNote,
      completedAt: completedAt ?? this.completedAt,
      completedBy: completedBy ?? this.completedBy,
      tenantId: tenantId ?? this.tenantId,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'machineId': machineId,
        'title': title,
        'description': description,
        'dueDate': dueDate.toIso8601String(),
        'status': status,
        'completionNote': completionNote,
        'completedAt': completedAt?.toIso8601String(),
        'completedBy': completedBy,
        'tenantId': tenantId,
        'isSynced': isSynced,
      };

  factory MaintenanceTask.fromJson(Map<String, dynamic> json) => MaintenanceTask(
        id: json['id'],
        machineId: json['machineId'],
        title: json['title'],
        description: json['description'],
        dueDate: DateTime.parse(json['dueDate']),
        status: json['status'] ?? 'due',
        completionNote: json['completionNote'],
        completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
        completedBy: json['completedBy'],
        tenantId: json['tenantId'],
        isSynced: json['isSynced'] ?? false,
      );
}