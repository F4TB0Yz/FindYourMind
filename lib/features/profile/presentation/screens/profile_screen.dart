import 'package:find_your_mind/features/auth/domain/entities/user_entity.dart';
import 'package:find_your_mind/features/auth/domain/usecases/usecases.dart';
import 'package:find_your_mind/features/habits/presentation/providers/habits_provider.dart';
import 'package:find_your_mind/shared/presentation/providers/sync_provider.dart';
import 'package:find_your_mind/shared/presentation/widgets/layouts/feature_layout.dart';
import 'package:find_your_mind/shared/presentation/widgets/toast/custom_toast.dart';
import 'package:find_your_mind/config/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.getCurrentUserUseCase,
    required this.signOutUseCase,
  });

  final GetCurrentUserUseCase getCurrentUserUseCase;
  final SignOutUseCase signOutUseCase;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserEntity? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await widget.getCurrentUserUseCase();
      setState(() {
        _currentUser = user;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        CustomToast.showToast(
          context: context,
          message: 'Error al cargar perfil: $e',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return FeatureLayout(
      scrollable: !_isLoading && _currentUser != null,
      padding: EdgeInsets.zero,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _currentUser == null
          ? const Center(child: Text('No hay usuario autenticado'))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  child: Column(
                    children: [
                      // Avatar
                      _buildAvatar(cs),
                      const SizedBox(height: 16),
                      // Nombre/Email
                      _buildUserInfo(cs),
                      const SizedBox(height: 32),
                      // Información de la cuenta
                      _buildAccountSection(cs),
                      const SizedBox(height: 16),
                      // Configuración
                      _buildSettingsSection(cs),
                      const SizedBox(height: 32),
                      // Botón de cerrar sesión
                      _buildSignOutButton(cs),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildAvatar(ColorScheme cs) {
    final initials = _getInitials();
    return CircleAvatar(
      radius: 50,
      backgroundColor: cs.primaryContainer,
      child: Text(
        initials,
        style: TextStyle(
          color: cs.onPrimaryContainer,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getInitials() {
    if (_currentUser?.displayName != null &&
        _currentUser!.displayName!.isNotEmpty) {
      final names = _currentUser!.displayName!.split(' ');
      if (names.length >= 2) {
        return '${names[0][0]}${names[1][0]}'.toUpperCase();
      }
      return _currentUser!.displayName!.substring(0, 2).toUpperCase();
    }
    final email = _currentUser?.email ?? '';
    return email.isNotEmpty ? email.substring(0, 2).toUpperCase() : 'US';
  }

  Widget _buildUserInfo(ColorScheme cs) {
    return Column(
      children: [
        Text(
          _currentUser?.displayName ?? 'Usuario',
          style: AppTextStyles.achievementTitle(context).copyWith(fontSize: 28),
        ),
        const SizedBox(height: 4),
        Text(
          _currentUser?.email ?? '',
          style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildAccountSection(ColorScheme cs) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Información de la cuenta',
              style: AppTextStyles.titleLarge(context).copyWith(fontSize: 16),
            ),
          ),
          _buildInfoTile(
            icon: Icons.email_outlined,
            title: 'Email',
            subtitle: _currentUser?.email ?? '',
            cs: cs,
          ),
          _buildInfoTile(
            icon: Icons.calendar_today_outlined,
            title: 'Miembro desde',
            subtitle: _formatDate(_currentUser?.createdAt),
            cs: cs,
          ),
          if (_currentUser?.lastSignInAt != null)
            _buildInfoTile(
              icon: Icons.login_outlined,
              title: 'Último acceso',
              subtitle: _formatDate(_currentUser?.lastSignInAt),
              cs: cs,
            ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(ColorScheme cs) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Configuración',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
          ),
          _buildSettingsTile(
            icon: Icons.notifications_outlined,
            title: 'Notificaciones',
            onTap: () {
              CustomToast.showToast(context: context, message: 'Próximamente');
            },
            cs: cs,
          ),
          _buildSettingsTile(
            icon: Icons.lock_outline,
            title: 'Privacidad',
            onTap: () {
              CustomToast.showToast(context: context, message: 'Próximamente');
            },
            cs: cs,
          ),
          _buildSettingsTile(
            icon: Icons.help_outline,
            title: 'Ayuda y soporte',
            onTap: () {
              CustomToast.showToast(context: context, message: 'Próximamente');
            },
            cs: cs,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required ColorScheme cs,
  }) {
    return ListTile(
      leading: Icon(icon, color: cs.onSurfaceVariant),
      title: Text(
        title,
        style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: cs.onSurface,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required ColorScheme cs,
  }) {
    return ListTile(
      leading: Icon(icon, color: cs.onSurfaceVariant),
      title: Text(title, style: TextStyle(fontSize: 16, color: cs.onSurface)),
      trailing: Icon(Icons.chevron_right, color: cs.outline),
      onTap: onTap,
    );
  }

  Widget _buildSignOutButton(ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _handleSignOut,
          style: ElevatedButton.styleFrom(
            backgroundColor: cs.error,
            foregroundColor: cs.onError,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Cerrar sesión',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSignOut() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );

    if (shouldLogout ?? false) {
      try {
        if (!mounted) return;
        final habitsProvider = Provider.of<HabitsProvider>(
          context,
          listen: false,
        );
        final syncProvider = Provider.of<SyncProvider>(context, listen: false);

        habitsProvider.clearAllData();
        syncProvider.resetSyncState();

        await widget.signOutUseCase();
        if (!mounted) return;
        context.go('/login');
      } catch (e) {
        if (!mounted) return;
        CustomToast.showToast(
          context: context,
          message: 'Error al cerrar sesión: $e',
        );
      }
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    final months = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
