// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'view_model_exception.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VMExceptionAdapter extends TypeAdapter<VMException> {
  @override
  final int typeId = 0;

  @override
  VMException read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VMException(
      fields[0] as String,
      callFuncName: fields[3] as String?,
      lineNum: fields[4] as String?,
      deviceInfo: fields[5] as String?,
    )
      ..tag = fields[1] as String
      ..time = fields[2] as String
      ..baseRequest = fields[6] as String?
      ..responseStatusCode = fields[7] as String?
      ..responsePhrase = fields[8] as String?
      ..responseBody = fields[9] as String?
      ..tokenIsValid = fields[10] as String?;
  }

  @override
  void write(BinaryWriter writer, VMException obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.message)
      ..writeByte(1)
      ..write(obj.tag)
      ..writeByte(2)
      ..write(obj.time)
      ..writeByte(3)
      ..write(obj.callFuncName)
      ..writeByte(4)
      ..write(obj.lineNum)
      ..writeByte(5)
      ..write(obj.deviceInfo)
      ..writeByte(6)
      ..write(obj.baseRequest)
      ..writeByte(7)
      ..write(obj.responseStatusCode)
      ..writeByte(8)
      ..write(obj.responsePhrase)
      ..writeByte(9)
      ..write(obj.responseBody)
      ..writeByte(10)
      ..write(obj.tokenIsValid);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VMExceptionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
