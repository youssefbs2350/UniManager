import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_logo.dart';
import 'student_list_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  String _selectedRole = 'Administrateur';

  final List<Map<String, dynamic>> _modules = [
    {
      'id': 1,
      'title': 'Gestion des étudiants',
      'member': 'Membre 1 (Notre partie)',
      'icon': Icons.people_alt_outlined,
      'activeIcon': Icons.people_alt,
      'isImplemented': true,
      'badge': 'Complet & Actif',
      'description': 'CRUD dossiers, inscriptions, affectation classes, fiches & historique',
    },
    {
      'id': 2,
      'title': 'Gestion des enseignants',
      'member': 'Membre 2',
      'icon': Icons.badge_outlined,
      'activeIcon': Icons.badge,
      'isImplemented': false,
      'badge': 'Module Membre 2',
      'description': 'Fiches enseignants, charges horaires, disponibilités & conflits',
    },
    {
      'id': 3,
      'title': 'Cours & Emploi du temps',
      'member': 'Membre 3',
      'icon': Icons.calendar_month_outlined,
      'activeIcon': Icons.calendar_month,
      'isImplemented': false,
      'badge': 'Module Membre 3',
      'description': 'Matières, séances, plannings, salles & détection des chevauchements',
    },
    {
      'id': 4,
      'title': 'Notes & Absences',
      'member': 'Membre 4',
      'icon': Icons.fact_check_outlined,
      'activeIcon': Icons.fact_check,
      'isImplemented': false,
      'badge': 'Module Membre 4',
      'description': 'Évaluations, calcul des moyennes avec coefficients, relevés PDF & assiduité',
    },
    {
      'id': 5,
      'title': 'Admin & Statistiques',
      'member': 'Membre 5',
      'icon': Icons.admin_panel_settings_outlined,
      'activeIcon': Icons.admin_panel_settings,
      'isImplemented': false,
      'badge': 'Module Membre 5',
      'description': 'Authentification, comptes, rôles, filières, tableau de bord & KPIs',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildAppDrawer(),
      body: _currentIndex == 0
          ? const StudentListScreen()
          : _buildPartnerModulePlaceholder(_modules[_currentIndex]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people, color: AppTheme.primaryBlue),
            label: 'Étudiants',
          ),
          NavigationDestination(
            icon: Icon(Icons.badge_outlined),
            selectedIcon: Icon(Icons.badge, color: AppTheme.primaryBlue),
            label: 'Enseignants',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today, color: AppTheme.primaryBlue),
            label: 'Planning',
          ),
          NavigationDestination(
            icon: Icon(Icons.fact_check_outlined),
            selectedIcon: Icon(Icons.fact_check, color: AppTheme.primaryBlue),
            label: 'Notes',
          ),
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard, color: AppTheme.primaryBlue),
            label: 'Admin',
          ),
        ],
      ),
    );
  }

  Widget _buildAppDrawer() {
    return Drawer(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 52, 20, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0F172A), Color(0xFF1E3A8A)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const UniManagerLogo(size: 46, isDarkBackground: true),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.security, size: 14, color: AppTheme.secondaryCyan),
                      const SizedBox(width: 6),
                      Text(
                        'Rôle actuel : $_selectedRole',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'RÉPARTITION DU PROJET (5 MODULES)',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF94A3B8),
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 10),
                ...List.generate(_modules.length, (i) {
                  final m = _modules[i];
                  final isSelected = _currentIndex == i;
                  return Card(
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 6),
                    color: isSelected ? AppTheme.primaryBlue.withOpacity(0.08) : Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: isSelected ? AppTheme.primaryBlue : Colors.transparent,
                      ),
                    ),
                    child: ListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                      leading: Icon(
                        isSelected ? m['activeIcon'] : m['icon'],
                        color: isSelected ? AppTheme.primaryBlue : const Color(0xFF64748B),
                      ),
                      title: Text(
                        m['title'],
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? AppTheme.primaryBlue : const Color(0xFF0F172A),
                        ),
                      ),
                      subtitle: Text(
                        m['member'],
                        style: TextStyle(
                          fontSize: 11,
                          color: m['isImplemented'] ? AppTheme.statusActive : const Color(0xFF64748B),
                          fontWeight: m['isImplemented'] ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      onTap: () {
                        setState(() => _currentIndex = i);
                        Navigator.pop(context);
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline, color: Color(0xFF64748B)),
            title: const Text('Spécifications CDC', style: TextStyle(fontSize: 13)),
            subtitle: const Text('Version 1.0 - Novembre 2026', style: TextStyle(fontSize: 11)),
            onTap: () => _showAboutModal(),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  void _showAboutModal() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const UniManagerLogo(size: 36),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'UniManager - Application Mobile Universitaire',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Projet académique Flutter / Dart découpé en 5 modules intégrés avec backend Spring Boot & MongoDB local.',
              style: TextStyle(fontSize: 13, color: Color(0xFF475569)),
            ),
            SizedBox(height: 12),
            Text(
              'Module sélectionné et généré :',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            Text(
              '• Module 1 : Gestion des étudiants (Membre 1)',
              style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _buildPartnerModulePlaceholder(Map<String, dynamic> module) {
    return Scaffold(
      appBar: AppBar(
        title: Text(module['title']),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryCyan.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(module['icon'], size: 56, color: AppTheme.secondaryCyan),
              ),
              const SizedBox(height: 24),
              Text(
                module['title'],
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Responsable : ${module['member']}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF92400E),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                module['description'],
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
              ),
              const SizedBox(height: 28),
              ElevatedButton.icon(
                icon: const Icon(Icons.arrow_back),
                label: const Text('Retourner au Module 1 (Étudiants)'),
                onPressed: () => setState(() => _currentIndex = 0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
