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
      padding: const EdgeInsets.only(left: 5, right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 100,
            height: 50,
            child: OverflowBox(
              maxHeight: 100,
              child: Image.asset(
                'assets/images/app_logo.png',
                height: 100,
                fit: BoxFit.contain,
              ),
            ),
          ),


          // // Workspace
          // Container(
          //   decoration: BoxDecoration(
          //     borderRadius: const BorderRadius.all(Radius.circular(10)),
          //     color: isDarkTheme
          //       ? AppColors.darkBackground
          //       : const Color(0xFFFFFFFF),
          //   ),
          //   padding: const EdgeInsets.all(5),
          //   child: const Row(
          //     children: [
          //       Text(
          //         "Felipe's Workspace",
          //         style: TextStyle(
          //           fontSize: 12,
          //         ),
          //       ),
      
          //       Icon(
          //         Icons.keyboard_arrow_down_rounded,
          //         color: Colors.white54,
          //       )
          //     ],
          //   ),
          // ),

          // const SizedBox(width: 8),

          // // Search Bar
          // Expanded(
          //   child: Container(
          //     decoration: BoxDecoration(
          //       borderRadius: const BorderRadius.all(Radius.circular(10)),
          //       color: isDarkTheme
          //         ? AppColors.darkBackground
          //         : const Color(0xFFFFFFFF),
          //     ),
          //     padding: const EdgeInsets.all(5),
          //     child: const Row(
          //       children: [
          //         Icon(
          //           Icons.search,
          //           size: 14,
          //           color: Colors.white54,
          //         ),
          //         SizedBox(width: 8),
          //         Text('Buscar', style: TextStyle(
          //           fontSize: 14,
          //           color: Colors.white54,
          //         ),)
          //       ],
          //     ),
          //   ),
          // ),

          // const SizedBox(width: 8),

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