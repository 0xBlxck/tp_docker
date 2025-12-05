# Dockerfile multi-étapes pour l'API Python
# Étape 1 : Build - Installation des dépendances
FROM python:3.11-alpine AS builder

WORKDIR /app

# Copier le fichier de dépendances
COPY requirements.txt .

# Installer les dépendances de compilation nécessaires pour psycopg2
RUN apk add --no-cache postgresql-dev gcc python3-dev musl-dev && \
    pip install --no-cache-dir -r requirements.txt

# Étape 2 : Production - Image finale légère
FROM python:3.11-alpine

# Installer uniquement les bibliothèques runtime nécessaires
RUN apk add --no-cache libpq

# Créer un utilisateur non-root pour la sécurité
RUN addgroup -g 1001 -S appuser && \
    adduser -S appuser -u 1001

WORKDIR /app

# Copier les dépendances Python depuis l'étape de build
COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages

# Copier le code source
COPY --chown=appuser:appuser . .

# Changer vers l'utilisateur non-root
USER appuser

# Exposer le port de l'API
EXPOSE 3000

# Healthcheck pour vérifier que l'API répond
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD python healthcheck.py

# Démarrer l'application Flask
CMD ["python", "app.py"]
