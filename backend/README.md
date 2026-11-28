# 🍃 Backend Spring Boot + MongoDB Local — UniManager

Ce dossier contient le backend complet développé en **Java 17 / Spring Boot 3** avec **Spring Data MongoDB**, connecté à votre instance **MongoDB locale**.

---

## ⚙️ Configuration

* **Base de données MongoDB** : `mongodb://localhost:27017/unimanager_db`
* **Port du serveur API** : `8081` *(configuré sur 8081 dans `application.properties` pour éviter le conflit avec Oracle sur le port 8080)*
* **Initialisation automatique** : Au premier démarrage, `DataInitializer` peuple automatiquement la collection `students` dans MongoDB avec les 6 dossiers de démonstration s'ils n'existent pas encore.

---

## 🔌 Endpoints REST disponibles (`/api/students`)

| Méthode | Endpoint | Description |
| :--- | :--- | :--- |
| `GET` | `/api/students` | Liste des étudiants (filtres optionnels : `query`, `status`, `filiere`, `sortBy`) |
| `GET` | `/api/students/{id}` | Détails complets d'un étudiant |
| `GET` | `/api/students/stats` | Statistiques KPIs (`total`, `actif`, `suspendu`, `diplome`) |
| `POST` | `/api/students` | Création d'un étudiant (avec validation matricule unique & email actif unique) |
| `PUT` | `/api/students/{id}` | Mise à jour d'un dossier étudiant |
| `PATCH` | `/api/students/{id}/status` | Modification du statut (`actif`, `suspendu`, `diplome`) |
| `POST` | `/api/students/{id}/documents` | Ajout d'un document administratif |
| `DELETE` | `/api/students/{id}` | Suppression d'un dossier étudiant |

---

## 🚀 Lancer le backend

1. Vérifiez que le service **MongoDB** est bien démarré localement (port `27017`).
2. Ouvrez ce dossier `backend/` dans **IntelliJ IDEA**, **Eclipse / STS** ou **VS Code** (Java Extension Pack), ou lancez avec Maven :
   ```powershell
   cd backend
   mvn spring-boot:run
   ```
   *(Ou via le wrapper `.\mvnw.cmd spring-boot:run` s'il est présent).*
3. L'API est accessible sur : `http://localhost:8081/api/students`
