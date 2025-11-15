import 'package:find_your_mind/core/constants/color_constants.dart';
import 'package:find_your_mind/features/auth/domain/usecases/usecases.dart';
import 'package:find_your_mind/shared/presentation/widgets/blur_show_dialogs.dart';
import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  const Profile({
    super.key, 
    required this.isDarkTheme,
    required this.signOutUseCase,
  });

  final bool isDarkTheme;
  final SignOutUseCase signOutUseCase;

  @override
  State<Profile> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<Profile> {
  final GlobalKey _widgetKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: _widgetKey,
      onTap: () => _showDropdownMenu(context),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: widget.isDarkTheme
              ? AppColors.darkBackground
              : const Color(0xFFFFFFFF),
        ),
        padding: const EdgeInsets.all(5),
        child: const Row(
          children: [
            CircleAvatar(
              radius: 12,
              backgroundColor: Colors.blue,
              child: Text(
                'JF',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.white54,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  void _showDropdownMenu(BuildContext context) {
    // Obtener Posicion del Widget
    final RenderBox? renderBox =
        _widgetKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final Offset position = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    final double screenWidth = MediaQuery.of(context).size.width;

    // Ajustar la posición horizontal para que el dropdown no se salga de la pantalla
    const double dropdownWidth = 150;
    const double horizontalPadding = 15; // margen mínimo desde los bordes
    double adjustedDx = position.dx;
    if (adjustedDx + dropdownWidth > screenWidth - horizontalPadding) {
      adjustedDx = screenWidth - dropdownWidth - horizontalPadding;
    }
    if (adjustedDx < horizontalPadding) adjustedDx = horizontalPadding;
    final Offset adjustedPosition = Offset(adjustedDx, position.dy);

    showDialog(
      context: context,
      builder: (context) {
        return BlurShowDialogs(
          position: adjustedPosition,
          size: size,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(10),
            color: widget.isDarkTheme ? AppColors.darkBackground : Colors.white,
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
                      child: const Icon(
                        Icons.close,
                        size: 18,
                        color: Colors.white54,
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
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Divisor
                  Divider(
                    color: Colors.white.withOpacity(0.1),
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
              color: isDestructive 
                ? Colors.red.shade400 
                : Colors.white70,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: isDestructive 
                  ? Colors.red.shade400 
                  : Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSignOut(BuildContext context) async {
    try {
      Navigator.of(context).pop(); // Cerrar el dropdown
      
      // Mostrar un diálogo de confirmación
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
              child: const Text('Cerrar sesión'),
            ),
          ],
        ),
      );

      if (shouldLogout ?? false) {
        // Ejecutar el logout
        await widget.signOutUseCase();
        
        if (!context.mounted) return;
        // Navegar a la pantalla de login
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cerrar sesión: $e'),
        ),
      );
    }
  }
}
