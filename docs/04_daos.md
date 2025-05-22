# 🔄 DAOs y Operaciones CRUD

## 📋 Índice

1. [Introducción a DAOs](#introducción-a-daos)
2. [Operaciones CRUD Básicas](#operaciones-crud-básicas)
3. [Consultas Avanzadas](#consultas-avanzadas)
4. [DAOs Personalizados](#daos-personalizados)
5. [Gestión de Transacciones](#gestión-de-transacciones)
6. [Paginación y Filtrado](#paginación-y-filtrado)
7. [Manejo de Errores](#manejo-de-errores)

## 🎯 Introducción a DAOs

Los DAOs (Data Access Objects) proporcionan una interfaz abstracta para interactuar con la base de datos.

### Registro de DAOs

```dart
void setupDAOs() {
  final client = Supabase.instance.client;
  
  // Registrar DAOs generados automáticamente
  DAORegistry.registerDAO<Product>(ProductDAO(client));
  DAORegistry.registerDAO<Category>(CategoryDAO(client));
  
  // Acceder a los DAOs
  final productDAO = DAORegistry.getDAO<Product>();
}
```

## 💾 Operaciones CRUD Básicas

### Create (Crear)

```dart
// Insertar un nuevo producto
final product = Product(
  name: 'Nuevo Producto',
  price: 99.99,
  categoryId: 1,
);

final savedProduct = await productDAO.insert(product);
print('Producto creado con ID: ${savedProduct.id}');

// Insertar múltiples productos
final products = [
  Product(name: 'Producto 1', price: 10.0),
  Product(name: 'Producto 2', price: 20.0),
];

final savedProducts = await productDAO.insertMany(products);
```

### Read (Leer)

```dart
// Buscar por ID
final product = await productDAO.findById(1);

// Obtener todos los registros
final allProducts = await productDAO.findAll();

// Buscar con condiciones
final activeProducts = await productDAO.findWhere({
  Product_.isActive.eq(true),
  Product_.price.greaterThan(100)
});

// Buscar con relaciones
final productWithDetails = await productDAO.findByIdWithRelations(
  1,
  ['category', 'reviews']
);
```

### Update (Actualizar)

```dart
// Actualizar un registro existente
final updatedProduct = product.copyWith(
  price: 199.99,
  isActive: true
);

await productDAO.update(updatedProduct);

// Actualizar múltiples registros
await productDAO.updateWhere(
  {Product_.categoryId.eq(1)},
  {'price': 99.99}
);
```

### Delete (Eliminar)

```dart
// Eliminar por ID
await productDAO.delete(1);

// Eliminar con condiciones
await productDAO.deleteWhere({
  Product_.price.lessThan(10),
  Product_.isActive.eq(false)
});
```

## 🔍 Consultas Avanzadas

### Filtrado Complejo

```dart
final results = await productDAO.findWhere({
  Product_.price.between(10, 100),
  Product_.name.like('%Phone%'),
  Product_.category.id.in_([1, 2, 3]),
  Product_.createdAt.greaterThan(DateTime.now().subtract(Duration(days: 30)))
});
```

### Ordenamiento

```dart
final sortedProducts = await productDAO.findAll(
  orderBy: [
    Product_.price.desc(),
    Product_.name.asc()
  ]
);
```

### Agregación

```dart
final stats = await productDAO.aggregate({
  'avg_price': Product_.price.avg(),
  'total_products': Product_.id.count(),
  'max_price': Product_.price.max(),
  'min_price': Product_.price.min()
});
```

### Joins y Relaciones

```dart
// Join explícito
final results = await productDAO.findWithJoin<Category>(
  joinField: 'category',
  where: {
    Product_.price.greaterThan(100),
    'category.name': 'Electronics'
  }
);

// Carga de relaciones
final product = await productDAO.findByIdWithRelations(
  1,
  ['category', 'reviews', 'tags']
);
```

## 🛠 DAOs Personalizados

### Extender BaseDAO

```dart
class CustomProductDAO extends BaseDAO<Product> {
  CustomProductDAO(SupabaseClient client) : super(client);
  
  // Métodos personalizados
  Future<List<Product>> findFeatured() async {
    return findWhere({
      Product_.isFeatured.eq(true),
      Product_.isActive.eq(true)
    });
  }
  
  Future<double> calculateTotalRevenue() async {
    final result = await aggregate({
      'total': Product_.price.sum()
    });
    return result['total'] as double;
  }
}
```

### Implementar Lógica de Negocio

```dart
class ProductService {
  final CustomProductDAO _productDAO;
  
  ProductService(this._productDAO);
  
  Future<void> applyDiscount(int productId, double percentage) async {
    final product = await _productDAO.findById(productId);
    if (product != null) {
      final discountedPrice = product.price * (1 - percentage / 100);
      await _productDAO.update(
        product.copyWith(price: discountedPrice)
      );
    }
  }
}
```

## 📦 Gestión de Transacciones

### Transacciones Simples

```dart
Future<void> transferProduct(int fromCategoryId, int toCategoryId) async {
  final productDAO = DAORegistry.getDAO<Product>();
  
  await productDAO.transaction((tx) async {
    // Actualizar productos
    await tx.updateWhere(
      {Product_.categoryId.eq(fromCategoryId)},
      {'category_id': toCategoryId}
    );
    
    // Actualizar contadores
    await tx.executeRaw('''
      UPDATE categories 
      SET product_count = product_count - 1 
      WHERE id = ?
    ''', [fromCategoryId]);
    
    await tx.executeRaw('''
      UPDATE categories 
      SET product_count = product_count + 1 
      WHERE id = ?
    ''', [toCategoryId]);
  });
}
```

### Manejo de Errores en Transacciones

```dart
Future<void> safeTransfer() async {
  try {
    await transferProduct(1, 2);
  } catch (e) {
    if (e is PostgrestError) {
      // Manejar error específico de Supabase
    }
    // Rollback automático
    rethrow;
  }
}
```

## 📄 Paginación y Filtrado

### Paginación Simple

```dart
Future<List<Product>> getProductPage(int page, int pageSize) async {
  return productDAO.findAll(
    limit: pageSize,
    offset: (page - 1) * pageSize
  );
}
```

### Paginación con Cursor

```dart
Future<PaginationResult<Product>> getProductsWithCursor(
  String? cursor,
  int limit
) async {
  return productDAO.findWithCursor(
    cursor: cursor,
    limit: limit,
    orderBy: [Product_.id.asc()]
  );
}
```

### Filtrado Avanzado

```dart
class ProductFilter {
  final double? minPrice;
  final double? maxPrice;
  final List<int>? categoryIds;
  final bool? isActive;
  
  Map<String, dynamic> toQuery() {
    final conditions = <dynamic>[];
    
    if (minPrice != null) {
      conditions.add(Product_.price.greaterThanOrEqual(minPrice!));
    }
    if (maxPrice != null) {
      conditions.add(Product_.price.lessThanOrEqual(maxPrice!));
    }
    if (categoryIds?.isNotEmpty ?? false) {
      conditions.add(Product_.categoryId.in_(categoryIds!));
    }
    if (isActive != null) {
      conditions.add(Product_.isActive.eq(isActive!));
    }
    
    return conditions;
  }
}

// Uso
final filter = ProductFilter(
  minPrice: 50,
  maxPrice: 200,
  categoryIds: [1, 2],
  isActive: true
);

final filteredProducts = await productDAO.findWhere(filter.toQuery());
```

## ⚠️ Manejo de Errores

### Tipos de Errores

```dart
try {
  await productDAO.insert(product);
} on PostgrestError catch (e) {
  switch (e.code) {
    case '23505': // Unique violation
      print('Producto duplicado');
      break;
    case '23503': // Foreign key violation
      print('Categoría no existe');
      break;
    default:
      print('Error desconocido: ${e.message}');
  }
} on DAOException catch (e) {
  print('Error de DAO: ${e.message}');
} catch (e) {
  print('Error inesperado: $e');
}
```

### Validación Personalizada

```dart
class ValidatedProductDAO extends ProductDAO {
  @override
  Future<Product> insert(Product product) async {
    // Validar antes de insertar
    if (product.price <= 0) {
      throw DAOException('El precio debe ser mayor a 0');
    }
    if (product.name.isEmpty) {
      throw DAOException('El nombre no puede estar vacío');
    }
    
    return super.insert(product);
  }
}
```

## 📚 Recursos Adicionales

- [API Reference](../09_api_reference.md)
- [Ejemplos Prácticos](../07_ejemplos.md)
- [FAQs](../10_faqs.md)
