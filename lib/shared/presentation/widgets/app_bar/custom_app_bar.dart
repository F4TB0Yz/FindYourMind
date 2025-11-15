import 'package:find_your_mind/core/constants/color_constants.dart';
import 'package:find_your_mind/features/auth/domain/usecases/usecases.dart';
import 'package:find_your_mind/shared/presentation/providers/theme_provider.dart';
import 'package:find_your_mind/shared/presentation/widgets/app_bar/profile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key, required this.signOutUseCase});

  final SignOutUseCase signOutUseCase;

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(50);
}

class _CustomAppBarState extends State<CustomAppBar> {
  @override
  Widget build(BuildContext context) {
    final ThemeProvider themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDarkTheme = themeProvider.themeMode == ThemeMode.dark;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          // Workspace
          Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              color: isDarkTheme
                ? AppColors.darkBackground
                : const Color(0xFFFFFFFF),
            ),
            padding: const EdgeInsets.all(5),
            child: const Row(
              children: [
                Text(
                  "Felipe's Workspace",
                  style: TextStyle(
                    fontSize: 12,
                  ),
                ),
      
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Colors.white54,
                )
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Search Bar
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                color: isDarkTheme
                  ? AppColors.darkBackground
                  : const Color(0xFFFFFFFF),
              ),
              padding: const EdgeInsets.all(5),
              child: const Row(
                children: [
                  Icon(
                    Icons.search,
                    size: 14,
                    color: Colors.white54,
                  ),
                  SizedBox(width: 8),
                  Text('Buscar', style: TextStyle(
                    fontSize: 14,
                    color: Colors.white54,
                  ),)
                ],
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Profile
          Profile(
            isDarkTheme: isDarkTheme,
            signOutUseCase: widget.signOutUseCase,
          )
        ],
      ),
    );
  }
}