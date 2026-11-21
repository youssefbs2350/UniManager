enum StudentStatus {
  actif,
  suspendu,
  diplome;

  String get label {
    switch (this) {
      case StudentStatus.actif:
        return 'Actif';
      case StudentStatus.suspendu:
        return 'Suspendu';
      case StudentStatus.diplome:
        return 'Diplômé';
    }
  }
}

class StudentDocument {
  final String id;
  final String title;
  final String category; // 'Identité', 'Baccalauréat', 'Attestation', 'Médical'
  final String fileName;
  final DateTime uploadDate;
  final bool isVerified;

  StudentDocument({
    required this.id,
    required this.title,
    required this.category,
    required this.fileName,
    required this.uploadDate,
    this.isVerified = true,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'category': category,
    'file_name': fileName,
    'upload_date': uploadDate.toIso8601String(),
    'is_verified': isVerified,
  };

  factory StudentDocument.fromMap(Map<String, dynamic> map) => StudentDocument(
    id: map['id'],
    title: map['title'],
    category: map['category'],
    fileName: map['file_name'],
    uploadDate: DateTime.parse(map['upload_date']),
    isVerified: map['is_verified'] ?? false,
  );
}

class AcademicYearRecord {
  final String academicYear; // e.g. "2024-2025"
  final String level; // "L2"
  final String className; // "L2 INFO-B"
  final double average; // e.g. 14.85
  final String mention; // "Bien"
  final String decision; // "Admis", "Ajourné"

  AcademicYearRecord({
    required this.academicYear,
    required this.level,
    required this.className,
    required this.average,
    required this.mention,
    required this.decision,
  });

  Map<String, dynamic> toMap() => {
    'academic_year': academicYear,
    'level': level,
    'class_name': className,
    'average': average,
    'mention': mention,
    'decision': decision,
  };

  factory AcademicYearRecord.fromMap(Map<String, dynamic> map) => AcademicYearRecord(
    academicYear: map['academic_year'],
    level: map['level'],
    className: map['class_name'],
    average: (map['average'] as num).toDouble(),
    mention: map['mention'],
    decision: map['decision'],
  );
}

class Student {
  final String id;
  final String matricule; // Unique (ex: ETU-2026-0101)
  final String nom;
  final String prenom;
  final DateTime dateNaissance;
  final String email; // Unique parmi les comptes actifs
  final String telephone;
  final String filiere; // e.g. "Génie Logiciel"
  final String niveau; // e.g. "Licence 3"
  final String classe; // e.g. "L3 INFO-A"
  final StudentStatus statut;
  final String? avatarUrl;
  final String genre; // 'M' ou 'F'
  final String adresse;
  final List<StudentDocument> documents;
  final List<AcademicYearRecord> historique;
  final DateTime dateCreation;

  Student({
    required this.id,
    required this.matricule,
    required this.nom,
    required this.prenom,
    required this.dateNaissance,
    required this.email,
    required this.telephone,
    required this.filiere,
    required this.niveau,
    required this.classe,
    required this.statut,
    this.avatarUrl,
    this.genre = 'M',
    this.adresse = 'Campus Universitaire',
    this.documents = const [],
    this.historique = const [],
    DateTime? dateCreation,
  }) : dateCreation = dateCreation ?? DateTime.now();

  String get nomComplet => '$prenom $nom';

  Student copyWith({
    String? id,
    String? matricule,
    String? nom,
    String? prenom,
    DateTime? dateNaissance,
    String? email,
    String? telephone,
    String? filiere,
    String? niveau,
    String? classe,
    StudentStatus? statut,
    String? avatarUrl,
    String? genre,
    String? adresse,
    List<StudentDocument>? documents,
    List<AcademicYearRecord>? historique,
  }) {
    return Student(
      id: id ?? this.id,
      matricule: matricule ?? this.matricule,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      dateNaissance: dateNaissance ?? this.dateNaissance,
      email: email ?? this.email,
      telephone: telephone ?? this.telephone,
      filiere: filiere ?? this.filiere,
      niveau: niveau ?? this.niveau,
      classe: classe ?? this.classe,
      statut: statut ?? this.statut,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      genre: genre ?? this.genre,
      adresse: adresse ?? this.adresse,
      documents: documents ?? this.documents,
      historique: historique ?? this.historique,
      dateCreation: dateCreation,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'matricule': matricule,
    'nom': nom,
    'prenom': prenom,
    'date_naissance': dateNaissance.toIso8601String(),
    'email': email,
    'telephone': telephone,
    'filiere': filiere,
    'niveau': niveau,
    'classe': classe,
    'statut': statut.name,
    'avatar_url': avatarUrl,
    'genre': genre,
    'adresse': adresse,
    'documents': documents.map((d) => d.toMap()).toList(),
    'historique': historique.map((h) => h.toMap()).toList(),
    'created_at': dateCreation.toIso8601String(),
  };

  factory Student.fromMap(Map<String, dynamic> map) => Student(
    id: map['id'],
    matricule: map['matricule'],
    nom: map['nom'],
    prenom: map['prenom'],
    dateNaissance: DateTime.parse(map['date_naissance']),
    email: map['email'],
    telephone: map['telephone'],
    filiere: map['filiere'],
    niveau: map['niveau'],
    classe: map['classe'],
    statut: StudentStatus.values.firstWhere(
      (s) => s.name == map['statut'],
      orElse: () => StudentStatus.actif,
    ),
    avatarUrl: map['avatar_url'],
    genre: map['genre'] ?? 'M',
    adresse: map['adresse'] ?? '',
    documents: (map['documents'] as List<dynamic>?)
            ?.map((d) => StudentDocument.fromMap(d))
            .toList() ??
        [],
    historique: (map['historique'] as List<dynamic>?)
            ?.map((h) => AcademicYearRecord.fromMap(h))
            .toList() ??
        [],
    dateCreation: DateTime.parse(map['created_at']),
  );
}
