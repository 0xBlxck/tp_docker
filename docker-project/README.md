# TP Docker - Liste des Élèves EPSI B3 SysOps

Application web conteneurisée pour gérer la liste des élèves Bachelor 3 SysOps de l'EPSI.

## C'est quoi ?

Un projet avec 3 services Docker :
- **API Python** (Flask) : routes `/status` et `/items`
- **Base PostgreSQL** : stocke les élèves
- **Frontend** : interface web avec HTML/CSS/JS

## Lancer le projet

\`\`\`bash
# 1. Copier les variables d'environnement
copy .env.example .env   # Windows
# ou
cp .env.example .env     # Linux/Mac

# 2. Démarrer tout
docker compose up -d

# 3. Ouvrir dans le navigateur
http://localhost:8080
\`\`\`

## Commandes utiles

\`\`\`bash
# Voir les logs en temps réel
docker compose logs -f

# Logs d'un service spécifique
docker compose logs -f api

# Arrêter les services
docker compose down

# Tout reconstruire (après modif du code)
docker compose up -d --build --force-recreate

# Effacer aussi la base de données
docker compose down -v

# Voir l'état des conteneurs
docker compose ps

# Entrer dans un conteneur
docker exec -it tp_docker-api sh
\`\`\`

## Architecture du projet

\`\`\`
docker-project/
├── api/                    # Service API
│   ├── Dockerfile          # Build multi-stage Python
│   ├── app.py              # Code de l'API Flask
│   ├── healthcheck.py      # Vérification santé API
│   ├── requirements.txt    # Dépendances Python
│   └── .dockerignore       # Fichiers exclus
├── database/           
│   └── init.sql            # Script d'initialisation DB
├── frontend/               # Interface web
│   ├── Dockerfile          # Build multi-stage Nginx
│   ├── index.html          # Page principale
│   ├── app.js              # Logique JavaScript
│   ├── styles.css          # Styles CSS
│   ├── nginx.conf          # Config serveur web
│   └── .dockerignore       # Fichiers exclus
├── docker-compose.yml      # Orchestre les 3 services
├── .env.example            # Template variables
├── deploy.sh               # Script automatisation
└── README.md               # Ce fichier
\`\`\`

## Comment ça marche ?

### L'API (Python/Flask)

L'API expose deux endpoints :
- `GET /status` : Retourne "OK" pour vérifier que l'API fonctionne
- `GET /items` : Récupère la liste des élèves depuis PostgreSQL
- `POST /items` : Ajoute un élève
- `DELETE /items/<id>` : Supprime un élève

\`\`\`bash
# Tester manuellement
curl http://localhost:3000/status
curl http://localhost:3000/items
\`\`\`

### La base de données (PostgreSQL)

Au démarrage, le script `init.sql` :
1. Crée la table `items`
2. Insère 7 élèves du Bachelor 3 SysOps

Les données persistent grâce au volume Docker `postgres_data`.

### Le frontend (Nginx)

Interface web statique qui :
- Affiche le statut de l'API
- Liste tous les élèves
- Permet d'ajouter/supprimer des élèves
- Fait des appels AJAX vers l'API

## Pourquoi ces choix techniques ?

### Python/Flask
- Simple à comprendre et maintenir
- Parfait pour des petites APIs
- Bon pour un profil réseau/sécurité

### PostgreSQL
- Base relationnelle solide
- Recommandée dans le TD
- Facile à initialiser avec un script SQL

### Nginx pour le frontend
- Serveur web léger et performant
- Image Docker très petite (40 MB)
- Configuration simple

### Docker Compose
- Orchestre les 3 services facilement
- Gère les dépendances (l'API attend la DB)
- Un seul fichier de config

## Optimisations

### Taille des images

Grâce au multi-stage build :
- **API** : 110 MB (Python slim + dépendances uniquement)
- **Frontend** : 80 MB (Nginx Alpine + fichiers statiques)
- **PostgreSQL** : 395 MB (image Alpine officielle)
- **Total application** : 190 MB (API + Frontend)

**Comparaison multi-stage**

Le TD demande de mesurer les économies du multi-stage build. Voici les résultats mesurés :

#### Avec multi-stage (optimisé) - Résultats réels
\`\`\`bash
# Images finales mesurées avec "docker images"
docker-project-api         110 MB
docker-project-frontend    80 MB
postgres                   395 MB
Total optimisé:            585 MB
\`\`\`

#### Comment vérifier vous-même
\`\`\`bash
# Afficher toutes vos images
docker images

# Sur Windows, filtrer par nom
docker images | findstr docker-project
\`\`\`

#### Pourquoi le multi-stage est important ?

Sans multi-stage, les images contiendraient :
- Tous les outils de compilation (gcc, make, etc.)
- Les fichiers sources et caches de build
- Les dépendances de développement

Avec le multi-stage, on garde **seulement** :
- Le runtime minimal (Python slim, Nginx Alpine)
- Les dépendances de production
- Le code compilé/optimisé

**Avantages concrets :**
- **Déploiement plus rapide** : Moins de données à transférer
- **Moins d'espace disque** : Important en production
- **Sécurité** : Surface d'attaque réduite (pas d'outils de build)
- **Performance** : Images plus légères = démarrage plus rapide

### Performance

- Cache des dépendances Python optimisé
- Nginx configuré pour servir efficacement les fichiers statiques
- Connexion persistante entre API et base de données

## Script d'automatisation

Le fichier `deploy.sh` automatise tout le workflow :

\`\`\`bash
# Sur Linux/Mac
chmod +x deploy.sh
./deploy.sh

# Sur Windows avec Git Bash
bash deploy.sh
\`\`\`

Il fait :
1. Build de toutes les images
2. Test du build
3. Lancement des services
4. Vérification que tout fonctionne

## Dépannage

### L'API ne démarre pas
\`\`\`bash
# Voir les logs
docker compose logs api

# Vérifier que la DB est prête
docker compose ps
\`\`\`

### La base de données ne s'initialise pas
\`\`\`bash
# Tout supprimer et recommencer
docker compose down -v
docker compose up -d
\`\`\`

### Le frontend affiche "API hors ligne"
1. Vérifier que l'API répond : `curl http://localhost:3000/status`
2. Regarder la console du navigateur (F12)
3. Vérifier les logs de l'API

### Les modifications du code n'apparaissent pas
\`\`\`bash
# Forcer la reconstruction
docker compose down
docker compose up -d --build --force-recreate
\`\`\`

### Cache du navigateur
Faire `Ctrl + Shift + R` pour forcer le rechargement.

## Variables d'environnement

Fichier `.env` :
\`\`\`env
POSTGRES_USER=student
POSTGRES_PASSWORD=student123
POSTGRES_DB=todoapp
DB_HOST=db
DB_PORT=5432
API_PORT=3000
\`\`\`

## Tests

### Test complet de l'API

\`\`\`bash
# 1. Vérifier le statut
curl http://localhost:3000/status
# Réponse : {"status":"OK"}

# 2. Lister les élèves
curl http://localhost:3000/items

# 3. Ajouter un élève
curl -X POST http://localhost:3000/items \
  -H "Content-Type: application/json" \
  -d '{"name":"Nouveau Élève","description":"Spé DevOps"}'

# 4. Supprimer l'élève #1
curl -X DELETE http://localhost:3000/items/1
\`\`\`

## Points importants du TD

✅ **Dockerfile multi-étages** : API et Frontend utilisent le multi-stage build  
✅ **Utilisateur non-root** : Tous les conteneurs  
✅ **Healthchecks** : Implémentés sur tous les services  
✅ **docker-compose.yml** : Orchestration complète avec réseaux et volumes  
✅ **Variables d'environnement** : Externalisées dans .env  
✅ **.dockerignore** : Optimise le build  
✅ **Script d'automatisation** : deploy.sh  
✅ **Documentation** : Ce README

## Ressources

- [Docker Docs](https://docs.docker.com/)
- [Flask Documentation](https://flask.palletsprojects.com/)
- [PostgreSQL Docker Image](https://hub.docker.com/_/postgres)
- [Nginx Docker Image](https://hub.docker.com/_/nginx)
