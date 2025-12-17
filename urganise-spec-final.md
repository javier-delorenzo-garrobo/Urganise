# CANVAS_OUTPUT_TYPE
doc

# CANVAS_PROJECT_NAME
Urganise Spec Prompt

# CANVAS_OPERATION_TYPE
doc_update

# CANVAS_DATA

## CANVAS_EDIT_1

### CANVAS_OLD_STR
```markdown
**Stack Tecnológico:**
- **Backend**: Ruby on Rails 7+
- **Frontend**: HTML5, CSS3 (Tailwind CSS recomendado), JavaScript (Stimulus JS)
- **AI Integration**: Google Gemini 3 Pro API (feature secundario)
- **Deployment**: Vercel (plan gratuito)
- **Control de Versiones**: Git Flow
- **Base de Datos**: PostgreSQL (Vercel Postgres)
- **Autenticación**: Devise (Rails) + JWT (para API)
```

### CANVAS_NEW_STR
```markdown
**Stack Tecnológico:**
- **Backend**: Ruby on Rails 7+
- **Frontend**: HTML5, CSS3 (Tailwind CSS recomendado), JavaScript (Stimulus JS)
- **AI Integration**: Google Gemini 3 Pro API (feature secundario)
- **Deployment**: Vercel (plan gratuito)
- **Base de Datos**: PostgreSQL (Vercel Postgres)
- **Autenticación**: Devise (Rails) + JWT (para API)
```

## CANVAS_EDIT_2

### CANVAS_OLD_STR
```markdown
### Deployment en Vercel
- Usar `/public` para assets
- Environment variables en `.env.production.local`
- Configurar PostgreSQL Neon o Vercel Postgres
- Build command: `bundle install && rails assets:precompile`
- Cron jobs para limpiar sesiones (Vercel Cron)

### Git Flow
```
Branches:
- main (producción)
- develop (staging)
- feature/* (nuevas features)
- bugfix/* (fixes)
- release/* (pre-release)

Convención de commits:
feat: nueva funcionalidad
fix: corrección de bug
refactor: refactorización
docs: documentación
test: tests
chore: cambios en build/herramientas
```
```

### CANVAS_NEW_STR
```markdown
### Deployment en Vercel
- Usar `/public` para assets
- Environment variables en `.env.production.local`
- Configurar PostgreSQL Neon o Vercel Postgres
- Build command: `bundle install && rails assets:precompile`
- Cron jobs para limpiar sesiones (Vercel Cron)
```

## CANVAS_EDIT_3

### CANVAS_OLD_STR
```markdown
- **Git**: Commits pequeños y significativos, PRs descriptivas
- **Seguridad**: Validar siempre en backend, sanitizar inputs, CORS configurado
```

### CANVAS_NEW_STR
```markdown
- **Seguridad**: Validar siempre en backend, sanitizar inputs, CORS configurado
```

# CANVAS_DESCRIPTION
Se ha removido completamente la mención a Git Flow en dos ubicaciones: 1) Stack Tecnológico (eliminada línea "Control de Versiones: Git Flow") 2) Sección "Deployment en Vercel" (removida subsección completa de Git Flow con branches y convención de commits). La documentación ahora se enfoca únicamente en los aspectos técnicos funcionales sin especificar estrategia de control de versiones.
