#!/bin/bash

# Urganise Docker Helper Script
# Este script facilita el uso de comandos comunes de Docker

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Detect docker compose command and create wrapper
if command -v docker-compose &> /dev/null; then
    dc() { docker-compose "$@"; }
elif docker compose version &> /dev/null 2>&1; then
    dc() { docker compose "$@"; }
else
    echo "Error: Docker Compose no está instalado"
    exit 1
fi

print_header() {
    echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║         🚀 Urganise Docker Helper         ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${YELLOW}ℹ${NC} $1"
}

show_help() {
    print_header
    echo "Uso: ./docker-helper.sh [comando] [opciones]"
    echo ""
    echo "Comandos disponibles:"
    echo ""
    echo "  ${GREEN}start${NC}          - Inicia la aplicación en modo desarrollo (por defecto)"
    echo "  ${GREEN}start --prod${NC}   - Inicia la aplicación en modo producción"
    echo "  ${GREEN}build${NC}          - Construye la imagen de producción"
    echo "  ${GREEN}stop${NC}           - Detiene la aplicación"
    echo "  ${GREEN}restart${NC}        - Reinicia la aplicación"
    echo "  ${GREEN}logs${NC}           - Muestra los logs en tiempo real"
    echo "  ${GREEN}console${NC}        - Abre la consola de Rails"
    echo "  ${GREEN}bash${NC}           - Abre una terminal bash en el contenedor"
    echo "  ${GREEN}db:reset${NC}       - Resetea la base de datos (elimina y recrea)"
    echo "  ${GREEN}db:migrate${NC}     - Ejecuta las migraciones pendientes"
    echo "  ${GREEN}db:seed${NC}        - Carga los datos de ejemplo"
    echo "  ${GREEN}test${NC}           - Ejecuta los tests"
    echo "  ${GREEN}clean${NC}          - Limpia contenedores, volúmenes e imágenes"
    echo "  ${GREEN}status${NC}         - Muestra el estado de los contenedores"
    echo "  ${GREEN}help${NC}           - Muestra esta ayuda"
    echo ""
    echo "Ejemplos:"
    echo "  ./docker-helper.sh start           # Inicia en desarrollo"
    echo "  ./docker-helper.sh start --prod    # Inicia en producción"
    echo "  ./docker-helper.sh build           # Construye imagen de producción"
    echo "  ./docker-helper.sh logs            # Ver logs"
    echo "  ./docker-helper.sh console         # Abrir Rails console"
    echo ""
}

check_docker() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker no está instalado. Por favor, instala Docker Desktop."
        exit 1
    fi
    
    if ! docker info &> /dev/null; then
        print_error "Docker no está ejecutándose. Por favor, inicia Docker Desktop."
        exit 1
    fi
}

case "$1" in
    start)
        print_header
        if [ "$2" = "--prod" ]; then
            print_info "Iniciando Urganise en modo PRODUCCIÓN..."
            check_docker
            
            # Check if .env.production exists
            if [ ! -f .env.production ]; then
                print_error "Archivo .env.production no encontrado"
                echo ""
                print_info "Creando .env.production desde .env.production.example..."
                cp .env.production.example .env.production
                print_info "⚠️  IMPORTANTE: Edita .env.production con valores seguros antes de usar en producción"
                echo ""
                read -p "Presiona Enter para continuar o Ctrl+C para cancelar..."
            fi
            
            # Generate SECRET_KEY_BASE if not set
            if ! grep -q "^SECRET_KEY_BASE=..*" .env.production; then
                print_info "Generando SECRET_KEY_BASE..."
                SECRET_KEY=$(docker run --rm ruby:3.4.7-slim ruby -e "require 'securerandom'; puts SecureRandom.hex(64)")
                echo "SECRET_KEY_BASE=$SECRET_KEY" >> .env.production
            fi
            
            dc -f docker-compose.prod.yml --env-file .env.production up --build -d
            print_success "Urganise está ejecutándose en modo PRODUCCIÓN!"
        else
            print_info "Iniciando Urganise en modo desarrollo..."
            check_docker
            dc up --build -d
            print_success "Urganise está ejecutándose en modo DESARROLLO!"
        fi
        echo ""
        print_info "Accede a la aplicación en: http://localhost:3000"
        if [ "$2" != "--prod" ]; then
            print_info "Demo credentials:"
            echo "   Email: demo@urganise.com"
            echo "   Password: password123"
        fi
        echo ""
        print_info "Ver logs: ./docker-helper.sh logs"
        ;;
    
    build)
        print_header
        print_info "Construyendo imagen de producción de Urganise..."
        check_docker
        dc -f docker-compose.prod.yml build --no-cache
        print_success "Imagen de producción construida exitosamente!"
        echo ""
        print_info "Para iniciar: ./docker-helper.sh start --prod"
        ;;
    
    stop)
        print_header
        print_info "Deteniendo Urganise..."
        check_docker
        # Stop both dev and prod if running
        dc down 2>/dev/null || true
        dc -f docker-compose.prod.yml down 2>/dev/null || true
        print_success "Urganise detenido"
        ;;
    
    restart)
        print_header
        print_info "Reiniciando Urganise..."
        check_docker
        dc restart
        print_success "Urganise reiniciado"
        ;;
    
    logs)
        print_header
        print_info "Mostrando logs (Ctrl+C para salir)..."
        check_docker
        dc logs -f
        ;;
    
    console)
        print_header
        print_info "Abriendo Rails console..."
        check_docker
        dc exec web rails console
        ;;
    
    bash)
        print_header
        print_info "Abriendo terminal bash..."
        check_docker
        dc exec web bash
        ;;
    
    db:reset)
        print_header
        print_info "⚠️  ADVERTENCIA: Esto eliminará todos los datos!"
        read -p "¿Estás seguro? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            check_docker
            print_info "Reseteando base de datos..."
            dc exec web rails db:drop db:create db:migrate db:seed
            print_success "Base de datos reseteada"
        else
            print_info "Operación cancelada"
        fi
        ;;
    
    db:migrate)
        print_header
        print_info "Ejecutando migraciones..."
        check_docker
        dc exec web rails db:migrate
        print_success "Migraciones completadas"
        ;;
    
    db:seed)
        print_header
        print_info "Cargando datos de ejemplo..."
        check_docker
        dc exec web rails db:seed
        print_success "Datos cargados"
        ;;
    
    test)
        print_header
        print_info "Ejecutando tests..."
        check_docker
        dc exec web rails test
        ;;
    
    clean)
        print_header
        print_info "⚠️  ADVERTENCIA: Esto eliminará contenedores, volúmenes e imágenes!"
        read -p "¿Estás seguro? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            check_docker
            print_info "Limpiando..."
            dc down -v --rmi local
            print_success "Limpieza completada"
        else
            print_info "Operación cancelada"
        fi
        ;;
    
    status)
        print_header
        print_info "Estado de los contenedores:"
        check_docker
        dc ps
        echo ""
        print_info "Uso de recursos:"
        docker stats --no-stream
        ;;
    
    help|--help|-h|"")
        show_help
        ;;
    
    *)
        print_error "Comando desconocido: $1"
        echo ""
        show_help
        exit 1
        ;;
esac
