import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/student_model.dart';
import 'supabase_config.dart';

class SupabaseApiService {
  static final SupabaseApiService _instance = SupabaseApiService._internal();
  factory SupabaseApiService() => _instance;
  SupabaseApiService._internal();

  /// Récupère la liste de tous les étudiants depuis PostgreSQL Supabase
  Future<List<Student>> fetchStudents() async {
    final uri = Uri.parse(
      '${SupabaseConfig.studentsEndpoint}?select=*,student_documents(*),academic_records(*)&order=nom.asc',
    );

    final response = await http.get(uri, headers: SupabaseConfig.headers);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) {
        // Adaptation des clés PostgreSQL vers le modèle Dart
        return Student(
          id: item['id'],
          matricule: item['matricule'],
          nom: item['nom'],
          prenom: item['prenom'],
          dateNaissance: DateTime.parse(item['date_naissance']),
          email: item['email'],
          telephone: item['telephone'],
          filiere: item['filiere_nom'] ?? '',
          niveau: item['niveau'] ?? '',
          classe: item['classe_nom'] ?? '',
          statut: StudentStatus.values.firstWhere(
            (s) => s.name == item['statut'],
            orElse: () => StudentStatus.actif,
          ),
          avatarUrl: item['avatar_url'],
          genre: item['genre'] ?? 'M',
          adresse: item['adresse'] ?? '',
          documents: (item['student_documents'] as List<dynamic>?)
                  ?.map((d) => StudentDocument(
                        id: d['id'],
                        title: d['title'],
                        category: d['category'],
                        fileName: d['file_name'],
                        uploadDate: DateTime.parse(d['uploaded_at']),
                        isVerified: d['is_verified'] ?? false,
                      ))
                  .toList() ??
              [],
          historique: (item['academic_records'] as List<dynamic>?)
                  ?.map((h) => AcademicYearRecord(
                        academicYear: h['academic_year'],
                        level: h['level'],
                        className: h['class_name'],
                        average: (h['average'] as num).toDouble(),
                        mention: h['mention'] ?? '',
                        decision: h['decision'] ?? '',
                      ))
                  .toList() ??
              [],
          dateCreation: item['created_at'] != null ? DateTime.parse(item['created_at']) : DateTime.now(),
        );
      }).toList();
    } else {
      throw Exception('Erreur API Supabase (${response.statusCode}) : ${response.body}');
    }
  }

  /// Insère un nouvel étudiant dans la base Supabase
  Future<void> insertStudent(Student student) async {
    final uri = Uri.parse(SupabaseConfig.studentsEndpoint);
    final body = jsonEncode({
      'matricule': student.matricule,
      'nom': student.nom,
      'prenom': student.prenom,
      'date_naissance': student.dateNaissance.toIso8601String().split('T')[0],
      'email': student.email,
      'telephone': student.telephone,
      'filiere_nom': student.filiere,
      'niveau': student.niveau,
      'classe_nom': student.classe,
      'statut': student.statut.name,
      'genre': student.genre,
      'adresse': student.adresse,
    });

    final response = await http.post(
      uri,
      headers: SupabaseConfig.headers,
      body: body,
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Échec de création sur Supabase : ${response.body}');
    }
  }

  /// Met à jour un étudiant existant
  Future<void> updateStudent(Student student) async {
    final uri = Uri.parse('${SupabaseConfig.studentsEndpoint}?id=eq.${student.id}');
    final body = jsonEncode({
      'matricule': student.matricule,
      'nom': student.nom,
      'prenom': student.prenom,
      'date_naissance': student.dateNaissance.toIso8601String().split('T')[0],
      'email': student.email,
      'telephone': student.telephone,
      'filiere_nom': student.filiere,
      'niveau': student.niveau,
      'classe_nom': student.classe,
      'statut': student.statut.name,
      'genre': student.genre,
      'adresse': student.adresse,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    });

    final response = await http.patch(
      uri,
      headers: SupabaseConfig.headers,
      body: body,
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Échec de mise à jour sur Supabase : ${response.body}');
    }
  }

  /// Modifie uniquement le statut d'un étudiant
  Future<void> updateStatus(String id, StudentStatus newStatus) async {
    final uri = Uri.parse('${SupabaseConfig.studentsEndpoint}?id=eq.$id');
    final body = jsonEncode({
      'statut': newStatus.name,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    });

    final response = await http.patch(
      uri,
      headers: SupabaseConfig.headers,
      body: body,
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Échec du changement de statut sur Supabase : ${response.body}');
    }
  }

  /// Supprime un dossier étudiant
  Future<void> deleteStudent(String id) async {
    final uri = Uri.parse('${SupabaseConfig.studentsEndpoint}?id=eq.$id');
    final response = await http.delete(uri, headers: SupabaseConfig.headers);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Échec de suppression sur Supabase : ${response.body}');
    }
  }
}
