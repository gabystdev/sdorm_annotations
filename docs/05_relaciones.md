# 🔗 Relaciones entre Modelos

## 📋 Índice

1. [Tipos de Relaciones](#tipos-de-relaciones)
2. [Configuración de Relaciones](#configuración-de-relaciones)
3. [Carga de Relaciones](#carga-de-relaciones)
4. [Gestión de Relaciones](#gestión-de-relaciones)
5. [Casos de Uso Avanzados](#casos-de-uso-avanzados)
6. [Optimización y Rendimiento](#optimización-y-rendimiento)

## 🔄 Tipos de Relaciones

### BelongsTo (Pertenece a)

Representa una relación "muchos a uno".

```dart
@Table('products')
class Product {
  @PrimaryKey()
  final int id;
  
  @BelongsTo(Category, 
    foreignKey: 'category_id',
    eager: true,
    includeInKeyPaths: true
  )
  @Column(columnName: 'category_id')
  final int categoryId;
  
  final Category? category; // Campo de relación
}
```

### HasMany (Tiene Muchos)

Representa una relación "uno a muchos".

```dart
@Table('categories')
class Category {
  @PrimaryKey()
  final int id;
  
  @HasMany(Product,
    foreignKey: 'category_id',
    eager: false,
    includeInKeyPaths: true,
    where: 'is_active = true' // Condición opcional
  )
  final List<Product>? products;
}
```

### HasOne (Tiene Uno)

Representa una relación "uno a uno".

```dart
@Table('users')
class User {
  @PrimaryKey()
  final int id;
  
  @HasOne(UserProfile,
    foreignKey: 'user_id',
    eager: true,
    includeInKeyPaths: true
  )
  final UserProfile? profile;
}

@Table('user_profiles')
class UserProfile {
  @PrimaryKey()
  final int id;
  
  @BelongsTo(User,
    foreignKey: 'user_id'
  )
  @Column(columnName: 'user_id')
  final int userId;
}
```

### ManyToMany (Muchos a Muchos)

Representa una relación "muchos a muchos" usando una tabla pivot.

```dart
@Table('products')
class Product {
  @PrimaryKey()
  final int id;
  
  @ManyToMany(Tag,
    pivotTable: 'product_tags',
    foreignKey: 'product_id',
    relatedKey: 'tag_id',
    eager: false,
    includeInKeyPaths: true
  )
  final List<Tag>? tags;
}

@Table('tags')
class Tag {
  @PrimaryKey()
  final int id;
  
  @ManyToMany(Product,
    pivotTable: 'product_tags',
    foreignKey: 'tag_id',
    relatedKey: 'product_id'
  )
  final List<Product>? products;
}
```

## ⚙️ Configuración de Relaciones

### Opciones Comunes

```dart
@BelongsTo(
  RelatedModel,            // Tipo de modelo relacionado
  foreignKey: 'key_name',  // Nombre de la clave foránea
  eager: true,            // Cargar automáticamente
  includeInKeyPaths: true, // Incluir en KeyPaths
  where: 'condition',     // Condición SQL opcional
  orderBy: 'field ASC'    // Ordenamiento opcional
)
```

### Configuración de Eager Loading

```dart
// Carga ansiosa (eager)
@BelongsTo(Category, eager: true)
final Category? category;

// Carga perezosa (lazy)
@BelongsTo(Category, eager: false)
final Category? category;
```

### Condiciones y Ordenamiento

```dart
@HasMany(Order,
  foreignKey: 'user_id',
  where: 'status = \'completed\'',
  orderBy: 'created_at DESC'
)
final List<Order>? completedOrders;
```

## 📥 Carga de Relaciones

### Carga Manual

```dart
// Cargar una relación específica
final product = await productDAO.findById(1);
final category = await productDAO.loadBelongsTo<Category>(
  product,
  'category'
);

// Cargar múltiples relaciones
final products = await productDAO.loadManyToMany<Tag>(
  product,
  'tags'
);
```

### Carga con Relaciones

```dart
// Cargar entidad con relaciones específicas
final product = await productDAO.findByIdWithRelations(
  1,
  ['category', 'reviews', 'tags']
);

// Cargar lista con relaciones
final products = await productDAO.findAllWithRelations(
  ['category', 'tags'],
  where: {Product_.price.greaterThan(100)}
);
```

### Carga Recursiva

```dart
// Cargar relaciones anidadas
final order = await orderDAO.findByIdWithRelations(
  1,
  [
    'customer',
    'items',
    'items.product',
    'items.product.category'
  ]
);
```

## 🛠 Gestión de Relaciones

### Agregar Relaciones

```dart
// Agregar tag a producto (ManyToMany)
await productDAO.addRelation<Tag>(
  product,
  'tags',
  tagId
);

// Agregar múltiples tags
await productDAO.addRelations<Tag>(
  product,
  'tags',
  [tag1Id, tag2Id]
);
```

### Eliminar Relaciones

```dart
// Eliminar una relación
await productDAO.removeRelation<Tag>(
  product,
  'tags',
  tagId
);

// Eliminar múltiples relaciones
await productDAO.removeRelations<Tag>(
  product,
  'tags',
  [tag1Id, tag2Id]
);
```

### Actualizar Relaciones

```dart
// Reemplazar todas las relaciones
await productDAO.syncRelations<Tag>(
  product,
  'tags',
  [tag1Id, tag2Id]
);
```

## 🎯 Casos de Uso Avanzados

### Relaciones Polimórficas

```dart
@Table('comments')
class Comment {
  @Column(columnName: 'commentable_id')
  final int commentableId;
  
  @Column(columnName: 'commentable_type')
  final String commentableType;
  
  @Polymorphic(
    types: {
      'product': Product,
      'post': Post
    },
    typeField: 'commentable_type',
    idField: 'commentable_id'
  )
  final dynamic commentable;
}
```

### Relaciones con Condiciones

```dart
@Table('users')
class User {
  @HasMany(Order,
    foreignKey: 'user_id',
    where: 'status = \'completed\'',
    orderBy: 'created_at DESC',
    limit: 5
  )
  final List<Order>? recentCompletedOrders;
}
```

### Relaciones Compuestas

```dart
@Table('product_variants')
class ProductVariant {
  @CompositeBelongsTo(
    Product,
    foreignKeys: {
      'product_id': 'id',
      'shop_id': 'shop_id'
    }
  )
  final Product? product;
}
```

## ⚡️ Optimización y Rendimiento

### Prevención de N+1

```dart
// Mal (N+1 queries)
final products = await productDAO.findAll();
for (final product in products) {
  await productDAO.loadBelongsTo<Category>(product, 'category');
}

// Bien (1 query)
final products = await productDAO.findAllWithRelations(['category']);
```

### Carga Selectiva

```dart
// Cargar solo campos necesarios
final orders = await orderDAO.findAllWithRelations(
  ['customer(id,name)', 'items(quantity,price)']
);
```

### Caché de Relaciones

```dart
class CachedProductDAO extends ProductDAO {
  final Cache _cache;
  
  Future<Category?> loadCategory(Product product) async {
    final cached = await _cache.get<Category>('product:${product.id}:category');
    if (cached != null) return cached;
    
    final category = await loadBelongsTo<Category>(product, 'category');
    await _cache.set('product:${product.id}:category', category);
    return category;
  }
}
```

## 📊 Mejores Prácticas

1. **Diseño de Relaciones**
   - Usar eager loading con moderación
   - Documentar relaciones complejas
   - Mantener la consistencia en nombrado

2. **Rendimiento**
   - Evitar N+1 queries
   - Cargar solo las relaciones necesarias
   - Usar índices apropiados

3. **Mantenibilidad**
   - Agrupar relaciones relacionadas
   - Usar constantes para nombres de relaciones
   - Mantener la documentación actualizada

## 🔍 Depuración

```dart
// Habilitar logging de queries
DAORegistry.enableLogging();

// Registrar custom logger
DAORegistry.setLogger((String message) {
  print('SQL: $message');
});

// Analizar queries generadas
final queryLog = await DAORegistry.getQueryLog();
```

## 📚 Referencias

- [API Reference](../09_api_reference.md)
- [Ejemplos Prácticos](../07_ejemplos.md)
- [FAQs](../10_faqs.md)
- [Supabase Relations Docs](https://supabase.com/docs/guides/database/queries#one-to-many)
