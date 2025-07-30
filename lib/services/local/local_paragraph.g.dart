// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_paragraph.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LocalParagraphAdapter extends TypeAdapter<LocalParagraph> {
  @override
  final int typeId = 1;

  @override
  LocalParagraph read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocalParagraph(
      author: fields[0] as String,
      text: fields[1] as String,
      timestamp: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, LocalParagraph obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.author)
      ..writeByte(1)
      ..write(obj.text)
      ..writeByte(2)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalParagraphAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
