import 'package:supabase_dart_client/src/dao/dao_registry.dart' as daoRegistry;
// Base implementation of DAO interface
// Provides common functionality that all generated DAOs can leverage
import 'package:supabase/supabase.dart';
import 'dao_interface.dart';
import 'relationship_metadata.dart';

/// Abstract base class for Data Access Objects
///
/// This class provides a common implementation for DAOs that can be extended
/// by generated DAO classes. It handles common database operations and
/// connection management.
abstract class BaseDAO<T> implements DAO<T> {
  /// The Supabase client used for database access
  final SupabaseClient _client;

  /// The name of the table this DAO manages
  @override
  final String tableName;

  /// Map of relationship metadata, keyed by field name
  final Map<String, RelationshipMetadata> _relationshipMetadata = {};

  /// Create a new BaseDAO with the given client and table name
  BaseDAO(this._client, this.tableName);

  /// Register relationship metadata for a field
  void registerRelationship(RelationshipMetadata metadata) {
    _relationshipMetadata[metadata.fieldName] = metadata;
  }

  /// Get relationship metadata for a field
  ///
  /// Returns null if no relationship exists for the given field
  RelationshipMetadata? getRelationshipMetadata(String fieldName) {
    return _relationshipMetadata[fieldName];
  }

  /// Get value of a field from an entity
  ///
  /// This should be implemented by generated DAOs to extract field values
  dynamic getFieldValue(T entity, String fieldName);

  /// Set value of a field on an entity
  ///
  /// This should be implemented by generated DAOs to set field values
  void setFieldValue(T entity, String fieldName, dynamic value);

  /// Convert a database row to an entity
  ///
  /// Implementations must override this to handle entity-specific conversions
  T fromJson(Map<String, dynamic> json);

  /// Convert an entity to a database row
  ///
  /// Implementations must override this to handle entity-specific conversions
  Map<String, dynamic> toJson(T entity);

  /// Get the primary key value of an entity
  ///
  /// Implementations must override this to extract the primary key
  int getPrimaryKey(T entity);

  /// Get column names to exclude from insert operations
  ///
  /// By default, returns an empty list. Override to specify columns to exclude.
  List<String> get excludeFromInsert => [];

  /// Get column names to exclude from update operations
  ///
  /// By default, returns an empty list. Override to specify columns to exclude.
  List<String> get excludeFromUpdate => [];

  @override
  Future<T?> findById(int id) async {
    final response =
        await _client.from(tableName).select().eq('id', id).single();

    return response != null ? fromJson(response) : null;
  }

  @override
  Future<List<T>> findAll() async {
    final response = await _client.from(tableName).select();

    return (response as List).map((json) => fromJson(json)).toList();
  }

  @override
  Future<List<T>> findWhere(Map<String, dynamic> conditions) async {
    var query = _client.from(tableName).select();

    // Apply each condition to the query
    conditions.forEach((field, value) {
      query = query.eq(field, value);
    });

    final response = await query;
    return (response as List).map((json) => fromJson(json)).toList();
  }

  @override
  Future<T?> findFirstWhere(Map<String, dynamic> conditions) async {
    try {
      var query = _client.from(tableName).select();

      // Apply each condition to the query
      conditions.forEach((field, value) {
        query = query.eq(field, value);
      });

      final response = await query.limit(1).single();
      return response != null ? fromJson(response) : null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<T> insert(T entity) async {
    final data = toJson(entity);

    // Remove columns that should be excluded from insert
    for (final column in excludeFromInsert) {
      data.remove(column);
    }

    final response =
        await _client.from(tableName).insert(data).select().single();

    return fromJson(response);
  }

  @override
  Future<T> update(T entity) async {
    final id = getPrimaryKey(entity);
    final data = toJson(entity);

    // Remove columns that should be excluded from update
    for (final column in excludeFromUpdate) {
      data.remove(column);
    }

    // Also remove the ID from the update data
    data.remove('id');

    final response = await _client
        .from(tableName)
        .update(data)
        .eq('id', id)
        .select()
        .single();

    return fromJson(response);
  }

  @override
  Future<void> delete(int id) async {
    await _client.from(tableName).delete().eq('id', id);
  }

  @override
  Future<int> count() async {
    final response = await _client.from(tableName).select(
        '*',
        const FetchOptions(
          count: CountOption.exact,
          head: true,
        ));
    return response.count ?? 0;
  }

  @override
  Future<int> countWhere(Map<String, dynamic> conditions) async {
    var query = _client.from(tableName).select(
        '*',
        const FetchOptions(
          count: CountOption.exact,
          head: true,
        ));

    // Apply each condition to the query
    conditions.forEach((field, value) {
      query = query.eq(field, value);
    });

    final response = await query;
    return response.count ?? 0;
  }

  @override
  Future<List<T>> rawQuery(String sql, [Map<String, dynamic>? params]) async {
    final response = await _client.rpc(
      'execute_sql',
      params: {
        'query': sql,
        'params': params ?? {},
      },
    );

    return (response as List).map((json) => fromJson(json)).toList();
  }

  @override
  Future<List<T>> findWhereIn(String column, List<dynamic> values) async {
    if (values.isEmpty) return [];

    final response = await _client.from(tableName).select().in_(column, values);

    return (response as List).map((json) => fromJson(json)).toList();
  }

  /// Gets a DAO for the specified type
  ///
  /// This is used for relationship loading
  DAO<R>? _getRelatedDAO<R>(Type type) {
    return daoRegistry.DAORegistry.getDAO<R>();
  }

  @override
  Future<R?> loadBelongsTo<R>(T entity, String relationName) async {
    // Get relationship metadata
    final metadata = getRelationshipMetadata(relationName);
    if (metadata == null || metadata.type != 'BelongsTo') {
      throw Exception(
          'Relation $relationName not found or not a BelongsTo relation');
    }

    // Get the foreign key value from the entity
    final foreignKeyValue = getFieldValue(entity, metadata.foreignKey);
    if (foreignKeyValue == null) return null;

    // Get the DAO for the related type
    final relatedDAO = _getRelatedDAO<R>(metadata.relatedClass);
    if (relatedDAO == null) {
      throw Exception('No DAO registered for ${metadata.relatedClass}');
    }

    // Load the related entity
    final relatedEntity = await relatedDAO.findById(foreignKeyValue);

    // If eager loading is enabled, update the entity field
    if (relatedEntity != null) {
      setFieldValue(entity, relationName, relatedEntity);
    }

    return relatedEntity;
  }

  @override
  Future<List<R>> loadHasMany<R>(T entity, String relationName) async {
    // Get relationship metadata
    final metadata = getRelationshipMetadata(relationName);
    if (metadata == null || metadata.type != 'HasMany') {
      throw Exception(
          'Relation $relationName not found or not a HasMany relation');
    }

    // Get the primary key value from the entity
    final primaryKey = getPrimaryKey(entity);

    // Get the DAO for the related type
    final relatedDAO = _getRelatedDAO<R>(metadata.relatedClass);
    if (relatedDAO == null) {
      throw Exception('No DAO registered for ${metadata.relatedClass}');
    }

    // Load the related entities
    final relatedEntities =
        await relatedDAO.findWhere({metadata.foreignKey: primaryKey});

    // If eager loading is enabled, update the entity field
    setFieldValue(entity, relationName, relatedEntities);

    return relatedEntities;
  }

  @override
  Future<R?> loadHasOne<R>(T entity, String relationName) async {
    // Get relationship metadata
    final metadata = getRelationshipMetadata(relationName);
    if (metadata == null || metadata.type != 'HasOne') {
      throw Exception(
          'Relation $relationName not found or not a HasOne relation');
    }

    // Get the primary key value from the entity
    final primaryKey = getPrimaryKey(entity);

    // Get the DAO for the related type
    final relatedDAO = _getRelatedDAO<R>(metadata.relatedClass);
    if (relatedDAO == null) {
      throw Exception('No DAO registered for ${metadata.relatedClass}');
    }

    // Load the related entity
    final relatedEntity =
        await relatedDAO.findFirstWhere({metadata.foreignKey: primaryKey});

    // If eager loading is enabled, update the entity field
    if (relatedEntity != null) {
      setFieldValue(entity, relationName, relatedEntity);
    }

    return relatedEntity;
  }

  @override
  Future<List<R>> loadManyToMany<R>(T entity, String relationName) async {
    // Get relationship metadata
    final metadata = getRelationshipMetadata(relationName);
    if (metadata == null || metadata.type != 'ManyToMany') {
      throw Exception(
          'Relation $relationName not found or not a ManyToMany relation');
    }

    // Ensure we have all required fields
    if (metadata.pivotTable == null || metadata.relatedKey == null) {
      throw Exception(
          'ManyToMany relation $relationName missing pivot table or related key');
    }

    // Get the primary key value from the entity
    final primaryKey = getPrimaryKey(entity);

    // Query the pivot table to get related IDs
    final pivotResponse = await _client
        .from(metadata.pivotTable!)
        .select(metadata.relatedKey!)
        .eq(metadata.foreignKey, primaryKey);

    // Extract the related IDs
    final relatedIds = (pivotResponse as List)
        .map((row) => row[metadata.relatedKey!])
        .whereType<int>()
        .toList();

    if (relatedIds.isEmpty) return [];

    // Get the DAO for the related type
    final relatedDAO = _getRelatedDAO<R>(metadata.relatedClass);
    if (relatedDAO == null) {
      throw Exception('No DAO registered for ${metadata.relatedClass}');
    }

    // Load the related entities
    final relatedEntities = await relatedDAO.findWhereIn('id', relatedIds);

    // If eager loading is enabled, update the entity field
    setFieldValue(entity, relationName, relatedEntities);

    return relatedEntities;
  }

  @override
  Future<void> addRelation<R>(T entity, String relationName, int relatedId,
      [Map<String, dynamic>? pivotData]) async {
    // Get relationship metadata
    final metadata = getRelationshipMetadata(relationName);
    if (metadata == null || metadata.type != 'ManyToMany') {
      throw Exception(
          'Relation $relationName not found or not a ManyToMany relation');
    }

    // Ensure we have all required fields
    if (metadata.pivotTable == null || metadata.relatedKey == null) {
      throw Exception(
          'ManyToMany relation $relationName missing pivot table or related key');
    }

    // Get the primary key value from the entity
    final primaryKey = getPrimaryKey(entity);

    // Create data for the pivot table
    final Map<String, dynamic> data = {
      metadata.foreignKey: primaryKey,
      metadata.relatedKey!: relatedId,
    };

    // Add any additional pivot data
    if (pivotData != null) {
      data.addAll(pivotData);
    }

    // Insert into the pivot table
    await _client.from(metadata.pivotTable!).insert(data);
  }

  @override
  Future<void> removeRelation<R>(
      T entity, String relationName, int relatedId) async {
    // Get relationship metadata
    final metadata = getRelationshipMetadata(relationName);
    if (metadata == null || metadata.type != 'ManyToMany') {
      throw Exception(
          'Relation $relationName not found or not a ManyToMany relation');
    }

    // Ensure we have all required fields
    if (metadata.pivotTable == null || metadata.relatedKey == null) {
      throw Exception(
          'ManyToMany relation $relationName missing pivot table or related key');
    }

    // Get the primary key value from the entity
    final primaryKey = getPrimaryKey(entity);

    // Delete from the pivot table
    await _client
        .from(metadata.pivotTable!)
        .delete()
        .eq(metadata.foreignKey, primaryKey)
        .eq(metadata.relatedKey!, relatedId);
  }

  @override
  Future<T?> findByIdWithRelations(int id, List<String> relations) async {
    // First load the entity
    final entity = await findById(id);
    if (entity == null) return null;

    // Then load all requested relations
    for (final relationName in relations) {
      final metadata = getRelationshipMetadata(relationName);
      if (metadata == null) {
        continue; // Skip unknown relations
      }

      // Load the appropriate relation type
      switch (metadata.type) {
        case 'BelongsTo':
          await loadBelongsTo(entity, relationName);
          break;
        case 'HasMany':
          await loadHasMany(entity, relationName);
          break;
        case 'HasOne':
          await loadHasOne(entity, relationName);
          break;
        case 'ManyToMany':
          await loadManyToMany(entity, relationName);
          break;
      }
    }

    return entity;
  }

  @override
  Future<List<T>> findAllWithRelations(List<String> relations) async {
    // First load all entities
    final entities = await findAll();

    // Then load relations for each entity
    for (final entity in entities) {
      for (final relationName in relations) {
        final metadata = getRelationshipMetadata(relationName);
        if (metadata == null) {
          continue; // Skip unknown relations
        }

        // Load the appropriate relation type
        switch (metadata.type) {
          case 'BelongsTo':
            await loadBelongsTo(entity, relationName);
            break;
          case 'HasMany':
            await loadHasMany(entity, relationName);
            break;
          case 'HasOne':
            await loadHasOne(entity, relationName);
            break;
          case 'ManyToMany':
            await loadManyToMany(entity, relationName);
            break;
        }
      }
    }

    return entities;
  }
}
