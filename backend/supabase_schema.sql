-- ====================================================================
-- UniManager - Schéma de Base de Données PostgreSQL / Supabase
-- Cahier des charges académique : Gestion Universitaire Intégrée (5 Modules)
-- ====================================================================

-- 1. EXTENSIONS & TYPES
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Enums pour statuts et rôles
DO $$ BEGIN
    CREATE TYPE student_status AS ENUM ('actif', 'suspendu', 'diplome');
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    CREATE TYPE user_role AS ENUM ('admin', 'responsable', 'enseignant', 'etudiant');
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    CREATE TYPE absence_status AS ENUM ('justifiee', 'non_justifiee', 'en_attente');
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;

-- 2. STRUCTURE PÉDAGOGIQUE (Filières, Niveaux, Classes)
CREATE TABLE IF NOT EXISTS departments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(20) UNIQUE NOT NULL,
    nom VARCHAR(100) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

CREATE TABLE IF NOT EXISTS filieres (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    department_id UUID REFERENCES departments(id) ON DELETE SET NULL,
    code VARCHAR(20) UNIQUE NOT NULL,
    nom VARCHAR(100) NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

CREATE TABLE IF NOT EXISTS classes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    filiere_id UUID NOT NULL REFERENCES filieres(id) ON DELETE CASCADE,
    code VARCHAR(30) UNIQUE NOT NULL, -- Ex: "L3-GL-A", "M1-DS"
    niveau VARCHAR(30) NOT NULL,      -- Ex: "Licence 3", "Master 1"
    annee_scolaire VARCHAR(10) NOT NULL DEFAULT '2025-2026',
    effectif_max INT DEFAULT 40,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- 3. MODULE 1 : GESTION DES ÉTUDIANTS
CREATE TABLE IF NOT EXISTS students (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    matricule VARCHAR(30) UNIQUE NOT NULL, -- Règle CDC : Matricule unique
    nom VARCHAR(60) NOT NULL,
    prenom VARCHAR(60) NOT NULL,
    date_naissance DATE NOT NULL,
    email VARCHAR(120) NOT NULL,
    telephone VARCHAR(30) NOT NULL,
    genre CHAR(1) CHECK (genre IN ('M', 'F')) DEFAULT 'M',
    adresse TEXT DEFAULT 'Campus Universitaire',
    filiere_id UUID REFERENCES filieres(id) ON DELETE RESTRICT,
    filiere_nom VARCHAR(100) NOT NULL,
    classe_id UUID REFERENCES classes(id) ON DELETE RESTRICT,
    classe_nom VARCHAR(30) NOT NULL, -- Règle CDC : Rattaché à une classe définie
    niveau VARCHAR(30) NOT NULL,
    statut student_status NOT NULL DEFAULT 'actif',
    avatar_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- Règle CDC : Une adresse email ne peut pas être associée à deux comptes actifs
CREATE UNIQUE INDEX IF NOT EXISTS idx_students_active_email 
ON students (LOWER(email)) 
WHERE statut = 'actif';

-- Documents administratifs de l'étudiant
CREATE TABLE IF NOT EXISTS student_documents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    title VARCHAR(120) NOT NULL,
    category VARCHAR(50) NOT NULL, -- 'Identité', 'Baccalauréat', 'Médical', etc.
    file_name VARCHAR(255) NOT NULL,
    file_url TEXT,
    is_verified BOOLEAN DEFAULT TRUE,
    uploaded_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- Historique académique et parcours antérieur de l'étudiant
CREATE TABLE IF NOT EXISTS academic_records (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    academic_year VARCHAR(15) NOT NULL, -- Ex: "2024-2025"
    level VARCHAR(30) NOT NULL,        -- Ex: "Licence 2"
    class_name VARCHAR(30) NOT NULL,
    average NUMERIC(4, 2) CHECK (average >= 0 AND average <= 20),
    mention VARCHAR(30),
    decision VARCHAR(50),              -- "Admis", "Ajourné"
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- 4. MODULE 2 : GESTION DES ENSEIGNANTS
CREATE TABLE IF NOT EXISTS teachers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    matricule VARCHAR(30) UNIQUE NOT NULL,
    nom VARCHAR(60) NOT NULL,
    prenom VARCHAR(60) NOT NULL,
    email VARCHAR(120) UNIQUE NOT NULL,
    telephone VARCHAR(30),
    grade VARCHAR(50) NOT NULL,       -- "Professeur", "Maître de Conférences", "Vacataire"
    specialite VARCHAR(100) NOT NULL,
    charge_hebdo_max INT DEFAULT 18,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- 5. MODULE 3 : COURS, SALLES & SÉANCES (Planning)
CREATE TABLE IF NOT EXISTS rooms (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nom VARCHAR(50) UNIQUE NOT NULL, -- Ex: "Amphi A", "Lab 204"
    capacite INT NOT NULL DEFAULT 40,
    type VARCHAR(30) DEFAULT 'Salle de TD'
);

CREATE TABLE IF NOT EXISTS courses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(20) UNIQUE NOT NULL, -- Ex: "INFO301"
    libelle VARCHAR(100) NOT NULL,
    coefficient NUMERIC(3, 1) DEFAULT 2.0,
    volume_horaire INT NOT NULL DEFAULT 30,
    filiere_id UUID REFERENCES filieres(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS course_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    teacher_id UUID NOT NULL REFERENCES teachers(id) ON DELETE CASCADE,
    class_id UUID NOT NULL REFERENCES classes(id) ON DELETE CASCADE,
    room_id UUID NOT NULL REFERENCES rooms(id) ON DELETE CASCADE,
    date_session DATE NOT NULL,
    heure_debut TIME NOT NULL,
    heure_fin TIME NOT NULL,
    CHECK (heure_fin > heure_debut), -- Règle CDC : heure fin > heure début
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- 6. MODULE 4 : ÉVALUATIONS, NOTES & ABSENCES
CREATE TABLE IF NOT EXISTS evaluations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    class_id UUID NOT NULL REFERENCES classes(id) ON DELETE CASCADE,
    titre VARCHAR(100) NOT NULL, -- "Contrôle Continu 1", "Examen Final"
    type VARCHAR(30) DEFAULT 'CC',
    coefficient NUMERIC(3, 1) DEFAULT 1.0,
    bareme NUMERIC(4, 2) DEFAULT 20.0,
    date_evaluation DATE NOT NULL
);

CREATE TABLE IF NOT EXISTS grades (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    evaluation_id UUID NOT NULL REFERENCES evaluations(id) ON DELETE CASCADE,
    student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    valeur NUMERIC(4, 2) NOT NULL CHECK (valeur >= 0 AND valeur <= 20), -- Règle CDC : barème 0 à 20
    commentaire TEXT,
    UNIQUE(evaluation_id, student_id)
);

CREATE TABLE IF NOT EXISTS absences (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id UUID NOT NULL REFERENCES course_sessions(id) ON DELETE CASCADE,
    student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    statut absence_status DEFAULT 'en_attente',
    justificatif_url TEXT,
    date_declaration TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
    UNIQUE(session_id, student_id)
);

-- 7. MODULE 5 : JOURNAUX D'AUDIT (Traçabilité des actions sensibles)
CREATE TABLE IF NOT EXISTS audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID,
    user_email VARCHAR(120),
    action VARCHAR(50) NOT NULL, -- 'INSERT', 'UPDATE', 'DELETE', 'LOGIN'
    table_name VARCHAR(50) NOT NULL,
    record_id UUID,
    details JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- 8. VUES UTILES POUR L'APPLICATION (KPIs & Statistiques)
CREATE OR REPLACE VIEW v_student_stats AS
SELECT 
    COUNT(*) AS total_students,
    COUNT(*) FILTER (WHERE statut = 'actif') AS active_students,
    COUNT(*) FILTER (WHERE statut = 'suspendu') AS suspended_students,
    COUNT(*) FILTER (WHERE statut = 'diplome') AS graduated_students
FROM students;

-- ====================================================================
-- RLS (ROW LEVEL SECURITY) SUPABASE
-- ====================================================================
ALTER TABLE students ENABLE ROW LEVEL SECURITY;
ALTER TABLE student_documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE academic_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE filieres ENABLE ROW LEVEL SECURITY;
ALTER TABLE classes ENABLE ROW LEVEL SECURITY;

-- Politiques ouvertes pour lecture/écriture en mode projet/démonstration
CREATE POLICY "Lecture ouverte étudiants" ON students FOR SELECT USING (true);
CREATE POLICY "Écriture ouverte étudiants" ON students FOR ALL USING (true);

CREATE POLICY "Lecture ouverte documents" ON student_documents FOR SELECT USING (true);
CREATE POLICY "Écriture ouverte documents" ON student_documents FOR ALL USING (true);

CREATE POLICY "Lecture ouverte historique" ON academic_records FOR SELECT USING (true);
CREATE POLICY "Écriture ouverte historique" ON academic_records FOR ALL USING (true);

CREATE POLICY "Lecture filieres" ON filieres FOR SELECT USING (true);
CREATE POLICY "Lecture classes" ON classes FOR SELECT USING (true);
