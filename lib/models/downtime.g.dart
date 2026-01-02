// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'downtime.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DowntimeAdapter extends TypeAdapter<Downtime> {
  @override
  final int typeId = 2;

  @override
  Downtime read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Downtime(
      id: fields[0] as String,
      machineId: fields[1] as String,
      reasonCode: fields[2] as String,
      reasonSubCode: fields[3] as String?,
      startTime: fields[4] as DateTime,
      endTime: fields[5] as DateTime?,
      photoPath: fields[6] as String?,
      tenantId: fields[7] as String,
      isSynced: fields[8] as bool,
      operatorEmail: fields[9] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Downtime obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.machineId)
      ..writeByte(2)
      ..write(obj.reasonCode)
      ..writeByte(3)
      ..write(obj.reasonSubCode)
      ..writeByte(4)
      ..write(obj.startTime)
      ..writeByte(5)
      ..write(obj.endTime)
      ..writeByte(6)
      ..write(obj.photoPath)
      ..writeByte(7)
      ..write(obj.tenantId)
      ..writeByte(8)
      ..write(obj.isSynced)
      ..writeByte(9)
      ..write(obj.operatorEmail);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DowntimeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
