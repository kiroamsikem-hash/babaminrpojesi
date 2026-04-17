// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'period_event.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPeriodEventCollection on Isar {
  IsarCollection<PeriodEvent> get periodEvents => this.collection();
}

const PeriodEventSchema = CollectionSchema(
  name: r'PeriodEvent',
  id: -2853730148844626160,
  properties: {
    r'civilizationId': PropertySchema(
      id: 0,
      name: r'civilizationId',
      type: IsarType.long,
    ),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'description': PropertySchema(
      id: 2,
      name: r'description',
      type: IsarType.string,
    ),
    r'duration': PropertySchema(
      id: 3,
      name: r'duration',
      type: IsarType.long,
    ),
    r'endYear': PropertySchema(
      id: 4,
      name: r'endYear',
      type: IsarType.long,
    ),
    r'gridX': PropertySchema(
      id: 5,
      name: r'gridX',
      type: IsarType.double,
    ),
    r'gridY': PropertySchema(
      id: 6,
      name: r'gridY',
      type: IsarType.double,
    ),
    r'isMultiYear': PropertySchema(
      id: 7,
      name: r'isMultiYear',
      type: IsarType.bool,
    ),
    r'period': PropertySchema(
      id: 8,
      name: r'period',
      type: IsarType.string,
    ),
    r'photoPath': PropertySchema(
      id: 9,
      name: r'photoPath',
      type: IsarType.string,
    ),
    r'photoUrl': PropertySchema(
      id: 10,
      name: r'photoUrl',
      type: IsarType.string,
    ),
    r'startYear': PropertySchema(
      id: 11,
      name: r'startYear',
      type: IsarType.long,
    ),
    r'tags': PropertySchema(
      id: 12,
      name: r'tags',
      type: IsarType.stringList,
    ),
    r'title': PropertySchema(
      id: 13,
      name: r'title',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 14,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _periodEventEstimateSize,
  serialize: _periodEventSerialize,
  deserialize: _periodEventDeserialize,
  deserializeProp: _periodEventDeserializeProp,
  idName: r'id',
  indexes: {
    r'startYear': IndexSchema(
      id: 2365176904539299076,
      name: r'startYear',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'startYear',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'title': IndexSchema(
      id: -7636685945352118059,
      name: r'title',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'title',
          type: IndexType.value,
          caseSensitive: true,
        )
      ],
    ),
    r'civilizationId': IndexSchema(
      id: -203566502877462255,
      name: r'civilizationId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'civilizationId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _periodEventGetId,
  getLinks: _periodEventGetLinks,
  attach: _periodEventAttach,
  version: '3.1.0+1',
);

int _periodEventEstimateSize(
  PeriodEvent object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.description;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.period;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.photoPath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.photoUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final list = object.tags;
    if (list != null) {
      bytesCount += 3 + list.length * 3;
      {
        for (var i = 0; i < list.length; i++) {
          final value = list[i];
          bytesCount += value.length * 3;
        }
      }
    }
  }
  bytesCount += 3 + object.title.length * 3;
  return bytesCount;
}

void _periodEventSerialize(
  PeriodEvent object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.civilizationId);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeString(offsets[2], object.description);
  writer.writeLong(offsets[3], object.duration);
  writer.writeLong(offsets[4], object.endYear);
  writer.writeDouble(offsets[5], object.gridX);
  writer.writeDouble(offsets[6], object.gridY);
  writer.writeBool(offsets[7], object.isMultiYear);
  writer.writeString(offsets[8], object.period);
  writer.writeString(offsets[9], object.photoPath);
  writer.writeString(offsets[10], object.photoUrl);
  writer.writeLong(offsets[11], object.startYear);
  writer.writeStringList(offsets[12], object.tags);
  writer.writeString(offsets[13], object.title);
  writer.writeDateTime(offsets[14], object.updatedAt);
}

PeriodEvent _periodEventDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PeriodEvent();
  object.civilizationId = reader.readLong(offsets[0]);
  object.createdAt = reader.readDateTimeOrNull(offsets[1]);
  object.description = reader.readStringOrNull(offsets[2]);
  object.endYear = reader.readLongOrNull(offsets[4]);
  object.gridX = reader.readDoubleOrNull(offsets[5]);
  object.gridY = reader.readDoubleOrNull(offsets[6]);
  object.id = id;
  object.period = reader.readStringOrNull(offsets[8]);
  object.photoPath = reader.readStringOrNull(offsets[9]);
  object.photoUrl = reader.readStringOrNull(offsets[10]);
  object.startYear = reader.readLong(offsets[11]);
  object.tags = reader.readStringList(offsets[12]);
  object.title = reader.readString(offsets[13]);
  object.updatedAt = reader.readDateTimeOrNull(offsets[14]);
  return object;
}

P _periodEventDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readLongOrNull(offset)) as P;
    case 5:
      return (reader.readDoubleOrNull(offset)) as P;
    case 6:
      return (reader.readDoubleOrNull(offset)) as P;
    case 7:
      return (reader.readBool(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    case 11:
      return (reader.readLong(offset)) as P;
    case 12:
      return (reader.readStringList(offset)) as P;
    case 13:
      return (reader.readString(offset)) as P;
    case 14:
      return (reader.readDateTimeOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _periodEventGetId(PeriodEvent object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _periodEventGetLinks(PeriodEvent object) {
  return [];
}

void _periodEventAttach(
    IsarCollection<dynamic> col, Id id, PeriodEvent object) {
  object.id = id;
}

extension PeriodEventQueryWhereSort
    on QueryBuilder<PeriodEvent, PeriodEvent, QWhere> {
  QueryBuilder<PeriodEvent, PeriodEvent, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterWhere> anyStartYear() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'startYear'),
      );
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterWhere> anyTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'title'),
      );
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterWhere> anyCivilizationId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'civilizationId'),
      );
    });
  }
}

extension PeriodEventQueryWhere
    on QueryBuilder<PeriodEvent, PeriodEvent, QWhereClause> {
  QueryBuilder<PeriodEvent, PeriodEvent, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterWhereClause> startYearEqualTo(
      int startYear) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'startYear',
        value: [startYear],
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterWhereClause> startYearNotEqualTo(
      int startYear) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'startYear',
              lower: [],
              upper: [startYear],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'startYear',
              lower: [startYear],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'startYear',
              lower: [startYear],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'startYear',
              lower: [],
              upper: [startYear],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterWhereClause>
      startYearGreaterThan(
    int startYear, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'startYear',
        lower: [startYear],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterWhereClause> startYearLessThan(
    int startYear, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'startYear',
        lower: [],
        upper: [startYear],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterWhereClause> startYearBetween(
    int lowerStartYear,
    int upperStartYear, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'startYear',
        lower: [lowerStartYear],
        includeLower: includeLower,
        upper: [upperStartYear],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterWhereClause> titleEqualTo(
      String title) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'title',
        value: [title],
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterWhereClause> titleNotEqualTo(
      String title) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'title',
              lower: [],
              upper: [title],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'title',
              lower: [title],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'title',
              lower: [title],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'title',
              lower: [],
              upper: [title],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterWhereClause> titleGreaterThan(
    String title, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'title',
        lower: [title],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterWhereClause> titleLessThan(
    String title, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'title',
        lower: [],
        upper: [title],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterWhereClause> titleBetween(
    String lowerTitle,
    String upperTitle, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'title',
        lower: [lowerTitle],
        includeLower: includeLower,
        upper: [upperTitle],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterWhereClause> titleStartsWith(
      String TitlePrefix) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'title',
        lower: [TitlePrefix],
        upper: ['$TitlePrefix\u{FFFFF}'],
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterWhereClause> titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'title',
        value: [''],
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterWhereClause> titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.lessThan(
              indexName: r'title',
              upper: [''],
            ))
            .addWhereClause(IndexWhereClause.greaterThan(
              indexName: r'title',
              lower: [''],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.greaterThan(
              indexName: r'title',
              lower: [''],
            ))
            .addWhereClause(IndexWhereClause.lessThan(
              indexName: r'title',
              upper: [''],
            ));
      }
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterWhereClause>
      civilizationIdEqualTo(int civilizationId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'civilizationId',
        value: [civilizationId],
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterWhereClause>
      civilizationIdNotEqualTo(int civilizationId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'civilizationId',
              lower: [],
              upper: [civilizationId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'civilizationId',
              lower: [civilizationId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'civilizationId',
              lower: [civilizationId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'civilizationId',
              lower: [],
              upper: [civilizationId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterWhereClause>
      civilizationIdGreaterThan(
    int civilizationId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'civilizationId',
        lower: [civilizationId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterWhereClause>
      civilizationIdLessThan(
    int civilizationId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'civilizationId',
        lower: [],
        upper: [civilizationId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterWhereClause>
      civilizationIdBetween(
    int lowerCivilizationId,
    int upperCivilizationId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'civilizationId',
        lower: [lowerCivilizationId],
        includeLower: includeLower,
        upper: [upperCivilizationId],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension PeriodEventQueryFilter
    on QueryBuilder<PeriodEvent, PeriodEvent, QFilterCondition> {
  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition>
      civilizationIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'civilizationId',
        value: value,
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition>
      civilizationIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'civilizationId',
        value: value,
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition>
      civilizationIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'civilizationId',
        value: value,
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition>
      civilizationIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'civilizationId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition>
      createdAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'createdAt',
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition>
      createdAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'createdAt',
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition>
      createdAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition>
      createdAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition>
      createdAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition>
      descriptionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'description',
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition>
      descriptionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'description',
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition>
      descriptionEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition>
      descriptionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition>
      descriptionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition>
      descriptionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'description',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition>
      descriptionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition>
      descriptionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition>
      descriptionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition>
      descriptionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'description',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition>
      descriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition>
      descriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition> durationEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'duration',
        value: value,
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition>
      durationGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'duration',
        value: value,
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition>
      durationLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'duration',
        value: value,
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition> durationBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'duration',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition>
      endYearIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'endYear',
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition>
      endYearIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'endYear',
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition> endYearEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'endYear',
        value: value,
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition>
      endYearGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'endYear',
        value: value,
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition> endYearLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'endYear',
        value: value,
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition> endYearBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'endYear',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition> gridXIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'gridX',
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition>
      gridXIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'gridX',
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition> gridXEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'gridX',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition>
      gridXGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'gridX',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition> gridXLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'gridX',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition> gridXBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'gridX',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition> gridYIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'gridY',
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition>
      gridYIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'gridY',
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition> gridYEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'gridY',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition>
      gridYGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'gridY',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition> gridYLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'gridY',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition> gridYBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'gridY',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition>
      isMultiYearEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isMultiYear',
        value: value,
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition> periodIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'period',
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition>
      periodIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'period',
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition> periodEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'period',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition>
      periodGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'period',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition> periodLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'period',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition> periodBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'period',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition>
      periodStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'period',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition> periodEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'period',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition> periodContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'period',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition> periodMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'period',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition>
      periodIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'period',
        value: '',
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition>
      periodIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'period',
        value: '',
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition>
      photoPathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'photoPath',
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition>
      photoPathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'photoPath',
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition>
      photoPathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'photoPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition>
      photoPathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'photoPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition>
      photoPathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'photoPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition>
      photoPathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'photoPath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition>
      photoPathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'photoPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition>
      photoPathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'photoPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition>
      photoPathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'photoPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition>
      photoPathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'photoPath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition>
      photoPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'photoPath',
        value: '',
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition>
      photoPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'photoPath',
        value: '',
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition>
      photoUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'photoUrl',
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition>
      photoUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'photoUrl',
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition> photoUrlEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'photoUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition>
      photoUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'photoUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition>
      photoUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'photoUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition> photoUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'photoUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition>
      photoUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'photoUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition>
      photoUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'photoUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition>
      photoUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'photoUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition> photoUrlMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'photoUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition>
      photoUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'photoUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition>
      photoUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'photoUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition>
      startYearEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'startYear',
        value: value,
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition>
      startYearGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'startYear',
        value: value,
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition>
      startYearLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'startYear',
        value: value,
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition>
      startYearBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'startYear',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition> tagsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'tags',
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition>
      tagsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'tags',
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition>
      tagsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition>
      tagsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition>
      tagsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition>
      tagsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tags',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition>
      tagsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'tags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition>
      tagsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'tags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition>
      tagsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'tags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition>
      tagsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'tags',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition>
      tagsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tags',
        value: '',
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition>
      tagsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'tags',
        value: '',
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition>
      tagsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tags',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition> tagsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tags',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition>
      tagsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tags',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition>
      tagsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tags',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition>
      tagsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tags',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition>
      tagsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tags',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition> titleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition>
      titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition> titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition> titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'title',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition> titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition> titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition> titleContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition> titleMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition> titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition>
      titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition>
      updatedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'updatedAt',
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition>
      updatedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'updatedAt',
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition>
      updatedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition>
      updatedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition>
      updatedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterFilterCondition>
      updatedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension PeriodEventQueryObject
    on QueryBuilder<PeriodEvent, PeriodEvent, QFilterCondition> {}

extension PeriodEventQueryLinks
    on QueryBuilder<PeriodEvent, PeriodEvent, QFilterCondition> {}

extension PeriodEventQuerySortBy
    on QueryBuilder<PeriodEvent, PeriodEvent, QSortBy> {
  QueryBuilder<PeriodEvent, PeriodEvent, QAfterSortBy> sortByCivilizationId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'civilizationId', Sort.asc);
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterSortBy>
      sortByCivilizationIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'civilizationId', Sort.desc);
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterSortBy> sortByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterSortBy> sortByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterSortBy> sortByDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duration', Sort.asc);
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterSortBy> sortByDurationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duration', Sort.desc);
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterSortBy> sortByEndYear() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endYear', Sort.asc);
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterSortBy> sortByEndYearDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endYear', Sort.desc);
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterSortBy> sortByGridX() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gridX', Sort.asc);
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterSortBy> sortByGridXDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gridX', Sort.desc);
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterSortBy> sortByGridY() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gridY', Sort.asc);
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterSortBy> sortByGridYDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gridY', Sort.desc);
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterSortBy> sortByIsMultiYear() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isMultiYear', Sort.asc);
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterSortBy> sortByIsMultiYearDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isMultiYear', Sort.desc);
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterSortBy> sortByPeriod() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'period', Sort.asc);
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterSortBy> sortByPeriodDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'period', Sort.desc);
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterSortBy> sortByPhotoPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'photoPath', Sort.asc);
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterSortBy> sortByPhotoPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'photoPath', Sort.desc);
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterSortBy> sortByPhotoUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'photoUrl', Sort.asc);
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterSortBy> sortByPhotoUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'photoUrl', Sort.desc);
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterSortBy> sortByStartYear() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startYear', Sort.asc);
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterSortBy> sortByStartYearDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startYear', Sort.desc);
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterSortBy> sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension PeriodEventQuerySortThenBy
    on QueryBuilder<PeriodEvent, PeriodEvent, QSortThenBy> {
  QueryBuilder<PeriodEvent, PeriodEvent, QAfterSortBy> thenByCivilizationId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'civilizationId', Sort.asc);
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterSortBy>
      thenByCivilizationIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'civilizationId', Sort.desc);
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterSortBy> thenByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterSortBy> thenByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterSortBy> thenByDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duration', Sort.asc);
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterSortBy> thenByDurationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duration', Sort.desc);
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterSortBy> thenByEndYear() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endYear', Sort.asc);
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterSortBy> thenByEndYearDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endYear', Sort.desc);
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterSortBy> thenByGridX() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gridX', Sort.asc);
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterSortBy> thenByGridXDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gridX', Sort.desc);
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterSortBy> thenByGridY() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gridY', Sort.asc);
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterSortBy> thenByGridYDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gridY', Sort.desc);
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterSortBy> thenByIsMultiYear() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isMultiYear', Sort.asc);
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterSortBy> thenByIsMultiYearDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isMultiYear', Sort.desc);
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterSortBy> thenByPeriod() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'period', Sort.asc);
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterSortBy> thenByPeriodDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'period', Sort.desc);
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterSortBy> thenByPhotoPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'photoPath', Sort.asc);
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterSortBy> thenByPhotoPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'photoPath', Sort.desc);
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterSortBy> thenByPhotoUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'photoUrl', Sort.asc);
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterSortBy> thenByPhotoUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'photoUrl', Sort.desc);
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterSortBy> thenByStartYear() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startYear', Sort.asc);
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterSortBy> thenByStartYearDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startYear', Sort.desc);
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterSortBy> thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension PeriodEventQueryWhereDistinct
    on QueryBuilder<PeriodEvent, PeriodEvent, QDistinct> {
  QueryBuilder<PeriodEvent, PeriodEvent, QDistinct> distinctByCivilizationId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'civilizationId');
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QDistinct> distinctByDescription(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'description', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QDistinct> distinctByDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'duration');
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QDistinct> distinctByEndYear() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'endYear');
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QDistinct> distinctByGridX() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'gridX');
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QDistinct> distinctByGridY() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'gridY');
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QDistinct> distinctByIsMultiYear() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isMultiYear');
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QDistinct> distinctByPeriod(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'period', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QDistinct> distinctByPhotoPath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'photoPath', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QDistinct> distinctByPhotoUrl(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'photoUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QDistinct> distinctByStartYear() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startYear');
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QDistinct> distinctByTags() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tags');
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QDistinct> distinctByTitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PeriodEvent, PeriodEvent, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension PeriodEventQueryProperty
    on QueryBuilder<PeriodEvent, PeriodEvent, QQueryProperty> {
  QueryBuilder<PeriodEvent, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PeriodEvent, int, QQueryOperations> civilizationIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'civilizationId');
    });
  }

  QueryBuilder<PeriodEvent, DateTime?, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<PeriodEvent, String?, QQueryOperations> descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'description');
    });
  }

  QueryBuilder<PeriodEvent, int, QQueryOperations> durationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'duration');
    });
  }

  QueryBuilder<PeriodEvent, int?, QQueryOperations> endYearProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'endYear');
    });
  }

  QueryBuilder<PeriodEvent, double?, QQueryOperations> gridXProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'gridX');
    });
  }

  QueryBuilder<PeriodEvent, double?, QQueryOperations> gridYProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'gridY');
    });
  }

  QueryBuilder<PeriodEvent, bool, QQueryOperations> isMultiYearProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isMultiYear');
    });
  }

  QueryBuilder<PeriodEvent, String?, QQueryOperations> periodProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'period');
    });
  }

  QueryBuilder<PeriodEvent, String?, QQueryOperations> photoPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'photoPath');
    });
  }

  QueryBuilder<PeriodEvent, String?, QQueryOperations> photoUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'photoUrl');
    });
  }

  QueryBuilder<PeriodEvent, int, QQueryOperations> startYearProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startYear');
    });
  }

  QueryBuilder<PeriodEvent, List<String>?, QQueryOperations> tagsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tags');
    });
  }

  QueryBuilder<PeriodEvent, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<PeriodEvent, DateTime?, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
