// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, Transaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _merchantMeta =
      const VerificationMeta('merchant');
  @override
  late final GeneratedColumn<String> merchant = GeneratedColumn<String>(
      'merchant', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('Other'));
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
      'source', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isRecurringMeta =
      const VerificationMeta('isRecurring');
  @override
  late final GeneratedColumn<bool> isRecurring = GeneratedColumn<bool>(
      'is_recurring', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_recurring" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _rawDataMeta =
      const VerificationMeta('rawData');
  @override
  late final GeneratedColumn<String> rawData = GeneratedColumn<String>(
      'raw_data', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        amount,
        merchant,
        date,
        category,
        source,
        isRecurring,
        rawData,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(Insertable<Transaction> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('merchant')) {
      context.handle(_merchantMeta,
          merchant.isAcceptableOrUnknown(data['merchant']!, _merchantMeta));
    } else if (isInserting) {
      context.missing(_merchantMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    }
    if (data.containsKey('source')) {
      context.handle(_sourceMeta,
          source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('is_recurring')) {
      context.handle(
          _isRecurringMeta,
          isRecurring.isAcceptableOrUnknown(
              data['is_recurring']!, _isRecurringMeta));
    }
    if (data.containsKey('raw_data')) {
      context.handle(_rawDataMeta,
          rawData.isAcceptableOrUnknown(data['raw_data']!, _rawDataMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Transaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Transaction(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      merchant: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}merchant'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      source: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source'])!,
      isRecurring: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_recurring'])!,
      rawData: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}raw_data']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }
}

class Transaction extends DataClass implements Insertable<Transaction> {
  final int id;
  final double amount;
  final String merchant;
  final DateTime date;
  final String category;
  final String source;
  final bool isRecurring;
  final String? rawData;
  final DateTime createdAt;
  const Transaction(
      {required this.id,
      required this.amount,
      required this.merchant,
      required this.date,
      required this.category,
      required this.source,
      required this.isRecurring,
      this.rawData,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['amount'] = Variable<double>(amount);
    map['merchant'] = Variable<String>(merchant);
    map['date'] = Variable<DateTime>(date);
    map['category'] = Variable<String>(category);
    map['source'] = Variable<String>(source);
    map['is_recurring'] = Variable<bool>(isRecurring);
    if (!nullToAbsent || rawData != null) {
      map['raw_data'] = Variable<String>(rawData);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      id: Value(id),
      amount: Value(amount),
      merchant: Value(merchant),
      date: Value(date),
      category: Value(category),
      source: Value(source),
      isRecurring: Value(isRecurring),
      rawData: rawData == null && nullToAbsent
          ? const Value.absent()
          : Value(rawData),
      createdAt: Value(createdAt),
    );
  }

  factory Transaction.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Transaction(
      id: serializer.fromJson<int>(json['id']),
      amount: serializer.fromJson<double>(json['amount']),
      merchant: serializer.fromJson<String>(json['merchant']),
      date: serializer.fromJson<DateTime>(json['date']),
      category: serializer.fromJson<String>(json['category']),
      source: serializer.fromJson<String>(json['source']),
      isRecurring: serializer.fromJson<bool>(json['isRecurring']),
      rawData: serializer.fromJson<String?>(json['rawData']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'amount': serializer.toJson<double>(amount),
      'merchant': serializer.toJson<String>(merchant),
      'date': serializer.toJson<DateTime>(date),
      'category': serializer.toJson<String>(category),
      'source': serializer.toJson<String>(source),
      'isRecurring': serializer.toJson<bool>(isRecurring),
      'rawData': serializer.toJson<String?>(rawData),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Transaction copyWith(
          {int? id,
          double? amount,
          String? merchant,
          DateTime? date,
          String? category,
          String? source,
          bool? isRecurring,
          Value<String?> rawData = const Value.absent(),
          DateTime? createdAt}) =>
      Transaction(
        id: id ?? this.id,
        amount: amount ?? this.amount,
        merchant: merchant ?? this.merchant,
        date: date ?? this.date,
        category: category ?? this.category,
        source: source ?? this.source,
        isRecurring: isRecurring ?? this.isRecurring,
        rawData: rawData.present ? rawData.value : this.rawData,
        createdAt: createdAt ?? this.createdAt,
      );
  Transaction copyWithCompanion(TransactionsCompanion data) {
    return Transaction(
      id: data.id.present ? data.id.value : this.id,
      amount: data.amount.present ? data.amount.value : this.amount,
      merchant: data.merchant.present ? data.merchant.value : this.merchant,
      date: data.date.present ? data.date.value : this.date,
      category: data.category.present ? data.category.value : this.category,
      source: data.source.present ? data.source.value : this.source,
      isRecurring:
          data.isRecurring.present ? data.isRecurring.value : this.isRecurring,
      rawData: data.rawData.present ? data.rawData.value : this.rawData,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Transaction(')
          ..write('id: $id, ')
          ..write('amount: $amount, ')
          ..write('merchant: $merchant, ')
          ..write('date: $date, ')
          ..write('category: $category, ')
          ..write('source: $source, ')
          ..write('isRecurring: $isRecurring, ')
          ..write('rawData: $rawData, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, amount, merchant, date, category, source,
      isRecurring, rawData, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Transaction &&
          other.id == this.id &&
          other.amount == this.amount &&
          other.merchant == this.merchant &&
          other.date == this.date &&
          other.category == this.category &&
          other.source == this.source &&
          other.isRecurring == this.isRecurring &&
          other.rawData == this.rawData &&
          other.createdAt == this.createdAt);
}

class TransactionsCompanion extends UpdateCompanion<Transaction> {
  final Value<int> id;
  final Value<double> amount;
  final Value<String> merchant;
  final Value<DateTime> date;
  final Value<String> category;
  final Value<String> source;
  final Value<bool> isRecurring;
  final Value<String?> rawData;
  final Value<DateTime> createdAt;
  const TransactionsCompanion({
    this.id = const Value.absent(),
    this.amount = const Value.absent(),
    this.merchant = const Value.absent(),
    this.date = const Value.absent(),
    this.category = const Value.absent(),
    this.source = const Value.absent(),
    this.isRecurring = const Value.absent(),
    this.rawData = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  TransactionsCompanion.insert({
    this.id = const Value.absent(),
    required double amount,
    required String merchant,
    required DateTime date,
    this.category = const Value.absent(),
    required String source,
    this.isRecurring = const Value.absent(),
    this.rawData = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : amount = Value(amount),
        merchant = Value(merchant),
        date = Value(date),
        source = Value(source);
  static Insertable<Transaction> custom({
    Expression<int>? id,
    Expression<double>? amount,
    Expression<String>? merchant,
    Expression<DateTime>? date,
    Expression<String>? category,
    Expression<String>? source,
    Expression<bool>? isRecurring,
    Expression<String>? rawData,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (amount != null) 'amount': amount,
      if (merchant != null) 'merchant': merchant,
      if (date != null) 'date': date,
      if (category != null) 'category': category,
      if (source != null) 'source': source,
      if (isRecurring != null) 'is_recurring': isRecurring,
      if (rawData != null) 'raw_data': rawData,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  TransactionsCompanion copyWith(
      {Value<int>? id,
      Value<double>? amount,
      Value<String>? merchant,
      Value<DateTime>? date,
      Value<String>? category,
      Value<String>? source,
      Value<bool>? isRecurring,
      Value<String?>? rawData,
      Value<DateTime>? createdAt}) {
    return TransactionsCompanion(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      merchant: merchant ?? this.merchant,
      date: date ?? this.date,
      category: category ?? this.category,
      source: source ?? this.source,
      isRecurring: isRecurring ?? this.isRecurring,
      rawData: rawData ?? this.rawData,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (merchant.present) {
      map['merchant'] = Variable<String>(merchant.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (isRecurring.present) {
      map['is_recurring'] = Variable<bool>(isRecurring.value);
    }
    if (rawData.present) {
      map['raw_data'] = Variable<String>(rawData.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsCompanion(')
          ..write('id: $id, ')
          ..write('amount: $amount, ')
          ..write('merchant: $merchant, ')
          ..write('date: $date, ')
          ..write('category: $category, ')
          ..write('source: $source, ')
          ..write('isRecurring: $isRecurring, ')
          ..write('rawData: $rawData, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $GhostBillsTable extends GhostBills
    with TableInfo<$GhostBillsTable, GhostBill> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GhostBillsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _predictedAmountMeta =
      const VerificationMeta('predictedAmount');
  @override
  late final GeneratedColumn<double> predictedAmount = GeneratedColumn<double>(
      'predicted_amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _merchantMeta =
      const VerificationMeta('merchant');
  @override
  late final GeneratedColumn<String> merchant = GeneratedColumn<String>(
      'merchant', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _frequencyMeta =
      const VerificationMeta('frequency');
  @override
  late final GeneratedColumn<String> frequency = GeneratedColumn<String>(
      'frequency', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nextDueDateMeta =
      const VerificationMeta('nextDueDate');
  @override
  late final GeneratedColumn<DateTime> nextDueDate = GeneratedColumn<DateTime>(
      'next_due_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _lastOccurrenceMeta =
      const VerificationMeta('lastOccurrence');
  @override
  late final GeneratedColumn<DateTime> lastOccurrence =
      GeneratedColumn<DateTime>('last_occurrence', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _confidenceMeta =
      const VerificationMeta('confidence');
  @override
  late final GeneratedColumn<int> confidence = GeneratedColumn<int>(
      'confidence', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _isInferredMeta =
      const VerificationMeta('isInferred');
  @override
  late final GeneratedColumn<bool> isInferred = GeneratedColumn<bool>(
      'is_inferred', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_inferred" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
      'source', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('inferred'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        predictedAmount,
        merchant,
        frequency,
        nextDueDate,
        lastOccurrence,
        confidence,
        isInferred,
        source
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ghost_bills';
  @override
  VerificationContext validateIntegrity(Insertable<GhostBill> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('predicted_amount')) {
      context.handle(
          _predictedAmountMeta,
          predictedAmount.isAcceptableOrUnknown(
              data['predicted_amount']!, _predictedAmountMeta));
    } else if (isInserting) {
      context.missing(_predictedAmountMeta);
    }
    if (data.containsKey('merchant')) {
      context.handle(_merchantMeta,
          merchant.isAcceptableOrUnknown(data['merchant']!, _merchantMeta));
    } else if (isInserting) {
      context.missing(_merchantMeta);
    }
    if (data.containsKey('frequency')) {
      context.handle(_frequencyMeta,
          frequency.isAcceptableOrUnknown(data['frequency']!, _frequencyMeta));
    } else if (isInserting) {
      context.missing(_frequencyMeta);
    }
    if (data.containsKey('next_due_date')) {
      context.handle(
          _nextDueDateMeta,
          nextDueDate.isAcceptableOrUnknown(
              data['next_due_date']!, _nextDueDateMeta));
    } else if (isInserting) {
      context.missing(_nextDueDateMeta);
    }
    if (data.containsKey('last_occurrence')) {
      context.handle(
          _lastOccurrenceMeta,
          lastOccurrence.isAcceptableOrUnknown(
              data['last_occurrence']!, _lastOccurrenceMeta));
    } else if (isInserting) {
      context.missing(_lastOccurrenceMeta);
    }
    if (data.containsKey('confidence')) {
      context.handle(
          _confidenceMeta,
          confidence.isAcceptableOrUnknown(
              data['confidence']!, _confidenceMeta));
    } else if (isInserting) {
      context.missing(_confidenceMeta);
    }
    if (data.containsKey('is_inferred')) {
      context.handle(
          _isInferredMeta,
          isInferred.isAcceptableOrUnknown(
              data['is_inferred']!, _isInferredMeta));
    }
    if (data.containsKey('source')) {
      context.handle(_sourceMeta,
          source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GhostBill map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GhostBill(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      predictedAmount: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}predicted_amount'])!,
      merchant: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}merchant'])!,
      frequency: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}frequency'])!,
      nextDueDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}next_due_date'])!,
      lastOccurrence: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_occurrence'])!,
      confidence: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}confidence'])!,
      isInferred: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_inferred'])!,
      source: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source'])!,
    );
  }

  @override
  $GhostBillsTable createAlias(String alias) {
    return $GhostBillsTable(attachedDatabase, alias);
  }
}

class GhostBill extends DataClass implements Insertable<GhostBill> {
  final int id;
  final double predictedAmount;
  final String merchant;
  final String frequency;
  final DateTime nextDueDate;
  final DateTime lastOccurrence;
  final int confidence;
  final bool isInferred;
  final String source;
  const GhostBill(
      {required this.id,
      required this.predictedAmount,
      required this.merchant,
      required this.frequency,
      required this.nextDueDate,
      required this.lastOccurrence,
      required this.confidence,
      required this.isInferred,
      required this.source});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['predicted_amount'] = Variable<double>(predictedAmount);
    map['merchant'] = Variable<String>(merchant);
    map['frequency'] = Variable<String>(frequency);
    map['next_due_date'] = Variable<DateTime>(nextDueDate);
    map['last_occurrence'] = Variable<DateTime>(lastOccurrence);
    map['confidence'] = Variable<int>(confidence);
    map['is_inferred'] = Variable<bool>(isInferred);
    map['source'] = Variable<String>(source);
    return map;
  }

  GhostBillsCompanion toCompanion(bool nullToAbsent) {
    return GhostBillsCompanion(
      id: Value(id),
      predictedAmount: Value(predictedAmount),
      merchant: Value(merchant),
      frequency: Value(frequency),
      nextDueDate: Value(nextDueDate),
      lastOccurrence: Value(lastOccurrence),
      confidence: Value(confidence),
      isInferred: Value(isInferred),
      source: Value(source),
    );
  }

  factory GhostBill.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GhostBill(
      id: serializer.fromJson<int>(json['id']),
      predictedAmount: serializer.fromJson<double>(json['predictedAmount']),
      merchant: serializer.fromJson<String>(json['merchant']),
      frequency: serializer.fromJson<String>(json['frequency']),
      nextDueDate: serializer.fromJson<DateTime>(json['nextDueDate']),
      lastOccurrence: serializer.fromJson<DateTime>(json['lastOccurrence']),
      confidence: serializer.fromJson<int>(json['confidence']),
      isInferred: serializer.fromJson<bool>(json['isInferred']),
      source: serializer.fromJson<String>(json['source']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'predictedAmount': serializer.toJson<double>(predictedAmount),
      'merchant': serializer.toJson<String>(merchant),
      'frequency': serializer.toJson<String>(frequency),
      'nextDueDate': serializer.toJson<DateTime>(nextDueDate),
      'lastOccurrence': serializer.toJson<DateTime>(lastOccurrence),
      'confidence': serializer.toJson<int>(confidence),
      'isInferred': serializer.toJson<bool>(isInferred),
      'source': serializer.toJson<String>(source),
    };
  }

  GhostBill copyWith(
          {int? id,
          double? predictedAmount,
          String? merchant,
          String? frequency,
          DateTime? nextDueDate,
          DateTime? lastOccurrence,
          int? confidence,
          bool? isInferred,
          String? source}) =>
      GhostBill(
        id: id ?? this.id,
        predictedAmount: predictedAmount ?? this.predictedAmount,
        merchant: merchant ?? this.merchant,
        frequency: frequency ?? this.frequency,
        nextDueDate: nextDueDate ?? this.nextDueDate,
        lastOccurrence: lastOccurrence ?? this.lastOccurrence,
        confidence: confidence ?? this.confidence,
        isInferred: isInferred ?? this.isInferred,
        source: source ?? this.source,
      );
  GhostBill copyWithCompanion(GhostBillsCompanion data) {
    return GhostBill(
      id: data.id.present ? data.id.value : this.id,
      predictedAmount: data.predictedAmount.present
          ? data.predictedAmount.value
          : this.predictedAmount,
      merchant: data.merchant.present ? data.merchant.value : this.merchant,
      frequency: data.frequency.present ? data.frequency.value : this.frequency,
      nextDueDate:
          data.nextDueDate.present ? data.nextDueDate.value : this.nextDueDate,
      lastOccurrence: data.lastOccurrence.present
          ? data.lastOccurrence.value
          : this.lastOccurrence,
      confidence:
          data.confidence.present ? data.confidence.value : this.confidence,
      isInferred:
          data.isInferred.present ? data.isInferred.value : this.isInferred,
      source: data.source.present ? data.source.value : this.source,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GhostBill(')
          ..write('id: $id, ')
          ..write('predictedAmount: $predictedAmount, ')
          ..write('merchant: $merchant, ')
          ..write('frequency: $frequency, ')
          ..write('nextDueDate: $nextDueDate, ')
          ..write('lastOccurrence: $lastOccurrence, ')
          ..write('confidence: $confidence, ')
          ..write('isInferred: $isInferred, ')
          ..write('source: $source')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, predictedAmount, merchant, frequency,
      nextDueDate, lastOccurrence, confidence, isInferred, source);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GhostBill &&
          other.id == this.id &&
          other.predictedAmount == this.predictedAmount &&
          other.merchant == this.merchant &&
          other.frequency == this.frequency &&
          other.nextDueDate == this.nextDueDate &&
          other.lastOccurrence == this.lastOccurrence &&
          other.confidence == this.confidence &&
          other.isInferred == this.isInferred &&
          other.source == this.source);
}

class GhostBillsCompanion extends UpdateCompanion<GhostBill> {
  final Value<int> id;
  final Value<double> predictedAmount;
  final Value<String> merchant;
  final Value<String> frequency;
  final Value<DateTime> nextDueDate;
  final Value<DateTime> lastOccurrence;
  final Value<int> confidence;
  final Value<bool> isInferred;
  final Value<String> source;
  const GhostBillsCompanion({
    this.id = const Value.absent(),
    this.predictedAmount = const Value.absent(),
    this.merchant = const Value.absent(),
    this.frequency = const Value.absent(),
    this.nextDueDate = const Value.absent(),
    this.lastOccurrence = const Value.absent(),
    this.confidence = const Value.absent(),
    this.isInferred = const Value.absent(),
    this.source = const Value.absent(),
  });
  GhostBillsCompanion.insert({
    this.id = const Value.absent(),
    required double predictedAmount,
    required String merchant,
    required String frequency,
    required DateTime nextDueDate,
    required DateTime lastOccurrence,
    required int confidence,
    this.isInferred = const Value.absent(),
    this.source = const Value.absent(),
  })  : predictedAmount = Value(predictedAmount),
        merchant = Value(merchant),
        frequency = Value(frequency),
        nextDueDate = Value(nextDueDate),
        lastOccurrence = Value(lastOccurrence),
        confidence = Value(confidence);
  static Insertable<GhostBill> custom({
    Expression<int>? id,
    Expression<double>? predictedAmount,
    Expression<String>? merchant,
    Expression<String>? frequency,
    Expression<DateTime>? nextDueDate,
    Expression<DateTime>? lastOccurrence,
    Expression<int>? confidence,
    Expression<bool>? isInferred,
    Expression<String>? source,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (predictedAmount != null) 'predicted_amount': predictedAmount,
      if (merchant != null) 'merchant': merchant,
      if (frequency != null) 'frequency': frequency,
      if (nextDueDate != null) 'next_due_date': nextDueDate,
      if (lastOccurrence != null) 'last_occurrence': lastOccurrence,
      if (confidence != null) 'confidence': confidence,
      if (isInferred != null) 'is_inferred': isInferred,
      if (source != null) 'source': source,
    });
  }

  GhostBillsCompanion copyWith(
      {Value<int>? id,
      Value<double>? predictedAmount,
      Value<String>? merchant,
      Value<String>? frequency,
      Value<DateTime>? nextDueDate,
      Value<DateTime>? lastOccurrence,
      Value<int>? confidence,
      Value<bool>? isInferred,
      Value<String>? source}) {
    return GhostBillsCompanion(
      id: id ?? this.id,
      predictedAmount: predictedAmount ?? this.predictedAmount,
      merchant: merchant ?? this.merchant,
      frequency: frequency ?? this.frequency,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      lastOccurrence: lastOccurrence ?? this.lastOccurrence,
      confidence: confidence ?? this.confidence,
      isInferred: isInferred ?? this.isInferred,
      source: source ?? this.source,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (predictedAmount.present) {
      map['predicted_amount'] = Variable<double>(predictedAmount.value);
    }
    if (merchant.present) {
      map['merchant'] = Variable<String>(merchant.value);
    }
    if (frequency.present) {
      map['frequency'] = Variable<String>(frequency.value);
    }
    if (nextDueDate.present) {
      map['next_due_date'] = Variable<DateTime>(nextDueDate.value);
    }
    if (lastOccurrence.present) {
      map['last_occurrence'] = Variable<DateTime>(lastOccurrence.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<int>(confidence.value);
    }
    if (isInferred.present) {
      map['is_inferred'] = Variable<bool>(isInferred.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GhostBillsCompanion(')
          ..write('id: $id, ')
          ..write('predictedAmount: $predictedAmount, ')
          ..write('merchant: $merchant, ')
          ..write('frequency: $frequency, ')
          ..write('nextDueDate: $nextDueDate, ')
          ..write('lastOccurrence: $lastOccurrence, ')
          ..write('confidence: $confidence, ')
          ..write('isInferred: $isInferred, ')
          ..write('source: $source')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  late final $GhostBillsTable ghostBills = $GhostBillsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [transactions, ghostBills];
}

typedef $$TransactionsTableCreateCompanionBuilder = TransactionsCompanion
    Function({
  Value<int> id,
  required double amount,
  required String merchant,
  required DateTime date,
  Value<String> category,
  required String source,
  Value<bool> isRecurring,
  Value<String?> rawData,
  Value<DateTime> createdAt,
});
typedef $$TransactionsTableUpdateCompanionBuilder = TransactionsCompanion
    Function({
  Value<int> id,
  Value<double> amount,
  Value<String> merchant,
  Value<DateTime> date,
  Value<String> category,
  Value<String> source,
  Value<bool> isRecurring,
  Value<String?> rawData,
  Value<DateTime> createdAt,
});

class $$TransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get merchant => $composableBuilder(
      column: $table.merchant, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isRecurring => $composableBuilder(
      column: $table.isRecurring, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rawData => $composableBuilder(
      column: $table.rawData, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$TransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get merchant => $composableBuilder(
      column: $table.merchant, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isRecurring => $composableBuilder(
      column: $table.isRecurring, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rawData => $composableBuilder(
      column: $table.rawData, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$TransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get merchant =>
      $composableBuilder(column: $table.merchant, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<bool> get isRecurring => $composableBuilder(
      column: $table.isRecurring, builder: (column) => column);

  GeneratedColumn<String> get rawData =>
      $composableBuilder(column: $table.rawData, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$TransactionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TransactionsTable,
    Transaction,
    $$TransactionsTableFilterComposer,
    $$TransactionsTableOrderingComposer,
    $$TransactionsTableAnnotationComposer,
    $$TransactionsTableCreateCompanionBuilder,
    $$TransactionsTableUpdateCompanionBuilder,
    (
      Transaction,
      BaseReferences<_$AppDatabase, $TransactionsTable, Transaction>
    ),
    Transaction,
    PrefetchHooks Function()> {
  $$TransactionsTableTableManager(_$AppDatabase db, $TransactionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<String> merchant = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<String> source = const Value.absent(),
            Value<bool> isRecurring = const Value.absent(),
            Value<String?> rawData = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              TransactionsCompanion(
            id: id,
            amount: amount,
            merchant: merchant,
            date: date,
            category: category,
            source: source,
            isRecurring: isRecurring,
            rawData: rawData,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required double amount,
            required String merchant,
            required DateTime date,
            Value<String> category = const Value.absent(),
            required String source,
            Value<bool> isRecurring = const Value.absent(),
            Value<String?> rawData = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              TransactionsCompanion.insert(
            id: id,
            amount: amount,
            merchant: merchant,
            date: date,
            category: category,
            source: source,
            isRecurring: isRecurring,
            rawData: rawData,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TransactionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TransactionsTable,
    Transaction,
    $$TransactionsTableFilterComposer,
    $$TransactionsTableOrderingComposer,
    $$TransactionsTableAnnotationComposer,
    $$TransactionsTableCreateCompanionBuilder,
    $$TransactionsTableUpdateCompanionBuilder,
    (
      Transaction,
      BaseReferences<_$AppDatabase, $TransactionsTable, Transaction>
    ),
    Transaction,
    PrefetchHooks Function()>;
typedef $$GhostBillsTableCreateCompanionBuilder = GhostBillsCompanion Function({
  Value<int> id,
  required double predictedAmount,
  required String merchant,
  required String frequency,
  required DateTime nextDueDate,
  required DateTime lastOccurrence,
  required int confidence,
  Value<bool> isInferred,
  Value<String> source,
});
typedef $$GhostBillsTableUpdateCompanionBuilder = GhostBillsCompanion Function({
  Value<int> id,
  Value<double> predictedAmount,
  Value<String> merchant,
  Value<String> frequency,
  Value<DateTime> nextDueDate,
  Value<DateTime> lastOccurrence,
  Value<int> confidence,
  Value<bool> isInferred,
  Value<String> source,
});

class $$GhostBillsTableFilterComposer
    extends Composer<_$AppDatabase, $GhostBillsTable> {
  $$GhostBillsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get predictedAmount => $composableBuilder(
      column: $table.predictedAmount,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get merchant => $composableBuilder(
      column: $table.merchant, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get frequency => $composableBuilder(
      column: $table.frequency, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get nextDueDate => $composableBuilder(
      column: $table.nextDueDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastOccurrence => $composableBuilder(
      column: $table.lastOccurrence,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isInferred => $composableBuilder(
      column: $table.isInferred, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnFilters(column));
}

class $$GhostBillsTableOrderingComposer
    extends Composer<_$AppDatabase, $GhostBillsTable> {
  $$GhostBillsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get predictedAmount => $composableBuilder(
      column: $table.predictedAmount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get merchant => $composableBuilder(
      column: $table.merchant, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get frequency => $composableBuilder(
      column: $table.frequency, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get nextDueDate => $composableBuilder(
      column: $table.nextDueDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastOccurrence => $composableBuilder(
      column: $table.lastOccurrence,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isInferred => $composableBuilder(
      column: $table.isInferred, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnOrderings(column));
}

class $$GhostBillsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GhostBillsTable> {
  $$GhostBillsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get predictedAmount => $composableBuilder(
      column: $table.predictedAmount, builder: (column) => column);

  GeneratedColumn<String> get merchant =>
      $composableBuilder(column: $table.merchant, builder: (column) => column);

  GeneratedColumn<String> get frequency =>
      $composableBuilder(column: $table.frequency, builder: (column) => column);

  GeneratedColumn<DateTime> get nextDueDate => $composableBuilder(
      column: $table.nextDueDate, builder: (column) => column);

  GeneratedColumn<DateTime> get lastOccurrence => $composableBuilder(
      column: $table.lastOccurrence, builder: (column) => column);

  GeneratedColumn<int> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => column);

  GeneratedColumn<bool> get isInferred => $composableBuilder(
      column: $table.isInferred, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);
}

class $$GhostBillsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $GhostBillsTable,
    GhostBill,
    $$GhostBillsTableFilterComposer,
    $$GhostBillsTableOrderingComposer,
    $$GhostBillsTableAnnotationComposer,
    $$GhostBillsTableCreateCompanionBuilder,
    $$GhostBillsTableUpdateCompanionBuilder,
    (GhostBill, BaseReferences<_$AppDatabase, $GhostBillsTable, GhostBill>),
    GhostBill,
    PrefetchHooks Function()> {
  $$GhostBillsTableTableManager(_$AppDatabase db, $GhostBillsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GhostBillsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GhostBillsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GhostBillsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<double> predictedAmount = const Value.absent(),
            Value<String> merchant = const Value.absent(),
            Value<String> frequency = const Value.absent(),
            Value<DateTime> nextDueDate = const Value.absent(),
            Value<DateTime> lastOccurrence = const Value.absent(),
            Value<int> confidence = const Value.absent(),
            Value<bool> isInferred = const Value.absent(),
            Value<String> source = const Value.absent(),
          }) =>
              GhostBillsCompanion(
            id: id,
            predictedAmount: predictedAmount,
            merchant: merchant,
            frequency: frequency,
            nextDueDate: nextDueDate,
            lastOccurrence: lastOccurrence,
            confidence: confidence,
            isInferred: isInferred,
            source: source,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required double predictedAmount,
            required String merchant,
            required String frequency,
            required DateTime nextDueDate,
            required DateTime lastOccurrence,
            required int confidence,
            Value<bool> isInferred = const Value.absent(),
            Value<String> source = const Value.absent(),
          }) =>
              GhostBillsCompanion.insert(
            id: id,
            predictedAmount: predictedAmount,
            merchant: merchant,
            frequency: frequency,
            nextDueDate: nextDueDate,
            lastOccurrence: lastOccurrence,
            confidence: confidence,
            isInferred: isInferred,
            source: source,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$GhostBillsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $GhostBillsTable,
    GhostBill,
    $$GhostBillsTableFilterComposer,
    $$GhostBillsTableOrderingComposer,
    $$GhostBillsTableAnnotationComposer,
    $$GhostBillsTableCreateCompanionBuilder,
    $$GhostBillsTableUpdateCompanionBuilder,
    (GhostBill, BaseReferences<_$AppDatabase, $GhostBillsTable, GhostBill>),
    GhostBill,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
  $$GhostBillsTableTableManager get ghostBills =>
      $$GhostBillsTableTableManager(_db, _db.ghostBills);
}
