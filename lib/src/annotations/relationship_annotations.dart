// Relationship annotations for the Supabase ORM system
// This file defines annotations used to mark relationships between tables
import 'package:meta/meta.dart';

/// Represents a Many-to-One relationship (this entity belongs to parent entity)
@immutable
class BelongsTo<T> {
  /// Foreign key field in this entity
  final String foreignKey;

  /// Whether to eagerly load the related entity
  final bool eager;

  /// Optional where clause for filtering related entities
  final String? where;

  /// Create a belongs-to relationship annotation
  const BelongsTo(
    Type type, {
    required this.foreignKey,
    this.eager = false,
    this.where,
  });
}

/// Represents a One-to-Many relationship (this entity has many child entities)
@immutable
class HasMany<T> {
  /// Foreign key field in the related entity
  final String foreignKey;

  /// Whether to eagerly load the related entities
  final bool eager;

  /// Optional where clause for filtering related entities
  final String? where;

  /// Create a has-many relationship annotation
  const HasMany(
    Type type, {
    required this.foreignKey,
    this.eager = false,
    this.where,
  });
}

/// Represents a One-to-One relationship (this entity has one related entity)
@immutable
class HasOne<T> {
  /// Foreign key field in the related entity
  final String foreignKey;

  /// Whether to eagerly load the related entity
  final bool eager;

  /// Optional where clause for filtering the related entity
  final String? where;

  /// Create a has-one relationship annotation
  const HasOne(
    Type type, {
    required this.foreignKey,
    this.eager = false,
    this.where,
  });
}

/// Represents a Many-to-Many relationship between entities
@immutable
class ManyToMany<T> {
  /// Name of the pivot table
  final String pivotTable;

  /// Foreign key in the pivot table referencing this entity
  final String foreignKey;

  /// Foreign key in the pivot table referencing the related entity
  final String relatedKey;

  /// Whether to eagerly load the related entities
  final bool eager;

  /// Optional where clause for filtering related entities
  final String? where;

  /// Optional list of additional fields to select from the pivot table
  final List<String>? pivotFields;

  /// Create a many-to-many relationship annotation
  const ManyToMany(
    Type type, {
    required this.pivotTable,
    required this.foreignKey,
    required this.relatedKey,
    this.eager = false,
    this.where,
    this.pivotFields,
  });
}

/// Represents a many-to-many relationship with a dedicated pivot entity
@immutable
class ManyToManyPivot<P, T> {
  /// Name of the pivot table
  final String pivotTable;

  /// The pivot entity type
  final Type pivotModel;

  /// Foreign key in the pivot table referencing this entity
  final String foreignKey;

  /// Foreign key in the pivot table referencing the related entity
  final String relatedKey;

  /// Whether to eagerly load the related entities
  final bool eager;

  /// Optional where clause for filtering related entities
  final String? where;

  /// Create a many-to-many relationship annotation with pivot entity
  const ManyToManyPivot(
    Type type, {
    required this.pivotTable,
    required this.pivotModel,
    required this.foreignKey,
    required this.relatedKey,
    this.eager = false,
    this.where,
  });
}
