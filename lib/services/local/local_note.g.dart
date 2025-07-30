// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_note.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LocalNoteAdapter extends TypeAdapter<LocalNote> {
  @override
  final int typeId = 0;

  @override
  LocalNote read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocalNote(
      id: fields[0] as String,
      userId: fields[1] as String,
      content: (fields[2] as List).cast<LocalParagraph>(),
      sharedWith: (fields[3] as List).cast<String>(),
      lastModified: fields[4] as DateTime,
      synced: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, LocalNote obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.content)
      ..writeByte(3)
      ..write(obj.sharedWith)
      ..writeByte(4)
      ..write(obj.lastModified)
      ..writeByte(5)
      ..write(obj.synced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalNoteAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
