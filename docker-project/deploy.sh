#!/bin/bash

# Script d'automatisation du build et deploiement
# Auteur: Etudiant EPSI Bachelor 3 SysOps

set -e  # Arreter en cas d'erreur

echo "=========================================="
echo "Debut du deploiement"
echo "=========================================="
echo ""

PROJECT_NAME="tp_docker"

# Etape 1: Verifications
echo "[1/6] Verification de l'environnement..."
echo "-------------------------------------------"

if ! command -v docker &> /dev/null; then
    echo "ERREUR: Docker n'est pas installe"
    exit 1
fi

if ! command -v docker compose &> /dev/null; then
    echo "ERREUR: Docker Compose n'est pas installe"
    exit 1
fi

docker compose config > /dev/null
echo "OK - Configuration validee"
echo ""

# Etape 2: Build des images
echo "[2/6] Construction des images Docker..."
echo "-------------------------------------------"

echo "Build de l'API..."
docker build -t ${PROJECT_NAME}-api:latest ./api

echo "Build du Frontend..."
docker build -t ${PROJECT_NAME}-frontend:latest ./frontend

echo "OK - Images construites"
echo ""

# Etape 3: Afficher la taille
echo "[3/6] Taille des images:"
echo "-------------------------------------------"
docker images | grep ${PROJECT_NAME}
echo ""

# Etape 4: Scan de securite (optionnel)
echo "[4/6] Scan de securite..."
echo "-------------------------------------------"

if command -v docker scan &> /dev/null; then
    echo "Scan de l'image API..."
    docker scan ${PROJECT_NAME}-api:latest 2>/dev/null || echo "Scan non disponible ou vulnerabilites detectees"
    
    echo "Scan de l'image Frontend..."
    docker scan ${PROJECT_NAME}-frontend:latest 2>/dev/null || echo "Scan non disponible ou vulnerabilites detectees"
else
    echo "Docker scan non disponible (optionnel)"
fi
echo ""

# Etape 5: Signature (Docker Content Trust)
echo "[5/6] Signature des images..."
echo "-------------------------------------------"

if [ "${DOCKER_CONTENT_TRUST:-0}" == "1" ]; then
    export DOCKER_CONTENT_TRUST=1
    echo "Docker Content Trust active"
else
    echo "Docker Content Trust desactive"
    echo "Pour activer: export DOCKER_CONTENT_TRUST=1"
fi
echo ""

# Etape 6: Deploiement
echo "[6/6] Deploiement avec Docker Compose..."
echo "-------------------------------------------"

echo "Arret des conteneurs existants..."
docker compose down

echo "Demarrage des services..."
docker compose up -d

echo "Attente du demarrage..."
sleep 5

echo ""
echo "Statut des conteneurs:"
docker compose ps

echo ""
echo "=========================================="
echo "Deploiement termine"
echo "=========================================="
echo ""
echo "Acces:"
echo "  Frontend: http://localhost:8080"
echo "  API: http://localhost:3000/status"
echo ""
echo "Commandes:"
echo "  docker compose logs -f    # Voir les logs"
echo "  docker compose down       # Arreter"
echo "  docker compose restart    # Redemarrer"
echo ""
