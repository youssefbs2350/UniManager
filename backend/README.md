# 🗄️ Backend Supabase & PostgreSQL - UniManager

Ce dossier contient l'ensemble de l'architecture backend requise par le cahier des charges d'**UniManager** (PostgreSQL hébergé sur Supabase).

---

## 📁 Contenu des scripts SQL

1. **`supabase_schema.sql`** :
   - Définition complète des tables pour les 5 modules :
     - `departments`, `filieres`, `classes` (Structure académique)
     - `students`, `student_documents`, `academic_records` (Module 1 - Étudiants)
     - `teachers` (Module 2 - Enseignants)
     - `rooms`, `courses`, `course_sessions` (Module 3 - Planning & Salles)
     - `evaluations`, `grades`, `absences` (Module 4 - Notes & Absences)
     - `audit_logs` (Module 5 - Traçabilité & Sécurité)
   - Contraintes d'intégrité et règles de gestion (Unicité matricule, unicité email actif, contrôles des notes de 0 à 20, cohérence des horaires).
   - Politiques de sécurité RLS (*Row Level Security*).

2. **`seed.sql`** :
   - Données de démonstration prêtes pour la soutenance (filières réelles, classes, étudiants avec pièces jointes et historique de notes).

---

## 🚀 Comment déployer et consommer le backend en 3 étapes :

### Étape 1 : Créer votre projet Supabase (Gratuit)
1. Rendez-vous sur [https://supabase.com](https://supabase.com) et créez un compte gratuit.
2. Cliquez sur **"New project"**, nommez-le `UniManager` et définissez un mot de passe pour la base de données.

### Étape 2 : Exécuter les scripts SQL
1. Dans le menu de gauche de votre projet Supabase, cliquez sur **"SQL Editor"**.
2. Créez une nouvelle requête (**"New query"**), copiez l'intégralité du fichier [`backend/supabase_schema.sql`](file:///C:/Users/youss/.gemini/antigravity/scratch/unimanager/backend/supabase_schema.sql) et cliquez sur **Run**.
3. Faites de même avec le fichier [`backend/seed.sql`](file:///C:/Users/youss/.gemini/antigravity/scratch/unimanager/backend/seed.sql) pour insérer les données d'exemple.

### Étape 3 : Connecter l'application Flutter
1. Dans Supabase, allez dans **Project Settings (roue crantée)** > **API**.
2. Copiez votre **Project URL** et votre clé **Project API Keys (anon / public)**.
3. Ouvrez le fichier Flutter [`lib/services/supabase_config.dart`](file:///C:/Users/youss/.gemini/antigravity/scratch/unimanager/lib/services/supabase_config.dart) :
   ```dart
   static const bool useOnlineBackend = true; // Passez à true
   static const String supabaseUrl = 'https://VOTRE_ID_PROJET.supabase.co';
   static const String supabaseAnonKey = 'VOTRE_CLE_ANON_ICI';
   ```
4. Relancez Flutter : toutes les opérations (Ajout, Consultation, Modification, Statuts, Suppression) sont instantanément synchronisées avec votre base PostgreSQL en ligne !
