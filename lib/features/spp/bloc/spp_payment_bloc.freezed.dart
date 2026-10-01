// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'spp_payment_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$SppPaymentEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      int studentId,
      List<String> billIds,
      num totalAmount,
      List<int> proofBytes,
      String proofFilename,
      String? bankName,
      String? accountHolder,
    )
    submitTransfer,
    required TResult Function(
      int studentId,
      List<String> billIds,
      num totalAmount,
    )
    submitCash,
    required TResult Function() reset,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
      int studentId,
      List<String> billIds,
      num totalAmount,
      List<int> proofBytes,
      String proofFilename,
      String? bankName,
      String? accountHolder,
    )?
    submitTransfer,
    TResult? Function(int studentId, List<String> billIds, num totalAmount)?
    submitCash,
    TResult? Function()? reset,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
      int studentId,
      List<String> billIds,
      num totalAmount,
      List<int> proofBytes,
      String proofFilename,
      String? bankName,
      String? accountHolder,
    )?
    submitTransfer,
    TResult Function(int studentId, List<String> billIds, num totalAmount)?
    submitCash,
    TResult Function()? reset,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SppPaymentSubmitTransfer value) submitTransfer,
    required TResult Function(SppPaymentSubmitCash value) submitCash,
    required TResult Function(SppPaymentReset value) reset,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SppPaymentSubmitTransfer value)? submitTransfer,
    TResult? Function(SppPaymentSubmitCash value)? submitCash,
    TResult? Function(SppPaymentReset value)? reset,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SppPaymentSubmitTransfer value)? submitTransfer,
    TResult Function(SppPaymentSubmitCash value)? submitCash,
    TResult Function(SppPaymentReset value)? reset,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SppPaymentEventCopyWith<$Res> {
  factory $SppPaymentEventCopyWith(
    SppPaymentEvent value,
    $Res Function(SppPaymentEvent) then,
  ) = _$SppPaymentEventCopyWithImpl<$Res, SppPaymentEvent>;
}

/// @nodoc
class _$SppPaymentEventCopyWithImpl<$Res, $Val extends SppPaymentEvent>
    implements $SppPaymentEventCopyWith<$Res> {
  _$SppPaymentEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SppPaymentEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$SppPaymentSubmitTransferImplCopyWith<$Res> {
  factory _$$SppPaymentSubmitTransferImplCopyWith(
    _$SppPaymentSubmitTransferImpl value,
    $Res Function(_$SppPaymentSubmitTransferImpl) then,
  ) = __$$SppPaymentSubmitTransferImplCopyWithImpl<$Res>;
  @useResult
  $Res call({
    int studentId,
    List<String> billIds,
    num totalAmount,
    List<int> proofBytes,
    String proofFilename,
    String? bankName,
    String? accountHolder,
  });
}

/// @nodoc
class __$$SppPaymentSubmitTransferImplCopyWithImpl<$Res>
    extends _$SppPaymentEventCopyWithImpl<$Res, _$SppPaymentSubmitTransferImpl>
    implements _$$SppPaymentSubmitTransferImplCopyWith<$Res> {
  __$$SppPaymentSubmitTransferImplCopyWithImpl(
    _$SppPaymentSubmitTransferImpl _value,
    $Res Function(_$SppPaymentSubmitTransferImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SppPaymentEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? studentId = null,
    Object? billIds = null,
    Object? totalAmount = null,
    Object? proofBytes = null,
    Object? proofFilename = null,
    Object? bankName = freezed,
    Object? accountHolder = freezed,
  }) {
    return _then(
      _$SppPaymentSubmitTransferImpl(
        studentId: null == studentId
            ? _value.studentId
            : studentId // ignore: cast_nullable_to_non_nullable
                  as int,
        billIds: null == billIds
            ? _value._billIds
            : billIds // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        totalAmount: null == totalAmount
            ? _value.totalAmount
            : totalAmount // ignore: cast_nullable_to_non_nullable
                  as num,
        proofBytes: null == proofBytes
            ? _value._proofBytes
            : proofBytes // ignore: cast_nullable_to_non_nullable
                  as List<int>,
        proofFilename: null == proofFilename
            ? _value.proofFilename
            : proofFilename // ignore: cast_nullable_to_non_nullable
                  as String,
        bankName: freezed == bankName
            ? _value.bankName
            : bankName // ignore: cast_nullable_to_non_nullable
                  as String?,
        accountHolder: freezed == accountHolder
            ? _value.accountHolder
            : accountHolder // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$SppPaymentSubmitTransferImpl implements SppPaymentSubmitTransfer {
  const _$SppPaymentSubmitTransferImpl({
    required this.studentId,
    required final List<String> billIds,
    required this.totalAmount,
    required final List<int> proofBytes,
    required this.proofFilename,
    this.bankName,
    this.accountHolder,
  }) : _billIds = billIds,
       _proofBytes = proofBytes;

  @override
  final int studentId;
  final List<String> _billIds;
  @override
  List<String> get billIds {
    if (_billIds is EqualUnmodifiableListView) return _billIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_billIds);
  }

  @override
  final num totalAmount;
  final List<int> _proofBytes;
  @override
  List<int> get proofBytes {
    if (_proofBytes is EqualUnmodifiableListView) return _proofBytes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_proofBytes);
  }

  @override
  final String proofFilename;
  @override
  final String? bankName;
  @override
  final String? accountHolder;

  @override
  String toString() {
    return 'SppPaymentEvent.submitTransfer(studentId: $studentId, billIds: $billIds, totalAmount: $totalAmount, proofBytes: $proofBytes, proofFilename: $proofFilename, bankName: $bankName, accountHolder: $accountHolder)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SppPaymentSubmitTransferImpl &&
            (identical(other.studentId, studentId) ||
                other.studentId == studentId) &&
            const DeepCollectionEquality().equals(other._billIds, _billIds) &&
            (identical(other.totalAmount, totalAmount) ||
                other.totalAmount == totalAmount) &&
            const DeepCollectionEquality().equals(
              other._proofBytes,
              _proofBytes,
            ) &&
            (identical(other.proofFilename, proofFilename) ||
                other.proofFilename == proofFilename) &&
            (identical(other.bankName, bankName) ||
                other.bankName == bankName) &&
            (identical(other.accountHolder, accountHolder) ||
                other.accountHolder == accountHolder));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    studentId,
    const DeepCollectionEquality().hash(_billIds),
    totalAmount,
    const DeepCollectionEquality().hash(_proofBytes),
    proofFilename,
    bankName,
    accountHolder,
  );

  /// Create a copy of SppPaymentEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SppPaymentSubmitTransferImplCopyWith<_$SppPaymentSubmitTransferImpl>
  get copyWith =>
      __$$SppPaymentSubmitTransferImplCopyWithImpl<
        _$SppPaymentSubmitTransferImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      int studentId,
      List<String> billIds,
      num totalAmount,
      List<int> proofBytes,
      String proofFilename,
      String? bankName,
      String? accountHolder,
    )
    submitTransfer,
    required TResult Function(
      int studentId,
      List<String> billIds,
      num totalAmount,
    )
    submitCash,
    required TResult Function() reset,
  }) {
    return submitTransfer(
      studentId,
      billIds,
      totalAmount,
      proofBytes,
      proofFilename,
      bankName,
      accountHolder,
    );
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
      int studentId,
      List<String> billIds,
      num totalAmount,
      List<int> proofBytes,
      String proofFilename,
      String? bankName,
      String? accountHolder,
    )?
    submitTransfer,
    TResult? Function(int studentId, List<String> billIds, num totalAmount)?
    submitCash,
    TResult? Function()? reset,
  }) {
    return submitTransfer?.call(
      studentId,
      billIds,
      totalAmount,
      proofBytes,
      proofFilename,
      bankName,
      accountHolder,
    );
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
      int studentId,
      List<String> billIds,
      num totalAmount,
      List<int> proofBytes,
      String proofFilename,
      String? bankName,
      String? accountHolder,
    )?
    submitTransfer,
    TResult Function(int studentId, List<String> billIds, num totalAmount)?
    submitCash,
    TResult Function()? reset,
    required TResult orElse(),
  }) {
    if (submitTransfer != null) {
      return submitTransfer(
        studentId,
        billIds,
        totalAmount,
        proofBytes,
        proofFilename,
        bankName,
        accountHolder,
      );
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SppPaymentSubmitTransfer value) submitTransfer,
    required TResult Function(SppPaymentSubmitCash value) submitCash,
    required TResult Function(SppPaymentReset value) reset,
  }) {
    return submitTransfer(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SppPaymentSubmitTransfer value)? submitTransfer,
    TResult? Function(SppPaymentSubmitCash value)? submitCash,
    TResult? Function(SppPaymentReset value)? reset,
  }) {
    return submitTransfer?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SppPaymentSubmitTransfer value)? submitTransfer,
    TResult Function(SppPaymentSubmitCash value)? submitCash,
    TResult Function(SppPaymentReset value)? reset,
    required TResult orElse(),
  }) {
    if (submitTransfer != null) {
      return submitTransfer(this);
    }
    return orElse();
  }
}

abstract class SppPaymentSubmitTransfer implements SppPaymentEvent {
  const factory SppPaymentSubmitTransfer({
    required final int studentId,
    required final List<String> billIds,
    required final num totalAmount,
    required final List<int> proofBytes,
    required final String proofFilename,
    final String? bankName,
    final String? accountHolder,
  }) = _$SppPaymentSubmitTransferImpl;

  int get studentId;
  List<String> get billIds;
  num get totalAmount;
  List<int> get proofBytes;
  String get proofFilename;
  String? get bankName;
  String? get accountHolder;

  /// Create a copy of SppPaymentEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SppPaymentSubmitTransferImplCopyWith<_$SppPaymentSubmitTransferImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$SppPaymentSubmitCashImplCopyWith<$Res> {
  factory _$$SppPaymentSubmitCashImplCopyWith(
    _$SppPaymentSubmitCashImpl value,
    $Res Function(_$SppPaymentSubmitCashImpl) then,
  ) = __$$SppPaymentSubmitCashImplCopyWithImpl<$Res>;
  @useResult
  $Res call({int studentId, List<String> billIds, num totalAmount});
}

/// @nodoc
class __$$SppPaymentSubmitCashImplCopyWithImpl<$Res>
    extends _$SppPaymentEventCopyWithImpl<$Res, _$SppPaymentSubmitCashImpl>
    implements _$$SppPaymentSubmitCashImplCopyWith<$Res> {
  __$$SppPaymentSubmitCashImplCopyWithImpl(
    _$SppPaymentSubmitCashImpl _value,
    $Res Function(_$SppPaymentSubmitCashImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SppPaymentEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? studentId = null,
    Object? billIds = null,
    Object? totalAmount = null,
  }) {
    return _then(
      _$SppPaymentSubmitCashImpl(
        studentId: null == studentId
            ? _value.studentId
            : studentId // ignore: cast_nullable_to_non_nullable
                  as int,
        billIds: null == billIds
            ? _value._billIds
            : billIds // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        totalAmount: null == totalAmount
            ? _value.totalAmount
            : totalAmount // ignore: cast_nullable_to_non_nullable
                  as num,
      ),
    );
  }
}

/// @nodoc

class _$SppPaymentSubmitCashImpl implements SppPaymentSubmitCash {
  const _$SppPaymentSubmitCashImpl({
    required this.studentId,
    required final List<String> billIds,
    required this.totalAmount,
  }) : _billIds = billIds;

  @override
  final int studentId;
  final List<String> _billIds;
  @override
  List<String> get billIds {
    if (_billIds is EqualUnmodifiableListView) return _billIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_billIds);
  }

  @override
  final num totalAmount;

  @override
  String toString() {
    return 'SppPaymentEvent.submitCash(studentId: $studentId, billIds: $billIds, totalAmount: $totalAmount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SppPaymentSubmitCashImpl &&
            (identical(other.studentId, studentId) ||
                other.studentId == studentId) &&
            const DeepCollectionEquality().equals(other._billIds, _billIds) &&
            (identical(other.totalAmount, totalAmount) ||
                other.totalAmount == totalAmount));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    studentId,
    const DeepCollectionEquality().hash(_billIds),
    totalAmount,
  );

  /// Create a copy of SppPaymentEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SppPaymentSubmitCashImplCopyWith<_$SppPaymentSubmitCashImpl>
  get copyWith =>
      __$$SppPaymentSubmitCashImplCopyWithImpl<_$SppPaymentSubmitCashImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      int studentId,
      List<String> billIds,
      num totalAmount,
      List<int> proofBytes,
      String proofFilename,
      String? bankName,
      String? accountHolder,
    )
    submitTransfer,
    required TResult Function(
      int studentId,
      List<String> billIds,
      num totalAmount,
    )
    submitCash,
    required TResult Function() reset,
  }) {
    return submitCash(studentId, billIds, totalAmount);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
      int studentId,
      List<String> billIds,
      num totalAmount,
      List<int> proofBytes,
      String proofFilename,
      String? bankName,
      String? accountHolder,
    )?
    submitTransfer,
    TResult? Function(int studentId, List<String> billIds, num totalAmount)?
    submitCash,
    TResult? Function()? reset,
  }) {
    return submitCash?.call(studentId, billIds, totalAmount);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
      int studentId,
      List<String> billIds,
      num totalAmount,
      List<int> proofBytes,
      String proofFilename,
      String? bankName,
      String? accountHolder,
    )?
    submitTransfer,
    TResult Function(int studentId, List<String> billIds, num totalAmount)?
    submitCash,
    TResult Function()? reset,
    required TResult orElse(),
  }) {
    if (submitCash != null) {
      return submitCash(studentId, billIds, totalAmount);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SppPaymentSubmitTransfer value) submitTransfer,
    required TResult Function(SppPaymentSubmitCash value) submitCash,
    required TResult Function(SppPaymentReset value) reset,
  }) {
    return submitCash(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SppPaymentSubmitTransfer value)? submitTransfer,
    TResult? Function(SppPaymentSubmitCash value)? submitCash,
    TResult? Function(SppPaymentReset value)? reset,
  }) {
    return submitCash?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SppPaymentSubmitTransfer value)? submitTransfer,
    TResult Function(SppPaymentSubmitCash value)? submitCash,
    TResult Function(SppPaymentReset value)? reset,
    required TResult orElse(),
  }) {
    if (submitCash != null) {
      return submitCash(this);
    }
    return orElse();
  }
}

abstract class SppPaymentSubmitCash implements SppPaymentEvent {
  const factory SppPaymentSubmitCash({
    required final int studentId,
    required final List<String> billIds,
    required final num totalAmount,
  }) = _$SppPaymentSubmitCashImpl;

  int get studentId;
  List<String> get billIds;
  num get totalAmount;

  /// Create a copy of SppPaymentEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SppPaymentSubmitCashImplCopyWith<_$SppPaymentSubmitCashImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$SppPaymentResetImplCopyWith<$Res> {
  factory _$$SppPaymentResetImplCopyWith(
    _$SppPaymentResetImpl value,
    $Res Function(_$SppPaymentResetImpl) then,
  ) = __$$SppPaymentResetImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$SppPaymentResetImplCopyWithImpl<$Res>
    extends _$SppPaymentEventCopyWithImpl<$Res, _$SppPaymentResetImpl>
    implements _$$SppPaymentResetImplCopyWith<$Res> {
  __$$SppPaymentResetImplCopyWithImpl(
    _$SppPaymentResetImpl _value,
    $Res Function(_$SppPaymentResetImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SppPaymentEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$SppPaymentResetImpl implements SppPaymentReset {
  const _$SppPaymentResetImpl();

  @override
  String toString() {
    return 'SppPaymentEvent.reset()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$SppPaymentResetImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      int studentId,
      List<String> billIds,
      num totalAmount,
      List<int> proofBytes,
      String proofFilename,
      String? bankName,
      String? accountHolder,
    )
    submitTransfer,
    required TResult Function(
      int studentId,
      List<String> billIds,
      num totalAmount,
    )
    submitCash,
    required TResult Function() reset,
  }) {
    return reset();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
      int studentId,
      List<String> billIds,
      num totalAmount,
      List<int> proofBytes,
      String proofFilename,
      String? bankName,
      String? accountHolder,
    )?
    submitTransfer,
    TResult? Function(int studentId, List<String> billIds, num totalAmount)?
    submitCash,
    TResult? Function()? reset,
  }) {
    return reset?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
      int studentId,
      List<String> billIds,
      num totalAmount,
      List<int> proofBytes,
      String proofFilename,
      String? bankName,
      String? accountHolder,
    )?
    submitTransfer,
    TResult Function(int studentId, List<String> billIds, num totalAmount)?
    submitCash,
    TResult Function()? reset,
    required TResult orElse(),
  }) {
    if (reset != null) {
      return reset();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SppPaymentSubmitTransfer value) submitTransfer,
    required TResult Function(SppPaymentSubmitCash value) submitCash,
    required TResult Function(SppPaymentReset value) reset,
  }) {
    return reset(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SppPaymentSubmitTransfer value)? submitTransfer,
    TResult? Function(SppPaymentSubmitCash value)? submitCash,
    TResult? Function(SppPaymentReset value)? reset,
  }) {
    return reset?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SppPaymentSubmitTransfer value)? submitTransfer,
    TResult Function(SppPaymentSubmitCash value)? submitCash,
    TResult Function(SppPaymentReset value)? reset,
    required TResult orElse(),
  }) {
    if (reset != null) {
      return reset(this);
    }
    return orElse();
  }
}

abstract class SppPaymentReset implements SppPaymentEvent {
  const factory SppPaymentReset() = _$SppPaymentResetImpl;
}

/// @nodoc
mixin _$SppPaymentState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() submitting,
    required TResult Function(String paymentId, String? message) success,
    required TResult Function(String message) failure,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? submitting,
    TResult? Function(String paymentId, String? message)? success,
    TResult? Function(String message)? failure,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? submitting,
    TResult Function(String paymentId, String? message)? success,
    TResult Function(String message)? failure,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SppPaymentInitial value) initial,
    required TResult Function(SppPaymentSubmitting value) submitting,
    required TResult Function(SppPaymentSuccess value) success,
    required TResult Function(SppPaymentFailure value) failure,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SppPaymentInitial value)? initial,
    TResult? Function(SppPaymentSubmitting value)? submitting,
    TResult? Function(SppPaymentSuccess value)? success,
    TResult? Function(SppPaymentFailure value)? failure,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SppPaymentInitial value)? initial,
    TResult Function(SppPaymentSubmitting value)? submitting,
    TResult Function(SppPaymentSuccess value)? success,
    TResult Function(SppPaymentFailure value)? failure,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SppPaymentStateCopyWith<$Res> {
  factory $SppPaymentStateCopyWith(
    SppPaymentState value,
    $Res Function(SppPaymentState) then,
  ) = _$SppPaymentStateCopyWithImpl<$Res, SppPaymentState>;
}

/// @nodoc
class _$SppPaymentStateCopyWithImpl<$Res, $Val extends SppPaymentState>
    implements $SppPaymentStateCopyWith<$Res> {
  _$SppPaymentStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SppPaymentState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$SppPaymentInitialImplCopyWith<$Res> {
  factory _$$SppPaymentInitialImplCopyWith(
    _$SppPaymentInitialImpl value,
    $Res Function(_$SppPaymentInitialImpl) then,
  ) = __$$SppPaymentInitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$SppPaymentInitialImplCopyWithImpl<$Res>
    extends _$SppPaymentStateCopyWithImpl<$Res, _$SppPaymentInitialImpl>
    implements _$$SppPaymentInitialImplCopyWith<$Res> {
  __$$SppPaymentInitialImplCopyWithImpl(
    _$SppPaymentInitialImpl _value,
    $Res Function(_$SppPaymentInitialImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SppPaymentState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$SppPaymentInitialImpl extends SppPaymentInitial {
  const _$SppPaymentInitialImpl() : super._();

  @override
  String toString() {
    return 'SppPaymentState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$SppPaymentInitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() submitting,
    required TResult Function(String paymentId, String? message) success,
    required TResult Function(String message) failure,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? submitting,
    TResult? Function(String paymentId, String? message)? success,
    TResult? Function(String message)? failure,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? submitting,
    TResult Function(String paymentId, String? message)? success,
    TResult Function(String message)? failure,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SppPaymentInitial value) initial,
    required TResult Function(SppPaymentSubmitting value) submitting,
    required TResult Function(SppPaymentSuccess value) success,
    required TResult Function(SppPaymentFailure value) failure,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SppPaymentInitial value)? initial,
    TResult? Function(SppPaymentSubmitting value)? submitting,
    TResult? Function(SppPaymentSuccess value)? success,
    TResult? Function(SppPaymentFailure value)? failure,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SppPaymentInitial value)? initial,
    TResult Function(SppPaymentSubmitting value)? submitting,
    TResult Function(SppPaymentSuccess value)? success,
    TResult Function(SppPaymentFailure value)? failure,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class SppPaymentInitial extends SppPaymentState {
  const factory SppPaymentInitial() = _$SppPaymentInitialImpl;
  const SppPaymentInitial._() : super._();
}

/// @nodoc
abstract class _$$SppPaymentSubmittingImplCopyWith<$Res> {
  factory _$$SppPaymentSubmittingImplCopyWith(
    _$SppPaymentSubmittingImpl value,
    $Res Function(_$SppPaymentSubmittingImpl) then,
  ) = __$$SppPaymentSubmittingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$SppPaymentSubmittingImplCopyWithImpl<$Res>
    extends _$SppPaymentStateCopyWithImpl<$Res, _$SppPaymentSubmittingImpl>
    implements _$$SppPaymentSubmittingImplCopyWith<$Res> {
  __$$SppPaymentSubmittingImplCopyWithImpl(
    _$SppPaymentSubmittingImpl _value,
    $Res Function(_$SppPaymentSubmittingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SppPaymentState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$SppPaymentSubmittingImpl extends SppPaymentSubmitting {
  const _$SppPaymentSubmittingImpl() : super._();

  @override
  String toString() {
    return 'SppPaymentState.submitting()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SppPaymentSubmittingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() submitting,
    required TResult Function(String paymentId, String? message) success,
    required TResult Function(String message) failure,
  }) {
    return submitting();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? submitting,
    TResult? Function(String paymentId, String? message)? success,
    TResult? Function(String message)? failure,
  }) {
    return submitting?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? submitting,
    TResult Function(String paymentId, String? message)? success,
    TResult Function(String message)? failure,
    required TResult orElse(),
  }) {
    if (submitting != null) {
      return submitting();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SppPaymentInitial value) initial,
    required TResult Function(SppPaymentSubmitting value) submitting,
    required TResult Function(SppPaymentSuccess value) success,
    required TResult Function(SppPaymentFailure value) failure,
  }) {
    return submitting(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SppPaymentInitial value)? initial,
    TResult? Function(SppPaymentSubmitting value)? submitting,
    TResult? Function(SppPaymentSuccess value)? success,
    TResult? Function(SppPaymentFailure value)? failure,
  }) {
    return submitting?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SppPaymentInitial value)? initial,
    TResult Function(SppPaymentSubmitting value)? submitting,
    TResult Function(SppPaymentSuccess value)? success,
    TResult Function(SppPaymentFailure value)? failure,
    required TResult orElse(),
  }) {
    if (submitting != null) {
      return submitting(this);
    }
    return orElse();
  }
}

abstract class SppPaymentSubmitting extends SppPaymentState {
  const factory SppPaymentSubmitting() = _$SppPaymentSubmittingImpl;
  const SppPaymentSubmitting._() : super._();
}

/// @nodoc
abstract class _$$SppPaymentSuccessImplCopyWith<$Res> {
  factory _$$SppPaymentSuccessImplCopyWith(
    _$SppPaymentSuccessImpl value,
    $Res Function(_$SppPaymentSuccessImpl) then,
  ) = __$$SppPaymentSuccessImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String paymentId, String? message});
}

/// @nodoc
class __$$SppPaymentSuccessImplCopyWithImpl<$Res>
    extends _$SppPaymentStateCopyWithImpl<$Res, _$SppPaymentSuccessImpl>
    implements _$$SppPaymentSuccessImplCopyWith<$Res> {
  __$$SppPaymentSuccessImplCopyWithImpl(
    _$SppPaymentSuccessImpl _value,
    $Res Function(_$SppPaymentSuccessImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SppPaymentState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? paymentId = null, Object? message = freezed}) {
    return _then(
      _$SppPaymentSuccessImpl(
        paymentId: null == paymentId
            ? _value.paymentId
            : paymentId // ignore: cast_nullable_to_non_nullable
                  as String,
        message: freezed == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$SppPaymentSuccessImpl extends SppPaymentSuccess {
  const _$SppPaymentSuccessImpl({required this.paymentId, this.message})
    : super._();

  @override
  final String paymentId;
  @override
  final String? message;

  @override
  String toString() {
    return 'SppPaymentState.success(paymentId: $paymentId, message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SppPaymentSuccessImpl &&
            (identical(other.paymentId, paymentId) ||
                other.paymentId == paymentId) &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, paymentId, message);

  /// Create a copy of SppPaymentState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SppPaymentSuccessImplCopyWith<_$SppPaymentSuccessImpl> get copyWith =>
      __$$SppPaymentSuccessImplCopyWithImpl<_$SppPaymentSuccessImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() submitting,
    required TResult Function(String paymentId, String? message) success,
    required TResult Function(String message) failure,
  }) {
    return success(paymentId, message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? submitting,
    TResult? Function(String paymentId, String? message)? success,
    TResult? Function(String message)? failure,
  }) {
    return success?.call(paymentId, message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? submitting,
    TResult Function(String paymentId, String? message)? success,
    TResult Function(String message)? failure,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(paymentId, message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SppPaymentInitial value) initial,
    required TResult Function(SppPaymentSubmitting value) submitting,
    required TResult Function(SppPaymentSuccess value) success,
    required TResult Function(SppPaymentFailure value) failure,
  }) {
    return success(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SppPaymentInitial value)? initial,
    TResult? Function(SppPaymentSubmitting value)? submitting,
    TResult? Function(SppPaymentSuccess value)? success,
    TResult? Function(SppPaymentFailure value)? failure,
  }) {
    return success?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SppPaymentInitial value)? initial,
    TResult Function(SppPaymentSubmitting value)? submitting,
    TResult Function(SppPaymentSuccess value)? success,
    TResult Function(SppPaymentFailure value)? failure,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(this);
    }
    return orElse();
  }
}

abstract class SppPaymentSuccess extends SppPaymentState {
  const factory SppPaymentSuccess({
    required final String paymentId,
    final String? message,
  }) = _$SppPaymentSuccessImpl;
  const SppPaymentSuccess._() : super._();

  String get paymentId;
  String? get message;

  /// Create a copy of SppPaymentState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SppPaymentSuccessImplCopyWith<_$SppPaymentSuccessImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$SppPaymentFailureImplCopyWith<$Res> {
  factory _$$SppPaymentFailureImplCopyWith(
    _$SppPaymentFailureImpl value,
    $Res Function(_$SppPaymentFailureImpl) then,
  ) = __$$SppPaymentFailureImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$SppPaymentFailureImplCopyWithImpl<$Res>
    extends _$SppPaymentStateCopyWithImpl<$Res, _$SppPaymentFailureImpl>
    implements _$$SppPaymentFailureImplCopyWith<$Res> {
  __$$SppPaymentFailureImplCopyWithImpl(
    _$SppPaymentFailureImpl _value,
    $Res Function(_$SppPaymentFailureImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SppPaymentState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null}) {
    return _then(
      _$SppPaymentFailureImpl(
        null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$SppPaymentFailureImpl extends SppPaymentFailure {
  const _$SppPaymentFailureImpl(this.message) : super._();

  @override
  final String message;

  @override
  String toString() {
    return 'SppPaymentState.failure(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SppPaymentFailureImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of SppPaymentState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SppPaymentFailureImplCopyWith<_$SppPaymentFailureImpl> get copyWith =>
      __$$SppPaymentFailureImplCopyWithImpl<_$SppPaymentFailureImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() submitting,
    required TResult Function(String paymentId, String? message) success,
    required TResult Function(String message) failure,
  }) {
    return failure(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? submitting,
    TResult? Function(String paymentId, String? message)? success,
    TResult? Function(String message)? failure,
  }) {
    return failure?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? submitting,
    TResult Function(String paymentId, String? message)? success,
    TResult Function(String message)? failure,
    required TResult orElse(),
  }) {
    if (failure != null) {
      return failure(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SppPaymentInitial value) initial,
    required TResult Function(SppPaymentSubmitting value) submitting,
    required TResult Function(SppPaymentSuccess value) success,
    required TResult Function(SppPaymentFailure value) failure,
  }) {
    return failure(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SppPaymentInitial value)? initial,
    TResult? Function(SppPaymentSubmitting value)? submitting,
    TResult? Function(SppPaymentSuccess value)? success,
    TResult? Function(SppPaymentFailure value)? failure,
  }) {
    return failure?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SppPaymentInitial value)? initial,
    TResult Function(SppPaymentSubmitting value)? submitting,
    TResult Function(SppPaymentSuccess value)? success,
    TResult Function(SppPaymentFailure value)? failure,
    required TResult orElse(),
  }) {
    if (failure != null) {
      return failure(this);
    }
    return orElse();
  }
}

abstract class SppPaymentFailure extends SppPaymentState {
  const factory SppPaymentFailure(final String message) =
      _$SppPaymentFailureImpl;
  const SppPaymentFailure._() : super._();

  String get message;

  /// Create a copy of SppPaymentState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SppPaymentFailureImplCopyWith<_$SppPaymentFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
