# 🚀 Introducción a supabase-dart-client

## 🎯 Propósito

`supabase-dart-client` es un ORM (Object-Relational Mapping) diseñado específicamente para trabajar con Supabase en aplicaciones Dart/Flutter. Proporciona una capa de abstracción que permite:

- Mapear tablas de Supabase a clases Dart
- Gestionar relaciones entre modelos
- Realizar consultas tipadas
- Manejar operaciones CRUD de forma segura
- Implementar patrones DAO

## 🌟 Características Principales

### 1. Modelado de Datos Seguro
```dart
@Table('products')
class Product {
  @PrimaryKey()
  final int id;
  
  @Column()
  final String name;
  
  @Column(columnName: 'unit_price')
  final double price;
}
```

### 2. Relaciones Entre Modelos
```dart
@Table('orders')
class Order {
  @HasMany(OrderItem, foreignKey: 'order_id')
  final List<OrderItem>? items;
  
  @BelongsTo(Customer, foreignKey: 'customer_id')
  final Customer? customer;
}
```

### 3. Consultas Tipadas con KeyPaths
```dart
final expensiveProducts = await productDAO.findWhere({
  Product_.price.greaterThan(100),
  Product_.category.eq(1)
});
```

### 4. Gestión Automática de DAOs
```dart
final productDAO = DAORegistry.getDAO<Product>();
final product = await productDAO.findById(1);
```

## 🏗 Arquitectura

El paquete está estructurado en capas:

1. **Capa de Anotaciones**
   - Define la estructura de los modelos
   - Configura el mapeo a la base de datos
   - Especifica relaciones

2. **Capa de DAO**
   - Implementa operaciones CRUD
   - Gestiona consultas complejas
   - Maneja relaciones

3. **Capa de KeyPaths**
   - Proporciona consultas tipadas
   - Permite operaciones de filtrado seguras
   - Facilita la navegación por relaciones

4. **Capa de Cliente**
   - Interactúa con Supabase
   - Gestiona la comunicación HTTP
   - Maneja errores y respuestas

## 🎯 Casos de Uso

### 1. Aplicaciones CRUD
Ideal para aplicaciones que necesitan:
- Gestionar datos estructurados
- Mantener relaciones entre entidades
- Realizar operaciones CRUD seguras

### 2. Aplicaciones con Datos Relacionales
Perfecto para sistemas que requieren:
- Relaciones complejas entre modelos
- Consultas anidadas
- Carga eficiente de datos relacionados

### 3. Aplicaciones Enterprise
Diseñado para proyectos que necesitan:
- Tipado fuerte
- Validación en tiempo de compilación
- Patrones de diseño robustos

## 🔄 Flujo de Trabajo Típico

1. **Definición de Modelos**
   ```dart
   @Table('users')
   class User {
     @PrimaryKey()
     final int id;
     
     @Column()
     final String name;
     
     @HasMany(Order)
     final List<Order>? orders;
   }
   ```

2. **Configuración de DAOs**
   ```dart
   void setupDAOs() {
     final userDAO = UserDAO(supabaseClient);
     DAORegistry.registerDAO<User>(userDAO);
   }
   ```

3. **Uso en la Aplicación**
   ```dart
   Future<void> loadUserData() async {
     final userDAO = DAORegistry.getDAO<User>();
     final user = await userDAO.findByIdWithRelations(
       1, 
       ['orders', 'orders.items']
     );
   }
   ```

## 📈 Mejores Prácticas

1. **Modelado de Datos**
   - Usar anotaciones apropiadas
   - Mantener modelos inmutables
   - Implementar métodos copyWith

2. **Gestión de DAOs**
   - Registrar DAOs al inicio
   - Usar el registro global
   - Manejar errores adecuadamente

3. **Consultas**
   - Preferir KeyPaths sobre strings
   - Cargar solo los datos necesarios
   - Optimizar consultas relacionales

4. **Relaciones**
   - Usar lazy loading cuando sea apropiado
   - Evitar ciclos en relaciones
   - Mantener la consistencia de datos

## 🚀 Primeros Pasos

1. **Instalación**
   ```yaml
   dependencies:
     supabase_dart_client: ^1.0.0
   ```

2. **Configuración Básica**
   ```dart
   void main() async {
     await Supabase.initialize(
       url: 'TU_URL',
       anonKey: 'TU_KEY'
     );
     setupDAOs();
   }
   ```

3. **Primer Modelo**
   ```dart
   @Table('products')
   class Product {
     @PrimaryKey()
     final int id;
     
     @Column()
     final String name;
     
     Product({
       required this.id,
       required this.name,
     });
   }
   ```

## 📚 Recursos Adicionales

- [Documentación API Completa](./09_api_reference.md)
- [Ejemplos de Código](./07_ejemplos.md)
- [FAQs](./10_faqs.md)
- [Guía de Migración](./08_migracion.md)
