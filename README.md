# Supabase Dart Client ORM

Un cliente para Supabase con características avanzadas de ORM, utilizando anotaciones en los modelos para generación automática de DAOs (Data Access Objects) que facilita el acceso y gestión de dato🌟 Características

- ✅ **Sistema unificado de anotaciones**: Define tus modelos de datos con anotaciones claras y coherentes 
- ✅ **Generación de DAOs**: Crea automáticamente objetos de acceso a datos con métodos CRUD completos
- ✅ **Soporte para relaciones**: Maneja relaciones `BelongsTo`, `HasMany`, `HasOne` y `ManyToMany` con tipos genéricos
- ✅ **Campos calculados**: Incluye propiedades computadas en tus modelos
- ✅ **Consultas eficientes**: Construye consultas complejas con un API intuitivo

## 📋 Requisitos

- Dart SDK: >=2.19.0 <4.0.0
- Supabase Flutter: ^1.10.4

## 🚀 Instalación

```yaml
dependencies:
  supabase_dart_client: ^0.2.0
  # O desde el repositorio:
  # supabase_dart_client:
  #   git:
  #     url: https://github.com/tuusuario/supabase-dart-client.git
  #     ref: main
  
dev_dependencies:
  build_runner: ^2.4.6
```

## 📖 Uso

### Definición de modelos

```dart
import 'package:supabase_dart_client/supabase_dart_client.dart';

@Table(
  'users',
  columnNaming: ColumnNaming.snakeCase,
  generateDAO: true
)
class User {
  @PrimaryKey(autoIncrement: true)
  final int? id;
  
  @Column()
  final String name;
  
  @Column(columnName: 'email_address')
  final String email;
  
  @Column(isNullable: true, description: 'URL de la imagen de perfil')
  final String? avatarUrl;
  
  @HasMany<Post>(Post, foreignKey: 'user_id')
  final List<Post>? posts;
  
  @BelongsTo<Role>(Role, foreignKey: 'role_id')
  @Column(columnName: 'role_id')
  final int roleId;
  
  @ManyToMany<Group>(Group,
    pivotTable: 'user_groups',
    foreignKey: 'user_id',
    relatedKey: 'group_id'
  )
  final List<Group>? groups;
  
  @ComputedField(description: 'Nombre completo del usuario')
  String get fullName => '$name ($email)';
  
  User({
    this.id, 
    required this.name, 
    required this.email,
    required this.roleId,
    this.avatarUrl,
    this.posts,
    this.groups,
  });
  
  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    name: json['name'],
    email: json['email_address'],
    roleId: json['role_id'],
    avatarUrl: json['avatar_url'],
  );
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email_address': email,
    'role_id': roleId,
    'avatar_url': avatarUrl,
  };
}
```

### Generación de código

Ejecuta build_runner para generar los DAOs:

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Uso de DAOs generados

```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'user.dao.g.dart'; // Archivo generado automáticamente

void main() async {
  // Inicializar Supabase
  final client = SupabaseClient('SUPABASE_URL', 'SUPABASE_KEY');
  
  // Crear instancia del DAO
  final userDAO = UserDAO(client);
  
  // Operaciones CRUD básicas
  final user = await userDAO.findById(1);
  final allUsers = await userDAO.findAll();
  
  // Consultas con condiciones
  final activeUsers = await userDAO.findWhere({'active': true});
  final adminUser = await userDAO.findFirstWhere({'role_id': 1});
  
  // Insertar un nuevo usuario
  final newUser = User(
    name: 'Nuevo Usuario',
    email: 'nuevo@example.com',
    roleId: 2,
  );
  final insertedUser = await userDAO.insert(newUser);
  
  // Actualizar un usuario
  final updatedUser = await userDAO.update(user);
  
  // Eliminar un usuario
  await userDAO.delete(1);
}

// Ejecutar tests de los DAOs
import 'package:supabase_dart_client/src/test_utils/dao_tester.dart';

void runTests() async {
  final client = Supabase.instance.client;
  
  // Test del DAO de productos
  await DAOTester.testProductDAO(client);
}

// Update a user
final updatedUser = await userDao.update(user.copyWith(name: 'Updated Name'));

// Delete a user
await userDao.delete(1);

// Use relationships
final posts = await userDao.getPostsFor(user);
```



## Annotations

### @Table

Marks a class as a database table.

```dart
@Table(
  'table_name',
  columnNaming: ColumnNaming.snakeCase,
  generateDAO: true,
)
```

### @Column

Marks a field as a database column.

```dart
@Column(
  columnName: 'custom_name',
  isNullable: true,
  description: 'Description for documentation',
  excludeFromInsert: false,
  excludeFromUpdate: false,
  isComputed: false,
)
```

### @PrimaryKey

Marks a field as the primary key.

```dart
@PrimaryKey(
  autoIncrement: true,
  includeInInsert: false,
  includeInUpdate: false,
)
```

### Relationship Annotations

- `@HasMany`: One-to-many relationship
- `@BelongsTo`: Many-to-one relationship
- `@HasOne`: One-to-one relationship
- `@ManyToMany`: Many-to-many relationship

## Generated Code

### DAO Methods

Each generated DAO includes:

- CRUD operations (findById, findAll, insert, update, delete)
- Relationship navigation methods
- Query helper methods

### KeyPath Fields

KeyPaths provide type-safe access to field names:

- Field names as strings for use in queries
- Support for nested properties
- Table name constants
