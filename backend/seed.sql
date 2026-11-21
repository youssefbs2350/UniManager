-- ====================================================================
-- Données de démonstration (Seed Data) pour UniManager
-- ====================================================================

-- 1. Départements & Filières
INSERT INTO departments (id, code, nom) VALUES
('11111111-1111-1111-1111-111111111111', 'DEP-INFO', 'Département Informatique & Mathématiques Appliquées'),
('22222222-2222-2222-2222-222222222222', 'DEP-GEST', 'Département Gestion & Management des Systèmes')
ON CONFLICT (code) DO NOTHING;

INSERT INTO filieres (id, department_id, code, nom, description) VALUES
('a1111111-1111-1111-1111-111111111111', '11111111-1111-1111-1111-111111111111', 'GL', 'Génie Logiciel', 'Conception et développement logiciel d’entreprise'),
('a2222222-2222-2222-2222-222222222222', '11111111-1111-1111-1111-111111111111', 'IAD', 'Intelligence Artificielle & Data', 'Machine learning, big data et data science'),
('a3333333-3333-3333-3333-333333333333', '11111111-1111-1111-1111-111111111111', 'SRI', 'Systèmes & Réseaux Informatiques', 'Infrastructures cloud, télécoms et réseaux'),
('a4444444-4444-4444-4444-444444444444', '11111111-1111-1111-1111-111111111111', 'CYBER', 'Cybersécurité', 'Sécurité offensive et défensive des SI'),
('a5555555-5555-5555-5555-555555555555', '22222222-2222-2222-2222-222222222222', 'MSI', 'Management des SI', 'Gouvernance, ERP et pilotage des projets digitaux')
ON CONFLICT (code) DO NOTHING;

-- 2. Classes
INSERT INTO classes (id, filiere_id, code, niveau) VALUES
('c1111111-1111-1111-1111-111111111111', 'a1111111-1111-1111-1111-111111111111', 'L3-GL-A', 'Licence 3 (L3)'),
('c2222222-2222-2222-2222-222222222222', 'a1111111-1111-1111-1111-111111111111', 'L3-GL-B', 'Licence 3 (L3)'),
('c3333333-3333-3333-3333-333333333333', 'a2222222-2222-2222-2222-222222222222', 'M1-DS', 'Master 1 (M1)'),
('c4444444-4444-4444-4444-444444444444', 'a3333333-3333-3333-3333-333333333333', 'L2-SRI', 'Licence 2 (L2)'),
('c5555555-5555-5555-5555-555555555555', 'a4444444-4444-4444-4444-444444444444', 'M2-CYBER', 'Master 2 (M2)'),
('c6666666-6666-6666-6666-666666666666', 'a5555555-5555-5555-5555-555555555555', 'M1-MSI', 'Master 1 (M1)')
ON CONFLICT (code) DO NOTHING;

-- 3. Étudiants
INSERT INTO students (id, matricule, nom, prenom, date_naissance, email, telephone, genre, adresse, filiere_nom, classe_nom, niveau, statut) VALUES
('e1111111-1111-1111-1111-111111111111', 'ETU-2026-001', 'Benali', 'Yasmine', '2003-04-15', 'yasmine.benali@unimanager.edu', '+212 6 12 34 56 78', 'F', 'Résidence Universitaire Al-Amal, Bâtiment C', 'Génie Logiciel', 'L3-GL-A', 'Licence 3 (L3)', 'actif'),
('e2222222-2222-2222-2222-222222222222', 'ETU-2026-002', 'El Amrani', 'Karim', '2002-11-20', 'karim.elamrani@unimanager.edu', '+212 6 98 76 54 32', 'M', '12 Avenue des Nations Unies, Agdal', 'Intelligence Artificielle & Data', 'M1-DS', 'Master 1 (M1)', 'actif'),
('e3333333-3333-3333-3333-333333333333', 'ETU-2026-003', 'Tazi', 'Salma', '2004-02-08', 'salma.tazi@unimanager.edu', '+212 6 55 44 33 22', 'F', '45 Rue Ibn Battouta', 'Systèmes & Réseaux Informatiques', 'L2-SRI', 'Licence 2 (L2)', 'actif'),
('e4444444-4444-4444-4444-444444444444', 'ETU-2026-004', 'Mansouri', 'Omar', '2001-07-30', 'omar.mansouri@unimanager.edu', '+212 6 22 11 00 99', 'M', '88 Boulevard Hassan II', 'Cybersécurité', 'M2-CYBER', 'Master 2 (M2)', 'diplome'),
('e5555555-5555-5555-5555-555555555555', 'ETU-2026-005', 'Chraibi', 'Mehdi', '2003-10-12', 'mehdi.chraibi@unimanager.edu', '+212 6 77 88 99 00', 'M', 'Résidence Universitaire Al-Amal, Bâtiment B', 'Génie Logiciel', 'L3-GL-B', 'Licence 3 (L3)', 'suspendu'),
('e6666666-6666-6666-6666-666666666666', 'ETU-2026-006', 'Berrada', 'Amina', '2003-05-25', 'amina.berrada@unimanager.edu', '+212 6 43 21 87 65', 'F', '33 Avenue Mohammed VI', 'Management des SI', 'M1-MSI', 'Master 1 (M1)', 'actif')
ON CONFLICT (matricule) DO NOTHING;

-- 4. Documents Étudiants
INSERT INTO student_documents (student_id, title, category, file_name, is_verified) VALUES
('e1111111-1111-1111-1111-111111111111', 'Carte Nationale d’Identité (CNIE)', 'Identité', 'cnie_yasmine_benali.pdf', true),
('e1111111-1111-1111-1111-111111111111', 'Attestation du Baccalauréat Scientifique', 'Baccalauréat', 'bac_scientifique_2022.pdf', true),
('e1111111-1111-1111-1111-111111111111', 'Certificat d’Aptitude Médicale', 'Médical', 'certificat_medical_2025.pdf', true),
('e2222222-2222-2222-2222-222222222222', 'Diplôme de Licence Fondamentale', 'Attestation', 'diplome_licence_info.pdf', true),
('e4444444-4444-4444-4444-444444444444', 'Attestation de Réussite Finale Master 2', 'Attestation', 'attestation_reussite_m2.pdf', true);

-- 5. Historique Académique
INSERT INTO academic_records (student_id, academic_year, level, class_name, average, mention, decision) VALUES
('e1111111-1111-1111-1111-111111111111', '2023-2024', 'Licence 1', 'L1-INFO-C', 15.65, 'Bien', 'Admis'),
('e1111111-1111-1111-1111-111111111111', '2024-2025', 'Licence 2', 'L2-INFO-A', 16.20, 'Très Bien', 'Admis (Major de promotion)'),
('e2222222-2222-2222-2222-222222222222', '2024-2025', 'Licence 3', 'L3-INFO-B', 14.90, 'Bien', 'Admis en Master'),
('e4444444-4444-4444-4444-444444444444', '2024-2025', 'Master 2', 'M2-CYBER', 17.10, 'Très Bien', 'Diplômé avec Félicitations du Jury');
