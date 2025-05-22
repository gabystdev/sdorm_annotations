// Interface for Data Access Objects (DAOs)
// This file defines the common interface that all generated DAOs will implement

/// Base interface for all Data Access Objects
///
/// This interface defines the standard operations that can be performed on a
/// database entity. Generated DAOs will implement this interface.
///
/// Type parameter [T] represents the entity type this DAO manages.
abstract class DAO<T> {
  /// The name of the table associated with this DAO
  String get tableName;

  /// Find an entity by its primary key ID
  ///
  /// Returns null if no entity is found with the given ID
  Future<T?> findById(int id);

  /// Find all entities in the table
  ///
  /// Returns an empty list if no entities are found
  Future<List<T>> findAll();

  /// Find entities matching the given conditions
  ///
  /// The [conditions] map contains column names as keys and expected values
  /// Returns an empty list if no matching entities are found
  Future<List<T>> findWhere(Map<String, dynamic> conditions);

  /// Find the first entity matching the given conditions
  ///
  /// The [conditions] map contains column names as keys and expected values
  /// Returns null if no matching entity is found
  Future<T?> findFirstWhere(Map<String, dynamic> conditions);

  /// Insert a new entity into the database
  ///
  /// Returns the inserted entity with any auto-generated fields populated
  Future<T> insert(T entity);

  /// Update an existing entity in the database
  ///
  /// Returns the updated entity
  Future<T> update(T entity);

  /// Delete an entity by its primary key ID
  Future<void> delete(int id);

  /// Count all entities in the table
  Future<int> count();

  /// Count entities matching the given conditions
  ///
  /// The [conditions] map contains column names as keys and expected values
  Future<int> countWhere(Map<String, dynamic> conditions);

  /// Execute a raw SQL query and return the results as entities
  ///
  /// Use this method with caution as it bypasses type safety
  Future<List<T>> rawQuery(String sql, [Map<String, dynamic>? params]);

  /// Find entities matching any of the values in the given column
  ///
  /// The [column] is the name of the column to check
  /// The [values] are the possible values to match against
  Future<List<T>> findWhereIn(String column, List<dynamic> values);

  // Relation loading methods

  /// Load a BelongsTo (Many-to-One) relation for the given entity
  ///
  /// The [relationName] is the field name in the entity that defines the relation
  /// Returns the related entity, or null if not found
  Future<R?> loadBelongsTo<R>(T entity, String relationName);

  /// Load a HasMany (One-to-Many) relation for the given entity
  ///
  /// The [relationName] is the field name in the entity that defines the relation
  /// Returns a list of related entities, or an empty list if none found
  Future<List<R>> loadHasMany<R>(T entity, String relationName);

  /// Load a HasOne (One-to-One) relation for the given entity
  ///
  /// The [relationName] is the field name in the entity that defines the relation
  /// Returns the related entity, or null if not found
  Future<R?> loadHasOne<R>(T entity, String relationName);

  /// Load a ManyToMany relation for the given entity
  ///
  /// The [relationName] is the field name in the entity that defines the relation
  /// Returns a list of related entities, or an empty list if none found
  Future<List<R>> loadManyToMany<R>(T entity, String relationName);

  // Relation management methods for ManyToMany relations

  /// Add a relation to a ManyToMany relationship
  ///
  /// Creates an entry in the pivot table linking the entity with the related entity
  /// The [relationName] is the field name defining the ManyToMany relation
  /// The [relatedId] is the primary key of the related entity to link
  /// Optional [pivotData] allows adding extra data to the pivot table
  Future<void> addRelation<R>(T entity, String relationName, int relatedId,
      [Map<String, dynamic>? pivotData]);

  /// Remove a relation from a ManyToMany relationship
  ///
  /// Removes the entry in the pivot table linking the entity with the related entity
  /// The [relationName] is the field name defining the ManyToMany relation
  /// The [relatedId] is the primary key of the related entity to unlink
  Future<void> removeRelation<R>(T entity, String relationName, int relatedId);

  /// Find an entity by ID with related entities preloaded
  ///
  /// The [id] is the primary key of the entity to find
  /// The [relations] is a list of relation names to preload
  /// Returns the entity with related entities loaded, or null if not found
  Future<T?> findByIdWithRelations(int id, List<String> relations);

  /// Find all entities with related entities preloaded
  ///
  /// The [relations] is a list of relation names to preload
  /// Returns a list of entities with related entities loaded
  Future<List<T>> findAllWithRelations(List<String> relations);
}
