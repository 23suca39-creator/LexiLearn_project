// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'content_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ContentItemAdapter extends TypeAdapter<ContentItem> {
  @override
  final int typeId = 0;

  @override
  ContentItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ContentItem(
      id: fields[0] as String,
      title: fields[1] as String,
      category: fields[2] as String,
      preview: fields[3] as String,
      fullText: fields[4] as String,
      url: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ContentItem obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.preview)
      ..writeByte(4)
      ..write(obj.fullText)
      ..writeByte(5)
      ..write(obj.url);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContentItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
