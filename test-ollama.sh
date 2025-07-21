#!/bin/bash

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Vérifier si podman compose est disponible
if command -v podman compose &> /dev/null; then
    COMPOSE_CMD="podman compose"
elif command -v docker compose &> /dev/null; then
    COMPOSE_CMD="docker compose"
else
    print_error "Ni podman compose ni docker compose ne sont disponibles !"
    exit 1
fi

# Vérifier qu'Ollama est démarré
if ! $COMPOSE_CMD ps ollama | grep -q "Up"; then
    print_error "Le conteneur Ollama n'est pas démarré !"
    print_status "Démarrez d'abord l'environnement avec : ./start.sh"
    exit 1
fi

# Lire le modèle depuis .env
if [ -f ".env" ]; then
    MODEL=$(grep "OLLAMA_MODEL=" .env | cut -d'=' -f2)
    MODEL=${MODEL:-llama3.2:3b}
else
    MODEL="llama3.2:3b"
fi

print_status "Test d'Ollama avec le modèle : $MODEL"
print_status "Tapez votre message (ou 'quit' pour quitter)"
echo ""

while true; do
    echo -n "Vous: "
    read -r input
    
    if [ "$input" = "quit" ] || [ "$input" = "exit" ]; then
        print_status "Au revoir !"
        break
    fi
    
    if [ -n "$input" ]; then
        echo -e "${BLUE}Ollama:${NC}"
        $COMPOSE_CMD exec ollama ollama run $MODEL "$input"
        echo ""
    fi
done
