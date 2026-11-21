/// Configuration de connexion au Backend Supabase & PostgreSQL
/// 
/// Pour connecter l'application à votre instance Supabase :
/// 1. Créez un projet gratuit sur https://supabase.com
/// 2. Allez dans "SQL Editor" et exécutez le script 'backend/supabase_schema.sql' puis 'backend/seed.sql'
/// 3. Copiez votre Project URL et votre anon/public API Key depuis Project Settings > API
/// 4. Collez-les ci-dessous et passez 'useOnlineBackend' à true.
class SupabaseConfig {
  static const bool useOnlineBackend = false; // Mettre à true dès que vos clés sont renseignées

  static const String supabaseUrl = 'https://YOUR_PROJECT_ID.supabase.co';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

  static Map<String, String> get headers => {
    'apikey': supabaseAnonKey,
    'Authorization': 'Bearer $supabaseAnonKey',
    'Content-Type': 'application/json',
    'Prefer': 'return=representation',
  };

  static String get studentsEndpoint => '$supabaseUrl/rest/v1/students';
  static String get documentsEndpoint => '$supabaseUrl/rest/v1/student_documents';
  static String get recordsEndpoint => '$supabaseUrl/rest/v1/academic_records';
}
