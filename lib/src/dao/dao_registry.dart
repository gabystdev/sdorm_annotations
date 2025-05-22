// DAO Registry
// This file provides a global registry for managing and accessing DAOs by entity type

import 'dao_interface.dart';

/// A global registry for DAOs
///
/// This class provides a way to register and look up DAOs by their entity type.
/// It is used primarily for relationship loading, allowing a DAO to access other
/// DAOs that handle related entity types.
class DAORegistry {
  // Private static map to hold the DAOs, keyed by type
  static final _daos = <Type, DAO>{};

  /// Register a DAO for a specific entity type
  ///
  /// [T] is the entity type this DAO manages
  /// [dao] is the DAO instance to register
  static void registerDAO<T>(DAO<T> dao) {
    _daos[T] = dao;
  }

  /// Get a DAO for a specific entity type
  ///
  /// [T] is the entity type to get a DAO for
  /// Returns the registered DAO for the given type, or null if none exists
  static DAO<T>? getDAO<T>() {
    final dao = _daos[T];
    if (dao is DAO<T>) {
      return dao;
    }
    return null;
  }

  /// Get a DAO by Type object rather than generic parameter
  ///
  /// [type] is the Type object representing the entity type
  /// Returns the registered DAO for the given type cast to the appropriate type,
  /// or null if none exists
  static DAO? getDAOByType(Type type) {
    return _daos[type];
  }

  /// Clear all registered DAOs
  ///
  /// This is primarily used for testing purposes
  static void clearAll() {
    _daos.clear();
  }

  /// Remove a specific DAO from the registry
  ///
  /// [T] is the entity type for which to unregister the DAO
  static void unregisterDAO<T>() {
    _daos.remove(T);
  }
}
