# PoliWiki con MySQL

## 1. Crear la base

Ejecuta el script `database/poliwiki_mysql.sql` en MySQL Workbench o desde consola:

```bash
mysql -u root -p < database/poliwiki_mysql.sql
```

El script crea la base `poliwiki`, las tablas y datos iniciales.

Usuarios de prueba:

- Administrador: `admin@alumno.ipn.mx` / `admin123`
- Estudiante: `mariana.tejados@alumno.ipn.mx` / `mariana123`

## 2. Configurar conexión

Por defecto la app usa:

- URL: `jdbc:mysql://localhost:3306/poliwiki`
- Usuario: `root`
- Contraseña: vacía

Si tu MySQL usa otros datos, inicia Tomcat con estas propiedades:

```bash
-Dpoliwiki.db.url=jdbc:mysql://localhost:3306/poliwiki?useSSL=false&serverTimezone=America/Mexico_City&allowPublicKeyRetrieval=true
-Dpoliwiki.db.user=TU_USUARIO
-Dpoliwiki.db.password=TU_PASSWORD
```

También puedes usar variables de entorno:

- `POLIWIKI_DB_URL`
- `POLIWIKI_DB_USER`
- `POLIWIKI_DB_PASSWORD`

## 3. Dependencia MySQL

El proyecto ya incluye `web/WEB-INF/lib/mysql-connector-j-8.4.0.jar`.

## 4. Funciones conectadas

- Crear cuenta
- Iniciar y cerrar sesión
- Listar carreras desde MySQL
- Listar profesores y materias
- Listar apuntes/PDFs destacados
- Crear publicaciones de foro
- Responder publicaciones de foro
- Listar trámites y guardar comentarios
- Listar eventos
- Publicar y listar artículos de marketplace
