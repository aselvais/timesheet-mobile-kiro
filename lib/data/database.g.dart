// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $TasksTable extends Tasks with TableInfo<$TasksTable, TaskData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
      'label', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, label, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasks';
  @override
  VerificationContext validateIntegrity(Insertable<TaskData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
          _labelMeta, label.isAcceptableOrUnknown(data['label']!, _labelMeta));
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TaskData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      label: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}label'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $TasksTable createAlias(String alias) {
    return $TasksTable(attachedDatabase, alias);
  }
}

class TaskData extends DataClass implements Insertable<TaskData> {
  final String id;
  final String label;
  final int createdAt;
  const TaskData(
      {required this.id, required this.label, required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['label'] = Variable<String>(label);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  TasksCompanion toCompanion(bool nullToAbsent) {
    return TasksCompanion(
      id: Value(id),
      label: Value(label),
      createdAt: Value(createdAt),
    );
  }

  factory TaskData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskData(
      id: serializer.fromJson<String>(json['id']),
      label: serializer.fromJson<String>(json['label']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'label': serializer.toJson<String>(label),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  TaskData copyWith({String? id, String? label, int? createdAt}) => TaskData(
        id: id ?? this.id,
        label: label ?? this.label,
        createdAt: createdAt ?? this.createdAt,
      );
  TaskData copyWithCompanion(TasksCompanion data) {
    return TaskData(
      id: data.id.present ? data.id.value : this.id,
      label: data.label.present ? data.label.value : this.label,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskData(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, label, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskData &&
          other.id == this.id &&
          other.label == this.label &&
          other.createdAt == this.createdAt);
}

class TasksCompanion extends UpdateCompanion<TaskData> {
  final Value<String> id;
  final Value<String> label;
  final Value<int> createdAt;
  final Value<int> rowid;
  const TasksCompanion({
    this.id = const Value.absent(),
    this.label = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TasksCompanion.insert({
    required String id,
    required String label,
    required int createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        label = Value(label),
        createdAt = Value(createdAt);
  static Insertable<TaskData> custom({
    Expression<String>? id,
    Expression<String>? label,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (label != null) 'label': label,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TasksCompanion copyWith(
      {Value<String>? id,
      Value<String>? label,
      Value<int>? createdAt,
      Value<int>? rowid}) {
    return TasksCompanion(
      id: id ?? this.id,
      label: label ?? this.label,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasksCompanion(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TimeLogsTable extends TimeLogs
    with TableInfo<$TimeLogsTable, TimeLogData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TimeLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
      'task_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES tasks (id) ON DELETE CASCADE'));
  static const VerificationMeta _startTimeMeta =
      const VerificationMeta('startTime');
  @override
  late final GeneratedColumn<int> startTime = GeneratedColumn<int>(
      'start_time', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _endTimeMeta =
      const VerificationMeta('endTime');
  @override
  late final GeneratedColumn<int> endTime = GeneratedColumn<int>(
      'end_time', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [id, taskId, startTime, endTime];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'time_logs';
  @override
  VerificationContext validateIntegrity(Insertable<TimeLogData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('task_id')) {
      context.handle(_taskIdMeta,
          taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta));
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('start_time')) {
      context.handle(_startTimeMeta,
          startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta));
    } else if (isInserting) {
      context.missing(_startTimeMeta);
    }
    if (data.containsKey('end_time')) {
      context.handle(_endTimeMeta,
          endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TimeLogData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TimeLogData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      taskId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}task_id'])!,
      startTime: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}start_time'])!,
      endTime: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}end_time']),
    );
  }

  @override
  $TimeLogsTable createAlias(String alias) {
    return $TimeLogsTable(attachedDatabase, alias);
  }
}

class TimeLogData extends DataClass implements Insertable<TimeLogData> {
  final String id;
  final String taskId;
  final int startTime;
  final int? endTime;
  const TimeLogData(
      {required this.id,
      required this.taskId,
      required this.startTime,
      this.endTime});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['task_id'] = Variable<String>(taskId);
    map['start_time'] = Variable<int>(startTime);
    if (!nullToAbsent || endTime != null) {
      map['end_time'] = Variable<int>(endTime);
    }
    return map;
  }

  TimeLogsCompanion toCompanion(bool nullToAbsent) {
    return TimeLogsCompanion(
      id: Value(id),
      taskId: Value(taskId),
      startTime: Value(startTime),
      endTime: endTime == null && nullToAbsent
          ? const Value.absent()
          : Value(endTime),
    );
  }

  factory TimeLogData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TimeLogData(
      id: serializer.fromJson<String>(json['id']),
      taskId: serializer.fromJson<String>(json['taskId']),
      startTime: serializer.fromJson<int>(json['startTime']),
      endTime: serializer.fromJson<int?>(json['endTime']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'taskId': serializer.toJson<String>(taskId),
      'startTime': serializer.toJson<int>(startTime),
      'endTime': serializer.toJson<int?>(endTime),
    };
  }

  TimeLogData copyWith(
          {String? id,
          String? taskId,
          int? startTime,
          Value<int?> endTime = const Value.absent()}) =>
      TimeLogData(
        id: id ?? this.id,
        taskId: taskId ?? this.taskId,
        startTime: startTime ?? this.startTime,
        endTime: endTime.present ? endTime.value : this.endTime,
      );
  TimeLogData copyWithCompanion(TimeLogsCompanion data) {
    return TimeLogData(
      id: data.id.present ? data.id.value : this.id,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TimeLogData(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, taskId, startTime, endTime);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TimeLogData &&
          other.id == this.id &&
          other.taskId == this.taskId &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime);
}

class TimeLogsCompanion extends UpdateCompanion<TimeLogData> {
  final Value<String> id;
  final Value<String> taskId;
  final Value<int> startTime;
  final Value<int?> endTime;
  final Value<int> rowid;
  const TimeLogsCompanion({
    this.id = const Value.absent(),
    this.taskId = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TimeLogsCompanion.insert({
    required String id,
    required String taskId,
    required int startTime,
    this.endTime = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        taskId = Value(taskId),
        startTime = Value(startTime);
  static Insertable<TimeLogData> custom({
    Expression<String>? id,
    Expression<String>? taskId,
    Expression<int>? startTime,
    Expression<int>? endTime,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (taskId != null) 'task_id': taskId,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TimeLogsCompanion copyWith(
      {Value<String>? id,
      Value<String>? taskId,
      Value<int>? startTime,
      Value<int?>? endTime,
      Value<int>? rowid}) {
    return TimeLogsCompanion(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<int>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<int>(endTime.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TimeLogsCompanion(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TagsTable extends Tags with TableInfo<$TagsTable, TagData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _colorValueMeta =
      const VerificationMeta('colorValue');
  @override
  late final GeneratedColumn<int> colorValue = GeneratedColumn<int>(
      'color_value', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, name, colorValue];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tags';
  @override
  VerificationContext validateIntegrity(Insertable<TagData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color_value')) {
      context.handle(
          _colorValueMeta,
          colorValue.isAcceptableOrUnknown(
              data['color_value']!, _colorValueMeta));
    } else if (isInserting) {
      context.missing(_colorValueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TagData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TagData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      colorValue: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}color_value'])!,
    );
  }

  @override
  $TagsTable createAlias(String alias) {
    return $TagsTable(attachedDatabase, alias);
  }
}

class TagData extends DataClass implements Insertable<TagData> {
  final String id;
  final String name;

  /// Color stored as ARGB integer.
  final int colorValue;
  const TagData(
      {required this.id, required this.name, required this.colorValue});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['color_value'] = Variable<int>(colorValue);
    return map;
  }

  TagsCompanion toCompanion(bool nullToAbsent) {
    return TagsCompanion(
      id: Value(id),
      name: Value(name),
      colorValue: Value(colorValue),
    );
  }

  factory TagData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TagData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      colorValue: serializer.fromJson<int>(json['colorValue']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'colorValue': serializer.toJson<int>(colorValue),
    };
  }

  TagData copyWith({String? id, String? name, int? colorValue}) => TagData(
        id: id ?? this.id,
        name: name ?? this.name,
        colorValue: colorValue ?? this.colorValue,
      );
  TagData copyWithCompanion(TagsCompanion data) {
    return TagData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      colorValue:
          data.colorValue.present ? data.colorValue.value : this.colorValue,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TagData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('colorValue: $colorValue')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, colorValue);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TagData &&
          other.id == this.id &&
          other.name == this.name &&
          other.colorValue == this.colorValue);
}

class TagsCompanion extends UpdateCompanion<TagData> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> colorValue;
  final Value<int> rowid;
  const TagsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.colorValue = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TagsCompanion.insert({
    required String id,
    required String name,
    required int colorValue,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        colorValue = Value(colorValue);
  static Insertable<TagData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? colorValue,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (colorValue != null) 'color_value': colorValue,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TagsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<int>? colorValue,
      Value<int>? rowid}) {
    return TagsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      colorValue: colorValue ?? this.colorValue,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (colorValue.present) {
      map['color_value'] = Variable<int>(colorValue.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('colorValue: $colorValue, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TaskTagsTable extends TaskTags
    with TableInfo<$TaskTagsTable, TaskTagData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TaskTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
      'task_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES tasks (id) ON DELETE CASCADE'));
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  @override
  late final GeneratedColumn<String> tagId = GeneratedColumn<String>(
      'tag_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES tags (id) ON DELETE CASCADE'));
  @override
  List<GeneratedColumn> get $columns => [taskId, tagId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'task_tags';
  @override
  VerificationContext validateIntegrity(Insertable<TaskTagData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('task_id')) {
      context.handle(_taskIdMeta,
          taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta));
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('tag_id')) {
      context.handle(
          _tagIdMeta, tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta));
    } else if (isInserting) {
      context.missing(_tagIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {taskId, tagId};
  @override
  TaskTagData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskTagData(
      taskId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}task_id'])!,
      tagId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tag_id'])!,
    );
  }

  @override
  $TaskTagsTable createAlias(String alias) {
    return $TaskTagsTable(attachedDatabase, alias);
  }
}

class TaskTagData extends DataClass implements Insertable<TaskTagData> {
  final String taskId;
  final String tagId;
  const TaskTagData({required this.taskId, required this.tagId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['task_id'] = Variable<String>(taskId);
    map['tag_id'] = Variable<String>(tagId);
    return map;
  }

  TaskTagsCompanion toCompanion(bool nullToAbsent) {
    return TaskTagsCompanion(
      taskId: Value(taskId),
      tagId: Value(tagId),
    );
  }

  factory TaskTagData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskTagData(
      taskId: serializer.fromJson<String>(json['taskId']),
      tagId: serializer.fromJson<String>(json['tagId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'taskId': serializer.toJson<String>(taskId),
      'tagId': serializer.toJson<String>(tagId),
    };
  }

  TaskTagData copyWith({String? taskId, String? tagId}) => TaskTagData(
        taskId: taskId ?? this.taskId,
        tagId: tagId ?? this.tagId,
      );
  TaskTagData copyWithCompanion(TaskTagsCompanion data) {
    return TaskTagData(
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskTagData(')
          ..write('taskId: $taskId, ')
          ..write('tagId: $tagId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(taskId, tagId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskTagData &&
          other.taskId == this.taskId &&
          other.tagId == this.tagId);
}

class TaskTagsCompanion extends UpdateCompanion<TaskTagData> {
  final Value<String> taskId;
  final Value<String> tagId;
  final Value<int> rowid;
  const TaskTagsCompanion({
    this.taskId = const Value.absent(),
    this.tagId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TaskTagsCompanion.insert({
    required String taskId,
    required String tagId,
    this.rowid = const Value.absent(),
  })  : taskId = Value(taskId),
        tagId = Value(tagId);
  static Insertable<TaskTagData> custom({
    Expression<String>? taskId,
    Expression<String>? tagId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (taskId != null) 'task_id': taskId,
      if (tagId != null) 'tag_id': tagId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TaskTagsCompanion copyWith(
      {Value<String>? taskId, Value<String>? tagId, Value<int>? rowid}) {
    return TaskTagsCompanion(
      taskId: taskId ?? this.taskId,
      tagId: tagId ?? this.tagId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (tagId.present) {
      map['tag_id'] = Variable<String>(tagId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TaskTagsCompanion(')
          ..write('taskId: $taskId, ')
          ..write('tagId: $tagId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TasksTable tasks = $TasksTable(this);
  late final $TimeLogsTable timeLogs = $TimeLogsTable(this);
  late final $TagsTable tags = $TagsTable(this);
  late final $TaskTagsTable taskTags = $TaskTagsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [tasks, timeLogs, tags, taskTags];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('tasks',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('time_logs', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('tasks',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('task_tags', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('tags',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('task_tags', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
}

typedef $$TasksTableCreateCompanionBuilder = TasksCompanion Function({
  required String id,
  required String label,
  required int createdAt,
  Value<int> rowid,
});
typedef $$TasksTableUpdateCompanionBuilder = TasksCompanion Function({
  Value<String> id,
  Value<String> label,
  Value<int> createdAt,
  Value<int> rowid,
});

final class $$TasksTableReferences
    extends BaseReferences<_$AppDatabase, $TasksTable, TaskData> {
  $$TasksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TimeLogsTable, List<TimeLogData>>
      _timeLogsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.timeLogs,
              aliasName: $_aliasNameGenerator(db.tasks.id, db.timeLogs.taskId));

  $$TimeLogsTableProcessedTableManager get timeLogsRefs {
    final manager = $$TimeLogsTableTableManager($_db, $_db.timeLogs)
        .filter((f) => f.taskId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_timeLogsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$TaskTagsTable, List<TaskTagData>>
      _taskTagsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.taskTags,
              aliasName: $_aliasNameGenerator(db.tasks.id, db.taskTags.taskId));

  $$TaskTagsTableProcessedTableManager get taskTagsRefs {
    final manager = $$TaskTagsTableTableManager($_db, $_db.taskTags)
        .filter((f) => f.taskId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_taskTagsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$TasksTableFilterComposer extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  Expression<bool> timeLogsRefs(
      Expression<bool> Function($$TimeLogsTableFilterComposer f) f) {
    final $$TimeLogsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.timeLogs,
        getReferencedColumn: (t) => t.taskId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TimeLogsTableFilterComposer(
              $db: $db,
              $table: $db.timeLogs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> taskTagsRefs(
      Expression<bool> Function($$TaskTagsTableFilterComposer f) f) {
    final $$TaskTagsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.taskTags,
        getReferencedColumn: (t) => t.taskId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TaskTagsTableFilterComposer(
              $db: $db,
              $table: $db.taskTags,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TasksTableOrderingComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$TasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> timeLogsRefs<T extends Object>(
      Expression<T> Function($$TimeLogsTableAnnotationComposer a) f) {
    final $$TimeLogsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.timeLogs,
        getReferencedColumn: (t) => t.taskId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TimeLogsTableAnnotationComposer(
              $db: $db,
              $table: $db.timeLogs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> taskTagsRefs<T extends Object>(
      Expression<T> Function($$TaskTagsTableAnnotationComposer a) f) {
    final $$TaskTagsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.taskTags,
        getReferencedColumn: (t) => t.taskId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TaskTagsTableAnnotationComposer(
              $db: $db,
              $table: $db.taskTags,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TasksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TasksTable,
    TaskData,
    $$TasksTableFilterComposer,
    $$TasksTableOrderingComposer,
    $$TasksTableAnnotationComposer,
    $$TasksTableCreateCompanionBuilder,
    $$TasksTableUpdateCompanionBuilder,
    (TaskData, $$TasksTableReferences),
    TaskData,
    PrefetchHooks Function({bool timeLogsRefs, bool taskTagsRefs})> {
  $$TasksTableTableManager(_$AppDatabase db, $TasksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> label = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TasksCompanion(
            id: id,
            label: label,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String label,
            required int createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              TasksCompanion.insert(
            id: id,
            label: label,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$TasksTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {timeLogsRefs = false, taskTagsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (timeLogsRefs) db.timeLogs,
                if (taskTagsRefs) db.taskTags
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (timeLogsRefs)
                    await $_getPrefetchedData<TaskData, $TasksTable,
                            TimeLogData>(
                        currentTable: table,
                        referencedTable:
                            $$TasksTableReferences._timeLogsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TasksTableReferences(db, table, p0).timeLogsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.taskId == item.id),
                        typedResults: items),
                  if (taskTagsRefs)
                    await $_getPrefetchedData<TaskData, $TasksTable,
                            TaskTagData>(
                        currentTable: table,
                        referencedTable:
                            $$TasksTableReferences._taskTagsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TasksTableReferences(db, table, p0).taskTagsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.taskId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$TasksTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TasksTable,
    TaskData,
    $$TasksTableFilterComposer,
    $$TasksTableOrderingComposer,
    $$TasksTableAnnotationComposer,
    $$TasksTableCreateCompanionBuilder,
    $$TasksTableUpdateCompanionBuilder,
    (TaskData, $$TasksTableReferences),
    TaskData,
    PrefetchHooks Function({bool timeLogsRefs, bool taskTagsRefs})>;
typedef $$TimeLogsTableCreateCompanionBuilder = TimeLogsCompanion Function({
  required String id,
  required String taskId,
  required int startTime,
  Value<int?> endTime,
  Value<int> rowid,
});
typedef $$TimeLogsTableUpdateCompanionBuilder = TimeLogsCompanion Function({
  Value<String> id,
  Value<String> taskId,
  Value<int> startTime,
  Value<int?> endTime,
  Value<int> rowid,
});

final class $$TimeLogsTableReferences
    extends BaseReferences<_$AppDatabase, $TimeLogsTable, TimeLogData> {
  $$TimeLogsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TasksTable _taskIdTable(_$AppDatabase db) => db.tasks
      .createAlias($_aliasNameGenerator(db.timeLogs.taskId, db.tasks.id));

  $$TasksTableProcessedTableManager get taskId {
    final $_column = $_itemColumn<String>('task_id')!;

    final manager = $$TasksTableTableManager($_db, $_db.tasks)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_taskIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$TimeLogsTableFilterComposer
    extends Composer<_$AppDatabase, $TimeLogsTable> {
  $$TimeLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get startTime => $composableBuilder(
      column: $table.startTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get endTime => $composableBuilder(
      column: $table.endTime, builder: (column) => ColumnFilters(column));

  $$TasksTableFilterComposer get taskId {
    final $$TasksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.taskId,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableFilterComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TimeLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $TimeLogsTable> {
  $$TimeLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get startTime => $composableBuilder(
      column: $table.startTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get endTime => $composableBuilder(
      column: $table.endTime, builder: (column) => ColumnOrderings(column));

  $$TasksTableOrderingComposer get taskId {
    final $$TasksTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.taskId,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableOrderingComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TimeLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TimeLogsTable> {
  $$TimeLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<int> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  $$TasksTableAnnotationComposer get taskId {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.taskId,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableAnnotationComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TimeLogsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TimeLogsTable,
    TimeLogData,
    $$TimeLogsTableFilterComposer,
    $$TimeLogsTableOrderingComposer,
    $$TimeLogsTableAnnotationComposer,
    $$TimeLogsTableCreateCompanionBuilder,
    $$TimeLogsTableUpdateCompanionBuilder,
    (TimeLogData, $$TimeLogsTableReferences),
    TimeLogData,
    PrefetchHooks Function({bool taskId})> {
  $$TimeLogsTableTableManager(_$AppDatabase db, $TimeLogsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TimeLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TimeLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TimeLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> taskId = const Value.absent(),
            Value<int> startTime = const Value.absent(),
            Value<int?> endTime = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TimeLogsCompanion(
            id: id,
            taskId: taskId,
            startTime: startTime,
            endTime: endTime,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String taskId,
            required int startTime,
            Value<int?> endTime = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TimeLogsCompanion.insert(
            id: id,
            taskId: taskId,
            startTime: startTime,
            endTime: endTime,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$TimeLogsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({taskId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (taskId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.taskId,
                    referencedTable: $$TimeLogsTableReferences._taskIdTable(db),
                    referencedColumn:
                        $$TimeLogsTableReferences._taskIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$TimeLogsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TimeLogsTable,
    TimeLogData,
    $$TimeLogsTableFilterComposer,
    $$TimeLogsTableOrderingComposer,
    $$TimeLogsTableAnnotationComposer,
    $$TimeLogsTableCreateCompanionBuilder,
    $$TimeLogsTableUpdateCompanionBuilder,
    (TimeLogData, $$TimeLogsTableReferences),
    TimeLogData,
    PrefetchHooks Function({bool taskId})>;
typedef $$TagsTableCreateCompanionBuilder = TagsCompanion Function({
  required String id,
  required String name,
  required int colorValue,
  Value<int> rowid,
});
typedef $$TagsTableUpdateCompanionBuilder = TagsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<int> colorValue,
  Value<int> rowid,
});

final class $$TagsTableReferences
    extends BaseReferences<_$AppDatabase, $TagsTable, TagData> {
  $$TagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TaskTagsTable, List<TaskTagData>>
      _taskTagsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.taskTags,
              aliasName: $_aliasNameGenerator(db.tags.id, db.taskTags.tagId));

  $$TaskTagsTableProcessedTableManager get taskTagsRefs {
    final manager = $$TaskTagsTableTableManager($_db, $_db.taskTags)
        .filter((f) => f.tagId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_taskTagsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$TagsTableFilterComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get colorValue => $composableBuilder(
      column: $table.colorValue, builder: (column) => ColumnFilters(column));

  Expression<bool> taskTagsRefs(
      Expression<bool> Function($$TaskTagsTableFilterComposer f) f) {
    final $$TaskTagsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.taskTags,
        getReferencedColumn: (t) => t.tagId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TaskTagsTableFilterComposer(
              $db: $db,
              $table: $db.taskTags,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TagsTableOrderingComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get colorValue => $composableBuilder(
      column: $table.colorValue, builder: (column) => ColumnOrderings(column));
}

class $$TagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get colorValue => $composableBuilder(
      column: $table.colorValue, builder: (column) => column);

  Expression<T> taskTagsRefs<T extends Object>(
      Expression<T> Function($$TaskTagsTableAnnotationComposer a) f) {
    final $$TaskTagsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.taskTags,
        getReferencedColumn: (t) => t.tagId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TaskTagsTableAnnotationComposer(
              $db: $db,
              $table: $db.taskTags,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TagsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TagsTable,
    TagData,
    $$TagsTableFilterComposer,
    $$TagsTableOrderingComposer,
    $$TagsTableAnnotationComposer,
    $$TagsTableCreateCompanionBuilder,
    $$TagsTableUpdateCompanionBuilder,
    (TagData, $$TagsTableReferences),
    TagData,
    PrefetchHooks Function({bool taskTagsRefs})> {
  $$TagsTableTableManager(_$AppDatabase db, $TagsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> colorValue = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TagsCompanion(
            id: id,
            name: name,
            colorValue: colorValue,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required int colorValue,
            Value<int> rowid = const Value.absent(),
          }) =>
              TagsCompanion.insert(
            id: id,
            name: name,
            colorValue: colorValue,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$TagsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({taskTagsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (taskTagsRefs) db.taskTags],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (taskTagsRefs)
                    await $_getPrefetchedData<TagData, $TagsTable, TaskTagData>(
                        currentTable: table,
                        referencedTable:
                            $$TagsTableReferences._taskTagsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TagsTableReferences(db, table, p0).taskTagsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.tagId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$TagsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TagsTable,
    TagData,
    $$TagsTableFilterComposer,
    $$TagsTableOrderingComposer,
    $$TagsTableAnnotationComposer,
    $$TagsTableCreateCompanionBuilder,
    $$TagsTableUpdateCompanionBuilder,
    (TagData, $$TagsTableReferences),
    TagData,
    PrefetchHooks Function({bool taskTagsRefs})>;
typedef $$TaskTagsTableCreateCompanionBuilder = TaskTagsCompanion Function({
  required String taskId,
  required String tagId,
  Value<int> rowid,
});
typedef $$TaskTagsTableUpdateCompanionBuilder = TaskTagsCompanion Function({
  Value<String> taskId,
  Value<String> tagId,
  Value<int> rowid,
});

final class $$TaskTagsTableReferences
    extends BaseReferences<_$AppDatabase, $TaskTagsTable, TaskTagData> {
  $$TaskTagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TasksTable _taskIdTable(_$AppDatabase db) => db.tasks
      .createAlias($_aliasNameGenerator(db.taskTags.taskId, db.tasks.id));

  $$TasksTableProcessedTableManager get taskId {
    final $_column = $_itemColumn<String>('task_id')!;

    final manager = $$TasksTableTableManager($_db, $_db.tasks)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_taskIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $TagsTable _tagIdTable(_$AppDatabase db) =>
      db.tags.createAlias($_aliasNameGenerator(db.taskTags.tagId, db.tags.id));

  $$TagsTableProcessedTableManager get tagId {
    final $_column = $_itemColumn<String>('tag_id')!;

    final manager = $$TagsTableTableManager($_db, $_db.tags)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tagIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$TaskTagsTableFilterComposer
    extends Composer<_$AppDatabase, $TaskTagsTable> {
  $$TaskTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$TasksTableFilterComposer get taskId {
    final $$TasksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.taskId,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableFilterComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TagsTableFilterComposer get tagId {
    final $$TagsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.tagId,
        referencedTable: $db.tags,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TagsTableFilterComposer(
              $db: $db,
              $table: $db.tags,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TaskTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $TaskTagsTable> {
  $$TaskTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$TasksTableOrderingComposer get taskId {
    final $$TasksTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.taskId,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableOrderingComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TagsTableOrderingComposer get tagId {
    final $$TagsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.tagId,
        referencedTable: $db.tags,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TagsTableOrderingComposer(
              $db: $db,
              $table: $db.tags,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TaskTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TaskTagsTable> {
  $$TaskTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$TasksTableAnnotationComposer get taskId {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.taskId,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableAnnotationComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TagsTableAnnotationComposer get tagId {
    final $$TagsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.tagId,
        referencedTable: $db.tags,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TagsTableAnnotationComposer(
              $db: $db,
              $table: $db.tags,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TaskTagsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TaskTagsTable,
    TaskTagData,
    $$TaskTagsTableFilterComposer,
    $$TaskTagsTableOrderingComposer,
    $$TaskTagsTableAnnotationComposer,
    $$TaskTagsTableCreateCompanionBuilder,
    $$TaskTagsTableUpdateCompanionBuilder,
    (TaskTagData, $$TaskTagsTableReferences),
    TaskTagData,
    PrefetchHooks Function({bool taskId, bool tagId})> {
  $$TaskTagsTableTableManager(_$AppDatabase db, $TaskTagsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TaskTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TaskTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TaskTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> taskId = const Value.absent(),
            Value<String> tagId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TaskTagsCompanion(
            taskId: taskId,
            tagId: tagId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String taskId,
            required String tagId,
            Value<int> rowid = const Value.absent(),
          }) =>
              TaskTagsCompanion.insert(
            taskId: taskId,
            tagId: tagId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$TaskTagsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({taskId = false, tagId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (taskId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.taskId,
                    referencedTable: $$TaskTagsTableReferences._taskIdTable(db),
                    referencedColumn:
                        $$TaskTagsTableReferences._taskIdTable(db).id,
                  ) as T;
                }
                if (tagId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.tagId,
                    referencedTable: $$TaskTagsTableReferences._tagIdTable(db),
                    referencedColumn:
                        $$TaskTagsTableReferences._tagIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$TaskTagsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TaskTagsTable,
    TaskTagData,
    $$TaskTagsTableFilterComposer,
    $$TaskTagsTableOrderingComposer,
    $$TaskTagsTableAnnotationComposer,
    $$TaskTagsTableCreateCompanionBuilder,
    $$TaskTagsTableUpdateCompanionBuilder,
    (TaskTagData, $$TaskTagsTableReferences),
    TaskTagData,
    PrefetchHooks Function({bool taskId, bool tagId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db, _db.tasks);
  $$TimeLogsTableTableManager get timeLogs =>
      $$TimeLogsTableTableManager(_db, _db.timeLogs);
  $$TagsTableTableManager get tags => $$TagsTableTableManager(_db, _db.tags);
  $$TaskTagsTableTableManager get taskTags =>
      $$TaskTagsTableTableManager(_db, _db.taskTags);
}
