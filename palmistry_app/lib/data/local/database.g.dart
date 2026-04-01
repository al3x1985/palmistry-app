// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $PalmScansTable extends PalmScans
    with TableInfo<$PalmScansTable, PalmScan> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PalmScansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _handMeta = const VerificationMeta('hand');
  @override
  late final GeneratedColumn<String> hand = GeneratedColumn<String>(
    'hand',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _imagePathMeta = const VerificationMeta(
    'imagePath',
  );
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
    'image_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _palmShapeMeta = const VerificationMeta(
    'palmShape',
  );
  @override
  late final GeneratedColumn<String> palmShape = GeneratedColumn<String>(
    'palm_shape',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _palmWidthRatioMeta = const VerificationMeta(
    'palmWidthRatio',
  );
  @override
  late final GeneratedColumn<double> palmWidthRatio = GeneratedColumn<double>(
    'palm_width_ratio',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fingerProportionsJsonMeta =
      const VerificationMeta('fingerProportionsJson');
  @override
  late final GeneratedColumn<String> fingerProportionsJson =
      GeneratedColumn<String>(
        'finger_proportions_json',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('processing'),
  );
  static const VerificationMeta _aiInterpretationJsonMeta =
      const VerificationMeta('aiInterpretationJson');
  @override
  late final GeneratedColumn<String> aiInterpretationJson =
      GeneratedColumn<String>(
        'ai_interpretation_json',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    hand,
    imagePath,
    palmShape,
    palmWidthRatio,
    fingerProportionsJson,
    status,
    aiInterpretationJson,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'palm_scans';
  @override
  VerificationContext validateIntegrity(
    Insertable<PalmScan> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('hand')) {
      context.handle(
        _handMeta,
        hand.isAcceptableOrUnknown(data['hand']!, _handMeta),
      );
    } else if (isInserting) {
      context.missing(_handMeta);
    }
    if (data.containsKey('image_path')) {
      context.handle(
        _imagePathMeta,
        imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta),
      );
    } else if (isInserting) {
      context.missing(_imagePathMeta);
    }
    if (data.containsKey('palm_shape')) {
      context.handle(
        _palmShapeMeta,
        palmShape.isAcceptableOrUnknown(data['palm_shape']!, _palmShapeMeta),
      );
    }
    if (data.containsKey('palm_width_ratio')) {
      context.handle(
        _palmWidthRatioMeta,
        palmWidthRatio.isAcceptableOrUnknown(
          data['palm_width_ratio']!,
          _palmWidthRatioMeta,
        ),
      );
    }
    if (data.containsKey('finger_proportions_json')) {
      context.handle(
        _fingerProportionsJsonMeta,
        fingerProportionsJson.isAcceptableOrUnknown(
          data['finger_proportions_json']!,
          _fingerProportionsJsonMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('ai_interpretation_json')) {
      context.handle(
        _aiInterpretationJsonMeta,
        aiInterpretationJson.isAcceptableOrUnknown(
          data['ai_interpretation_json']!,
          _aiInterpretationJsonMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PalmScan map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PalmScan(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      hand: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hand'],
      )!,
      imagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_path'],
      )!,
      palmShape: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}palm_shape'],
      ),
      palmWidthRatio: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}palm_width_ratio'],
      ),
      fingerProportionsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}finger_proportions_json'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      aiInterpretationJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ai_interpretation_json'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PalmScansTable createAlias(String alias) {
    return $PalmScansTable(attachedDatabase, alias);
  }
}

class PalmScan extends DataClass implements Insertable<PalmScan> {
  final int id;

  /// 'left' or 'right'
  final String hand;
  final String imagePath;

  /// PalmShape enum name; nullable until CV analysis completes
  final String? palmShape;
  final double? palmWidthRatio;

  /// JSON-encoded Map<String, double>
  final String? fingerProportionsJson;

  /// ScanStatus enum name
  final String status;

  /// JSON-encoded PalmInterpretation
  final String? aiInterpretationJson;
  final DateTime createdAt;
  const PalmScan({
    required this.id,
    required this.hand,
    required this.imagePath,
    this.palmShape,
    this.palmWidthRatio,
    this.fingerProportionsJson,
    required this.status,
    this.aiInterpretationJson,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['hand'] = Variable<String>(hand);
    map['image_path'] = Variable<String>(imagePath);
    if (!nullToAbsent || palmShape != null) {
      map['palm_shape'] = Variable<String>(palmShape);
    }
    if (!nullToAbsent || palmWidthRatio != null) {
      map['palm_width_ratio'] = Variable<double>(palmWidthRatio);
    }
    if (!nullToAbsent || fingerProportionsJson != null) {
      map['finger_proportions_json'] = Variable<String>(fingerProportionsJson);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || aiInterpretationJson != null) {
      map['ai_interpretation_json'] = Variable<String>(aiInterpretationJson);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PalmScansCompanion toCompanion(bool nullToAbsent) {
    return PalmScansCompanion(
      id: Value(id),
      hand: Value(hand),
      imagePath: Value(imagePath),
      palmShape: palmShape == null && nullToAbsent
          ? const Value.absent()
          : Value(palmShape),
      palmWidthRatio: palmWidthRatio == null && nullToAbsent
          ? const Value.absent()
          : Value(palmWidthRatio),
      fingerProportionsJson: fingerProportionsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(fingerProportionsJson),
      status: Value(status),
      aiInterpretationJson: aiInterpretationJson == null && nullToAbsent
          ? const Value.absent()
          : Value(aiInterpretationJson),
      createdAt: Value(createdAt),
    );
  }

  factory PalmScan.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PalmScan(
      id: serializer.fromJson<int>(json['id']),
      hand: serializer.fromJson<String>(json['hand']),
      imagePath: serializer.fromJson<String>(json['imagePath']),
      palmShape: serializer.fromJson<String?>(json['palmShape']),
      palmWidthRatio: serializer.fromJson<double?>(json['palmWidthRatio']),
      fingerProportionsJson: serializer.fromJson<String?>(
        json['fingerProportionsJson'],
      ),
      status: serializer.fromJson<String>(json['status']),
      aiInterpretationJson: serializer.fromJson<String?>(
        json['aiInterpretationJson'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'hand': serializer.toJson<String>(hand),
      'imagePath': serializer.toJson<String>(imagePath),
      'palmShape': serializer.toJson<String?>(palmShape),
      'palmWidthRatio': serializer.toJson<double?>(palmWidthRatio),
      'fingerProportionsJson': serializer.toJson<String?>(
        fingerProportionsJson,
      ),
      'status': serializer.toJson<String>(status),
      'aiInterpretationJson': serializer.toJson<String?>(aiInterpretationJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PalmScan copyWith({
    int? id,
    String? hand,
    String? imagePath,
    Value<String?> palmShape = const Value.absent(),
    Value<double?> palmWidthRatio = const Value.absent(),
    Value<String?> fingerProportionsJson = const Value.absent(),
    String? status,
    Value<String?> aiInterpretationJson = const Value.absent(),
    DateTime? createdAt,
  }) => PalmScan(
    id: id ?? this.id,
    hand: hand ?? this.hand,
    imagePath: imagePath ?? this.imagePath,
    palmShape: palmShape.present ? palmShape.value : this.palmShape,
    palmWidthRatio: palmWidthRatio.present
        ? palmWidthRatio.value
        : this.palmWidthRatio,
    fingerProportionsJson: fingerProportionsJson.present
        ? fingerProportionsJson.value
        : this.fingerProportionsJson,
    status: status ?? this.status,
    aiInterpretationJson: aiInterpretationJson.present
        ? aiInterpretationJson.value
        : this.aiInterpretationJson,
    createdAt: createdAt ?? this.createdAt,
  );
  PalmScan copyWithCompanion(PalmScansCompanion data) {
    return PalmScan(
      id: data.id.present ? data.id.value : this.id,
      hand: data.hand.present ? data.hand.value : this.hand,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      palmShape: data.palmShape.present ? data.palmShape.value : this.palmShape,
      palmWidthRatio: data.palmWidthRatio.present
          ? data.palmWidthRatio.value
          : this.palmWidthRatio,
      fingerProportionsJson: data.fingerProportionsJson.present
          ? data.fingerProportionsJson.value
          : this.fingerProportionsJson,
      status: data.status.present ? data.status.value : this.status,
      aiInterpretationJson: data.aiInterpretationJson.present
          ? data.aiInterpretationJson.value
          : this.aiInterpretationJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PalmScan(')
          ..write('id: $id, ')
          ..write('hand: $hand, ')
          ..write('imagePath: $imagePath, ')
          ..write('palmShape: $palmShape, ')
          ..write('palmWidthRatio: $palmWidthRatio, ')
          ..write('fingerProportionsJson: $fingerProportionsJson, ')
          ..write('status: $status, ')
          ..write('aiInterpretationJson: $aiInterpretationJson, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    hand,
    imagePath,
    palmShape,
    palmWidthRatio,
    fingerProportionsJson,
    status,
    aiInterpretationJson,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PalmScan &&
          other.id == this.id &&
          other.hand == this.hand &&
          other.imagePath == this.imagePath &&
          other.palmShape == this.palmShape &&
          other.palmWidthRatio == this.palmWidthRatio &&
          other.fingerProportionsJson == this.fingerProportionsJson &&
          other.status == this.status &&
          other.aiInterpretationJson == this.aiInterpretationJson &&
          other.createdAt == this.createdAt);
}

class PalmScansCompanion extends UpdateCompanion<PalmScan> {
  final Value<int> id;
  final Value<String> hand;
  final Value<String> imagePath;
  final Value<String?> palmShape;
  final Value<double?> palmWidthRatio;
  final Value<String?> fingerProportionsJson;
  final Value<String> status;
  final Value<String?> aiInterpretationJson;
  final Value<DateTime> createdAt;
  const PalmScansCompanion({
    this.id = const Value.absent(),
    this.hand = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.palmShape = const Value.absent(),
    this.palmWidthRatio = const Value.absent(),
    this.fingerProportionsJson = const Value.absent(),
    this.status = const Value.absent(),
    this.aiInterpretationJson = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  PalmScansCompanion.insert({
    this.id = const Value.absent(),
    required String hand,
    required String imagePath,
    this.palmShape = const Value.absent(),
    this.palmWidthRatio = const Value.absent(),
    this.fingerProportionsJson = const Value.absent(),
    this.status = const Value.absent(),
    this.aiInterpretationJson = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : hand = Value(hand),
       imagePath = Value(imagePath);
  static Insertable<PalmScan> custom({
    Expression<int>? id,
    Expression<String>? hand,
    Expression<String>? imagePath,
    Expression<String>? palmShape,
    Expression<double>? palmWidthRatio,
    Expression<String>? fingerProportionsJson,
    Expression<String>? status,
    Expression<String>? aiInterpretationJson,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (hand != null) 'hand': hand,
      if (imagePath != null) 'image_path': imagePath,
      if (palmShape != null) 'palm_shape': palmShape,
      if (palmWidthRatio != null) 'palm_width_ratio': palmWidthRatio,
      if (fingerProportionsJson != null)
        'finger_proportions_json': fingerProportionsJson,
      if (status != null) 'status': status,
      if (aiInterpretationJson != null)
        'ai_interpretation_json': aiInterpretationJson,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  PalmScansCompanion copyWith({
    Value<int>? id,
    Value<String>? hand,
    Value<String>? imagePath,
    Value<String?>? palmShape,
    Value<double?>? palmWidthRatio,
    Value<String?>? fingerProportionsJson,
    Value<String>? status,
    Value<String?>? aiInterpretationJson,
    Value<DateTime>? createdAt,
  }) {
    return PalmScansCompanion(
      id: id ?? this.id,
      hand: hand ?? this.hand,
      imagePath: imagePath ?? this.imagePath,
      palmShape: palmShape ?? this.palmShape,
      palmWidthRatio: palmWidthRatio ?? this.palmWidthRatio,
      fingerProportionsJson:
          fingerProportionsJson ?? this.fingerProportionsJson,
      status: status ?? this.status,
      aiInterpretationJson: aiInterpretationJson ?? this.aiInterpretationJson,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (hand.present) {
      map['hand'] = Variable<String>(hand.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (palmShape.present) {
      map['palm_shape'] = Variable<String>(palmShape.value);
    }
    if (palmWidthRatio.present) {
      map['palm_width_ratio'] = Variable<double>(palmWidthRatio.value);
    }
    if (fingerProportionsJson.present) {
      map['finger_proportions_json'] = Variable<String>(
        fingerProportionsJson.value,
      );
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (aiInterpretationJson.present) {
      map['ai_interpretation_json'] = Variable<String>(
        aiInterpretationJson.value,
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PalmScansCompanion(')
          ..write('id: $id, ')
          ..write('hand: $hand, ')
          ..write('imagePath: $imagePath, ')
          ..write('palmShape: $palmShape, ')
          ..write('palmWidthRatio: $palmWidthRatio, ')
          ..write('fingerProportionsJson: $fingerProportionsJson, ')
          ..write('status: $status, ')
          ..write('aiInterpretationJson: $aiInterpretationJson, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $PalmLinesTable extends PalmLines
    with TableInfo<$PalmLinesTable, PalmLine> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PalmLinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _scanIdMeta = const VerificationMeta('scanId');
  @override
  late final GeneratedColumn<int> scanId = GeneratedColumn<int>(
    'scan_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES palm_scans (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _lineTypeMeta = const VerificationMeta(
    'lineType',
  );
  @override
  late final GeneratedColumn<String> lineType = GeneratedColumn<String>(
    'line_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _controlPointsJsonMeta = const VerificationMeta(
    'controlPointsJson',
  );
  @override
  late final GeneratedColumn<String> controlPointsJson =
      GeneratedColumn<String>(
        'control_points_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _lengthMeta = const VerificationMeta('length');
  @override
  late final GeneratedColumn<double> length = GeneratedColumn<double>(
    'length',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _depthMeta = const VerificationMeta('depth');
  @override
  late final GeneratedColumn<String> depth = GeneratedColumn<String>(
    'depth',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _curvatureMeta = const VerificationMeta(
    'curvature',
  );
  @override
  late final GeneratedColumn<String> curvature = GeneratedColumn<String>(
    'curvature',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startPointMeta = const VerificationMeta(
    'startPoint',
  );
  @override
  late final GeneratedColumn<String> startPoint = GeneratedColumn<String>(
    'start_point',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endPointMeta = const VerificationMeta(
    'endPoint',
  );
  @override
  late final GeneratedColumn<String> endPoint = GeneratedColumn<String>(
    'end_point',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isUserEditedMeta = const VerificationMeta(
    'isUserEdited',
  );
  @override
  late final GeneratedColumn<bool> isUserEdited = GeneratedColumn<bool>(
    'is_user_edited',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_user_edited" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    scanId,
    lineType,
    controlPointsJson,
    length,
    depth,
    curvature,
    startPoint,
    endPoint,
    isUserEdited,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'palm_lines';
  @override
  VerificationContext validateIntegrity(
    Insertable<PalmLine> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('scan_id')) {
      context.handle(
        _scanIdMeta,
        scanId.isAcceptableOrUnknown(data['scan_id']!, _scanIdMeta),
      );
    } else if (isInserting) {
      context.missing(_scanIdMeta);
    }
    if (data.containsKey('line_type')) {
      context.handle(
        _lineTypeMeta,
        lineType.isAcceptableOrUnknown(data['line_type']!, _lineTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_lineTypeMeta);
    }
    if (data.containsKey('control_points_json')) {
      context.handle(
        _controlPointsJsonMeta,
        controlPointsJson.isAcceptableOrUnknown(
          data['control_points_json']!,
          _controlPointsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_controlPointsJsonMeta);
    }
    if (data.containsKey('length')) {
      context.handle(
        _lengthMeta,
        length.isAcceptableOrUnknown(data['length']!, _lengthMeta),
      );
    }
    if (data.containsKey('depth')) {
      context.handle(
        _depthMeta,
        depth.isAcceptableOrUnknown(data['depth']!, _depthMeta),
      );
    }
    if (data.containsKey('curvature')) {
      context.handle(
        _curvatureMeta,
        curvature.isAcceptableOrUnknown(data['curvature']!, _curvatureMeta),
      );
    }
    if (data.containsKey('start_point')) {
      context.handle(
        _startPointMeta,
        startPoint.isAcceptableOrUnknown(data['start_point']!, _startPointMeta),
      );
    }
    if (data.containsKey('end_point')) {
      context.handle(
        _endPointMeta,
        endPoint.isAcceptableOrUnknown(data['end_point']!, _endPointMeta),
      );
    }
    if (data.containsKey('is_user_edited')) {
      context.handle(
        _isUserEditedMeta,
        isUserEdited.isAcceptableOrUnknown(
          data['is_user_edited']!,
          _isUserEditedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PalmLine map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PalmLine(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      scanId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}scan_id'],
      )!,
      lineType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}line_type'],
      )!,
      controlPointsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}control_points_json'],
      )!,
      length: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}length'],
      ),
      depth: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}depth'],
      ),
      curvature: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}curvature'],
      ),
      startPoint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}start_point'],
      ),
      endPoint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}end_point'],
      ),
      isUserEdited: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_user_edited'],
      )!,
    );
  }

  @override
  $PalmLinesTable createAlias(String alias) {
    return $PalmLinesTable(attachedDatabase, alias);
  }
}

class PalmLine extends DataClass implements Insertable<PalmLine> {
  final int id;
  final int scanId;

  /// LineType enum name
  final String lineType;

  /// JSON-encoded List<{x, y}>
  final String controlPointsJson;
  final double? length;

  /// LineDepth enum name
  final String? depth;

  /// LineCurvature enum name
  final String? curvature;
  final String? startPoint;
  final String? endPoint;
  final bool isUserEdited;
  const PalmLine({
    required this.id,
    required this.scanId,
    required this.lineType,
    required this.controlPointsJson,
    this.length,
    this.depth,
    this.curvature,
    this.startPoint,
    this.endPoint,
    required this.isUserEdited,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['scan_id'] = Variable<int>(scanId);
    map['line_type'] = Variable<String>(lineType);
    map['control_points_json'] = Variable<String>(controlPointsJson);
    if (!nullToAbsent || length != null) {
      map['length'] = Variable<double>(length);
    }
    if (!nullToAbsent || depth != null) {
      map['depth'] = Variable<String>(depth);
    }
    if (!nullToAbsent || curvature != null) {
      map['curvature'] = Variable<String>(curvature);
    }
    if (!nullToAbsent || startPoint != null) {
      map['start_point'] = Variable<String>(startPoint);
    }
    if (!nullToAbsent || endPoint != null) {
      map['end_point'] = Variable<String>(endPoint);
    }
    map['is_user_edited'] = Variable<bool>(isUserEdited);
    return map;
  }

  PalmLinesCompanion toCompanion(bool nullToAbsent) {
    return PalmLinesCompanion(
      id: Value(id),
      scanId: Value(scanId),
      lineType: Value(lineType),
      controlPointsJson: Value(controlPointsJson),
      length: length == null && nullToAbsent
          ? const Value.absent()
          : Value(length),
      depth: depth == null && nullToAbsent
          ? const Value.absent()
          : Value(depth),
      curvature: curvature == null && nullToAbsent
          ? const Value.absent()
          : Value(curvature),
      startPoint: startPoint == null && nullToAbsent
          ? const Value.absent()
          : Value(startPoint),
      endPoint: endPoint == null && nullToAbsent
          ? const Value.absent()
          : Value(endPoint),
      isUserEdited: Value(isUserEdited),
    );
  }

  factory PalmLine.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PalmLine(
      id: serializer.fromJson<int>(json['id']),
      scanId: serializer.fromJson<int>(json['scanId']),
      lineType: serializer.fromJson<String>(json['lineType']),
      controlPointsJson: serializer.fromJson<String>(json['controlPointsJson']),
      length: serializer.fromJson<double?>(json['length']),
      depth: serializer.fromJson<String?>(json['depth']),
      curvature: serializer.fromJson<String?>(json['curvature']),
      startPoint: serializer.fromJson<String?>(json['startPoint']),
      endPoint: serializer.fromJson<String?>(json['endPoint']),
      isUserEdited: serializer.fromJson<bool>(json['isUserEdited']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'scanId': serializer.toJson<int>(scanId),
      'lineType': serializer.toJson<String>(lineType),
      'controlPointsJson': serializer.toJson<String>(controlPointsJson),
      'length': serializer.toJson<double?>(length),
      'depth': serializer.toJson<String?>(depth),
      'curvature': serializer.toJson<String?>(curvature),
      'startPoint': serializer.toJson<String?>(startPoint),
      'endPoint': serializer.toJson<String?>(endPoint),
      'isUserEdited': serializer.toJson<bool>(isUserEdited),
    };
  }

  PalmLine copyWith({
    int? id,
    int? scanId,
    String? lineType,
    String? controlPointsJson,
    Value<double?> length = const Value.absent(),
    Value<String?> depth = const Value.absent(),
    Value<String?> curvature = const Value.absent(),
    Value<String?> startPoint = const Value.absent(),
    Value<String?> endPoint = const Value.absent(),
    bool? isUserEdited,
  }) => PalmLine(
    id: id ?? this.id,
    scanId: scanId ?? this.scanId,
    lineType: lineType ?? this.lineType,
    controlPointsJson: controlPointsJson ?? this.controlPointsJson,
    length: length.present ? length.value : this.length,
    depth: depth.present ? depth.value : this.depth,
    curvature: curvature.present ? curvature.value : this.curvature,
    startPoint: startPoint.present ? startPoint.value : this.startPoint,
    endPoint: endPoint.present ? endPoint.value : this.endPoint,
    isUserEdited: isUserEdited ?? this.isUserEdited,
  );
  PalmLine copyWithCompanion(PalmLinesCompanion data) {
    return PalmLine(
      id: data.id.present ? data.id.value : this.id,
      scanId: data.scanId.present ? data.scanId.value : this.scanId,
      lineType: data.lineType.present ? data.lineType.value : this.lineType,
      controlPointsJson: data.controlPointsJson.present
          ? data.controlPointsJson.value
          : this.controlPointsJson,
      length: data.length.present ? data.length.value : this.length,
      depth: data.depth.present ? data.depth.value : this.depth,
      curvature: data.curvature.present ? data.curvature.value : this.curvature,
      startPoint: data.startPoint.present
          ? data.startPoint.value
          : this.startPoint,
      endPoint: data.endPoint.present ? data.endPoint.value : this.endPoint,
      isUserEdited: data.isUserEdited.present
          ? data.isUserEdited.value
          : this.isUserEdited,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PalmLine(')
          ..write('id: $id, ')
          ..write('scanId: $scanId, ')
          ..write('lineType: $lineType, ')
          ..write('controlPointsJson: $controlPointsJson, ')
          ..write('length: $length, ')
          ..write('depth: $depth, ')
          ..write('curvature: $curvature, ')
          ..write('startPoint: $startPoint, ')
          ..write('endPoint: $endPoint, ')
          ..write('isUserEdited: $isUserEdited')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    scanId,
    lineType,
    controlPointsJson,
    length,
    depth,
    curvature,
    startPoint,
    endPoint,
    isUserEdited,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PalmLine &&
          other.id == this.id &&
          other.scanId == this.scanId &&
          other.lineType == this.lineType &&
          other.controlPointsJson == this.controlPointsJson &&
          other.length == this.length &&
          other.depth == this.depth &&
          other.curvature == this.curvature &&
          other.startPoint == this.startPoint &&
          other.endPoint == this.endPoint &&
          other.isUserEdited == this.isUserEdited);
}

class PalmLinesCompanion extends UpdateCompanion<PalmLine> {
  final Value<int> id;
  final Value<int> scanId;
  final Value<String> lineType;
  final Value<String> controlPointsJson;
  final Value<double?> length;
  final Value<String?> depth;
  final Value<String?> curvature;
  final Value<String?> startPoint;
  final Value<String?> endPoint;
  final Value<bool> isUserEdited;
  const PalmLinesCompanion({
    this.id = const Value.absent(),
    this.scanId = const Value.absent(),
    this.lineType = const Value.absent(),
    this.controlPointsJson = const Value.absent(),
    this.length = const Value.absent(),
    this.depth = const Value.absent(),
    this.curvature = const Value.absent(),
    this.startPoint = const Value.absent(),
    this.endPoint = const Value.absent(),
    this.isUserEdited = const Value.absent(),
  });
  PalmLinesCompanion.insert({
    this.id = const Value.absent(),
    required int scanId,
    required String lineType,
    required String controlPointsJson,
    this.length = const Value.absent(),
    this.depth = const Value.absent(),
    this.curvature = const Value.absent(),
    this.startPoint = const Value.absent(),
    this.endPoint = const Value.absent(),
    this.isUserEdited = const Value.absent(),
  }) : scanId = Value(scanId),
       lineType = Value(lineType),
       controlPointsJson = Value(controlPointsJson);
  static Insertable<PalmLine> custom({
    Expression<int>? id,
    Expression<int>? scanId,
    Expression<String>? lineType,
    Expression<String>? controlPointsJson,
    Expression<double>? length,
    Expression<String>? depth,
    Expression<String>? curvature,
    Expression<String>? startPoint,
    Expression<String>? endPoint,
    Expression<bool>? isUserEdited,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (scanId != null) 'scan_id': scanId,
      if (lineType != null) 'line_type': lineType,
      if (controlPointsJson != null) 'control_points_json': controlPointsJson,
      if (length != null) 'length': length,
      if (depth != null) 'depth': depth,
      if (curvature != null) 'curvature': curvature,
      if (startPoint != null) 'start_point': startPoint,
      if (endPoint != null) 'end_point': endPoint,
      if (isUserEdited != null) 'is_user_edited': isUserEdited,
    });
  }

  PalmLinesCompanion copyWith({
    Value<int>? id,
    Value<int>? scanId,
    Value<String>? lineType,
    Value<String>? controlPointsJson,
    Value<double?>? length,
    Value<String?>? depth,
    Value<String?>? curvature,
    Value<String?>? startPoint,
    Value<String?>? endPoint,
    Value<bool>? isUserEdited,
  }) {
    return PalmLinesCompanion(
      id: id ?? this.id,
      scanId: scanId ?? this.scanId,
      lineType: lineType ?? this.lineType,
      controlPointsJson: controlPointsJson ?? this.controlPointsJson,
      length: length ?? this.length,
      depth: depth ?? this.depth,
      curvature: curvature ?? this.curvature,
      startPoint: startPoint ?? this.startPoint,
      endPoint: endPoint ?? this.endPoint,
      isUserEdited: isUserEdited ?? this.isUserEdited,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (scanId.present) {
      map['scan_id'] = Variable<int>(scanId.value);
    }
    if (lineType.present) {
      map['line_type'] = Variable<String>(lineType.value);
    }
    if (controlPointsJson.present) {
      map['control_points_json'] = Variable<String>(controlPointsJson.value);
    }
    if (length.present) {
      map['length'] = Variable<double>(length.value);
    }
    if (depth.present) {
      map['depth'] = Variable<String>(depth.value);
    }
    if (curvature.present) {
      map['curvature'] = Variable<String>(curvature.value);
    }
    if (startPoint.present) {
      map['start_point'] = Variable<String>(startPoint.value);
    }
    if (endPoint.present) {
      map['end_point'] = Variable<String>(endPoint.value);
    }
    if (isUserEdited.present) {
      map['is_user_edited'] = Variable<bool>(isUserEdited.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PalmLinesCompanion(')
          ..write('id: $id, ')
          ..write('scanId: $scanId, ')
          ..write('lineType: $lineType, ')
          ..write('controlPointsJson: $controlPointsJson, ')
          ..write('length: $length, ')
          ..write('depth: $depth, ')
          ..write('curvature: $curvature, ')
          ..write('startPoint: $startPoint, ')
          ..write('endPoint: $endPoint, ')
          ..write('isUserEdited: $isUserEdited')
          ..write(')'))
        .toString();
  }
}

class $LineReadingsTable extends LineReadings
    with TableInfo<$LineReadingsTable, LineReading> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LineReadingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _scanIdMeta = const VerificationMeta('scanId');
  @override
  late final GeneratedColumn<int> scanId = GeneratedColumn<int>(
    'scan_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES palm_scans (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _lineIdMeta = const VerificationMeta('lineId');
  @override
  late final GeneratedColumn<int> lineId = GeneratedColumn<int>(
    'line_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES palm_lines (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _traitMeta = const VerificationMeta('trait');
  @override
  late final GeneratedColumn<String> trait = GeneratedColumn<String>(
    'trait',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
    'confidence',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ruleIdMeta = const VerificationMeta('ruleId');
  @override
  late final GeneratedColumn<String> ruleId = GeneratedColumn<String>(
    'rule_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    scanId,
    lineId,
    category,
    trait,
    confidence,
    ruleId,
    description,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'line_readings';
  @override
  VerificationContext validateIntegrity(
    Insertable<LineReading> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('scan_id')) {
      context.handle(
        _scanIdMeta,
        scanId.isAcceptableOrUnknown(data['scan_id']!, _scanIdMeta),
      );
    } else if (isInserting) {
      context.missing(_scanIdMeta);
    }
    if (data.containsKey('line_id')) {
      context.handle(
        _lineIdMeta,
        lineId.isAcceptableOrUnknown(data['line_id']!, _lineIdMeta),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('trait')) {
      context.handle(
        _traitMeta,
        trait.isAcceptableOrUnknown(data['trait']!, _traitMeta),
      );
    } else if (isInserting) {
      context.missing(_traitMeta);
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    } else if (isInserting) {
      context.missing(_confidenceMeta);
    }
    if (data.containsKey('rule_id')) {
      context.handle(
        _ruleIdMeta,
        ruleId.isAcceptableOrUnknown(data['rule_id']!, _ruleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ruleIdMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LineReading map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LineReading(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      scanId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}scan_id'],
      )!,
      lineId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}line_id'],
      ),
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      trait: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trait'],
      )!,
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence'],
      )!,
      ruleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rule_id'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
    );
  }

  @override
  $LineReadingsTable createAlias(String alias) {
    return $LineReadingsTable(attachedDatabase, alias);
  }
}

class LineReading extends DataClass implements Insertable<LineReading> {
  final int id;
  final int scanId;

  /// Nullable FK to PalmLines
  final int? lineId;
  final String category;
  final String trait;
  final double confidence;
  final String ruleId;
  final String description;
  const LineReading({
    required this.id,
    required this.scanId,
    this.lineId,
    required this.category,
    required this.trait,
    required this.confidence,
    required this.ruleId,
    required this.description,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['scan_id'] = Variable<int>(scanId);
    if (!nullToAbsent || lineId != null) {
      map['line_id'] = Variable<int>(lineId);
    }
    map['category'] = Variable<String>(category);
    map['trait'] = Variable<String>(trait);
    map['confidence'] = Variable<double>(confidence);
    map['rule_id'] = Variable<String>(ruleId);
    map['description'] = Variable<String>(description);
    return map;
  }

  LineReadingsCompanion toCompanion(bool nullToAbsent) {
    return LineReadingsCompanion(
      id: Value(id),
      scanId: Value(scanId),
      lineId: lineId == null && nullToAbsent
          ? const Value.absent()
          : Value(lineId),
      category: Value(category),
      trait: Value(trait),
      confidence: Value(confidence),
      ruleId: Value(ruleId),
      description: Value(description),
    );
  }

  factory LineReading.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LineReading(
      id: serializer.fromJson<int>(json['id']),
      scanId: serializer.fromJson<int>(json['scanId']),
      lineId: serializer.fromJson<int?>(json['lineId']),
      category: serializer.fromJson<String>(json['category']),
      trait: serializer.fromJson<String>(json['trait']),
      confidence: serializer.fromJson<double>(json['confidence']),
      ruleId: serializer.fromJson<String>(json['ruleId']),
      description: serializer.fromJson<String>(json['description']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'scanId': serializer.toJson<int>(scanId),
      'lineId': serializer.toJson<int?>(lineId),
      'category': serializer.toJson<String>(category),
      'trait': serializer.toJson<String>(trait),
      'confidence': serializer.toJson<double>(confidence),
      'ruleId': serializer.toJson<String>(ruleId),
      'description': serializer.toJson<String>(description),
    };
  }

  LineReading copyWith({
    int? id,
    int? scanId,
    Value<int?> lineId = const Value.absent(),
    String? category,
    String? trait,
    double? confidence,
    String? ruleId,
    String? description,
  }) => LineReading(
    id: id ?? this.id,
    scanId: scanId ?? this.scanId,
    lineId: lineId.present ? lineId.value : this.lineId,
    category: category ?? this.category,
    trait: trait ?? this.trait,
    confidence: confidence ?? this.confidence,
    ruleId: ruleId ?? this.ruleId,
    description: description ?? this.description,
  );
  LineReading copyWithCompanion(LineReadingsCompanion data) {
    return LineReading(
      id: data.id.present ? data.id.value : this.id,
      scanId: data.scanId.present ? data.scanId.value : this.scanId,
      lineId: data.lineId.present ? data.lineId.value : this.lineId,
      category: data.category.present ? data.category.value : this.category,
      trait: data.trait.present ? data.trait.value : this.trait,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      ruleId: data.ruleId.present ? data.ruleId.value : this.ruleId,
      description: data.description.present
          ? data.description.value
          : this.description,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LineReading(')
          ..write('id: $id, ')
          ..write('scanId: $scanId, ')
          ..write('lineId: $lineId, ')
          ..write('category: $category, ')
          ..write('trait: $trait, ')
          ..write('confidence: $confidence, ')
          ..write('ruleId: $ruleId, ')
          ..write('description: $description')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    scanId,
    lineId,
    category,
    trait,
    confidence,
    ruleId,
    description,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LineReading &&
          other.id == this.id &&
          other.scanId == this.scanId &&
          other.lineId == this.lineId &&
          other.category == this.category &&
          other.trait == this.trait &&
          other.confidence == this.confidence &&
          other.ruleId == this.ruleId &&
          other.description == this.description);
}

class LineReadingsCompanion extends UpdateCompanion<LineReading> {
  final Value<int> id;
  final Value<int> scanId;
  final Value<int?> lineId;
  final Value<String> category;
  final Value<String> trait;
  final Value<double> confidence;
  final Value<String> ruleId;
  final Value<String> description;
  const LineReadingsCompanion({
    this.id = const Value.absent(),
    this.scanId = const Value.absent(),
    this.lineId = const Value.absent(),
    this.category = const Value.absent(),
    this.trait = const Value.absent(),
    this.confidence = const Value.absent(),
    this.ruleId = const Value.absent(),
    this.description = const Value.absent(),
  });
  LineReadingsCompanion.insert({
    this.id = const Value.absent(),
    required int scanId,
    this.lineId = const Value.absent(),
    required String category,
    required String trait,
    required double confidence,
    required String ruleId,
    required String description,
  }) : scanId = Value(scanId),
       category = Value(category),
       trait = Value(trait),
       confidence = Value(confidence),
       ruleId = Value(ruleId),
       description = Value(description);
  static Insertable<LineReading> custom({
    Expression<int>? id,
    Expression<int>? scanId,
    Expression<int>? lineId,
    Expression<String>? category,
    Expression<String>? trait,
    Expression<double>? confidence,
    Expression<String>? ruleId,
    Expression<String>? description,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (scanId != null) 'scan_id': scanId,
      if (lineId != null) 'line_id': lineId,
      if (category != null) 'category': category,
      if (trait != null) 'trait': trait,
      if (confidence != null) 'confidence': confidence,
      if (ruleId != null) 'rule_id': ruleId,
      if (description != null) 'description': description,
    });
  }

  LineReadingsCompanion copyWith({
    Value<int>? id,
    Value<int>? scanId,
    Value<int?>? lineId,
    Value<String>? category,
    Value<String>? trait,
    Value<double>? confidence,
    Value<String>? ruleId,
    Value<String>? description,
  }) {
    return LineReadingsCompanion(
      id: id ?? this.id,
      scanId: scanId ?? this.scanId,
      lineId: lineId ?? this.lineId,
      category: category ?? this.category,
      trait: trait ?? this.trait,
      confidence: confidence ?? this.confidence,
      ruleId: ruleId ?? this.ruleId,
      description: description ?? this.description,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (scanId.present) {
      map['scan_id'] = Variable<int>(scanId.value);
    }
    if (lineId.present) {
      map['line_id'] = Variable<int>(lineId.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (trait.present) {
      map['trait'] = Variable<String>(trait.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (ruleId.present) {
      map['rule_id'] = Variable<String>(ruleId.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LineReadingsCompanion(')
          ..write('id: $id, ')
          ..write('scanId: $scanId, ')
          ..write('lineId: $lineId, ')
          ..write('category: $category, ')
          ..write('trait: $trait, ')
          ..write('confidence: $confidence, ')
          ..write('ruleId: $ruleId, ')
          ..write('description: $description')
          ..write(')'))
        .toString();
  }
}

class $ScanMessagesTable extends ScanMessages
    with TableInfo<$ScanMessagesTable, ScanMessage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScanMessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _scanIdMeta = const VerificationMeta('scanId');
  @override
  late final GeneratedColumn<int> scanId = GeneratedColumn<int>(
    'scan_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES palm_scans (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, scanId, role, content, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'scan_messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScanMessage> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('scan_id')) {
      context.handle(
        _scanIdMeta,
        scanId.isAcceptableOrUnknown(data['scan_id']!, _scanIdMeta),
      );
    } else if (isInserting) {
      context.missing(_scanIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ScanMessage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScanMessage(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      scanId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}scan_id'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ScanMessagesTable createAlias(String alias) {
    return $ScanMessagesTable(attachedDatabase, alias);
  }
}

class ScanMessage extends DataClass implements Insertable<ScanMessage> {
  final int id;
  final int scanId;

  /// MessageRole enum name: 'user' or 'assistant'
  final String role;
  final String content;
  final DateTime createdAt;
  const ScanMessage({
    required this.id,
    required this.scanId,
    required this.role,
    required this.content,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['scan_id'] = Variable<int>(scanId);
    map['role'] = Variable<String>(role);
    map['content'] = Variable<String>(content);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ScanMessagesCompanion toCompanion(bool nullToAbsent) {
    return ScanMessagesCompanion(
      id: Value(id),
      scanId: Value(scanId),
      role: Value(role),
      content: Value(content),
      createdAt: Value(createdAt),
    );
  }

  factory ScanMessage.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScanMessage(
      id: serializer.fromJson<int>(json['id']),
      scanId: serializer.fromJson<int>(json['scanId']),
      role: serializer.fromJson<String>(json['role']),
      content: serializer.fromJson<String>(json['content']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'scanId': serializer.toJson<int>(scanId),
      'role': serializer.toJson<String>(role),
      'content': serializer.toJson<String>(content),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ScanMessage copyWith({
    int? id,
    int? scanId,
    String? role,
    String? content,
    DateTime? createdAt,
  }) => ScanMessage(
    id: id ?? this.id,
    scanId: scanId ?? this.scanId,
    role: role ?? this.role,
    content: content ?? this.content,
    createdAt: createdAt ?? this.createdAt,
  );
  ScanMessage copyWithCompanion(ScanMessagesCompanion data) {
    return ScanMessage(
      id: data.id.present ? data.id.value : this.id,
      scanId: data.scanId.present ? data.scanId.value : this.scanId,
      role: data.role.present ? data.role.value : this.role,
      content: data.content.present ? data.content.value : this.content,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScanMessage(')
          ..write('id: $id, ')
          ..write('scanId: $scanId, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, scanId, role, content, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScanMessage &&
          other.id == this.id &&
          other.scanId == this.scanId &&
          other.role == this.role &&
          other.content == this.content &&
          other.createdAt == this.createdAt);
}

class ScanMessagesCompanion extends UpdateCompanion<ScanMessage> {
  final Value<int> id;
  final Value<int> scanId;
  final Value<String> role;
  final Value<String> content;
  final Value<DateTime> createdAt;
  const ScanMessagesCompanion({
    this.id = const Value.absent(),
    this.scanId = const Value.absent(),
    this.role = const Value.absent(),
    this.content = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ScanMessagesCompanion.insert({
    this.id = const Value.absent(),
    required int scanId,
    required String role,
    required String content,
    this.createdAt = const Value.absent(),
  }) : scanId = Value(scanId),
       role = Value(role),
       content = Value(content);
  static Insertable<ScanMessage> custom({
    Expression<int>? id,
    Expression<int>? scanId,
    Expression<String>? role,
    Expression<String>? content,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (scanId != null) 'scan_id': scanId,
      if (role != null) 'role': role,
      if (content != null) 'content': content,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ScanMessagesCompanion copyWith({
    Value<int>? id,
    Value<int>? scanId,
    Value<String>? role,
    Value<String>? content,
    Value<DateTime>? createdAt,
  }) {
    return ScanMessagesCompanion(
      id: id ?? this.id,
      scanId: scanId ?? this.scanId,
      role: role ?? this.role,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (scanId.present) {
      map['scan_id'] = Variable<int>(scanId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScanMessagesCompanion(')
          ..write('id: $id, ')
          ..write('scanId: $scanId, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PalmScansTable palmScans = $PalmScansTable(this);
  late final $PalmLinesTable palmLines = $PalmLinesTable(this);
  late final $LineReadingsTable lineReadings = $LineReadingsTable(this);
  late final $ScanMessagesTable scanMessages = $ScanMessagesTable(this);
  late final ScanDao scanDao = ScanDao(this as AppDatabase);
  late final MessageDao messageDao = MessageDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    palmScans,
    palmLines,
    lineReadings,
    scanMessages,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'palm_scans',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('palm_lines', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'palm_scans',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('line_readings', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'palm_lines',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('line_readings', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'palm_scans',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('scan_messages', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$PalmScansTableCreateCompanionBuilder =
    PalmScansCompanion Function({
      Value<int> id,
      required String hand,
      required String imagePath,
      Value<String?> palmShape,
      Value<double?> palmWidthRatio,
      Value<String?> fingerProportionsJson,
      Value<String> status,
      Value<String?> aiInterpretationJson,
      Value<DateTime> createdAt,
    });
typedef $$PalmScansTableUpdateCompanionBuilder =
    PalmScansCompanion Function({
      Value<int> id,
      Value<String> hand,
      Value<String> imagePath,
      Value<String?> palmShape,
      Value<double?> palmWidthRatio,
      Value<String?> fingerProportionsJson,
      Value<String> status,
      Value<String?> aiInterpretationJson,
      Value<DateTime> createdAt,
    });

final class $$PalmScansTableReferences
    extends BaseReferences<_$AppDatabase, $PalmScansTable, PalmScan> {
  $$PalmScansTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PalmLinesTable, List<PalmLine>>
  _palmLinesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.palmLines,
    aliasName: $_aliasNameGenerator(db.palmScans.id, db.palmLines.scanId),
  );

  $$PalmLinesTableProcessedTableManager get palmLinesRefs {
    final manager = $$PalmLinesTableTableManager(
      $_db,
      $_db.palmLines,
    ).filter((f) => f.scanId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_palmLinesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$LineReadingsTable, List<LineReading>>
  _lineReadingsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.lineReadings,
    aliasName: $_aliasNameGenerator(db.palmScans.id, db.lineReadings.scanId),
  );

  $$LineReadingsTableProcessedTableManager get lineReadingsRefs {
    final manager = $$LineReadingsTableTableManager(
      $_db,
      $_db.lineReadings,
    ).filter((f) => f.scanId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_lineReadingsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ScanMessagesTable, List<ScanMessage>>
  _scanMessagesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.scanMessages,
    aliasName: $_aliasNameGenerator(db.palmScans.id, db.scanMessages.scanId),
  );

  $$ScanMessagesTableProcessedTableManager get scanMessagesRefs {
    final manager = $$ScanMessagesTableTableManager(
      $_db,
      $_db.scanMessages,
    ).filter((f) => f.scanId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_scanMessagesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PalmScansTableFilterComposer
    extends Composer<_$AppDatabase, $PalmScansTable> {
  $$PalmScansTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hand => $composableBuilder(
    column: $table.hand,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get palmShape => $composableBuilder(
    column: $table.palmShape,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get palmWidthRatio => $composableBuilder(
    column: $table.palmWidthRatio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fingerProportionsJson => $composableBuilder(
    column: $table.fingerProportionsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get aiInterpretationJson => $composableBuilder(
    column: $table.aiInterpretationJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> palmLinesRefs(
    Expression<bool> Function($$PalmLinesTableFilterComposer f) f,
  ) {
    final $$PalmLinesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.palmLines,
      getReferencedColumn: (t) => t.scanId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PalmLinesTableFilterComposer(
            $db: $db,
            $table: $db.palmLines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> lineReadingsRefs(
    Expression<bool> Function($$LineReadingsTableFilterComposer f) f,
  ) {
    final $$LineReadingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lineReadings,
      getReferencedColumn: (t) => t.scanId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LineReadingsTableFilterComposer(
            $db: $db,
            $table: $db.lineReadings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> scanMessagesRefs(
    Expression<bool> Function($$ScanMessagesTableFilterComposer f) f,
  ) {
    final $$ScanMessagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.scanMessages,
      getReferencedColumn: (t) => t.scanId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScanMessagesTableFilterComposer(
            $db: $db,
            $table: $db.scanMessages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PalmScansTableOrderingComposer
    extends Composer<_$AppDatabase, $PalmScansTable> {
  $$PalmScansTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hand => $composableBuilder(
    column: $table.hand,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get palmShape => $composableBuilder(
    column: $table.palmShape,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get palmWidthRatio => $composableBuilder(
    column: $table.palmWidthRatio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fingerProportionsJson => $composableBuilder(
    column: $table.fingerProportionsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get aiInterpretationJson => $composableBuilder(
    column: $table.aiInterpretationJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PalmScansTableAnnotationComposer
    extends Composer<_$AppDatabase, $PalmScansTable> {
  $$PalmScansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get hand =>
      $composableBuilder(column: $table.hand, builder: (column) => column);

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  GeneratedColumn<String> get palmShape =>
      $composableBuilder(column: $table.palmShape, builder: (column) => column);

  GeneratedColumn<double> get palmWidthRatio => $composableBuilder(
    column: $table.palmWidthRatio,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fingerProportionsJson => $composableBuilder(
    column: $table.fingerProportionsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get aiInterpretationJson => $composableBuilder(
    column: $table.aiInterpretationJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> palmLinesRefs<T extends Object>(
    Expression<T> Function($$PalmLinesTableAnnotationComposer a) f,
  ) {
    final $$PalmLinesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.palmLines,
      getReferencedColumn: (t) => t.scanId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PalmLinesTableAnnotationComposer(
            $db: $db,
            $table: $db.palmLines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> lineReadingsRefs<T extends Object>(
    Expression<T> Function($$LineReadingsTableAnnotationComposer a) f,
  ) {
    final $$LineReadingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lineReadings,
      getReferencedColumn: (t) => t.scanId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LineReadingsTableAnnotationComposer(
            $db: $db,
            $table: $db.lineReadings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> scanMessagesRefs<T extends Object>(
    Expression<T> Function($$ScanMessagesTableAnnotationComposer a) f,
  ) {
    final $$ScanMessagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.scanMessages,
      getReferencedColumn: (t) => t.scanId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScanMessagesTableAnnotationComposer(
            $db: $db,
            $table: $db.scanMessages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PalmScansTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PalmScansTable,
          PalmScan,
          $$PalmScansTableFilterComposer,
          $$PalmScansTableOrderingComposer,
          $$PalmScansTableAnnotationComposer,
          $$PalmScansTableCreateCompanionBuilder,
          $$PalmScansTableUpdateCompanionBuilder,
          (PalmScan, $$PalmScansTableReferences),
          PalmScan,
          PrefetchHooks Function({
            bool palmLinesRefs,
            bool lineReadingsRefs,
            bool scanMessagesRefs,
          })
        > {
  $$PalmScansTableTableManager(_$AppDatabase db, $PalmScansTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PalmScansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PalmScansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PalmScansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> hand = const Value.absent(),
                Value<String> imagePath = const Value.absent(),
                Value<String?> palmShape = const Value.absent(),
                Value<double?> palmWidthRatio = const Value.absent(),
                Value<String?> fingerProportionsJson = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> aiInterpretationJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => PalmScansCompanion(
                id: id,
                hand: hand,
                imagePath: imagePath,
                palmShape: palmShape,
                palmWidthRatio: palmWidthRatio,
                fingerProportionsJson: fingerProportionsJson,
                status: status,
                aiInterpretationJson: aiInterpretationJson,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String hand,
                required String imagePath,
                Value<String?> palmShape = const Value.absent(),
                Value<double?> palmWidthRatio = const Value.absent(),
                Value<String?> fingerProportionsJson = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> aiInterpretationJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => PalmScansCompanion.insert(
                id: id,
                hand: hand,
                imagePath: imagePath,
                palmShape: palmShape,
                palmWidthRatio: palmWidthRatio,
                fingerProportionsJson: fingerProportionsJson,
                status: status,
                aiInterpretationJson: aiInterpretationJson,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PalmScansTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                palmLinesRefs = false,
                lineReadingsRefs = false,
                scanMessagesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (palmLinesRefs) db.palmLines,
                    if (lineReadingsRefs) db.lineReadings,
                    if (scanMessagesRefs) db.scanMessages,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (palmLinesRefs)
                        await $_getPrefetchedData<
                          PalmScan,
                          $PalmScansTable,
                          PalmLine
                        >(
                          currentTable: table,
                          referencedTable: $$PalmScansTableReferences
                              ._palmLinesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PalmScansTableReferences(
                                db,
                                table,
                                p0,
                              ).palmLinesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.scanId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (lineReadingsRefs)
                        await $_getPrefetchedData<
                          PalmScan,
                          $PalmScansTable,
                          LineReading
                        >(
                          currentTable: table,
                          referencedTable: $$PalmScansTableReferences
                              ._lineReadingsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PalmScansTableReferences(
                                db,
                                table,
                                p0,
                              ).lineReadingsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.scanId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (scanMessagesRefs)
                        await $_getPrefetchedData<
                          PalmScan,
                          $PalmScansTable,
                          ScanMessage
                        >(
                          currentTable: table,
                          referencedTable: $$PalmScansTableReferences
                              ._scanMessagesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PalmScansTableReferences(
                                db,
                                table,
                                p0,
                              ).scanMessagesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.scanId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$PalmScansTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PalmScansTable,
      PalmScan,
      $$PalmScansTableFilterComposer,
      $$PalmScansTableOrderingComposer,
      $$PalmScansTableAnnotationComposer,
      $$PalmScansTableCreateCompanionBuilder,
      $$PalmScansTableUpdateCompanionBuilder,
      (PalmScan, $$PalmScansTableReferences),
      PalmScan,
      PrefetchHooks Function({
        bool palmLinesRefs,
        bool lineReadingsRefs,
        bool scanMessagesRefs,
      })
    >;
typedef $$PalmLinesTableCreateCompanionBuilder =
    PalmLinesCompanion Function({
      Value<int> id,
      required int scanId,
      required String lineType,
      required String controlPointsJson,
      Value<double?> length,
      Value<String?> depth,
      Value<String?> curvature,
      Value<String?> startPoint,
      Value<String?> endPoint,
      Value<bool> isUserEdited,
    });
typedef $$PalmLinesTableUpdateCompanionBuilder =
    PalmLinesCompanion Function({
      Value<int> id,
      Value<int> scanId,
      Value<String> lineType,
      Value<String> controlPointsJson,
      Value<double?> length,
      Value<String?> depth,
      Value<String?> curvature,
      Value<String?> startPoint,
      Value<String?> endPoint,
      Value<bool> isUserEdited,
    });

final class $$PalmLinesTableReferences
    extends BaseReferences<_$AppDatabase, $PalmLinesTable, PalmLine> {
  $$PalmLinesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PalmScansTable _scanIdTable(_$AppDatabase db) => db.palmScans
      .createAlias($_aliasNameGenerator(db.palmLines.scanId, db.palmScans.id));

  $$PalmScansTableProcessedTableManager get scanId {
    final $_column = $_itemColumn<int>('scan_id')!;

    final manager = $$PalmScansTableTableManager(
      $_db,
      $_db.palmScans,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_scanIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$LineReadingsTable, List<LineReading>>
  _lineReadingsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.lineReadings,
    aliasName: $_aliasNameGenerator(db.palmLines.id, db.lineReadings.lineId),
  );

  $$LineReadingsTableProcessedTableManager get lineReadingsRefs {
    final manager = $$LineReadingsTableTableManager(
      $_db,
      $_db.lineReadings,
    ).filter((f) => f.lineId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_lineReadingsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PalmLinesTableFilterComposer
    extends Composer<_$AppDatabase, $PalmLinesTable> {
  $$PalmLinesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lineType => $composableBuilder(
    column: $table.lineType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get controlPointsJson => $composableBuilder(
    column: $table.controlPointsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get length => $composableBuilder(
    column: $table.length,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get depth => $composableBuilder(
    column: $table.depth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get curvature => $composableBuilder(
    column: $table.curvature,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startPoint => $composableBuilder(
    column: $table.startPoint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endPoint => $composableBuilder(
    column: $table.endPoint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isUserEdited => $composableBuilder(
    column: $table.isUserEdited,
    builder: (column) => ColumnFilters(column),
  );

  $$PalmScansTableFilterComposer get scanId {
    final $$PalmScansTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.scanId,
      referencedTable: $db.palmScans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PalmScansTableFilterComposer(
            $db: $db,
            $table: $db.palmScans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> lineReadingsRefs(
    Expression<bool> Function($$LineReadingsTableFilterComposer f) f,
  ) {
    final $$LineReadingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lineReadings,
      getReferencedColumn: (t) => t.lineId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LineReadingsTableFilterComposer(
            $db: $db,
            $table: $db.lineReadings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PalmLinesTableOrderingComposer
    extends Composer<_$AppDatabase, $PalmLinesTable> {
  $$PalmLinesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lineType => $composableBuilder(
    column: $table.lineType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get controlPointsJson => $composableBuilder(
    column: $table.controlPointsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get length => $composableBuilder(
    column: $table.length,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get depth => $composableBuilder(
    column: $table.depth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get curvature => $composableBuilder(
    column: $table.curvature,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startPoint => $composableBuilder(
    column: $table.startPoint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endPoint => $composableBuilder(
    column: $table.endPoint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isUserEdited => $composableBuilder(
    column: $table.isUserEdited,
    builder: (column) => ColumnOrderings(column),
  );

  $$PalmScansTableOrderingComposer get scanId {
    final $$PalmScansTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.scanId,
      referencedTable: $db.palmScans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PalmScansTableOrderingComposer(
            $db: $db,
            $table: $db.palmScans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PalmLinesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PalmLinesTable> {
  $$PalmLinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get lineType =>
      $composableBuilder(column: $table.lineType, builder: (column) => column);

  GeneratedColumn<String> get controlPointsJson => $composableBuilder(
    column: $table.controlPointsJson,
    builder: (column) => column,
  );

  GeneratedColumn<double> get length =>
      $composableBuilder(column: $table.length, builder: (column) => column);

  GeneratedColumn<String> get depth =>
      $composableBuilder(column: $table.depth, builder: (column) => column);

  GeneratedColumn<String> get curvature =>
      $composableBuilder(column: $table.curvature, builder: (column) => column);

  GeneratedColumn<String> get startPoint => $composableBuilder(
    column: $table.startPoint,
    builder: (column) => column,
  );

  GeneratedColumn<String> get endPoint =>
      $composableBuilder(column: $table.endPoint, builder: (column) => column);

  GeneratedColumn<bool> get isUserEdited => $composableBuilder(
    column: $table.isUserEdited,
    builder: (column) => column,
  );

  $$PalmScansTableAnnotationComposer get scanId {
    final $$PalmScansTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.scanId,
      referencedTable: $db.palmScans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PalmScansTableAnnotationComposer(
            $db: $db,
            $table: $db.palmScans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> lineReadingsRefs<T extends Object>(
    Expression<T> Function($$LineReadingsTableAnnotationComposer a) f,
  ) {
    final $$LineReadingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lineReadings,
      getReferencedColumn: (t) => t.lineId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LineReadingsTableAnnotationComposer(
            $db: $db,
            $table: $db.lineReadings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PalmLinesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PalmLinesTable,
          PalmLine,
          $$PalmLinesTableFilterComposer,
          $$PalmLinesTableOrderingComposer,
          $$PalmLinesTableAnnotationComposer,
          $$PalmLinesTableCreateCompanionBuilder,
          $$PalmLinesTableUpdateCompanionBuilder,
          (PalmLine, $$PalmLinesTableReferences),
          PalmLine,
          PrefetchHooks Function({bool scanId, bool lineReadingsRefs})
        > {
  $$PalmLinesTableTableManager(_$AppDatabase db, $PalmLinesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PalmLinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PalmLinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PalmLinesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> scanId = const Value.absent(),
                Value<String> lineType = const Value.absent(),
                Value<String> controlPointsJson = const Value.absent(),
                Value<double?> length = const Value.absent(),
                Value<String?> depth = const Value.absent(),
                Value<String?> curvature = const Value.absent(),
                Value<String?> startPoint = const Value.absent(),
                Value<String?> endPoint = const Value.absent(),
                Value<bool> isUserEdited = const Value.absent(),
              }) => PalmLinesCompanion(
                id: id,
                scanId: scanId,
                lineType: lineType,
                controlPointsJson: controlPointsJson,
                length: length,
                depth: depth,
                curvature: curvature,
                startPoint: startPoint,
                endPoint: endPoint,
                isUserEdited: isUserEdited,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int scanId,
                required String lineType,
                required String controlPointsJson,
                Value<double?> length = const Value.absent(),
                Value<String?> depth = const Value.absent(),
                Value<String?> curvature = const Value.absent(),
                Value<String?> startPoint = const Value.absent(),
                Value<String?> endPoint = const Value.absent(),
                Value<bool> isUserEdited = const Value.absent(),
              }) => PalmLinesCompanion.insert(
                id: id,
                scanId: scanId,
                lineType: lineType,
                controlPointsJson: controlPointsJson,
                length: length,
                depth: depth,
                curvature: curvature,
                startPoint: startPoint,
                endPoint: endPoint,
                isUserEdited: isUserEdited,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PalmLinesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({scanId = false, lineReadingsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (lineReadingsRefs) db.lineReadings],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (scanId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.scanId,
                                referencedTable: $$PalmLinesTableReferences
                                    ._scanIdTable(db),
                                referencedColumn: $$PalmLinesTableReferences
                                    ._scanIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (lineReadingsRefs)
                    await $_getPrefetchedData<
                      PalmLine,
                      $PalmLinesTable,
                      LineReading
                    >(
                      currentTable: table,
                      referencedTable: $$PalmLinesTableReferences
                          ._lineReadingsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$PalmLinesTableReferences(
                            db,
                            table,
                            p0,
                          ).lineReadingsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.lineId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$PalmLinesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PalmLinesTable,
      PalmLine,
      $$PalmLinesTableFilterComposer,
      $$PalmLinesTableOrderingComposer,
      $$PalmLinesTableAnnotationComposer,
      $$PalmLinesTableCreateCompanionBuilder,
      $$PalmLinesTableUpdateCompanionBuilder,
      (PalmLine, $$PalmLinesTableReferences),
      PalmLine,
      PrefetchHooks Function({bool scanId, bool lineReadingsRefs})
    >;
typedef $$LineReadingsTableCreateCompanionBuilder =
    LineReadingsCompanion Function({
      Value<int> id,
      required int scanId,
      Value<int?> lineId,
      required String category,
      required String trait,
      required double confidence,
      required String ruleId,
      required String description,
    });
typedef $$LineReadingsTableUpdateCompanionBuilder =
    LineReadingsCompanion Function({
      Value<int> id,
      Value<int> scanId,
      Value<int?> lineId,
      Value<String> category,
      Value<String> trait,
      Value<double> confidence,
      Value<String> ruleId,
      Value<String> description,
    });

final class $$LineReadingsTableReferences
    extends BaseReferences<_$AppDatabase, $LineReadingsTable, LineReading> {
  $$LineReadingsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PalmScansTable _scanIdTable(_$AppDatabase db) =>
      db.palmScans.createAlias(
        $_aliasNameGenerator(db.lineReadings.scanId, db.palmScans.id),
      );

  $$PalmScansTableProcessedTableManager get scanId {
    final $_column = $_itemColumn<int>('scan_id')!;

    final manager = $$PalmScansTableTableManager(
      $_db,
      $_db.palmScans,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_scanIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PalmLinesTable _lineIdTable(_$AppDatabase db) =>
      db.palmLines.createAlias(
        $_aliasNameGenerator(db.lineReadings.lineId, db.palmLines.id),
      );

  $$PalmLinesTableProcessedTableManager? get lineId {
    final $_column = $_itemColumn<int>('line_id');
    if ($_column == null) return null;
    final manager = $$PalmLinesTableTableManager(
      $_db,
      $_db.palmLines,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_lineIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$LineReadingsTableFilterComposer
    extends Composer<_$AppDatabase, $LineReadingsTable> {
  $$LineReadingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get trait => $composableBuilder(
    column: $table.trait,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ruleId => $composableBuilder(
    column: $table.ruleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  $$PalmScansTableFilterComposer get scanId {
    final $$PalmScansTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.scanId,
      referencedTable: $db.palmScans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PalmScansTableFilterComposer(
            $db: $db,
            $table: $db.palmScans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PalmLinesTableFilterComposer get lineId {
    final $$PalmLinesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.lineId,
      referencedTable: $db.palmLines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PalmLinesTableFilterComposer(
            $db: $db,
            $table: $db.palmLines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LineReadingsTableOrderingComposer
    extends Composer<_$AppDatabase, $LineReadingsTable> {
  $$LineReadingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get trait => $composableBuilder(
    column: $table.trait,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ruleId => $composableBuilder(
    column: $table.ruleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  $$PalmScansTableOrderingComposer get scanId {
    final $$PalmScansTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.scanId,
      referencedTable: $db.palmScans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PalmScansTableOrderingComposer(
            $db: $db,
            $table: $db.palmScans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PalmLinesTableOrderingComposer get lineId {
    final $$PalmLinesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.lineId,
      referencedTable: $db.palmLines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PalmLinesTableOrderingComposer(
            $db: $db,
            $table: $db.palmLines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LineReadingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LineReadingsTable> {
  $$LineReadingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get trait =>
      $composableBuilder(column: $table.trait, builder: (column) => column);

  GeneratedColumn<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ruleId =>
      $composableBuilder(column: $table.ruleId, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  $$PalmScansTableAnnotationComposer get scanId {
    final $$PalmScansTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.scanId,
      referencedTable: $db.palmScans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PalmScansTableAnnotationComposer(
            $db: $db,
            $table: $db.palmScans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PalmLinesTableAnnotationComposer get lineId {
    final $$PalmLinesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.lineId,
      referencedTable: $db.palmLines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PalmLinesTableAnnotationComposer(
            $db: $db,
            $table: $db.palmLines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LineReadingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LineReadingsTable,
          LineReading,
          $$LineReadingsTableFilterComposer,
          $$LineReadingsTableOrderingComposer,
          $$LineReadingsTableAnnotationComposer,
          $$LineReadingsTableCreateCompanionBuilder,
          $$LineReadingsTableUpdateCompanionBuilder,
          (LineReading, $$LineReadingsTableReferences),
          LineReading,
          PrefetchHooks Function({bool scanId, bool lineId})
        > {
  $$LineReadingsTableTableManager(_$AppDatabase db, $LineReadingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LineReadingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LineReadingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LineReadingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> scanId = const Value.absent(),
                Value<int?> lineId = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> trait = const Value.absent(),
                Value<double> confidence = const Value.absent(),
                Value<String> ruleId = const Value.absent(),
                Value<String> description = const Value.absent(),
              }) => LineReadingsCompanion(
                id: id,
                scanId: scanId,
                lineId: lineId,
                category: category,
                trait: trait,
                confidence: confidence,
                ruleId: ruleId,
                description: description,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int scanId,
                Value<int?> lineId = const Value.absent(),
                required String category,
                required String trait,
                required double confidence,
                required String ruleId,
                required String description,
              }) => LineReadingsCompanion.insert(
                id: id,
                scanId: scanId,
                lineId: lineId,
                category: category,
                trait: trait,
                confidence: confidence,
                ruleId: ruleId,
                description: description,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$LineReadingsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({scanId = false, lineId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (scanId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.scanId,
                                referencedTable: $$LineReadingsTableReferences
                                    ._scanIdTable(db),
                                referencedColumn: $$LineReadingsTableReferences
                                    ._scanIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (lineId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.lineId,
                                referencedTable: $$LineReadingsTableReferences
                                    ._lineIdTable(db),
                                referencedColumn: $$LineReadingsTableReferences
                                    ._lineIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$LineReadingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LineReadingsTable,
      LineReading,
      $$LineReadingsTableFilterComposer,
      $$LineReadingsTableOrderingComposer,
      $$LineReadingsTableAnnotationComposer,
      $$LineReadingsTableCreateCompanionBuilder,
      $$LineReadingsTableUpdateCompanionBuilder,
      (LineReading, $$LineReadingsTableReferences),
      LineReading,
      PrefetchHooks Function({bool scanId, bool lineId})
    >;
typedef $$ScanMessagesTableCreateCompanionBuilder =
    ScanMessagesCompanion Function({
      Value<int> id,
      required int scanId,
      required String role,
      required String content,
      Value<DateTime> createdAt,
    });
typedef $$ScanMessagesTableUpdateCompanionBuilder =
    ScanMessagesCompanion Function({
      Value<int> id,
      Value<int> scanId,
      Value<String> role,
      Value<String> content,
      Value<DateTime> createdAt,
    });

final class $$ScanMessagesTableReferences
    extends BaseReferences<_$AppDatabase, $ScanMessagesTable, ScanMessage> {
  $$ScanMessagesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PalmScansTable _scanIdTable(_$AppDatabase db) =>
      db.palmScans.createAlias(
        $_aliasNameGenerator(db.scanMessages.scanId, db.palmScans.id),
      );

  $$PalmScansTableProcessedTableManager get scanId {
    final $_column = $_itemColumn<int>('scan_id')!;

    final manager = $$PalmScansTableTableManager(
      $_db,
      $_db.palmScans,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_scanIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ScanMessagesTableFilterComposer
    extends Composer<_$AppDatabase, $ScanMessagesTable> {
  $$ScanMessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$PalmScansTableFilterComposer get scanId {
    final $$PalmScansTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.scanId,
      referencedTable: $db.palmScans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PalmScansTableFilterComposer(
            $db: $db,
            $table: $db.palmScans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScanMessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $ScanMessagesTable> {
  $$ScanMessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PalmScansTableOrderingComposer get scanId {
    final $$PalmScansTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.scanId,
      referencedTable: $db.palmScans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PalmScansTableOrderingComposer(
            $db: $db,
            $table: $db.palmScans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScanMessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScanMessagesTable> {
  $$ScanMessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$PalmScansTableAnnotationComposer get scanId {
    final $$PalmScansTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.scanId,
      referencedTable: $db.palmScans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PalmScansTableAnnotationComposer(
            $db: $db,
            $table: $db.palmScans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScanMessagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ScanMessagesTable,
          ScanMessage,
          $$ScanMessagesTableFilterComposer,
          $$ScanMessagesTableOrderingComposer,
          $$ScanMessagesTableAnnotationComposer,
          $$ScanMessagesTableCreateCompanionBuilder,
          $$ScanMessagesTableUpdateCompanionBuilder,
          (ScanMessage, $$ScanMessagesTableReferences),
          ScanMessage,
          PrefetchHooks Function({bool scanId})
        > {
  $$ScanMessagesTableTableManager(_$AppDatabase db, $ScanMessagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScanMessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScanMessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScanMessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> scanId = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ScanMessagesCompanion(
                id: id,
                scanId: scanId,
                role: role,
                content: content,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int scanId,
                required String role,
                required String content,
                Value<DateTime> createdAt = const Value.absent(),
              }) => ScanMessagesCompanion.insert(
                id: id,
                scanId: scanId,
                role: role,
                content: content,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ScanMessagesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({scanId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (scanId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.scanId,
                                referencedTable: $$ScanMessagesTableReferences
                                    ._scanIdTable(db),
                                referencedColumn: $$ScanMessagesTableReferences
                                    ._scanIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ScanMessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ScanMessagesTable,
      ScanMessage,
      $$ScanMessagesTableFilterComposer,
      $$ScanMessagesTableOrderingComposer,
      $$ScanMessagesTableAnnotationComposer,
      $$ScanMessagesTableCreateCompanionBuilder,
      $$ScanMessagesTableUpdateCompanionBuilder,
      (ScanMessage, $$ScanMessagesTableReferences),
      ScanMessage,
      PrefetchHooks Function({bool scanId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PalmScansTableTableManager get palmScans =>
      $$PalmScansTableTableManager(_db, _db.palmScans);
  $$PalmLinesTableTableManager get palmLines =>
      $$PalmLinesTableTableManager(_db, _db.palmLines);
  $$LineReadingsTableTableManager get lineReadings =>
      $$LineReadingsTableTableManager(_db, _db.lineReadings);
  $$ScanMessagesTableTableManager get scanMessages =>
      $$ScanMessagesTableTableManager(_db, _db.scanMessages);
}
