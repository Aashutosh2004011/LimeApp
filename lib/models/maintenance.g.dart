// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'maintenance.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MaintenanceTaskAdapter extends TypeAdapter<MaintenanceTask> {
  @override
  final int typeId = 3;

  @override
  MaintenanceTask read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MaintenanceTask(
      id: fields[0] as String,
      machineId: fields[1] as String,
      title: fields[2] as String,
      description: fields[3] as String,
      dueDate: fields[4] as DateTime,
      status: fields[5] as String,
      completionNote: fields[6] as String?,
      completedAt: fields[7] as DateTime?,
      completedBy: fields[8] as String?,
      tenantId: fields[9] as String,
      isSynced: fields[10] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, MaintenanceTask obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.machineId)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.dueDate)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.completionNote)
      ..writeByte(7)
      ..write(obj.completedAt)
      ..writeByte(8)
      ..write(obj.completedBy)
      ..writeByte(9)
      ..write(obj.tenantId)
      ..writeByte(10)
      ..write(obj.isSynced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MaintenanceTaskAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
