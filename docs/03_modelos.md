# 📝 Modelos y Anotaciones

## 📋 Índice

1. [Conceptos Básicos](#conceptos-básicos)
2. [Anotaciones Disponibles](#anotaciones-disponibles)
3. [Tipos de Columnas](#tipos-de-columnas)
4. [Relaciones](#relaciones)
5. [Generación de Código](#generación-de-código)
6. [Mejores Prácticas](#mejores-prácticas)

## 🔰 Conceptos Básicos

### Estructura Básica de un Modelo

```dart
import 'package:supabase_dart_client/supabase_dart_client.dart';

@Table(
  'products',
  columnNaming: ColumnNaming.snakeCase,
  generateDAO: true,
  generateKeyPaths: true,
)
class Product {
  @PrimaryKey(autoIncrement: true)
  final int id;
  
  @Column()
  final String name;
  
  Product({
    required this.id,
    required this.name,
  });
  
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
```

## 📌 Anotaciones Disponibles

### @Table

Define la configuración de la tabla en Supabase.

```dart
@Table(
  'table_name',                    // Nombre de la tabla en Supabase
  columnNaming: ColumnNaming.snakeCase,  // Esquema de nombres
  generateDAO: true,               // Generar DAO automáticamente
  generateKeyPaths: true,          // Generar KeyPaths para consultas
  description: 'Table description' // Documentación
)
```

Opciones disponibles:
- `name`: Nombre de la tabla en Supabase
- `columnNaming`: Esquema de nombres para columnas
  - `ColumnNaming.snakeCase` (default)
  - `ColumnNaming.camelCase`
- `generateDAO`: Genera clase DAO automáticamente
- `generateKeyPaths`: Genera KeyPaths para consultas tipadas
- `description`: Documentación de la tabla

### @Column

Define una columna en la tabla.

```dart
@Column(
  columnName: 'custom_name',    // Nombre personalizado
  isNullable: true,            // Permite valores null
  description: 'Description',   // Documentación
  excludeFromInsert: true,     // Excluir al insertar
  excludeFromUpdate: true      // Excluir al actualizar
)
final String myColumn;
```

Opciones:
- `columnName`: Nombre personalizado en la base de datos
- `isNullable`: Si permite valores null
- `description`: Documentación de la columna
- `excludeFromInsert`: No incluir en operaciones INSERT
- `excludeFromUpdate`: No incluir en operaciones UPDATE

### @PrimaryKey

Define la clave primaria de la tabla.

```dart
@PrimaryKey(
  autoIncrement: true,           // Auto-incrementar
  includeInInsert: false,       // Incluir en INSERT
  includeInUpdate: false        // Incluir en UPDATE
)
final int id;
```

### @Index

Define índices para la tabla.

```dart
@Index(
  fields: ['name', 'email'],    // Campos del índice
  unique: true                  // Si es único
)
@Table('users')
class User { ... }
```

### @ComputedField

Define un campo calculado.

```dart
@ComputedField(
  description: 'Full price with tax',
  includeInKeyPaths: true
)
double get totalPrice => price * (1 + taxRate);
```

## 🔤 Tipos de Columnas

### Tipos Básicos
```dart
@Column()
final int intValue;

@Column()
final double doubleValue;

@Column()
final String stringValue;

@Column()
final bool boolValue;

@Column()
final DateTime dateValue;
```

### Tipos Personalizados
```dart
@Column(
  fromJson: _statusFromJson,
  toJson: _statusToJson
)
final OrderStatus status;

static OrderStatus _statusFromJson(dynamic json) {
  return OrderStatus.values[json as int];
}

static dynamic _statusToJson(OrderStatus status) {
  return status.index;
}
```

### Arrays
```dart
@Column(isArray: true)
final List<String> tags;

@Column(isArray: true)
final List<int> numbers;
```

## 🔗 Relaciones

### @BelongsTo (Muchos a Uno)
```dart
@Table('products')
class Product {
  @BelongsTo(Category, 
    foreignKey: 'category_id',
    eager: true,
    includeInKeyPaths: true
  )
  @Column(columnName: 'category_id')
  final int categoryId;
  
  final Category? category;  // Campo de relación
}
```

### @HasMany (Uno a Muchos)
```dart
@Table('categories')
class Category {
  @HasMany(Product,
    foreignKey: 'category_id',
    eager: false,
    includeInKeyPaths: true
  )
  final List<Product>? products;
}
```

### @HasOne (Uno a Uno)
```dart
@Table('users')
class User {
  @HasOne(UserProfile,
    foreignKey: 'user_id',
    eager: true,
    includeInKeyPaths: true
  )
  final UserProfile? profile;
}
```

### @ManyToMany (Muchos a Muchos)
```dart
@Table('products')
class Product {
  @ManyToMany(Tag,
    pivotTable: 'product_tags',
    foreignKey: 'product_id',
    relatedKey: 'tag_id',
    eager: false,
    includeInKeyPaths: true
  )
  final List<Tag>? tags;
}
```

## 🛠 Generación de Código

### Archivos Generados

Por cada modelo se generan:

1. **DAO**
```dart
// product.dao.dart
class ProductDAO extends BaseDAO<Product> {
  // Métodos generados automáticamente
}
```

2. **KeyPaths**
```dart
// product.keypaths.dart
class Product_ {
  static final SimpleKeyPath<Product, int> id = ...
  static final SimpleKeyPath<Product, String> name = ...
}
```

### Proceso de Generación

1. Ejecutar build_runner:
```bash
dart run build_runner build
```

2. Verificar archivos generados:
```bash
dart run build_runner watch
```

## ✨ Mejores Prácticas

### 1. Inmutabilidad
```dart
@Table('products')
class Product {
  // Campos finales
  final int id;
  final String name;
  
  // Constructor con parámetros nombrados
  const Product({
    required this.id,
    required this.name,
  });
  
  // Método copyWith para modificaciones
  Product copyWith({
    int? id,
    String? name,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }
}
```

### 2. Validación de Datos
```dart
@Table('users')
class User {
  @Column()
  final String email;
  
  User({required String email}) : 
    assert(email.contains('@')),
    this.email = email;
}
```

### 3. Documentación
```dart
/// Representa un producto en el sistema de inventario
///
/// Cada producto puede pertenecer a una categoría y tener múltiples tags
@Table(
  'products',
  description: 'Tabla de productos del sistema'
)
class Product {
  /// Identificador único del producto
  @PrimaryKey(autoIncrement: true)
  final int id;
  
  /// Nombre del producto
  /// 
  /// Debe ser único en el sistema
  @Column(description: 'Nombre único del producto')
  final String name;
}
```

### 4. Organización de Archivos
```
lib/
  ├── models/
  │   ├── product.dart
  │   ├── product.g.dart       // Generado
  │   ├── product.dao.dart     // Generado
  │   └── product.keypaths.dart // Generado
  └── dao/
      └── custom_daos.dart     // DAOs personalizados
```

## 🎯 Tips y Consejos

1. **Nombrado de Clases**
   - Usar PascalCase para clases
   - Sufijo DAO para clases DAO
   - Sufijo _ para clases KeyPath

2. **Relaciones**
   - Usar eager: true solo cuando sea necesario
   - Documentar relaciones complejas
   - Evitar ciclos en relaciones

3. **Rendimiento**
   - Limitar campos eager loading
   - Usar índices apropiadamente
   - Implementar paginación cuando sea necesario

4. **Testing**
   - Crear factories para pruebas
   - Probar casos límite
   - Validar relaciones

## 📚 Referencias

- [Documentación Supabase](https://supabase.com/docs)
- [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- [API Reference](../09_api_reference.md)
- [Ejemplos](../07_ejemplos.md)
