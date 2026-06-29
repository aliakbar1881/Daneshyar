// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_review.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserReviewAdapter extends TypeAdapter<UserReview> {
  @override
  final int typeId = 1;

  @override
  UserReview read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserReview(
      articleId: fields[0] as String,
      rating: fields[1] as int,
      notes: fields[2] as String,
      pros: (fields[3] as List).cast<String>(),
      cons: (fields[4] as List).cast<String>(),
      createdAt: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, UserReview obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.articleId)
      ..writeByte(1)
      ..write(obj.rating)
      ..writeByte(2)
      ..write(obj.notes)
      ..writeByte(3)
      ..write(obj.pros)
      ..writeByte(4)
      ..write(obj.cons)
      ..writeByte(5)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserReviewAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
