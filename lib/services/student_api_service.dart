import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/student_model.dart';
import 'api_config.dart';

/// Client REST pour consommer le backend Spring Boot + MongoDB
class StudentApiService {
  static final StudentApiService _instance = StudentApiService._internal();
  factory StudentApiService() => _instance;
  StudentApiService._internal();

  /// Récupère tous les étudiants depuis Spring Boot / MongoDB
  Future<List<Student>> fetchStudents() async {
    final uri = Uri.parse(ApiConfig.studentsEndpoint);
    final response = await http.get(uri, headers: ApiConfig.headers).timeout(
      const Duration(seconds: 5),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((item) => _fromSpringJson(item)).toList();
    } else {
      throw Exception(_extractError(response.body, response.statusCode));
    }
  }

  /// Crée un étudiant dans MongoDB via Spring Boot
  Future<Student> createStudent(Student student) async {
    final uri = Uri.parse(ApiConfig.studentsEndpoint);
    final response = await http
        .post(
          uri,
          headers: ApiConfig.headers,
          body: jsonEncode(_toSpringJson(student)),
        )
        .timeout(const Duration(seconds: 5));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return _fromSpringJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception(_extractError(response.body, response.statusCode));
    }
  }

  /// Met à jour un étudiant existant
  Future<Student> updateStudent(Student student) async {
    final uri = Uri.parse('${ApiConfig.studentsEndpoint}/${student.id}');
    final response = await http
        .put(
          uri,
          headers: ApiConfig.headers,
          body: jsonEncode(_toSpringJson(student)),
        )
        .timeout(const Duration(seconds: 5));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return _fromSpringJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception(_extractError(response.body, response.statusCode));
    }
  }

  /// Met à jour uniquement le statut administratif
  Future<Student> updateStatus(String id, StudentStatus newStatus) async {
    final uri = Uri.parse('${ApiConfig.studentsEndpoint}/$id/status');
    final response = await http
        .patch(
          uri,
          headers: ApiConfig.headers,
          body: jsonEncode({'statut': newStatus.name}),
        )
        .timeout(const Duration(seconds: 5));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return _fromSpringJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception(_extractError(response.body, response.statusCode));
    }
  }

  /// Supprime un dossier étudiant
  Future<void> deleteStudent(String id) async {
    final uri = Uri.parse('${ApiConfig.studentsEndpoint}/$id');
    final response = await http
        .delete(uri, headers: ApiConfig.headers)
        .timeout(const Duration(seconds: 5));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_extractError(response.body, response.statusCode));
    }
  }

  Student _fromSpringJson(Map<String, dynamic> item) {
    return Student(
      id: item['id'] ?? '',
      matricule: item['matricule'] ?? '',
      nom: item['nom'] ?? '',
      prenom: item['prenom'] ?? '',
      dateNaissance: DateTime.parse(item['dateNaissance']),
      email: item['email'] ?? '',
      telephone: item['telephone'] ?? '',
      filiere: item['filiere'] ?? '',
      niveau: item['niveau'] ?? '',
      classe: item['classe'] ?? '',
      statut: StudentStatus.values.firstWhere(
        (s) => s.name == item['statut'],
        orElse: () => StudentStatus.actif,
      ),
      avatarUrl: item['avatarUrl'],
      genre: item['genre'] ?? 'M',
      adresse: item['adresse'] ?? 'Campus Universitaire',
      documents: (item['documents'] as List<dynamic>?)
              ?.map((d) => StudentDocument(
                    id: d['id'] ?? '',
                    title: d['title'] ?? '',
                    category: d['category'] ?? '',
                    fileName: d['fileName'] ?? '',
                    uploadDate: d['uploadDate'] != null
                        ? DateTime.parse(d['uploadDate'])
                        : DateTime.now(),
                    isVerified: d['verified'] ?? true,
                  ))
              .toList() ??
          [],
      historique: (item['historique'] as List<dynamic>?)
              ?.map((h) => AcademicYearRecord(
                    academicYear: h['academicYear'] ?? '',
                    level: h['level'] ?? '',
                    className: h['className'] ?? '',
                    average: (h['average'] as num).toDouble(),
                    mention: h['mention'] ?? '',
                    decision: h['decision'] ?? '',
                  ))
              .toList() ??
          [],
      dateCreation: item['dateCreation'] != null
          ? DateTime.parse(item['dateCreation'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> _toSpringJson(Student s) {
    return {
      'id': s.id,
      'matricule': s.matricule,
      'nom': s.nom,
      'prenom': s.prenom,
      'dateNaissance': s.dateNaissance.toIso8601String().split('T')[0],
      'email': s.email,
      'telephone': s.telephone,
      'filiere': s.filiere,
      'niveau': s.niveau,
      'classe': s.classe,
      'statut': s.statut.name,
      'avatarUrl': s.avatarUrl,
      'genre': s.genre,
      'adresse': s.adresse,
      'documents': s.documents
          .map((d) => {
                'id': d.id,
                'title': d.title,
                'category': d.category,
                'fileName': d.fileName,
                'uploadDate': d.uploadDate.toUtc().toIso8601String(),
                'verified': d.isVerified,
              })
          .toList(),
      'historique': s.historique
          .map((h) => {
                'academicYear': h.academicYear,
                'level': h.level,
                'className': h.className,
                'average': h.average,
                'mention': h.mention,
                'decision': h.decision,
              })
          .toList(),
    };
  }

  String _extractError(String body, int statusCode) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map && decoded.containsKey('error')) {
        return decoded['error'].toString();
      }
    } catch (_) {}
    return 'Erreur serveur Spring Boot ($statusCode)';
  }
}
