// Utility classes to handle relationship metadata
import '../annotations/relationship_annotations.dart';

/// Information about a relationship between entities
class RelationshipMetadata {
  /// The type of relationship (BelongsTo, HasMany, HasOne, ManyToMany)
  final String type;

  /// The name of the field in the entity that defines this relationship
  final String fieldName;

  /// The class of the related entity
  final Type relatedClass;

  /// The name of the foreign key field
  final String foreignKey;

  /// For ManyToMany relationships, the name of the pivot table
  final String? pivotTable;

  /// For ManyToMany relationships, the name of the related key in the pivot table
  final String? relatedKey;

  /// Whether to eagerly load this relationship by default
  final bool eager;

  /// Optional WHERE clause to filter related entities
  final String? where;

  RelationshipMetadata({
    required this.type,
    required this.fieldName,
    required this.relatedClass,
    required this.foreignKey,
    this.pivotTable,
    this.relatedKey,
    this.eager = false,
    this.where,
  });

  /// Create RelationshipMetadata from a BelongsTo annotation
  factory RelationshipMetadata.fromBelongsTo(
    String fieldName,
    BelongsTo annotation,
  ) {
    return RelationshipMetadata(
      type: 'BelongsTo',
      fieldName: fieldName,
      relatedClass: annotation.runtimeType.toString().contains('<')
          ? _extractGenericType(annotation.runtimeType.toString())
          : Object,
      foreignKey: annotation.foreignKey,
      eager: annotation.eager,
      where: annotation.where,
    );
  }

  /// Create RelationshipMetadata from a HasMany annotation
  factory RelationshipMetadata.fromHasMany(
    String fieldName,
    HasMany annotation,
  ) {
    return RelationshipMetadata(
      type: 'HasMany',
      fieldName: fieldName,
      relatedClass: annotation.runtimeType.toString().contains('<')
          ? _extractGenericType(annotation.runtimeType.toString())
          : Object,
      foreignKey: annotation.foreignKey,
      eager: annotation.eager,
      where: annotation.where,
    );
  }

  /// Create RelationshipMetadata from a HasOne annotation
  factory RelationshipMetadata.fromHasOne(
    String fieldName,
    HasOne annotation,
  ) {
    return RelationshipMetadata(
      type: 'HasOne',
      fieldName: fieldName,
      relatedClass: annotation.runtimeType.toString().contains('<')
          ? _extractGenericType(annotation.runtimeType.toString())
          : Object,
      foreignKey: annotation.foreignKey,
      eager: annotation.eager,
      where: annotation.where,
    );
  }

  /// Create RelationshipMetadata from a ManyToMany annotation
  factory RelationshipMetadata.fromManyToMany(
    String fieldName,
    ManyToMany annotation,
  ) {
    return RelationshipMetadata(
      type: 'ManyToMany',
      fieldName: fieldName,
      relatedClass: annotation.runtimeType.toString().contains('<')
          ? _extractGenericType(annotation.runtimeType.toString())
          : Object,
      foreignKey: annotation.foreignKey,
      pivotTable: annotation.pivotTable,
      relatedKey: annotation.relatedKey,
      eager: annotation.eager,
      where: annotation.where,
    );
  }
}

/// Extract the generic type from a type string
/// e.g. "BelongsTo<User>" -> User
Type _extractGenericType(String typeString) {
  final match = RegExp(r'<([^>]+)>').firstMatch(typeString);
  if (match != null && match.groupCount >= 1) {
    // The typeName is extracted but currently not used
    // In a real implementation, you would need to resolve this type name
    // to an actual Type object, which is non-trivial in Dart
    // For now, return a placeholder
    return Object;
  }
  return Object;
}
