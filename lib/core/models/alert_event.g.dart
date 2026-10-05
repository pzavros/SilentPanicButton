// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alert_event.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AlertEventAdapter extends TypeAdapter<AlertEvent> {
  @override
  final int typeId = 1;

  @override
  AlertEvent read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AlertEvent(
      id: fields[0] as String,
      createdAt: fields[1] as DateTime,
      latitude: fields[2] as double,
      longitude: fields[3] as double,
      batteryPercent: fields[4] as int?,
      shareMessage: fields[5] as String,
      status: fields[6] as AlertStatus,
      resolvedAt: fields[7] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, AlertEvent obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.createdAt)
      ..writeByte(2)
      ..write(obj.latitude)
      ..writeByte(3)
      ..write(obj.longitude)
      ..writeByte(4)
      ..write(obj.batteryPercent)
      ..writeByte(5)
      ..write(obj.shareMessage)
      ..writeByte(6)
      ..write(obj.status)
      ..writeByte(7)
      ..write(obj.resolvedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlertEventAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AlertStatusAdapter extends TypeAdapter<AlertStatus> {
  @override
  final int typeId = 2;

  @override
  AlertStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AlertStatus.active;
      case 1:
        return AlertStatus.resolved;
      default:
        return AlertStatus.active;
    }
  }

  @override
  void write(BinaryWriter writer, AlertStatus obj) {
    switch (obj) {
      case AlertStatus.active:
        writer.writeByte(0);
        break;
      case AlertStatus.resolved:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlertStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
