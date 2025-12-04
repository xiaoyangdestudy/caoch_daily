// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reading_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ReadingRecord _$ReadingRecordFromJson(Map<String, dynamic> json) {
  return _ReadingRecord.fromJson(json);
}

/// @nodoc
mixin _$ReadingRecord {
  String get id => throw _privateConstructorUsedError;
  String get bookTitle => throw _privateConstructorUsedError;
  String? get bookAuthor => throw _privateConstructorUsedError;
  DateTime get startTime => throw _privateConstructorUsedError;
  int get durationMinutes => throw _privateConstructorUsedError;
  int? get pagesRead => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  String? get excerpt => throw _privateConstructorUsedError;
  String? get aiSummary => throw _privateConstructorUsedError;

  /// Serializes this ReadingRecord to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReadingRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReadingRecordCopyWith<ReadingRecord> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReadingRecordCopyWith<$Res> {
  factory $ReadingRecordCopyWith(
    ReadingRecord value,
    $Res Function(ReadingRecord) then,
  ) = _$ReadingRecordCopyWithImpl<$Res, ReadingRecord>;
  @useResult
  $Res call({
    String id,
    String bookTitle,
    String? bookAuthor,
    DateTime startTime,
    int durationMinutes,
    int? pagesRead,
    String? notes,
    String? excerpt,
    String? aiSummary,
  });
}

/// @nodoc
class _$ReadingRecordCopyWithImpl<$Res, $Val extends ReadingRecord>
    implements $ReadingRecordCopyWith<$Res> {
  _$ReadingRecordCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReadingRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? bookTitle = null,
    Object? bookAuthor = freezed,
    Object? startTime = null,
    Object? durationMinutes = null,
    Object? pagesRead = freezed,
    Object? notes = freezed,
    Object? excerpt = freezed,
    Object? aiSummary = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            bookTitle: null == bookTitle
                ? _value.bookTitle
                : bookTitle // ignore: cast_nullable_to_non_nullable
                      as String,
            bookAuthor: freezed == bookAuthor
                ? _value.bookAuthor
                : bookAuthor // ignore: cast_nullable_to_non_nullable
                      as String?,
            startTime: null == startTime
                ? _value.startTime
                : startTime // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            durationMinutes: null == durationMinutes
                ? _value.durationMinutes
                : durationMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
            pagesRead: freezed == pagesRead
                ? _value.pagesRead
                : pagesRead // ignore: cast_nullable_to_non_nullable
                      as int?,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
            excerpt: freezed == excerpt
                ? _value.excerpt
                : excerpt // ignore: cast_nullable_to_non_nullable
                      as String?,
            aiSummary: freezed == aiSummary
                ? _value.aiSummary
                : aiSummary // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ReadingRecordImplCopyWith<$Res>
    implements $ReadingRecordCopyWith<$Res> {
  factory _$$ReadingRecordImplCopyWith(
    _$ReadingRecordImpl value,
    $Res Function(_$ReadingRecordImpl) then,
  ) = __$$ReadingRecordImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String bookTitle,
    String? bookAuthor,
    DateTime startTime,
    int durationMinutes,
    int? pagesRead,
    String? notes,
    String? excerpt,
    String? aiSummary,
  });
}

/// @nodoc
class __$$ReadingRecordImplCopyWithImpl<$Res>
    extends _$ReadingRecordCopyWithImpl<$Res, _$ReadingRecordImpl>
    implements _$$ReadingRecordImplCopyWith<$Res> {
  __$$ReadingRecordImplCopyWithImpl(
    _$ReadingRecordImpl _value,
    $Res Function(_$ReadingRecordImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ReadingRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? bookTitle = null,
    Object? bookAuthor = freezed,
    Object? startTime = null,
    Object? durationMinutes = null,
    Object? pagesRead = freezed,
    Object? notes = freezed,
    Object? excerpt = freezed,
    Object? aiSummary = freezed,
  }) {
    return _then(
      _$ReadingRecordImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        bookTitle: null == bookTitle
            ? _value.bookTitle
            : bookTitle // ignore: cast_nullable_to_non_nullable
                  as String,
        bookAuthor: freezed == bookAuthor
            ? _value.bookAuthor
            : bookAuthor // ignore: cast_nullable_to_non_nullable
                  as String?,
        startTime: null == startTime
            ? _value.startTime
            : startTime // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        durationMinutes: null == durationMinutes
            ? _value.durationMinutes
            : durationMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
        pagesRead: freezed == pagesRead
            ? _value.pagesRead
            : pagesRead // ignore: cast_nullable_to_non_nullable
                  as int?,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
        excerpt: freezed == excerpt
            ? _value.excerpt
            : excerpt // ignore: cast_nullable_to_non_nullable
                  as String?,
        aiSummary: freezed == aiSummary
            ? _value.aiSummary
            : aiSummary // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ReadingRecordImpl implements _ReadingRecord {
  const _$ReadingRecordImpl({
    required this.id,
    required this.bookTitle,
    this.bookAuthor,
    required this.startTime,
    required this.durationMinutes,
    this.pagesRead,
    this.notes,
    this.excerpt,
    this.aiSummary,
  });

  factory _$ReadingRecordImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReadingRecordImplFromJson(json);

  @override
  final String id;
  @override
  final String bookTitle;
  @override
  final String? bookAuthor;
  @override
  final DateTime startTime;
  @override
  final int durationMinutes;
  @override
  final int? pagesRead;
  @override
  final String? notes;
  @override
  final String? excerpt;
  @override
  final String? aiSummary;

  @override
  String toString() {
    return 'ReadingRecord(id: $id, bookTitle: $bookTitle, bookAuthor: $bookAuthor, startTime: $startTime, durationMinutes: $durationMinutes, pagesRead: $pagesRead, notes: $notes, excerpt: $excerpt, aiSummary: $aiSummary)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReadingRecordImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.bookTitle, bookTitle) ||
                other.bookTitle == bookTitle) &&
            (identical(other.bookAuthor, bookAuthor) ||
                other.bookAuthor == bookAuthor) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.durationMinutes, durationMinutes) ||
                other.durationMinutes == durationMinutes) &&
            (identical(other.pagesRead, pagesRead) ||
                other.pagesRead == pagesRead) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.excerpt, excerpt) || other.excerpt == excerpt) &&
            (identical(other.aiSummary, aiSummary) ||
                other.aiSummary == aiSummary));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    bookTitle,
    bookAuthor,
    startTime,
    durationMinutes,
    pagesRead,
    notes,
    excerpt,
    aiSummary,
  );

  /// Create a copy of ReadingRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReadingRecordImplCopyWith<_$ReadingRecordImpl> get copyWith =>
      __$$ReadingRecordImplCopyWithImpl<_$ReadingRecordImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReadingRecordImplToJson(this);
  }
}

abstract class _ReadingRecord implements ReadingRecord {
  const factory _ReadingRecord({
    required final String id,
    required final String bookTitle,
    final String? bookAuthor,
    required final DateTime startTime,
    required final int durationMinutes,
    final int? pagesRead,
    final String? notes,
    final String? excerpt,
    final String? aiSummary,
  }) = _$ReadingRecordImpl;

  factory _ReadingRecord.fromJson(Map<String, dynamic> json) =
      _$ReadingRecordImpl.fromJson;

  @override
  String get id;
  @override
  String get bookTitle;
  @override
  String? get bookAuthor;
  @override
  DateTime get startTime;
  @override
  int get durationMinutes;
  @override
  int? get pagesRead;
  @override
  String? get notes;
  @override
  String? get excerpt;
  @override
  String? get aiSummary;

  /// Create a copy of ReadingRecord
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReadingRecordImplCopyWith<_$ReadingRecordImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
