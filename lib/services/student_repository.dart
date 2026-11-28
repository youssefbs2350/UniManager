import 'package:flutter/foundation.dart';
import '../models/student_model.dart';
import 'api_config.dart';
import 'student_api_service.dart';

class StudentRepository extends ChangeNotifier {
  // Singleton pattern pour un accès centralisé
  static final StudentRepository _instance = StudentRepository._internal();
  factory StudentRepository() => _instance;

  final StudentApiService _api = StudentApiService();

  StudentRepository._internal() {
    _initSeedData();
    if (ApiConfig.useOnlineBackend) {
      syncWithBackend();
    }
  }

  /// Synchronisation avec le backend Spring Boot + MongoDB local
  Future<void> syncWithBackend() async {
    try {
      final remoteStudents = await _api.fetchStudents();
      _students.clear();
      _students.addAll(remoteStudents);
      notifyListeners();
    } catch (e) {
      debugPrint('Mode hors-ligne / Erreur Spring Boot : $e');
    }
  }

  final List<Student> _students = [];

  List<Student> get students => List.unmodifiable(_students);

  // Statistiques en direct
  int get totalCount => _students.length;
  int get activeCount => _students.where((s) => s.statut == StudentStatus.actif).length;
  int get suspendedCount => _students.where((s) => s.statut == StudentStatus.suspendu).length;
  int get graduatedCount => _students.where((s) => s.statut == StudentStatus.diplome).length;

  List<String> get availableFilieres => [
    'Génie Logiciel',
    'Intelligence Artificielle & Data',
    'Systèmes & Réseaux Informatiques',
    'Cybersécurité',
    'Management des SI',
  ];

  List<String> get availableNiveaux => [
    'Licence 1 (L1)',
    'Licence 2 (L2)',
    'Licence 3 (L3)',
    'Master 1 (M1)',
    'Master 2 (M2)',
  ];

  List<String> getClassesForFiliere(String filiere) {
    switch (filiere) {
      case 'Génie Logiciel':
        return ['L3-GL-A', 'L3-GL-B', 'M1-GL', 'M2-GL'];
      case 'Intelligence Artificielle & Data':
        return ['L3-IA-A', 'M1-DS', 'M2-IA'];
      case 'Systèmes & Réseaux Informatiques':
        return ['L2-SRI', 'L3-SRI-A', 'M1-SRI'];
      case 'Cybersécurité':
        return ['M1-CYBER', 'M2-CYBER'];
      case 'Management des SI':
        return ['L3-MSI', 'M1-MSI', 'M2-MSI'];
      default:
        return ['L1-COMMUN', 'L2-INFO'];
    }
  }

  // --- Règles de gestion & Validations ---

  /// Règle : Le matricule étudiant doit être unique
  bool isMatriculeUnique(String matricule, {String? excludeStudentId}) {
    final clean = matricule.trim().toUpperCase();
    return !_students.any((s) => s.id != excludeStudentId && s.matricule.toUpperCase() == clean);
  }

  /// Règle : Une adresse email ne peut pas être associée à deux comptes actifs
  bool isEmailAvailable(String email, {String? excludeStudentId, StudentStatus status = StudentStatus.actif}) {
    if (status != StudentStatus.actif) return true;
    final clean = email.trim().toLowerCase();
    return !_students.any((s) =>
        s.id != excludeStudentId &&
        s.statut == StudentStatus.actif &&
        s.email.toLowerCase() == clean);
  }

  /// Générateur de prochain matricule
  String generateNextMatricule() {
    final year = DateTime.now().year;
    final count = _students.length + 1;
    final seq = count.toString().padLeft(3, '0');
    return 'ETU-$year-$seq';
  }

  // --- CRUD Opérations ---

  Future<void> addStudent(Student student) async {
    // Vérification des règles de gestion
    if (!isMatriculeUnique(student.matricule)) {
      throw Exception('Le matricule ${student.matricule} est déjà attribué à un autre étudiant.');
    }
    if (!isEmailAvailable(student.email, status: student.statut)) {
      throw Exception('L\'adresse email ${student.email} est déjà active sur un autre compte.');
    }
    if (student.classe.trim().isEmpty) {
      throw Exception('Un étudiant doit obligatoirement être rattaché à une classe.');
    }

    var created = student;
    if (ApiConfig.useOnlineBackend) {
      try {
        created = await _api.createStudent(student);
      } on ApiBusinessException {
        rethrow;
      } catch (e) {
        debugPrint('Création locale (API indisponible) : $e');
      }
    }

    _students.insert(0, created);
    notifyListeners();
  }

  Future<void> updateStudent(Student student) async {
    final index = _students.indexWhere((s) => s.id == student.id);
    if (index == -1) throw Exception('Étudiant introuvable.');

    if (!isMatriculeUnique(student.matricule, excludeStudentId: student.id)) {
      throw Exception('Le matricule ${student.matricule} existe déjà.');
    }
    if (!isEmailAvailable(student.email, excludeStudentId: student.id, status: student.statut)) {
      throw Exception('Cette adresse email est déjà utilisée par un compte actif.');
    }

    var updated = student;
    if (ApiConfig.useOnlineBackend) {
      try {
        updated = await _api.updateStudent(student);
      } on ApiBusinessException {
        rethrow;
      } catch (e) {
        debugPrint('Mise à jour locale (API indisponible) : $e');
      }
    }

    _students[index] = updated;
    notifyListeners();
  }

  Future<void> updateStatus(String id, StudentStatus newStatus) async {
    final index = _students.indexWhere((s) => s.id == id);
    if (index == -1) return;

    final current = _students[index];
    if (newStatus == StudentStatus.actif) {
      if (!isEmailAvailable(current.email, excludeStudentId: current.id, status: newStatus)) {
        throw Exception('Impossible de réactiver : email déjà lié à un autre compte actif.');
      }
    }

    if (ApiConfig.useOnlineBackend) {
      try {
        await _api.updateStatus(id, newStatus);
      } on ApiBusinessException {
        rethrow;
      } catch (e) {
        debugPrint('Changement statut local (API indisponible) : $e');
      }
    }

    _students[index] = current.copyWith(statut: newStatus);
    notifyListeners();
  }

  Future<void> deleteStudent(String id) async {
    if (ApiConfig.useOnlineBackend) {
      try {
        await _api.deleteStudent(id);
      } on ApiBusinessException {
        rethrow;
      } catch (e) {
        debugPrint('Suppression locale (API indisponible) : $e');
      }
    }

    _students.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  Student? getById(String id) {
    try {
      return _students.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  // --- Recherche & Filtres ---

  List<Student> filterStudents({
    String query = '',
    StudentStatus? statusFilter,
    String? filiereFilter,
    String? classeFilter,
    String sortBy = 'name_asc', // 'name_asc', 'name_desc', 'matricule', 'date'
  }) {
    var result = List<Student>.from(_students);

    // Recherche par texte
    if (query.trim().isNotEmpty) {
      final q = query.toLowerCase().trim();
      result = result.where((s) {
        return s.nom.toLowerCase().contains(q) ||
            s.prenom.toLowerCase().contains(q) ||
            s.matricule.toLowerCase().contains(q) ||
            s.email.toLowerCase().contains(q) ||
            s.classe.toLowerCase().contains(q);
      }).toList();
    }

    // Filtre statut
    if (statusFilter != null) {
      result = result.where((s) => s.statut == statusFilter).toList();
    }

    // Filtre filière
    if (filiereFilter != null && filiereFilter.isNotEmpty && filiereFilter != 'Toutes') {
      result = result.where((s) => s.filiere == filiereFilter).toList();
    }

    // Filtre classe
    if (classeFilter != null && classeFilter.isNotEmpty && classeFilter != 'Toutes') {
      result = result.where((s) => s.classe == classeFilter).toList();
    }

    // Tri
    switch (sortBy) {
      case 'name_asc':
        result.sort((a, b) => a.nom.compareTo(b.nom));
        break;
      case 'name_desc':
        result.sort((a, b) => b.nom.compareTo(a.nom));
        break;
      case 'matricule':
        result.sort((a, b) => a.matricule.compareTo(b.matricule));
        break;
      case 'date':
        result.sort((a, b) => b.dateCreation.compareTo(a.dateCreation));
        break;
    }

    return result;
  }

  // --- Initialisation des données de test pour la soutenance ---
  void _initSeedData() {
    _students.addAll([
      Student(
        id: 'std_01',
        matricule: 'ETU-2026-001',
        nom: 'Benali',
        prenom: 'Yasmine',
        dateNaissance: DateTime(2003, 4, 15),
        email: 'yasmine.benali@unimanager.edu',
        telephone: '+212 6 12 34 56 78',
        filiere: 'Génie Logiciel',
        niveau: 'Licence 3 (L3)',
        classe: 'L3-GL-A',
        statut: StudentStatus.actif,
        genre: 'F',
        adresse: 'Résidence Universitaire Al-Amal, Bâtiment C',
        documents: [
          StudentDocument(
            id: 'doc_1',
            title: 'Carte Nationale d\'Identité (CNIE)',
            category: 'Identité',
            fileName: 'cnie_yasmine_benali.pdf',
            uploadDate: DateTime(2025, 9, 2),
            isVerified: true,
          ),
          StudentDocument(
            id: 'doc_2',
            title: 'Attestation du Baccalauréat Scientifique',
            category: 'Baccalauréat',
            fileName: 'bac_scientifique_2022.pdf',
            uploadDate: DateTime(2025, 9, 2),
            isVerified: true,
          ),
          StudentDocument(
            id: 'doc_3',
            title: 'Certificat d\'Aptitude Médicale',
            category: 'Médical',
            fileName: 'certificat_medical_2025.pdf',
            uploadDate: DateTime(2025, 9, 5),
            isVerified: true,
          ),
        ],
        historique: [
          AcademicYearRecord(
            academicYear: '2023-2024',
            level: 'Licence 1',
            className: 'L1-INFO-C',
            average: 15.65,
            mention: 'Bien',
            decision: 'Admis',
          ),
          AcademicYearRecord(
            academicYear: '2024-2025',
            level: 'Licence 2',
            className: 'L2-INFO-A',
            average: 16.20,
            mention: 'Très Bien',
            decision: 'Admis (Major de promotion)',
          ),
        ],
      ),
      Student(
        id: 'std_02',
        matricule: 'ETU-2026-002',
        nom: 'El Amrani',
        prenom: 'Karim',
        dateNaissance: DateTime(2002, 11, 20),
        email: 'karim.elamrani@unimanager.edu',
        telephone: '+212 6 98 76 54 32',
        filiere: 'Intelligence Artificielle & Data',
        niveau: 'Master 1 (M1)',
        classe: 'M1-DS',
        statut: StudentStatus.actif,
        genre: 'M',
        adresse: '12 Avenue des Nations Unies, Quartier Agdal',
        documents: [
          StudentDocument(
            id: 'doc_4',
            title: 'Licence Fondamentale en Informatique',
            category: 'Attestation',
            fileName: 'diplome_licence_info.pdf',
            uploadDate: DateTime(2025, 9, 10),
            isVerified: true,
          ),
          StudentDocument(
            id: 'doc_5',
            title: 'Relevé des Notes S1-S6',
            category: 'Attestation',
            fileName: 'releves_s1_s6.pdf',
            uploadDate: DateTime(2025, 9, 10),
            isVerified: true,
          ),
        ],
        historique: [
          AcademicYearRecord(
            academicYear: '2024-2025',
            level: 'Licence 3',
            className: 'L3-INFO-B',
            average: 14.90,
            mention: 'Bien',
            decision: 'Admis en Master',
          ),
        ],
      ),
      Student(
        id: 'std_03',
        matricule: 'ETU-2026-003',
        nom: 'Tazi',
        prenom: 'Salma',
        dateNaissance: DateTime(2004, 2, 8),
        email: 'salma.tazi@unimanager.edu',
        telephone: '+212 6 55 44 33 22',
        filiere: 'Systèmes & Réseaux Informatiques',
        niveau: 'Licence 2 (L2)',
        classe: 'L2-SRI',
        statut: StudentStatus.actif,
        genre: 'F',
        adresse: '45 Rue Ibn Battouta',
        documents: [
          StudentDocument(
            id: 'doc_6',
            title: 'Carte d\'Identité Nationale',
            category: 'Identité',
            fileName: 'cnie_salma.pdf',
            uploadDate: DateTime(2025, 9, 15),
            isVerified: true,
          ),
        ],
        historique: [
          AcademicYearRecord(
            academicYear: '2024-2025',
            level: 'Licence 1',
            className: 'L1-INFO-A',
            average: 13.50,
            mention: 'Assez Bien',
            decision: 'Admis',
          ),
        ],
      ),
      Student(
        id: 'std_04',
        matricule: 'ETU-2026-004',
        nom: 'Mansouri',
        prenom: 'Omar',
        dateNaissance: DateTime(2001, 7, 30),
        email: 'omar.mansouri@unimanager.edu',
        telephone: '+212 6 22 11 00 99',
        filiere: 'Cybersécurité',
        niveau: 'Master 2 (M2)',
        classe: 'M2-CYBER',
        statut: StudentStatus.diplome,
        genre: 'M',
        adresse: '88 Boulevard Hassan II',
        documents: [
          StudentDocument(
            id: 'doc_7',
            title: 'Attestation de Réussite Finale',
            category: 'Attestation',
            fileName: 'attestation_reussite_m2.pdf',
            uploadDate: DateTime(2025, 7, 10),
            isVerified: true,
          ),
        ],
        historique: [
          AcademicYearRecord(
            academicYear: '2024-2025',
            level: 'Master 2',
            className: 'M2-CYBER',
            average: 17.10,
            mention: 'Très Bien',
            decision: 'Diplômé avec Félicitations du Jury',
          ),
        ],
      ),
      Student(
        id: 'std_05',
        matricule: 'ETU-2026-005',
        nom: 'Chraibi',
        prenom: 'Mehdi',
        dateNaissance: DateTime(2003, 10, 12),
        email: 'mehdi.chraibi@unimanager.edu',
        telephone: '+212 6 77 88 99 00',
        filiere: 'Génie Logiciel',
        niveau: 'Licence 3 (L3)',
        classe: 'L3-GL-B',
        statut: StudentStatus.suspendu,
        genre: 'M',
        adresse: 'Résidence Universitaire Al-Amal, Bâtiment B',
        documents: [
          StudentDocument(
            id: 'doc_8',
            title: 'Demande de Suspension Académique Temporaire',
            category: 'Administratif',
            fileName: 'demande_suspension_medicale.pdf',
            uploadDate: DateTime(2025, 10, 5),
            isVerified: true,
          ),
        ],
        historique: [
          AcademicYearRecord(
            academicYear: '2023-2024',
            level: 'Licence 1',
            className: 'L1-INFO-B',
            average: 12.00,
            mention: 'Passable',
            decision: 'Admis',
          ),
        ],
      ),
      Student(
        id: 'std_06',
        matricule: 'ETU-2026-006',
        nom: 'Berrada',
        prenom: 'Amina',
        dateNaissance: DateTime(2003, 5, 25),
        email: 'amina.berrada@unimanager.edu',
        telephone: '+212 6 43 21 87 65',
        filiere: 'Management des SI',
        niveau: 'Master 1 (M1)',
        classe: 'M1-MSI',
        statut: StudentStatus.actif,
        genre: 'F',
        adresse: '33 Avenue Mohammed VI',
        documents: [],
        historique: [],
      ),
    ]);
  }
}
