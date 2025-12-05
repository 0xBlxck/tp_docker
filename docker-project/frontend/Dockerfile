# Dockerfile multi-étapes pour le frontend
# Étape 1 : Build - Préparation des fichiers statiques
FROM nginx:alpine AS builder

WORKDIR /app

# Copier les fichiers du frontend
COPY . .

# Étape 2 : Production - Serveur Nginx léger
FROM nginx:alpine

# Créer un utilisateur non-root
RUN addgroup -g 1001 -S nginx-app && \
    adduser -S nginx-app -u 1001 -G nginx-app

# Copier les fichiers statiques
COPY --chown=nginx-app:nginx-app ./index.html /usr/share/nginx/html/
COPY --chown=nginx-app:nginx-app ./styles.css /usr/share/nginx/html/
COPY --chown=nginx-app:nginx-app ./app.js /usr/share/nginx/html/

# Copier la configuration Nginx personnalisée
COPY --chown=nginx-app:nginx-app nginx.conf /etc/nginx/conf.d/default.conf

# Modifier les permissions pour nginx
RUN chown -R nginx-app:nginx-app /usr/share/nginx/html && \
    chown -R nginx-app:nginx-app /var/cache/nginx && \
    chown -R nginx-app:nginx-app /var/log/nginx && \
    chown -R nginx-app:nginx-app /etc/nginx/conf.d && \
    touch /var/run/nginx.pid && \
    chown -R nginx-app:nginx-app /var/run/nginx.pid

# Changer vers l'utilisateur non-root
USER nginx-app

# Exposer le port
EXPOSE 8080

# Healthcheck
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost:8080/ || exit 1

# Démarrer Nginx
CMD ["nginx", "-g", "daemon off;"]
