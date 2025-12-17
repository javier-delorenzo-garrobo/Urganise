#!/bin/bash

# Pre-deployment Verification Script for Urganise Production
# This script checks if the environment is ready for production deployment

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

ERRORS=0
WARNINGS=0

print_header() {
    echo -e "${BLUE}╔════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║     🔍 Urganise Production Readiness Check        ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
    ((ERRORS++))
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
    ((WARNINGS++))
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_header

# Check Docker
echo "Checking prerequisites..."
echo ""

if command -v docker &> /dev/null; then
    print_success "Docker is installed"
    
    if docker info &> /dev/null; then
        print_success "Docker is running"
    else
        print_error "Docker is not running. Please start Docker Desktop."
    fi
else
    print_error "Docker is not installed. Install Docker Desktop first."
fi

if command -v docker-compose &> /dev/null; then
    print_success "Docker Compose is installed"
elif docker compose version &> /dev/null; then
    print_success "Docker Compose is installed (as Docker plugin)"
else
    print_error "Docker Compose is not installed"
fi

echo ""
echo "Checking configuration files..."
echo ""

# Check .env.production
if [ -f .env.production ]; then
    print_success ".env.production file exists"
    
    # Check SECRET_KEY_BASE
    if grep -q "^SECRET_KEY_BASE=..*" .env.production; then
        SECRET_KEY_LENGTH=$(grep "^SECRET_KEY_BASE=" .env.production | cut -d'=' -f2 | wc -c)
        if [ "$SECRET_KEY_LENGTH" -gt 64 ]; then
            print_success "SECRET_KEY_BASE is set and looks secure"
        else
            print_warning "SECRET_KEY_BASE seems too short (should be 128+ characters)"
        fi
    else
        print_error "SECRET_KEY_BASE is not set in .env.production"
    fi
    
    # Check POSTGRES_PASSWORD
    if grep -q "^POSTGRES_PASSWORD=..*" .env.production; then
        POSTGRES_PASSWORD=$(grep "^POSTGRES_PASSWORD=" .env.production | cut -d'=' -f2)
        if [ "$POSTGRES_PASSWORD" = "password" ] || [ "$POSTGRES_PASSWORD" = "CHANGE_ME_TO_SECURE_PASSWORD" ]; then
            print_error "POSTGRES_PASSWORD is using default/example value. Change it!"
        elif [ ${#POSTGRES_PASSWORD} -lt 12 ]; then
            print_warning "POSTGRES_PASSWORD is too short (should be 12+ characters)"
        else
            print_success "POSTGRES_PASSWORD is set"
        fi
    else
        print_error "POSTGRES_PASSWORD is not set in .env.production"
    fi
    
    # Check SEED_DB
    if grep -q "^SEED_DB=true" .env.production; then
        print_warning "SEED_DB is set to true. This will create demo user. Set to false for production!"
    else
        print_success "SEED_DB is disabled (good for production)"
    fi
    
else
    print_error ".env.production file not found. Copy from .env.production.example"
fi

# Check Dockerfile
if [ -f Dockerfile ]; then
    print_success "Dockerfile exists"
else
    print_error "Dockerfile not found"
fi

# Check docker-compose.prod.yml
if [ -f docker-compose.prod.yml ]; then
    print_success "docker-compose.prod.yml exists"
else
    print_error "docker-compose.prod.yml not found"
fi

# Check production entrypoint
if [ -f bin/docker-entrypoint-prod ]; then
    print_success "Production entrypoint script exists"
    
    if [ -x bin/docker-entrypoint-prod ]; then
        print_success "Production entrypoint is executable"
    else
        print_warning "Production entrypoint is not executable. Run: chmod +x bin/docker-entrypoint-prod"
    fi
else
    print_error "bin/docker-entrypoint-prod not found"
fi

echo ""
echo "Checking security..."
echo ""

# Check .gitignore
if [ -f .gitignore ]; then
    if grep -q ".env.production" .gitignore || grep -q "/.env*" .gitignore; then
        print_success ".env.production is in .gitignore"
    else
        print_warning ".env.production should be in .gitignore to avoid committing secrets"
    fi
fi

# Check if .env.production is tracked by git
if git ls-files --error-unmatch .env.production &> /dev/null; then
    print_error ".env.production is tracked by git! Remove it with: git rm --cached .env.production"
fi

# Check if config/master.key exists
if [ -f config/master.key ]; then
    if git ls-files --error-unmatch config/master.key &> /dev/null; then
        print_error "config/master.key is tracked by git! Remove it immediately!"
    else
        print_success "config/master.key is not tracked by git"
    fi
fi

echo ""
echo "Checking available resources..."
echo ""

# Check available disk space
AVAILABLE_SPACE=$(df -h . | awk 'NR==2 {print $4}')
print_info "Available disk space: $AVAILABLE_SPACE"

# Check if Docker has enough resources
if docker info &> /dev/null; then
    DOCKER_MEM=$(docker info --format '{{.MemTotal}}' 2>/dev/null || echo "unknown")
    if [ "$DOCKER_MEM" != "unknown" ]; then
        DOCKER_MEM_GB=$((DOCKER_MEM / 1024 / 1024 / 1024))
        if [ "$DOCKER_MEM_GB" -ge 2 ]; then
            print_success "Docker has sufficient memory allocated (${DOCKER_MEM_GB}GB)"
        else
            print_warning "Docker has limited memory (${DOCKER_MEM_GB}GB). Recommend 2GB+ for production"
        fi
    fi
fi

echo ""
echo "═══════════════════════════════════════════════════"
echo ""

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✓ ALL CHECKS PASSED!${NC}"
    echo "Your environment is ready for production deployment."
    echo ""
    echo "To deploy, run:"
    echo "  ./docker-helper.sh start --prod"
    echo "  OR"
    echo "  make start-prod"
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠ PASSED WITH $WARNINGS WARNING(S)${NC}"
    echo "Your environment has some warnings but can proceed."
    echo "Review the warnings above before deploying."
    echo ""
    echo "To deploy, run:"
    echo "  ./docker-helper.sh start --prod"
    exit 0
else
    echo -e "${RED}✗ FAILED WITH $ERRORS ERROR(S) AND $WARNINGS WARNING(S)${NC}"
    echo "Please fix the errors above before deploying to production."
    echo ""
    echo "Quick fixes:"
    echo "  1. Create .env.production: cp .env.production.example .env.production"
    echo "  2. Generate SECRET_KEY_BASE: docker run --rm ruby:3.4.7-slim ruby -e \"require 'securerandom'; puts SecureRandom.hex(64)\""
    echo "  3. Change POSTGRES_PASSWORD to a secure value"
    echo "  4. Set SEED_DB=false in .env.production"
    exit 1
fi
