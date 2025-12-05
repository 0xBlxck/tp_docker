-- Script d'initialisation de la base de données
-- Exécuté automatiquement au premier démarrage du conteneur PostgreSQL

-- Création de la table students pour les élèves de l'EPSI
CREATE TABLE IF NOT EXISTS items (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Index pour améliorer les performances des requêtes
CREATE INDEX IF NOT EXISTS idx_items_created_at ON items(created_at DESC);

-- Insertion d'élèves Bachelor 3 SysOps de l'EPSI
INSERT INTO items (name, description) VALUES
    ('Wassim Ben Ali', 'Bachelor 3 SysOps - Spécialisation Sécurité & Infrastructure'),
    ('Johan Dupont', 'Bachelor 3 SysOps - Spécialisation DevOps'),
    ('Marie Martin', 'Bachelor 3 SysOps - Spécialisation Cloud & Conteneurisation'),
    ('Thomas Bernard', 'Bachelor 3 SysOps - Spécialisation Réseaux'),
    ('Sarah Lefebvre', 'Bachelor 3 SysOps - Spécialisation Automatisation'),
    ('Lucas Moreau', 'Bachelor 3 SysOps - Spécialisation Virtualisation'),
    ('Emma Dubois', 'Bachelor 3 SysOps - Spécialisation Monitoring'),
    ('Alexandre Petit', 'Bachelor 3 SysOps - Spécialisation Infrastructure as Code');

-- Afficher un message de confirmation
DO $$
BEGIN
    RAISE NOTICE 'Base de données initialisée avec les élèves EPSI Bachelor 3 SysOps !';
END $$;
