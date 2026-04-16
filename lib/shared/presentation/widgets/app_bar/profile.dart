import 'package:find_your_mind/features/auth/presentation/providers/auth_service_locator.dart';
import 'package:find_your_mind/features/habits/presentation/providers/habits_provider.dart';
import 'package:find_your_mind/shared/presentation/providers/sync_provider.dart';
import 'package:find_your_mind/shared/presentation/widgets/blur_show_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Profile extends StatefulWidget {
  const Profile({
    super.key, 
    required this.isDarkTheme,
  });

  final bool isDarkTheme;

  @override
  State<Profile> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<Profile> {
  final GlobalKey _widgetKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      key: _widgetKey,
      onTap: () => _showDropdownMenu(context),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: cs.surface,
        ),
        padding: const EdgeInsets.all(5),
        child: Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: cs.primary.withValues(alpha: 0.15),
              child: Text(
                'JF',
                style: TextStyle(
                  color: cs.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: cs.onSurfaceVariant,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showDropdownMenu(BuildContext context) {
    final RenderBox? renderBox =
        _widgetKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final Offset position = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    final double screenWidth = MediaQuery.of(context).size.width;

    const double dropdownWidth = 150;
    const double horizontalPadding = 15;
    double adjustedDx = position.dx;
    if (adjustedDx + dropdownWidth > screenWidth - horizontalPadding) {
      adjustedDx = screenWidth - dropdownWidth - horizontalPadding;
    }
    if (adjustedDx < horizontalPadding) adjustedDx = horizontalPadding;
    final Offset adjustedPosition = Offset(adjustedDx, position.dy);

    showDialog(
      context: context,
      builder: (context) {
        final cs = Theme.of(context).colorScheme;
        return BlurShowDialogs(
          position: adjustedPosition,
          size: size,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(10),
            color: cs.surface,
            child: Container(
              width: 160,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Botón de cerrar
                  Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Icon(
                        Icons.close,
                        size: 18,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Opción Ver perfil
                  _buildMenuOption(
                    context: context,
                    icon: Icons.person_outline,
                    label: 'Ver perfil',
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pushNamed('/profile');
                    },
                    cs: cs,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Divider(
                    color: cs.outlineVariant,
                    height: 1,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Opción Cerrar sesión
                  _buildMenuOption(
                    context: context,
                    icon: Icons.logout,
                    label: 'Cerrar sesión',
                    onTap: () => _handleSignOut(context),
                    isDestructive: true,
                    cs: cs,
                  ),
                  
                  const SizedBox(height: 4),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required ColorScheme cs,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isDestructive ? cs.error : cs.onSurfaceVariant,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: isDestructive ? cs.error : cs.onSurfaceVariant,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSignOut(BuildContext dropdownContext) async {
    final rootContext = context;
    
    Navigator.of(dropdownContext).pop();
    
    final shouldLogout = await showDialog<bool>(
      context: rootContext,
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
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );

    if (shouldLogout ?? false) {
      if (!rootContext.mounted) return;
      final habitsProvider = Provider.of<HabitsProvider>(rootContext, listen: false);
      final syncProvider = Provider.of<SyncProvider>(rootContext, listen: false);
      
      habitsProvider.clearAllData();
      syncProvider.resetSyncState();
      
      final result = await AuthServiceLocator().signOutUseCase();
      
      if (!rootContext.mounted) return;
      
      result.fold(
        (failure) {
          ScaffoldMessenger.of(rootContext).showSnackBar(
            SnackBar(content: Text('Error al cerrar sesión: ${failure.message}')),
          );
        },
        (_) {
          Navigator.of(rootContext).pushNamedAndRemoveUntil('/', (route) => false);
        },
      );
    }
  }
}
