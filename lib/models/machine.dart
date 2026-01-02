import 'package:hive/hive.dart';

part 'machine.g.dart';

enum MachineStatus {
  run,
  idle,
  off,
}

@HiveType(typeId: 1)
class Machine extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String type;

  @HiveField(3)
  String status;

  @HiveField(4)
  final String tenantId;

  Machine({
    required this.id,
    required this.name,
    required this.type,
    this.status = 'run',
    required this.tenantId,
  });

  MachineStatus get machineStatus {
    switch (status.toLowerCase()) {
      case 'run':
        return MachineStatus.run;
      case 'idle':
        return MachineStatus.idle;
      case 'off':
        return MachineStatus.off;
      default:
        return MachineStatus.idle;
    }
  }

  Machine copyWith({
    String? id,
    String? name,
    String? type,
    String? status,
    String? tenantId,
  }) {
    return Machine(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      status: status ?? this.status,
      tenantId: tenantId ?? this.tenantId,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type,
        'status': status,
        'tenantId': tenantId,
      };

  factory Machine.fromJson(Map<String, dynamic> json) => Machine(
        id: json['id'],
        name: json['name'],
        type: json['type'],
        status: json['status'] ?? 'run',
        tenantId: json['tenantId'],
      );
}