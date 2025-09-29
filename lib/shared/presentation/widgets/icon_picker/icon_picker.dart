import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class IconPicker {
  static Future<String?> showSvgIconPicker({
    required BuildContext context,
    required List<String> icons,
  }) async {
    return showGeneralDialog(
      context: context, 
      pageBuilder: (_, __, ___) => Container(), // No se usa
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final CurvedAnimation curvedAnimation = CurvedAnimation(
          parent: animation, 
          curve: Curves.easeInOut,
        );

        return ScaleTransition(
          scale: curvedAnimation,
          child: AlertDialog(
            title: const Text(
              'Selecciona un icono',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600
              ),
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: icons.length,
                itemBuilder: (context, index) {
                  final iconPath = icons[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop(iconPath);
                    },
                    child: SvgPicture.asset(iconPath),
                  );
                },
              ),
            ),
          )
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black54,
    );
  }
}