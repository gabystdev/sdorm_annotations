# 🛠 Instalación y Configuración

## 📥 Instalación

### 1. Agregar Dependencias

En tu `pubspec.yaml`, añade las siguientes dependencias:

```yaml
dependencies:
  supabase_dart_client: ^1.0.0
  supabase_flutter: ^1.0.0

dev_dependencies:
  supabase_dart_generators: ^1.0.0
  build_runner: ^2.4.0
```

### 2. Configurar build.yaml

Crea o modifica el archivo `build.yaml` en la raíz de tu proyecto:

```yaml
targets:
  $default:
    builders:
      supabase_dart_generators|dao_generator:
        enabled: true
        generate_for:
          - lib/models/**.dart
```

## ⚙️ Configuración

### 1. Inicializar Supabase

```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_dart_client/supabase_dart_client.dart';

Future<void> initializeSupabase() async {
  await Supabase.initialize(
    url: 'TU_URL_SUPABASE',
    anonKey: 'TU_ANON_KEY',
    // Configuración opcional
    authCallbackUrlHostname: 'login-callback',
    debug: true,
  );
}
```

### 2. Configurar DAOs

```dart
void setupDAOs() {
  // Obtener cliente de Supabase
  final client = Supabase.instance.client;
  
  // Crear DAOs
  final productDAO = ProductDAO(client);
  final categoryDAO = CategoryDAO(client);
  final orderDAO = OrderDAO(client);
  
  // Registrar DAOs
  DAORegistry.registerDAO<Product>(productDAO);
  DAORegistry.registerDAO<Category>(categoryDAO);
  DAORegistry.registerDAO<Order>(orderDAO);
}
```

### 3. Configuración Completa

```dart
Future<void> main() async {
  // Asegurar inicialización de Flutter
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Supabase
  await initializeSupabase();
  
  // Configurar DAOs
  setupDAOs();
  
  // Iniciar aplicación
  runApp(MyApp());
}
```

## 🔧 Configuración Avanzada

### 1. Configuración de Entornos

```dart
enum Environment { dev, staging, prod }

class Config {
  static late final String supabaseUrl;
  static late final String supabaseAnonKey;
  static late final Environment environment;
  
  static Future<void> initialize(Environment env) async {
    environment = env;
    
    switch (env) {
      case Environment.dev:
        supabaseUrl = 'DEV_URL';
        supabaseAnonKey = 'DEV_KEY';
        break;
      case Environment.staging:
        supabaseUrl = 'STAGING_URL';
        supabaseAnonKey = 'STAGING_KEY';
        break;
      case Environment.prod:
        supabaseUrl = 'PROD_URL';
        supabaseAnonKey = 'PROD_KEY';
        break;
    }
    
    await initializeSupabase();
    setupDAOs();
  }
}
```

### 2. Configuración de Logging

```dart
class CustomLogger implements Logger {
  @override
  void log(String message) {
    // Implementa tu lógica de logging
  }
  
  @override
  void error(String message, [dynamic error]) {
    // Implementa tu lógica de error logging
  }
}

void configureLogging() {
  DAORegistry.logger = CustomLogger();
}
```

### 3. Configuración de Caché

```dart
class CustomCache implements Cache {
  @override
  Future<T?> get<T>(String key) async {
    // Implementa tu lógica de caché
  }
  
  @override
  Future<void> set<T>(String key, T value) async {
    // Implementa tu lógica de caché
  }
}

void configureCache() {
  DAORegistry.cache = CustomCache();
}
```

## 🧪 Configuración para Testing

### 1. Mock de DAOs

```dart
class MockProductDAO extends Mock implements ProductDAO {
  @override
  Future<Product?> findById(int id) async {
    // Implementa el mock
    return Product(id: id, name: 'Test Product');
  }
}

void setupTestDAOs() {
  final mockProductDAO = MockProductDAO();
  DAORegistry.registerDAO<Product>(mockProductDAO);
}
```

### 2. Configuración de Tests

```dart
void main() {
  setUp(() async {
    // Configurar entorno de prueba
    await Config.initialize(Environment.test);
    setupTestDAOs();
  });
  
  test('Product CRUD operations', () async {
    final productDAO = DAORegistry.getDAO<Product>();
    // Implementar tests
  });
}
```

## 📋 Lista de Verificación

### Pre-configuración
- [ ] Configurar `pubspec.yaml`
- [ ] Configurar `build.yaml`
- [ ] Crear estructura de carpetas

### Configuración Básica
- [ ] Inicializar Supabase
- [ ] Configurar DAOs principales
- [ ] Verificar conexión

### Configuración Avanzada
- [ ] Configurar entornos
- [ ] Configurar logging
- [ ] Configurar caché (opcional)
- [ ] Configurar tests

## 🚨 Solución de Problemas

### 1. Errores Comunes

#### Error de Conexión
```
Error: Connection refused
```
**Solución**: Verifica la URL y las credenciales de Supabase

#### Error de DAO no Registrado
```
Error: DAO not registered for type Product
```
**Solución**: Asegúrate de registrar el DAO en `setupDAOs()`

#### Error de Generación
```
Error: Builder not found
```
**Solución**: Verifica la configuración en `build.yaml`

### 2. Mejores Prácticas

1. **Organización de Código**
   ```
   lib/
     ├── config/
     │   ├── environment.dart
     │   └── supabase_config.dart
     ├── models/
     │   └── ...
     └── dao/
         └── ...
   ```

2. **Manejo de Errores**
   ```dart
   try {
     await initializeSupabase();
   } catch (e) {
     log.error('Failed to initialize Supabase: $e');
     // Manejo de error apropiado
   }
   ```

3. **Seguridad**
   - No comitear credenciales
   - Usar variables de entorno
   - Implementar timeout apropiado

## 📚 Referencias

- [Documentación de Supabase](https://supabase.com/docs)
- [Documentación de Flutter](https://flutter.dev/docs)
- [API Reference](../09_api_reference.md)
- [Ejemplos](../07_ejemplos.md)
