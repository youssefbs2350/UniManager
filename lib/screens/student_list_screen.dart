import 'package:flutter/material.dart';
import '../models/student_model.dart';
import '../services/student_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_chips.dart';
import '../widgets/stat_card.dart';
import 'student_detail_screen.dart';
import 'student_form_screen.dart';

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  final StudentRepository _repo = StudentRepository();
  final TextEditingController _searchController = TextEditingController();

  StudentStatus? _selectedStatusFilter;
  String? _selectedFiliereFilter;
  String _currentSort = 'name_asc';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showSortDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Trier la liste par',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildSortOption('Nom (A à Z)', 'name_asc'),
              _buildSortOption('Nom (Z à A)', 'name_desc'),
              _buildSortOption('Numéro de matricule', 'matricule'),
              _buildSortOption('Date d\'inscription récente', 'date'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSortOption(String label, String sortKey) {
    final isSelected = _currentSort == sortKey;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? AppTheme.primaryBlue : Colors.black87,
        ),
      ),
      trailing: isSelected ? const Icon(Icons.check, color: AppTheme.primaryBlue) : null,
      onTap: () {
        setState(() => _currentSort = sortKey);
        Navigator.pop(context);
      },
    );
  }

  void _showFiliereFilterDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filtrer par filière',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Toutes les filières'),
                trailing: _selectedFiliereFilter == null ? const Icon(Icons.check, color: AppTheme.primaryBlue) : null,
                onTap: () {
                  setState(() => _selectedFiliereFilter = null);
                  Navigator.pop(ctx);
                },
              ),
              ..._repo.availableFilieres.map((filiere) {
                final isSelected = _selectedFiliereFilter == filiere;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(filiere),
                  trailing: isSelected ? const Icon(Icons.check, color: AppTheme.primaryBlue) : null,
                  onTap: () {
                    setState(() => _selectedFiliereFilter = filiere);
                    Navigator.pop(ctx);
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _repo,
      builder: (context, _) {
        final filteredStudents = _repo.filterStudents(
          query: _searchController.text,
          statusFilter: _selectedStatusFilter,
          filiereFilter: _selectedFiliereFilter,
          sortBy: _currentSort,
        );

        return Scaffold(
          appBar: AppBar(
            title: const Text('Gestion des Étudiants'),
            actions: [
              IconButton(
                icon: const Icon(Icons.sort_rounded),
                tooltip: 'Trier',
                onPressed: _showSortDialog,
              ),
              IconButton(
                icon: Icon(
                  Icons.filter_alt_outlined,
                  color: _selectedFiliereFilter != null ? AppTheme.primaryBlue : null,
                ),
                tooltip: 'Filtrer par filière',
                onPressed: _showFiliereFilterDialog,
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: AppTheme.primaryBlue,
            icon: const Icon(Icons.person_add, color: Colors.white),
            label: const Text('Nouvel étudiant', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StudentFormScreen()),
              );
            },
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              await _repo.syncWithBackend();
              if (mounted) setState(() {});
            },
            child: CustomScrollView(
              slivers: [
                // 1. Statistiques KPIs horizontales
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            title: 'Effectif Total',
                            value: '${_repo.totalCount}',
                            icon: Icons.people_alt_outlined,
                            color: AppTheme.primaryBlue,
                            onTap: () => setState(() => _selectedStatusFilter = null),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: StatCard(
                            title: 'Inscrits Actifs',
                            value: '${_repo.activeCount}',
                            icon: Icons.check_circle_outline,
                            color: AppTheme.statusActive,
                            onTap: () => setState(() => _selectedStatusFilter = StudentStatus.actif),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: StatCard(
                            title: 'Diplômés',
                            value: '${_repo.graduatedCount}',
                            icon: Icons.school_outlined,
                            color: AppTheme.statusGraduated,
                            onTap: () => setState(() => _selectedStatusFilter = StudentStatus.diplome),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 2. Barre de recherche
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Rechercher par nom, matricule, classe...',
                        prefixIcon: const Icon(Icons.search, color: Color(0xFF64748B)),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 20),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {});
                                },
                              )
                            : null,
                      ),
                    ),
                  ),
                ),

                // 3. Puces de filtrage rapide du statut
                SliverToBoxAdapter(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        FilterChip(
                          label: const Text('Tous'),
                          selected: _selectedStatusFilter == null,
                          onSelected: (_) => setState(() => _selectedStatusFilter = null),
                          selectedColor: AppTheme.primaryBlue.withOpacity(0.15),
                          checkmarkColor: AppTheme.primaryBlue,
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: const Text('Actifs'),
                          selected: _selectedStatusFilter == StudentStatus.actif,
                          onSelected: (_) => setState(() => _selectedStatusFilter = StudentStatus.actif),
                          selectedColor: AppTheme.statusActive.withOpacity(0.15),
                          checkmarkColor: AppTheme.statusActive,
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: const Text('Suspendus'),
                          selected: _selectedStatusFilter == StudentStatus.suspendu,
                          onSelected: (_) => setState(() => _selectedStatusFilter = StudentStatus.suspendu),
                          selectedColor: AppTheme.statusSuspended.withOpacity(0.15),
                          checkmarkColor: AppTheme.statusSuspended,
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: const Text('Diplômés'),
                          selected: _selectedStatusFilter == StudentStatus.diplome,
                          onSelected: (_) => setState(() => _selectedStatusFilter = StudentStatus.diplome),
                          selectedColor: AppTheme.statusGraduated.withOpacity(0.15),
                          checkmarkColor: AppTheme.statusGraduated,
                        ),
                        if (_selectedFiliereFilter != null) ...[
                          const SizedBox(width: 8),
                          InputChip(
                            label: Text(_selectedFiliereFilter!),
                            onDeleted: () => setState(() => _selectedFiliereFilter = null),
                            deleteIconColor: AppTheme.primaryBlue,
                            backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // 4. Nombre de résultats
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    child: Text(
                      '${filteredStudents.length} étudiant${filteredStudents.length > 1 ? 's' : ''} trouvé${filteredStudents.length > 1 ? 's' : ''}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                ),

                // 5. Liste des étudiants ou État Vide
                filteredStudents.isEmpty
                    ? SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.shade400),
                              const SizedBox(height: 16),
                              const Text(
                                'Aucun étudiant ne correspond aux critères',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF475569),
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Modifiez vos filtres ou effectuez une autre recherche.',
                                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                              ),
                              const SizedBox(height: 16),
                              OutlinedButton(
                                onPressed: () {
                                  setState(() {
                                    _searchController.clear();
                                    _selectedStatusFilter = null;
                                    _selectedFiliereFilter = null;
                                  });
                                },
                                child: const Text('Réinitialiser les filtres'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 6, 16, 80),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final student = filteredStudents[index];
                              return _buildStudentCard(student);
                            },
                            childCount: filteredStudents.length,
                          ),
                        ),
                      ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStudentCard(Student student) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StudentDetailScreen(studentId: student.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                    child: Text(
                      '${student.prenom[0]}${student.nom[0]}',
                      style: const TextStyle(
                        color: AppTheme.primaryBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                student.nomComplet,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            StatusBadge(status: student.statut, isCompact: true),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                student.matricule,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF475569),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              student.classe,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.secondaryCyan,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(height: 1, color: AppTheme.cardBorder),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${student.filiere} • ${student.niveau}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFF94A3B8)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
