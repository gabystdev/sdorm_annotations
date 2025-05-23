import 'package:supabase/supabase.dart';
import 'package:supabase_dart_client/src/dao/dao_registry.dart' as daoRegistry;
import 'dao_interface.dart';
import 'relationship_metadata.dart';

abstract class BaseDAO<T> implements DAO<T> {
  final SupabaseClient _client;
  @override
  final String tableName;

  final Map<String, RelationshipMetadata> _relationshipMetadata = {};

  BaseDAO(this._client, this.tableName);

  void registerRelationship(RelationshipMetadata metadata) {
    _relationshipMetadata[metadata.fieldName] = metadata;
  }

  RelationshipMetadata? getRelationshipMetadata(String fieldName) {
    return _relationshipMetadata[fieldName];
  }

  dynamic getFieldValue(T entity, String fieldName);
  void setFieldValue(T entity, String fieldName, dynamic value);
  T fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson(T entity);
  int getPrimaryKey(T entity);
  List<String> get excludeFromInsert => [];
  List<String> get excludeFromUpdate => [];

  @override
  Future<T?> findById(int id) async {
    final response = await _client.from(tableName).select().eq('id', id).maybeSingle();
    return response != null ? fromJson(response as Map<String, dynamic>) : null;
  }

  @override
  Future<List<T>> findAll() async {
    final response = await _client.from(tableName).select();
    return (response as List).map((e) => fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<T>> findWhere(Map<String, dynamic> conditions) async {
    var query = _client.from(tableName).select();
    conditions.forEach((field, value) {
      query = query.eq(field, value);
    });
    final response = await query;
    return (response as List).map((e) => fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<T?> findFirstWhere(Map<String, dynamic> conditions) async {
    try {
      var query = _client.from(tableName).select();
      conditions.forEach((field, value) {
        query = query.eq(field, value);
      });
      final response = await query.limit(1).maybeSingle();
      return response != null ? fromJson(response as Map<String, dynamic>) : null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<T> insert(T entity) async {
    final data = toJson(entity)..removeWhere((k, _) => excludeFromInsert.contains(k));
    final response = await _client.from(tableName).insert(data).select().single();
    return fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<T> update(T entity) async {
    final id = getPrimaryKey(entity);
    final data = toJson(entity)
      ..removeWhere((k, _) => excludeFromUpdate.contains(k))
      ..remove('id');
    final response = await _client.from(tableName).update(data).eq('id', id).select().single();
    return fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<void> delete(int id) async {
    await _client.from(tableName).delete().eq('id', id);
  }

  @override
  Future<int> count() async {
    final response = await _client
        .from(tableName)
        .select('*', const FetchOptions(count: CountOption.exact));
    return response.count ?? 0;
  }

  @override
  Future<int> countWhere(Map<String, dynamic> conditions) async {
    var query = _client
        .from(tableName)
        .select('*', const FetchOptions(count: CountOption.exact));
    conditions.forEach((field, value) {
      query = query.eq(field, value);
    });
    final response = await query;
    return response.count ?? 0;
  }

  @override
  Future<List<T>> rawQuery(String sql, [Map<String, dynamic>? params]) async {
    final result = await _client.rpc('execute_sql', params: {
      'query': sql,
      'params': params ?? {},
    });
    return (result as List).map((e) => fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<T>> findWhereIn(String column, List<dynamic> values) async {
    if (values.isEmpty) return [];
    final response = await _client.from(tableName).select().in_(column, values);
    return (response as List).map((e) => fromJson(e as Map<String, dynamic>)).toList();
  }

  DAO<R>? _getRelatedDAO<R>(Type type) {
    return daoRegistry.DAORegistry.getDAO<R>();
  }

  @override
  Future<R?> loadBelongsTo<R>(T entity, String relationName) async {
    final metadata = getRelationshipMetadata(relationName);
    if (metadata == null || metadata.type != 'BelongsTo') {
      throw Exception('Relation $relationName not found or not a BelongsTo relation');
    }
    final foreignKeyValue = getFieldValue(entity, metadata.foreignKey);
    if (foreignKeyValue == null) return null;
    final relatedDAO = _getRelatedDAO<R>(metadata.relatedClass);
    if (relatedDAO == null) {
      throw Exception('No DAO registered for ${metadata.relatedClass}');
    }
    final relatedEntity = await relatedDAO.findById(foreignKeyValue);
    if (relatedEntity != null) {
      setFieldValue(entity, relationName, relatedEntity);
    }
    return relatedEntity;
  }

  @override
  Future<List<R>> loadHasMany<R>(T entity, String relationName) async {
    final metadata = getRelationshipMetadata(relationName);
    if (metadata == null || metadata.type != 'HasMany') {
      throw Exception('Relation $relationName not found or not a HasMany relation');
    }
    final primaryKey = getPrimaryKey(entity);
    final relatedDAO = _getRelatedDAO<R>(metadata.relatedClass);
    if (relatedDAO == null) {
      throw Exception('No DAO registered for ${metadata.relatedClass}');
    }
    final relatedEntities = await relatedDAO.findWhere({metadata.foreignKey: primaryKey});
    setFieldValue(entity, relationName, relatedEntities);
    return relatedEntities;
  }

  @override
  Future<R?> loadHasOne<R>(T entity, String relationName) async {
    final metadata = getRelationshipMetadata(relationName);
    if (metadata == null || metadata.type != 'HasOne') {
      throw Exception('Relation $relationName not found or not a HasOne relation');
    }
    final primaryKey = getPrimaryKey(entity);
    final relatedDAO = _getRelatedDAO<R>(metadata.relatedClass);
    if (relatedDAO == null) {
      throw Exception('No DAO registered for ${metadata.relatedClass}');
    }
    final relatedEntity = await relatedDAO.findFirstWhere({metadata.foreignKey: primaryKey});
    if (relatedEntity != null) {
      setFieldValue(entity, relationName, relatedEntity);
    }
    return relatedEntity;
  }

  @override
  Future<List<R>> loadManyToMany<R>(T entity, String relationName) async {
    final metadata = getRelationshipMetadata(relationName);
    if (metadata == null || metadata.type != 'ManyToMany') {
      throw Exception('Relation $relationName not found or not a ManyToMany relation');
    }

    final primaryKey = getPrimaryKey(entity);
    final junctionTable = metadata.junctionTable;
    final foreignKey = metadata.foreignKey;
    final relatedForeignKey = metadata.relatedForeignKey;

    final junctionRows = await _client
        .from(junctionTable)
        .select()
        .eq(foreignKey, primaryKey);

    final relatedIds = (junctionRows as List)
        .map((row) => row[relatedForeignKey])
        .whereType<dynamic>()
        .toList();

    final relatedDAO = _getRelatedDAO<R>(metadata.relatedClass);
    if (relatedDAO == null) {
      throw Exception('No DAO registered for ${metadata.relatedClass}');
    }

    final relatedEntities = await relatedDAO.findWhereIn('id', relatedIds);
    setFieldValue(entity, relationName, relatedEntities);
    return relatedEntities;
  }
}
