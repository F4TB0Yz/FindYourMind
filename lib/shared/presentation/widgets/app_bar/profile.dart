import 'package:find_your_mind/features/auth/presentation/providers/auth_service_locator.dart';
import 'package:find_your_mind/features/habits/presentation/providers/habits_provider.dart';
import 'package:find_your_mind/shared/presentation/providers/sync_provider.dart';
import 'package:find_your_mind/shared/presentation/widgets/blur_show_dialogs.dart';
import 'package:find_your_mind/shared/presentation/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class Profile extends StatefulWidget {
  const Profile({
    super.key, 
  });

  @override
  State<Profile> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<Profile> {
  final GlobalKey _widgetKey = GlobalKey();
  String _initials = 'US';
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _loadInitials();
  }

  Future<void> _loadInitials() async {
    try {
      final user = await AuthServiceLocator().getCurrentUserUseCase();
      if (user != null && mounted) {
        final name = user.displayName ?? user.email;
        if (name.isNotEmpty) {
          String init = name[0].toUpperCase();
          final parts = name.split(' ');
          if (parts.length > 1 && parts[1].isNotEmpty) {
            init += parts[1][0].toUpperCase();
          } else if (name.length > 1 && user.displayName == null) {
            init += name[1].toUpperCase();
          }
          setState(() {
            _initials = init;
          });
        }
      }
    } catch (_) {
      // Ignorar error, usa por defecto 'US'
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      key: _widgetKey,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () => _showDropdownMenu(context),
      child: AnimatedScale(
        scale: _isPressed ? 0.85 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOutBack,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.transparent,
          ),
          padding: const EdgeInsets.all(4),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: cs.primary.withOpacity(0.15),
            child: Text(
              _initials,
              style: TextStyle(
                color: cs.primary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showDropdownMenu(BuildContext context) {
    final RenderBox? renderBox =
        _widgetKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;
    final cs = Theme.of(context).colorScheme;

    showMenu(
      context: context,
      elevation: 8,
      clipBehavior: Clip.antiAlias,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + size.height + 8,
        MediaQuery.of(context).size.width - offset.dx - size.width,
        0,
      ),
      items: <PopupMenuEntry<dynamic>>[
        PopupMenuItem(
          onTap: () => Future.microtask(() => context.goNamed('perfil')),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Builder(
            builder: (innerContext) {
              final csInner = Theme.of(innerContext).colorScheme;
              return Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: csInner.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.person_outline, size: 20, color: csInner.primary),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Mi Perfil',
                    style: TextStyle(color: csInner.onSurface, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ],
              );
            }
          ),
        ),
        const PopupMenuDivider(),

        PopupMenuItem(
          onTap: () => Future.microtask(() => _handleSignOut()),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Builder(
            builder: (innerContext) {
              final csInner = Theme.of(innerContext).colorScheme;
              return Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: csInner.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.logout_rounded, size: 20, color: csInner.error),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Cerrar sesión',
                    style: TextStyle(color: csInner.error, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ],
              );
            }
          ),
        ),
      ],
    );
  }

  Future<void> _handleSignOut() async {
    final rootContext = context;
    
    final shouldLogout = await showDialog<bool>(
      context: rootContext,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cerrar sesión', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Salir'),
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
          context.go('/login');
        },
      );
    }
  }
}

