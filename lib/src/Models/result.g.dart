// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'result.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ResultAdapter extends TypeAdapter<Result> {
  @override
  final int typeId = 0;

  @override
  Result read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Result(
      key: fields[0] as String?,
      label: fields[1] as String?,
      keyword: fields[2] as String,
      title: fields[3] as String?,
      subTitle: fields[4] as String?,
      star: fields[5] as double?,
      totalReview: fields[6] as int?,
      categoryName: fields[7] as String?,
      attributes: (fields[8] as List?)?.cast<String>(),
      address: fields[9] as String?,
      openHours: fields[10] as String?,
      websiteUrl: fields[11] as String?,
      phoneNumber: fields[12] as String?,
      imageUrl: fields[13] as String?,
      createdAt: fields[14] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Result obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.key)
      ..writeByte(1)
      ..write(obj.label)
      ..writeByte(2)
      ..write(obj.keyword)
      ..writeByte(3)
      ..write(obj.title)
      ..writeByte(4)
      ..write(obj.subTitle)
      ..writeByte(5)
      ..write(obj.star)
      ..writeByte(6)
      ..write(obj.totalReview)
      ..writeByte(7)
      ..write(obj.categoryName)
      ..writeByte(8)
      ..write(obj.attributes)
      ..writeByte(9)
      ..write(obj.address)
      ..writeByte(10)
      ..write(obj.openHours)
      ..writeByte(11)
      ..write(obj.websiteUrl)
      ..writeByte(12)
      ..write(obj.phoneNumber)
      ..writeByte(13)
      ..write(obj.imageUrl)
      ..writeByte(14)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
