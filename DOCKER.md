# 🐳 Docker Setup for Urganise

Este documento explica cómo ejecutar Urganise usando Docker Desktop.

## 📋 Prerrequisitos

- Docker Desktop instalado y ejecutándose
- Git (para clonar el repositorio)
- Al menos 4GB de RAM disponible para Docker

## 🚀 Inicio Rápido

### 1. Configurar Variables de Entorno (Opcional)

Si deseas usar las funcionalidades de AI, crea un archivo `.env` en la raíz del proyecto:

```bash
cp .env.example .env
```

Edita `.env` y agrega tu API key de Google Gemini:
```
GOOGLE_GEMINI_API_KEY=tu_api_key_aqui
```

> **Nota**: La aplicación funcionará sin la API key, pero las funcionalidades de AI no estarán disponibles.

### 2. Construir y Levantar los Contenedores

```bash
docker-compose up --build
```

Este comando:
- Construye la imagen de la aplicación
- Descarga la imagen de PostgreSQL
- Crea la base de datos
- Ejecuta las migraciones
- Carga datos de ejemplo (usuario demo)
- Inicia el servidor Rails

### 3. Acceder a la Aplicación

Una vez que veas el mensaje "Listening on http://0.0.0.0:3000", abre tu navegador:

```
http://localhost:3000
```

### 4. Credenciales de Demo

La aplicación incluye un usuario de demostración:
- **Email**: demo@urganise.com
- **Password**: password123

## 🛠 Comandos Útiles

### Detener los Contenedores
```bash
docker-compose down
```

### Detener y Eliminar Volúmenes (Reset completo)
```bash
docker-compose down -v
```

### Ver Logs
```bash
# Todos los servicios
docker-compose logs -f

# Solo la aplicación web
docker-compose logs -f web

# Solo la base de datos
docker-compose logs -f db
```

### Ejecutar Comandos en el Contenedor

```bash
# Abrir consola de Rails
docker-compose exec web rails console

# Ejecutar migraciones manualmente
docker-compose exec web rails db:migrate

# Ejecutar seeds manualmente
docker-compose exec web rails db:seed

# Acceder al bash del contenedor
docker-compose exec web bash
```

### Reiniciar un Servicio Específico

```bash
# Reiniciar solo la aplicación web
docker-compose restart web

# Reiniciar solo la base de datos
docker-compose restart db
```

## 🗄️ Base de Datos

### Información de Conexión

- **Host**: localhost
- **Puerto**: 5432
- **Usuario**: urganise
- **Password**: password
- **Base de datos**: urganise_development

### Conectar desde Herramientas Externas

Puedes conectarte a PostgreSQL usando herramientas como pgAdmin, DBeaver, o desde la línea de comandos:

```bash
psql -h localhost -p 5432 -U urganise -d urganise_development
```

### Backup de la Base de Datos

```bash
# Crear backup
docker-compose exec db pg_dump -U urganise urganise_development > backup.sql

# Restaurar backup
docker-compose exec -T db psql -U urganise urganise_development < backup.sql
```

## 🔧 Desarrollo

### Modificar el Código

Los cambios en el código se reflejarán automáticamente gracias al volumen montado:
- Los archivos Ruby se recargan automáticamente
- Para cambios en el Gemfile, necesitas reconstruir: `docker-compose up --build`

### Agregar Gemas

1. Edita el `Gemfile`
2. Reconstruye el contenedor:
   ```bash
   docker-compose down
   docker-compose up --build
   ```

### Ejecutar Tests

```bash
docker-compose exec web rails test
```

## 📦 Estructura de Volúmenes

Docker Compose crea dos volúmenes persistentes:

- **postgres_data**: Almacena los datos de PostgreSQL
- **bundle_cache**: Cachea las gemas de Ruby para builds más rápidos

## 🐛 Troubleshooting

### El puerto 3000 ya está en uso

Si tienes otro servidor Rails corriendo:
```bash
# Encuentra el proceso
lsof -ti:3000

# Mátalo
kill -9 $(lsof -ti:3000)

# O cambia el puerto en docker-compose.yml
ports:
  - "3001:3000"  # Usa el puerto 3001 en tu host
```

### El puerto 5432 ya está en uso

Si tienes PostgreSQL corriendo localmente, puedes:
1. Detener PostgreSQL local
2. O cambiar el puerto en docker-compose.yml:
   ```yaml
   ports:
     - "5433:5432"  # Usa el puerto 5433
   ```

### Error: "Database does not exist"

```bash
docker-compose exec web rails db:create db:migrate db:seed
```

### Los cambios no se reflejan

1. Verifica que el volumen esté montado correctamente
2. Reinicia el contenedor:
   ```bash
   docker-compose restart web
   ```

### Problemas de Permisos

```bash
# Linux/Mac: Ajustar permisos
sudo chown -R $USER:$USER .
```

### Limpiar Todo y Empezar de Nuevo

```bash
# Detener y eliminar todo
docker-compose down -v

# Eliminar imágenes
docker-compose down --rmi all

# Reconstruir desde cero
docker-compose up --build
```

## 🚀 Producción

Para producción, usa el `Dockerfile` principal (sin el sufijo .dev):

```bash
# Construir imagen de producción
docker build -t urganise:latest .

# Ejecutar con variables de entorno
docker run -d \
  -p 80:80 \
  -e DATABASE_URL=postgresql://... \
  -e GOOGLE_GEMINI_API_KEY=... \
  -e SECRET_KEY_BASE=... \
  --name urganise \
  urganise:latest
```

## 📊 Monitoreo

### Ver Uso de Recursos

```bash
docker stats
```

### Inspeccionar Contenedores

```bash
# Ver contenedores activos
docker-compose ps

# Ver información detallada
docker-compose exec web rails about
```

## 🔐 Seguridad

### Recomendaciones para Producción

1. ✅ Usa contraseñas fuertes para PostgreSQL
2. ✅ No commits el archivo `.env` al repositorio
3. ✅ Usa secrets de Docker para información sensible
4. ✅ Mantén las imágenes actualizadas
5. ✅ Ejecuta como usuario no-root (ya configurado)

## 📚 Recursos Adicionales

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Reference](https://docs.docker.com/compose/)
- [Rails Guides](https://guides.rubyonrails.org/)

## 🆘 Soporte

Si encuentras problemas:
1. Revisa los logs: `docker-compose logs -f`
2. Verifica que Docker Desktop esté ejecutándose
3. Asegúrate de tener suficiente espacio en disco
4. Consulta la sección de Troubleshooting

---

**¡Feliz desarrollo con Docker! 🐳**
