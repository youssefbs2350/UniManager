import 'package:flutter/material.dart';
import '../models/student_model.dart';
import '../services/student_repository.dart';
import '../theme/app_theme.dart';

class StudentFormScreen extends StatefulWidget {
  final Student? studentToEdit;

  const StudentFormScreen({super.key, this.studentToEdit});

  @override
  State<StudentFormScreen> createState() => _StudentFormScreenState();
}

class _StudentFormScreenState extends State<StudentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final StudentRepository _repo = StudentRepository();

  late TextEditingController _matriculeController;
  late TextEditingController _nomController;
  late TextEditingController _prenomController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _adresseController;

  DateTime? _selectedDateNaissance;
  String _selectedFiliere = 'Génie Logiciel';
  String _selectedNiveau = 'Licence 3 (L3)';
  String? _selectedClasse;
  StudentStatus _selectedStatus = StudentStatus.actif;
  String _selectedGenre = 'M';

  bool get isEditing => widget.studentToEdit != null;

  @override
  void initState() {
    super.initState();
    final s = widget.studentToEdit;
    if (s != null) {
      _matriculeController = TextEditingController(text: s.matricule);
      _nomController = TextEditingController(text: s.nom);
      _prenomController = TextEditingController(text: s.prenom);
      _emailController = TextEditingController(text: s.email);
      _phoneController = TextEditingController(text: s.telephone);
      _adresseController = TextEditingController(text: s.adresse);
      _selectedDateNaissance = s.dateNaissance;
      _selectedFiliere = s.filiere;
      _selectedNiveau = s.niveau;
      _selectedClasse = s.classe;
      _selectedStatus = s.statut;
      _selectedGenre = s.genre;
    } else {
      _matriculeController = TextEditingController(text: _repo.generateNextMatricule());
      _nomController = TextEditingController();
      _prenomController = TextEditingController();
      _emailController = TextEditingController();
      _phoneController = TextEditingController();
      _adresseController = TextEditingController();
      _selectedDateNaissance = DateTime(2004, 1, 1);
      final classes = _repo.getClassesForFiliere(_selectedFiliere);
      _selectedClasse = classes.isNotEmpty ? classes.first : null;
    }
  }

  @override
  void dispose() {
    _matriculeController.dispose();
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _adresseController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateNaissance ?? DateTime(2004, 1, 1),
      firstDate: DateTime(1970),
      lastDate: DateTime(now.year - 15), // Doit avoir au moins 15 ans
      helpText: 'Date de naissance de l\'étudiant',
    );
    if (picked != null) {
      setState(() => _selectedDateNaissance = picked);
    }
  }

  Future<void> _saveStudent() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDateNaissance == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner la date de naissance.')),
      );
      return;
    }
    if (_selectedClasse == null || _selectedClasse!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez affecter une classe à l\'étudiant.')),
      );
      return;
    }

    final newStudent = Student(
      id: isEditing ? widget.studentToEdit!.id : 'std_${DateTime.now().millisecondsSinceEpoch}',
      matricule: _matriculeController.text.trim().toUpperCase(),
      nom: _nomController.text.trim(),
      prenom: _prenomController.text.trim(),
      dateNaissance: _selectedDateNaissance!,
      email: _emailController.text.trim(),
      telephone: _phoneController.text.trim(),
      filiere: _selectedFiliere,
      niveau: _selectedNiveau,
      classe: _selectedClasse!,
      statut: _selectedStatus,
      genre: _selectedGenre,
      adresse: _adresseController.text.trim().isEmpty ? 'Campus Universitaire' : _adresseController.text.trim(),
      documents: isEditing ? widget.studentToEdit!.documents : [],
      historique: isEditing ? widget.studentToEdit!.historique : [],
    );

    try {
      if (isEditing) {
        await _repo.updateStudent(newStudent);
      } else {
        await _repo.addStudent(newStudent);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditing ? 'Dossier étudiant mis à jour' : 'Étudiant enregistré avec succès',
            ),
            backgroundColor: AppTheme.statusActive,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppTheme.statusError,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final availableClasses = _repo.getClassesForFiliere(_selectedFiliere);
    if (!availableClasses.contains(_selectedClasse)) {
      _selectedClasse = availableClasses.isNotEmpty ? availableClasses.first : null;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Modifier le dossier' : 'Nouvel Étudiant'),
        actions: [
          TextButton.icon(
            onPressed: _saveStudent,
            icon: const Icon(Icons.check, color: AppTheme.primaryBlue),
            label: const Text(
              'Enregistrer',
              style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Section 1 : Identifiants & État Civil
            _buildSectionHeader('Identité de l\'étudiant', Icons.badge_outlined),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _matriculeController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      labelText: 'Matricule *',
                      hintText: 'ETU-2026-XXX',
                      suffixIcon: isEditing
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.refresh),
                              tooltip: 'Générer matricule',
                              onPressed: () {
                                setState(() {
                                  _matriculeController.text = _repo.generateNextMatricule();
                                });
                              },
                            ),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Matricule requis';
                      if (!_repo.isMatriculeUnique(val, excludeStudentId: widget.studentToEdit?.id)) {
                        return 'Ce matricule existe déjà';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedGenre,
                    decoration: const InputDecoration(labelText: 'Genre'),
                    items: const [
                      DropdownMenuItem(value: 'M', child: Text('Homme')),
                      DropdownMenuItem(value: 'F', child: Text('Femme')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedGenre = val);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _prenomController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(labelText: 'Prénom *'),
                    validator: (val) => val == null || val.trim().isEmpty ? 'Prénom requis' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _nomController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(labelText: 'Nom *'),
                    validator: (val) => val == null || val.trim().isEmpty ? 'Nom requis' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date de naissance *',
                  suffixIcon: Icon(Icons.calendar_today_outlined),
                ),
                child: Text(
                  _selectedDateNaissance != null
                      ? '${_selectedDateNaissance!.day.toString().padLeft(2, '0')}/${_selectedDateNaissance!.month.toString().padLeft(2, '0')}/${_selectedDateNaissance!.year}'
                      : 'Sélectionner la date',
                  style: TextStyle(
                    color: _selectedDateNaissance != null ? Colors.black87 : Colors.grey.shade600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Section 2 : Affectation Pédagogique
            _buildSectionHeader('Affectation pédagogique', Icons.school_outlined),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedFiliere,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Filière *'),
              items: _repo.availableFilieres
                  .map((f) => DropdownMenuItem(value: f, child: Text(f, overflow: TextOverflow.ellipsis)))
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedFiliere = val;
                    final list = _repo.getClassesForFiliere(val);
                    _selectedClasse = list.isNotEmpty ? list.first : null;
                  });
                }
              },
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedNiveau,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Niveau *'),
                    items: _repo.availableNiveaux
                        .map((n) => DropdownMenuItem(value: n, child: Text(n, overflow: TextOverflow.ellipsis)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedNiveau = val);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedClasse,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Classe / Groupe *'),
                    items: availableClasses
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedClasse = val);
                    },
                    validator: (val) => val == null ? 'Classe requise' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<StudentStatus>(
              value: _selectedStatus,
              decoration: const InputDecoration(labelText: 'Statut administratif *'),
              items: StudentStatus.values
                  .map((s) => DropdownMenuItem(value: s, child: Text(s.label)))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedStatus = val);
              },
            ),
            const SizedBox(height: 24),

            // Section 3 : Coordonnées
            _buildSectionHeader('Coordonnées & Contact', Icons.email_outlined),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email institutionnel *',
                hintText: 'prenom.nom@unimanager.edu',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) return 'Email requis';
                final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                if (!emailRegex.hasMatch(val.trim())) return 'Format email invalide';
                if (!_repo.isEmailAvailable(val.trim(),
                    excludeStudentId: widget.studentToEdit?.id,
                    status: _selectedStatus)) {
                  return 'Cet email est déjà utilisé par un compte actif';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Téléphone *',
                hintText: '+212 6 XX XX XX XX',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              validator: (val) => val == null || val.trim().isEmpty ? 'Téléphone requis' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _adresseController,
              decoration: const InputDecoration(
                labelText: 'Adresse de résidence',
                hintText: 'Ex: Cité Universitaire, Bloc B',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
            ),
            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: _saveStudent,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
              child: Text(
                isEditing ? 'Enregistrer les modifications' : 'Créer le dossier étudiant',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryBlue),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}
