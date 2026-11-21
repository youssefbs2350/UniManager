import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/student_model.dart';
import '../services/student_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_chips.dart';
import 'student_form_screen.dart';

class StudentDetailScreen extends StatefulWidget {
  final String studentId;

  const StudentDetailScreen({super.key, required this.studentId});

  @override
  State<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final StudentRepository _repo = StudentRepository();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showChangeStatusDialog(Student student) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Modifier le statut administratif',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Sélectionnez le nouveau statut pour cet étudiant selon les règles de scolarité :',
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                ),
                const SizedBox(height: 20),
                ...StudentStatus.values.map((status) {
                  final isCurrent = student.statut == status;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isCurrent ? AppTheme.primaryBlue : AppTheme.cardBorder,
                        width: isCurrent ? 2 : 1,
                      ),
                    ),
                    child: ListTile(
                      leading: StatusBadge(status: status, isCompact: true),
                      title: Text(
                        status.label,
                        style: TextStyle(
                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                        ),
                      ),
                      trailing: isCurrent
                          ? const Icon(Icons.check, color: AppTheme.primaryBlue)
                          : null,
                      onTap: () async {
                        final nav = Navigator.of(ctx);
                        final messenger = ScaffoldMessenger.of(context);
                        try {
                          await _repo.updateStatus(student.id, status);
                          nav.pop();
                          if (mounted) setState(() {});
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text('Statut mis à jour : ${status.label}'),
                              backgroundColor: AppTheme.statusActive,
                            ),
                          );
                        } catch (e) {
                          nav.pop();
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(e.toString().replaceAll('Exception: ', '')),
                              backgroundColor: AppTheme.statusError,
                            ),
                          );
                        }
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDelete(Student student) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text(
          'Voulez-vous supprimer définitivement le dossier de ${student.nomComplet} (${student.matricule}) ? Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.statusError),
            onPressed: () async {
              final dialogNav = Navigator.of(ctx);
              final rootNav = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              await _repo.deleteStudent(student.id);
              dialogNav.pop();
              rootNav.pop();
              messenger.showSnackBar(
                const SnackBar(content: Text('Dossier étudiant supprimé avec succès')),
              );
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _repo,
      builder: (context, _) {
        final student = _repo.getById(widget.studentId);
        if (student == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Dossier introuvable')),
            body: const Center(child: Text('L\'étudiant recherché n\'existe plus.')),
          );
        }

        return Scaffold(
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  expandedHeight: 280,
                  pinned: true,
                  title: innerBoxIsScrolled ? Text(student.nomComplet) : null,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      tooltip: 'Modifier le dossier',
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => StudentFormScreen(studentToEdit: student),
                          ),
                        );
                        setState(() {});
                      },
                    ),
                    PopupMenuButton<String>(
                      onSelected: (val) {
                        if (val == 'status') {
                          _showChangeStatusDialog(student);
                        } else if (val == 'delete') {
                          _confirmDelete(student);
                        }
                      },
                      itemBuilder: (ctx) => [
                        const PopupMenuItem(
                          value: 'status',
                          child: Row(
                            children: [
                              Icon(Icons.swap_horiz, size: 20),
                              SizedBox(width: 10),
                              Text('Changer le statut'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline, size: 20, color: Colors.red),
                              SizedBox(width: 10),
                              Text('Supprimer le dossier', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFF1E3A8A),
                            Color(0xFF0F172A),
                          ],
                        ),
                      ),
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 48, 20, 16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 42,
                                backgroundColor: Colors.white,
                                child: CircleAvatar(
                                  radius: 39,
                                  backgroundColor: AppTheme.secondaryCyan.withOpacity(0.2),
                                  child: Text(
                                    '${student.prenom[0]}${student.nom[0]}',
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryBlue,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                student.nomComplet,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      Clipboard.setData(ClipboardData(text: student.matricule));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Matricule copié dans le presse-papier'),
                                          duration: Duration(seconds: 1),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            student.matricule,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          const Icon(Icons.copy, size: 12, color: Colors.white70),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  StatusBadge(status: student.statut, isCompact: true),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  bottom: TabBar(
                    controller: _tabController,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white60,
                    indicatorColor: AppTheme.secondaryCyan,
                    indicatorWeight: 3,
                    tabs: const [
                      Tab(text: 'Informations'),
                      Tab(text: 'Parcours'),
                      Tab(text: 'Documents'),
                    ],
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildInfoTab(student),
                _buildHistoryTab(student),
                _buildDocumentsTab(student),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoTab(Student student) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Carte Affectation Académique
        _buildSectionCard(
          title: 'Affectation Académique',
          icon: Icons.school_outlined,
          children: [
            _buildDetailRow('Filière', student.filiere, isBold: true),
            _buildDetailRow('Niveau', student.niveau),
            _buildDetailRow('Classe / Groupe', student.classe, highlight: true),
            _buildDetailRow('Statut de scolarité', student.statut.label),
          ],
        ),
        const SizedBox(height: 16),

        // Carte Coordonnées & Contact
        _buildSectionCard(
          title: 'Coordonnées & Contact',
          icon: Icons.contact_mail_outlined,
          children: [
            _buildDetailRow('Email institutionnel', student.email),
            _buildDetailRow('Téléphone mobile', student.telephone),
            _buildDetailRow('Adresse de résidence', student.adresse),
          ],
        ),
        const SizedBox(height: 16),

        // Carte État Civil
        _buildSectionCard(
          title: 'État Civil',
          icon: Icons.person_outline,
          children: [
            _buildDetailRow('Nom', student.nom),
            _buildDetailRow('Prénom', student.prenom),
            _buildDetailRow('Genre', student.genre == 'M' ? 'Masculin' : 'Féminin'),
            _buildDetailRow(
              'Date de naissance',
              '${student.dateNaissance.day.toString().padLeft(2, '0')}/${student.dateNaissance.month.toString().padLeft(2, '0')}/${student.dateNaissance.year}',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHistoryTab(Student student) {
    if (student.historique.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_edu, size: 56, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            const Text(
              'Aucun historique antérieur',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 4),
            const Text(
              'L\'étudiant est en cours de sa première année d\'inscription.',
              style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: student.historique.length,
      itemBuilder: (context, index) {
        final item = student.historique[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.academicYear,
                        style: const TextStyle(
                          color: AppTheme.primaryBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Moyenne : ${item.average.toStringAsFixed(2)} / 20',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '${item.level} - ${item.className}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      'Mention : ${item.mention}',
                      style: const TextStyle(color: Color(0xFF475569), fontSize: 13),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Décision : ${item.decision}',
                      style: const TextStyle(
                        color: AppTheme.primaryBlue,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDocumentsTab(Student student) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryBlue,
        icon: const Icon(Icons.upload_file, color: Colors.white),
        label: const Text('Ajouter un document', style: TextStyle(color: Colors.white)),
        onPressed: () {
          _showUploadDocumentDialog(student);
        },
      ),
      body: student.documents.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_open_outlined, size: 56, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  const Text(
                    'Aucun document administratif',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Appuyez sur "Ajouter" pour téléverser une pièce.',
                    style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              itemCount: student.documents.length,
              itemBuilder: (context, index) {
                final doc = student.documents[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 24),
                    ),
                    title: Text(
                      doc.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          '${doc.fileName} • ${doc.category}',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Déposé le ${doc.uploadDate.day}/${doc.uploadDate.month}/${doc.uploadDate.year}',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                        ),
                      ],
                    ),
                    trailing: doc.isVerified
                        ? const Tooltip(
                            message: 'Document vérifié et validé',
                            child: Icon(Icons.verified, color: Colors.teal, size: 22),
                          )
                        : const Tooltip(
                            message: 'En cours de validation',
                            child: Icon(Icons.pending, color: Colors.amber, size: 22),
                          ),
                  ),
                );
              },
            ),
    );
  }

  void _showUploadDocumentDialog(Student student) {
    final titleController = TextEditingController();
    String category = 'Identité';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Téléverser un document'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Titre du document',
                  hintText: 'Ex: Attestation de scolarité',
                ),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: category,
                decoration: const InputDecoration(labelText: 'Catégorie'),
                items: ['Identité', 'Baccalauréat', 'Attestation', 'Médical', 'Autre']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setDialogState(() => category = val);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.trim().isEmpty) return;
                final newDoc = StudentDocument(
                  id: 'doc_${DateTime.now().millisecondsSinceEpoch}',
                  title: titleController.text.trim(),
                  category: category,
                  fileName: '${titleController.text.trim().toLowerCase().replaceAll(' ', '_')}.pdf',
                  uploadDate: DateTime.now(),
                  isVerified: true,
                );
                final updatedList = List<StudentDocument>.from(student.documents)..add(newDoc);
                _repo.updateStudent(student.copyWith(documents: updatedList));
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Document téléversé avec succès')),
                );
              },
              child: const Text('Téléverser'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false, bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isBold || highlight ? FontWeight.bold : FontWeight.w500,
                color: highlight ? AppTheme.primaryBlue : const Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
