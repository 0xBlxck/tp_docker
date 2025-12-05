// Configuration de l'URL de l'API
// En production Docker, on utilise le même host
const API_URL = window.location.hostname === "localhost" ? "http://localhost:3000" : "http://api:3000"

// Fonction pour vérifier le statut de l'API
async function checkAPIStatus() {
  const statusElement = document.getElementById("api-status")

  try {
    const response = await fetch(`${API_URL}/status`)
    const data = await response.json()

    if (data.status === "OK") {
      statusElement.className = "status-indicator online"
      statusElement.innerHTML = "✅ <span>API en ligne</span>"
    } else {
      throw new Error("API non disponible")
    }
  } catch (error) {
    statusElement.className = "status-indicator offline"
    statusElement.innerHTML = "❌ <span>API hors ligne</span>"
    console.error("Erreur de connexion à l'API:", error)
  }
}

// Fonction pour charger les items
async function loadItems() {
  const container = document.getElementById("items-container")

  // Afficher le loader
  container.innerHTML = `
        <div class="loader-container">
            <span class="loader"></span>
            <p>Chargement des élèves...</p>
        </div>
    `

  try {
    const response = await fetch(`${API_URL}/items`)
    const data = await response.json()

    if (data.success && data.items.length > 0) {
      displayItems(data.items)
    } else {
      container.innerHTML = `
                <div class="empty-state">
                    <p>📭 Aucun élève enregistré pour le moment</p>
                </div>
            `
    }
  } catch (error) {
    console.error("Erreur lors du chargement des items:", error)
    container.innerHTML = `
            <div class="error-message">
                ❌ Erreur lors du chargement des élèves. Vérifiez que l'API est accessible.
            </div>
        `
  }
}

// Fonction pour afficher les items
function displayItems(items) {
  const container = document.getElementById("items-container")

  container.innerHTML = items
    .map(
      (item) => `
        <div class="item-card">
            <h3>${escapeHtml(item.name)}</h3>
            ${item.description ? `<p>${escapeHtml(item.description)}</p>` : ""}
            <div class="item-meta">
                ID: ${item.id} | Créé le ${new Date(item.created_at).toLocaleDateString("fr-FR")}
            </div>
            <button class="delete-btn" onclick="deleteItem(${item.id})">🗑️ Supprimer</button>
        </div>
    `,
    )
    .join("")
}

// Fonction pour échapper le HTML (sécurité XSS)
function escapeHtml(text) {
  const div = document.createElement("div")
  div.textContent = text
  return div.innerHTML
}

// Fonction pour ajouter un item
async function addItem(name, description) {
  try {
    const response = await fetch(`${API_URL}/items`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ name, description }),
    })

    const data = await response.json()

    if (data.success) {
      // Recharger la liste des items
      await loadItems()

      // Réinitialiser le formulaire
      document.getElementById("add-item-form").reset()

      // Afficher un message de succès (simple)
      alert("✅ Élève ajouté avec succès !")
    } else {
      alert("❌ Erreur lors de l'ajout de l'élève")
    }
  } catch (error) {
    console.error("Erreur lors de l'ajout de l'item:", error)
    alert("❌ Erreur lors de l'ajout de l'élève")
  }
}

// Fonction pour supprimer un item
async function deleteItem(itemId) {
  if (!confirm("Êtes-vous sûr de vouloir supprimer cet élève ?")) {
    return
  }

  try {
    const response = await fetch(`${API_URL}/items/${itemId}`, {
      method: "DELETE",
    })

    const data = await response.json()

    if (data.success) {
      // Recharger la liste des items
      await loadItems()
      alert("✅ Élève supprimé avec succès !")
    } else {
      alert("❌ Erreur lors de la suppression de l'élève")
    }
  } catch (error) {
    console.error("Erreur lors de la suppression de l'item:", error)
    alert("❌ Erreur lors de la suppression de l'élève")
  }
}

// Event Listeners
document.addEventListener("DOMContentLoaded", () => {
  // Vérifier le statut de l'API au chargement
  checkAPIStatus()

  // Charger les items au chargement
  loadItems()

  // Vérifier le statut toutes les 30 secondes
  setInterval(checkAPIStatus, 30000)

  // Formulaire d'ajout d'item
  document.getElementById("add-item-form").addEventListener("submit", async (e) => {
    e.preventDefault()

    const name = document.getElementById("item-name").value.trim()
    const description = document.getElementById("item-description").value.trim()

    if (name) {
      await addItem(name, description)
    }
  })

  // Bouton de rafraîchissement
  document.getElementById("refresh-btn").addEventListener("click", () => {
    loadItems()
    checkAPIStatus()
  })
})
