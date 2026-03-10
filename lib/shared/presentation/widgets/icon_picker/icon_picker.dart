import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:find_your_mind/core/constants/color_constants.dart';

class IconPicker {
  static Future<String?> showSvgIconPicker({
    required BuildContext context,
    required List<String> icons,
  }) async {
    return showDialog<String>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: AppColors.darkBackground,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: AppColors.borderSubtle, width: 1),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Selecciona un ícono',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.darkBackgroundAlt,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.borderSubtle, width: 1),
                          ),
                          child: const Icon(Icons.close, size: 16, color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Flexible(
                    child: GridView.builder(
                      shrinkWrap: true,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: icons.length,
                      itemBuilder: (context, index) {
                        final iconPath = icons[index];
                        return GestureDetector(
                          onTap: () => Navigator.of(context).pop(iconPath),
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.darkBackgroundAlt,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.borderSubtle, width: 1),
                            ),
                            padding: const EdgeInsets.all(12),
                            child: SvgPicture.asset(
                              iconPath,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}