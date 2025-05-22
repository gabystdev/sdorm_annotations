// Table-related annotations for the Supabase ORM system
// This file defines annotations used to mark Dart classes as database tables
import 'package:meta/meta.dart';

/// Enum defining column naming strategies
enum ColumnNaming {
  /// Use snake_case for column names (default)
  snakeCase,

  /// Use camelCase for column names
  camelCase,

  /// Use column names exactly as defined in the model
  exact,
}

/// Marks a class as a database table
@immutable
class Table {
  /// The name of the database table
  final String name;

  /// The column naming strategy to use
  final ColumnNaming columnNaming;

  /// Whether to generate a DAO for this table
  final bool generateDAO;

  /// Create a table annotation
  const Table(
    this.name, {
    this.columnNaming = ColumnNaming.snakeCase,
    this.generateDAO = true,
  });
}

/// Marks a field as a column in the database
@immutable
class Column {
  /// Custom name for the column in the database
  final String? columnName;

  /// Whether this column can be null
  final bool isNullable;

  /// Whether to exclude this field when inserting
  final bool excludeFromInsert;

  /// Whether to exclude this field when updating
  final bool excludeFromUpdate;

  /// Documentation for the field
  final String? description;

  /// Create a column annotation
  const Column({
    this.columnName,
    this.isNullable = false,
    this.excludeFromInsert = false,
    this.excludeFromUpdate = false,
    this.description,
  });
}

/// Marks a field as the primary key
@immutable
class PrimaryKey {
  /// Whether the primary key is auto-incrementing
  final bool autoIncrement;

  /// Whether to exclude this field when inserting
  final bool includeInInsert;

  /// Whether to exclude this field when updating
  final bool includeInUpdate;

  /// Create a primary key annotation
  const PrimaryKey({
    this.autoIncrement = true,
    this.includeInInsert = false,
    this.includeInUpdate = false,
  });
}

/// Marks a field as a computed field that doesn't exist in the database
@immutable
class ComputedField {
  /// Optional description of the computed field
  final String? description;

  /// Create a computed field annotation
  const ComputedField({
    this.description,
  });
}

/// Marks a table as having database indexes
@immutable
class Index {
  /// The fields included in the index
  final List<String> fields;

  /// Whether the index enforces uniqueness
  final bool unique;

  /// Optional name for the index
  final String? name;

  /// Create an index annotation
  const Index({
    required this.fields,
    this.unique = false,
    this.name,
  });
}
