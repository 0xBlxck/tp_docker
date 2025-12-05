from flask import Flask, jsonify, request
from flask_cors import CORS
import psycopg2
from psycopg2.extras import RealDictCursor
import os
import signal
import sys

app = Flask(__name__)
CORS(app)  # Permet au frontend d'appeler l'API

# Configuration de la base de données depuis les variables d'environnement
DB_CONFIG = {
    'host': os.getenv('DB_HOST', 'db'),
    'port': int(os.getenv('DB_PORT', 5432)),
    'user': os.getenv('DB_USER', 'postgres'),
    'password': os.getenv('DB_PASSWORD', 'password'),
    'database': os.getenv('DB_NAME', 'myapp')
}

def get_db_connection():
    """Crée une connexion à la base de données"""
    return psycopg2.connect(**DB_CONFIG, cursor_factory=RealDictCursor)

@app.route('/status', methods=['GET'])
def status():
    """Route /status : indique que l'API est fonctionnelle"""
    return jsonify({
        'status': 'OK',
        'message': 'API is running',
        'language': 'Python/Flask'
    })

@app.route('/items', methods=['GET'])
def get_items():
    """Route /items : retourne les items depuis la base de données"""
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute('SELECT * FROM items ORDER BY created_at DESC')
        items = cursor.fetchall()
        cursor.close()
        conn.close()
        
        return jsonify({
            'success': True,
            'count': len(items),
            'items': items
        })
    except Exception as e:
        print(f"Erreur lors de la récupération des items: {e}")
        return jsonify({
            'success': False,
            'error': 'Erreur serveur lors de la récupération des items'
        }), 500

@app.route('/items', methods=['POST'])
def add_item():
    """Route POST /items : ajoute un nouvel item"""
    data = request.get_json()
    name = data.get('name')
    description = data.get('description')
    
    if not name:
        return jsonify({
            'success': False,
            'error': 'Le nom est requis'
        }), 400
    
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute(
            'INSERT INTO items (name, description) VALUES (%s, %s) RETURNING *',
            (name, description)
        )
        new_item = cursor.fetchone()
        conn.commit()
        cursor.close()
        conn.close()
        
        return jsonify({
            'success': True,
            'item': new_item
        }), 201
    except Exception as e:
        print(f"Erreur lors de l'ajout de l'item: {e}")
        return jsonify({
            'success': False,
            'error': 'Erreur serveur lors de l\'ajout de l\'item'
        }), 500

@app.route('/items/<int:item_id>', methods=['DELETE'])
def delete_item(item_id):
    """Route DELETE /items/<id> : supprime un item par son ID"""
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute('DELETE FROM items WHERE id = %s RETURNING id', (item_id,))
        deleted = cursor.fetchone()
        conn.commit()
        cursor.close()
        conn.close()
        
        if deleted:
            return jsonify({
                'success': True,
                'message': f'Item {item_id} supprimé'
            })
        else:
            return jsonify({
                'success': False,
                'error': 'Item non trouvé'
            }), 404
            
    except Exception as e:
        print(f"Erreur lors de la suppression de l'item: {e}")
        return jsonify({
            'success': False,
            'error': 'Erreur serveur lors de la suppression'
        }), 500

def shutdown_handler(signum, frame):
    """Gestion propre de l'arrêt du serveur"""
    print("Signal reçu, fermeture de l'API...")
    sys.exit(0)

if __name__ == '__main__':
    # Gestion des signaux pour un arrêt propre
    signal.signal(signal.SIGTERM, shutdown_handler)
    signal.signal(signal.SIGINT, shutdown_handler)
    
    # Démarrage du serveur
    port = int(os.getenv('API_PORT', 3000))
    print(f"API Flask démarrée sur le port {port}")
    app.run(host='0.0.0.0', port=port)
