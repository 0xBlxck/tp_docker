import requests
import sys
import os

port = os.getenv('API_PORT', '3000')
url = f'http://localhost:{port}/status'

try:
    response = requests.get(url, timeout=5)
    if response.status_code == 200:
        sys.exit(0)
    else:
        sys.exit(1)
except Exception:
    sys.exit(1)
