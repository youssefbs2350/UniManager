# 🎓 UniManager - Application Mobile de Gestion Universitaire
> Projet académique Flutter & Dart • Découpage en 5 Modules • Architecture en Couches

---

## 📌 1. Répartition du Projet (Équipe de 5 Personnes)

Selon les spécifications du Cahier des Charges (**Section 9 - Répartition du travail et intégration**) :

| Membre | Module Principal | Responsabilités & Livrables | Statut dans ce projet |
| :--- | :--- | :--- | :--- |
| **Membre 1** | **Module 1 - Gestion des étudiants** | **Dossiers étudiants, CRUD complet, affectations de classe, statuts, recherche & filtres, fiche détaillée, historique & documents.** | 🏆 **Partie choisie & 100% Développée** |
| Membre 2 | Module 2 - Gestion des enseignants | Fiches enseignants, charges horaires, disponibilités/indisponibilités, affectation aux cours, détection conflits. | Attribué au binôme 2 |
| Membre 3 | Module 3 - Cours et emplois du temps | Matières, séances, salles, planning hebdomadaire/journalier, détection des chevauchements. | Attribué au binôme 3 |
| Membre 4 | Module 4 - Gestion des notes et absences | Évaluations, calcul automatique des moyennes pondérées, feuille de présence/absences, relevé PDF. | Attribué au binôme 4 |
| Membre 5 | Module 5 - Administration & statistiques | Authentification, gestion des comptes & rôles, départements, tableaux de bord avec indicateurs KPIs. | Attribué au binôme 5 |

---

## 🎨 2. Identité Visuelle & Logo Officiel UniManager

Le logo officiel d'**UniManager** a été conçu sur mesure sous forme de composant vectoriel Flutter haute fidélité (`UniManagerLogo`) :
- **Emblème Vectoriel** : Toque de diplômé universitaire (mortarboard) avec pompon doré surmontant un livre ouvert stylisé, incarnant à la fois l'excellence académique et la modernité logicielle.
- **Palette Graphique** :
  - *Bleu Royal Universitaire* (`#1E3A8A`) : Rigueur académique et confiance institutionnelle.
  - *Cyan Océan Vif* (`#0EA5E9`) : Dynamisme numérique et clarté d'interface.
  - *Accents d'état* : Vert Émeraude (`#10B981` Actif), Orange Ambre (`#F59E0B` Suspendu), Indigo (`#6366F1` Diplômé).
- **Typographie** : Contraste de graisse entre **Uni** (Extra Bold) et **Manager** (Heavy Cyan) accompagné du badge institutionnel *"GESTION UNIVERSITAIRE"*.

---

## 📱 3. Interfaces Complètes Réalisées (Module 1 : Gestion des étudiants)

Toutes les interfaces requises par le cahier des charges ont été générées avec une architecture modulaire et réactive :

### 1. `SplashScreen` (`lib/screens/splash_screen.dart`)
- Animation d'échelle et de fondu du logo officiel **UniManager**.
- Sous-titre et identification du module sélectionné (Membre 1).
- Transition fluide vers l'écran d'accueil.

### 2. `MainNavigationScreen` (`lib/screens/main_navigation_screen.dart`)
- **Navigation unifiée** : `NavigationBar` Material 3 reliant les 5 modules prévus au cahier des charges.
- **Drawer interactif** : Présente la répartition des 5 membres de l'équipe, le rôle connecté (Administrateur, Responsable, etc.) et les informations du CDC.

### 3. `StudentListScreen` (`lib/screens/student_list_screen.dart`)
- **Indicateurs KPIs en direct** : Cartes horizontales dénombrant l'Effectif total, les Inscrits actifs et les Diplômés.
- **Recherche en temps réel** : Filtrage instantané sur le Nom, Prénom, Matricule ou Classe.
- **Filtres rapides en puces (FilterChips)** : Tous, Actifs, Suspendus, Diplômés.
- **Filtres avancés par filière** : Génie Logiciel, IA & Data, Systèmes & Réseaux, Cybersécurité, Management des SI.
- **Tri multi-critères** : Nom alphabétique (A-Z / Z-A), Matricule, Inscription récente.
- **Cartes étudiants élégantes** : Avatar avec initiales, badges de statut colorés, classe rattachée et accès rapide.

### 4. `StudentDetailScreen` (`lib/screens/student_detail_screen.dart`)
- **En-tête Sliver dynamique** : Grand avatar, nom complet, matricule avec bouton de copie en 1 clic et badge de statut.
- **3 Onglets complets** :
  1. **Onglet Informations** : Détails d'affectation académique, coordonnées (email, téléphone, adresse) et état civil complet.
  2. **Onglet Parcours** : Historique complet des années antérieures (niveaux, classes, moyennes sur 20, mentions et décisions du jury).
  3. **Onglet Documents** : Gestion des pièces administratives (CNIE, attestation de Bac, certificats) avec statut de validation et modal d'upload.
- **Actions contextuelles** : Dialogue de modification du statut (Actif, Suspendu, Diplômé) avec contrôle de réactivation, bouton de modification et suppression avec confirmation de sécurité.

### 5. `StudentFormScreen` (`lib/screens/student_form_screen.dart`)
- Formulaire complet de **création** et **modification** d'un dossier étudiant.
- Contrôle strict des règles de gestion énoncées au cahier des charges :
  - ✅ **Règle 1** : Matricule unique (généré automatiquement ou saisi avec validation d'unicité).
  - ✅ **Règle 2** : Email unique parmi les comptes actifs.
  - ✅ **Règle 3** : Rattachement obligatoire à une filière et une classe définie.
  - ✅ Contrôle des formats (regex email, datepicker avec contrôle d'âge minimum).

---

## 🗄️ 4. Backend Spring Boot & MongoDB Local

Le projet utilise un backend **Spring Boot 3 (Java 17)** connecté à une base de données **MongoDB locale** (`mongodb://localhost:27017/unimanager_db`) dans le dossier `backend/` :
- `Student` (`@Document(collection = "students")`) : `id`, `matricule` (index unique), `nom`, `prenom`, `dateNaissance`, `email`, `telephone`, `filiere`, `niveau`, `classe`, `statut`, `documents`, `historique`, `dateCreation`.
- API REST complète exposée sur `http://localhost:8081/api/students` (port 8081 pour éviter le conflit avec Oracle sur 8080).
- Client Flutter dans `lib/services/student_api_service.dart` et `lib/services/api_config.dart`.

---

## 🚀 5. Exécution du Projet

```bash
# Se placer dans le répertoire du projet
cd "C:\Users\youss\.gemini\antigravity\scratch\unimanager"

# Lancer l'analyse du code
flutter analyze

# Lancer les tests unitaires et de widgets
flutter test

# Exécuter l'application sur émulateur ou sur Windows/Chrome
flutter run
```
