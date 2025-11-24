import 'package:find_your_mind/core/constants/color_constants.dart';
import 'package:find_your_mind/features/auth/domain/entities/user_entity.dart';
import 'package:find_your_mind/features/auth/domain/usecases/usecases.dart';
import 'package:find_your_mind/features/habits/presentation/providers/habits_provider.dart';
import 'package:find_your_mind/shared/presentation/providers/sync_provider.dart';
import 'package:find_your_mind/shared/presentation/widgets/toast/custom_toast.dart';
import 'package:flutter/material.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.grey[100],
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _currentUser == null
              ? const Center(child: Text('No hay usuario autenticado'))
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      // Avatar
                      _buildAvatar(),
                      const SizedBox(height: 16),
                      // Nombre/Email
                      _buildUserInfo(isDark),
                      const SizedBox(height: 32),
                      // Información de la cuenta
                      _buildAccountSection(isDark),
                      const SizedBox(height: 16),
                      // Configuración
                      _buildSettingsSection(isDark),
                      const SizedBox(height: 32),
                      // Botón de cerrar sesión
                      _buildSignOutButton(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
    );
  }

  Widget _buildAvatar() {
    final initials = _getInitials();
    return CircleAvatar(
      radius: 50,
      backgroundColor: Colors.blue,
      child: Text(
        initials,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getInitials() {
    if (_currentUser?.displayName != null && _currentUser!.displayName!.isNotEmpty) {
      final names = _currentUser!.displayName!.split(' ');
      if (names.length >= 2) {
        return '${names[0][0]}${names[1][0]}'.toUpperCase();
      }
      return _currentUser!.displayName!.substring(0, 2).toUpperCase();
    }
    final email = _currentUser?.email ?? '';
    return email.isNotEmpty ? email.substring(0, 2).toUpperCase() : 'US';
  }

  Widget _buildUserInfo(bool isDark) {
    return Column(
      children: [
        Text(
          _currentUser?.displayName ?? 'Usuario',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _currentUser?.email ?? '',
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.white54 : Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildAccountSection(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Información de la cuenta',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          _buildInfoTile(
            icon: Icons.email_outlined,
            title: 'Email',
            subtitle: _currentUser?.email ?? '',
            isDark: isDark,
          ),
          _buildInfoTile(
            icon: Icons.calendar_today_outlined,
            title: 'Miembro desde',
            subtitle: _formatDate(_currentUser?.createdAt),
            isDark: isDark,
          ),
          if (_currentUser?.lastSignInAt != null)
            _buildInfoTile(
              icon: Icons.login_outlined,
              title: 'Último acceso',
              subtitle: _formatDate(_currentUser?.lastSignInAt),
              isDark: isDark,
            ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
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
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          _buildSettingsTile(
            icon: Icons.notifications_outlined,
            title: 'Notificaciones',
            onTap: () {
              // TODO: Implementar configuración de notificaciones
              CustomToast.showToast(
                context: context,
                message: 'Próximamente',
              );
            },
            isDark: isDark,
          ),
          _buildSettingsTile(
            icon: Icons.lock_outline,
            title: 'Privacidad',
            onTap: () {
              // TODO: Implementar configuración de privacidad
              CustomToast.showToast(
                context: context,
                message: 'Próximamente',
              );
            },
            isDark: isDark,
          ),
          _buildSettingsTile(
            icon: Icons.help_outline,
            title: 'Ayuda y soporte',
            onTap: () {
              // TODO: Implementar ayuda y soporte
              CustomToast.showToast(
                context: context,
                message: 'Próximamente',
              );
            },
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDark ? Colors.white70 : Colors.black54,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          color: isDark ? Colors.white70 : Colors.black54,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDark ? Colors.white70 : Colors.black54,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: isDark ? Colors.white54 : Colors.black38,
      ),
      onTap: onTap,
    );
  }

  Widget _buildSignOutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _handleSignOut,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Cerrar sesión',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
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
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );

    if (shouldLogout ?? false) {
      try {
        // Limpiar providers antes del logout
        final habitsProvider = Provider.of<HabitsProvider>(context, listen: false);
        final syncProvider = Provider.of<SyncProvider>(context, listen: false);
        
        habitsProvider.clearAllData();
        syncProvider.resetSyncState();
        
        // Ejecutar el logout (ya limpia la base de datos SQLite)
        await widget.signOutUseCase();
        if (!mounted) return;
        // Volver a la pantalla de autenticación (home)
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
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
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
