#!/bin/bash

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonction pour afficher les messages
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Vérifier que le fichier .env existe
if [ ! -f ".env" ]; then
    print_error "Le fichier .env n'existe pas !"
    exit 1
fi

# Vérifier si podman-compose est disponible
if command -v podman compose &> /dev/null; then
    COMPOSE_CMD="podman compose"
elif command -v docker compose &> /dev/null; then
    COMPOSE_CMD="docker compose"
    print_warning "Utilisation de docker compose au lieu de podman compose"
else
    print_error "Ni podman compose ni docker compose ne sont disponibles !"
    exit 1
fi

print_status "Utilisation de : $COMPOSE_CMD"

# Vérifier les mots de passe par défaut
if grep -q "changeme123!" .env; then
    print_warning "⚠️  Vous utilisez encore des mots de passe par défaut !"
    print_warning "⚠️  Veuillez modifier le fichier .env avant de continuer"
    echo ""
    echo "Mots de passe à changer :"
    echo "- POSTGRES_PASSWORD"
    echo "- POSTGRES_NON_ROOT_PASSWORD"
    echo "- N8N_BASIC_AUTH_PASSWORD"
    echo "- N8N_ENCRYPTION_KEY"
    echo ""
    read -p "Voulez-vous continuer quand même ? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

print_status "Démarrage des services n8n avec PostgreSQL..."

# Démarrer les services
$COMPOSE_CMD up -d

if [ $? -eq 0 ]; then
    print_success "Services démarrés avec succès !"
    echo ""
    print_status "Vérification de l'état des services..."
    $COMPOSE_CMD ps
    echo ""
    print_status "n8n sera accessible sur : http://localhost:5678"
    print_status "Ollama sera accessible sur : http://localhost:11435"
    print_status "Attendez quelques secondes pour que tous les services soient complètement démarrés"
    echo ""
    print_status "Pour configurer Ollama avec un modèle : ./setup-ollama.sh"
    print_status "Pour voir les logs : $COMPOSE_CMD logs -f n8n"
    print_status "Pour arrêter : $COMPOSE_CMD stop"
else
    print_error "Erreur lors du démarrage des services !"
    exit 1
fi
