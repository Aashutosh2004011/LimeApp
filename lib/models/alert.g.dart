// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alert.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AlertAdapter extends TypeAdapter<Alert> {
  @override
  final int typeId = 4;

  @override
  Alert read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Alert(
      id: fields[0] as String,
      machineId: fields[1] as String,
      title: fields[2] as String,
      message: fields[3] as String,
      severity: fields[4] as String,
      status: fields[5] as String,
      createdAt: fields[6] as DateTime,
      acknowledgedBy: fields[7] as String?,
      acknowledgedAt: fields[8] as DateTime?,
      clearedAt: fields[9] as DateTime?,
      tenantId: fields[10] as String,
      isSynced: fields[11] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Alert obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.machineId)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.message)
      ..writeByte(4)
      ..write(obj.severity)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.acknowledgedBy)
      ..writeByte(8)
      ..write(obj.acknowledgedAt)
      ..writeByte(9)
      ..write(obj.clearedAt)
      ..writeByte(10)
      ..write(obj.tenantId)
      ..writeByte(11)
      ..write(obj.isSynced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlertAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
