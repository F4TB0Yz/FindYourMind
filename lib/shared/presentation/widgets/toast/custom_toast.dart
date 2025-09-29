import 'dart:ui';

import 'package:flutter/material.dart';

class CustomToast {
  static void showToast({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 2),
  }) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    const fadeDuration = Duration(milliseconds: 350);
    late OverlayEntry overlayEntry;
    double opacity = 0.0;

    overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          top: mediaQuery.size.height * 0.5 - 25,
          left: mediaQuery.size.width * 0.2,
          child: Material(
            color: Colors.transparent,
            child: StatefulBuilder(
              builder: (context, setState) {
                return AnimatedOpacity(
                  opacity: opacity,
                  duration: fadeDuration,
                    child: Container(
                    width: mediaQuery.size.width * 0.6,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                      color: Colors.white70,
                      width: 0.5,
                      ),
                      color: Colors.transparent,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                        color: const Color.fromRGBO(42, 42, 42, 0.1),
                        child: Text(
                        message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.2,
                          color: Colors.white,
                        ),
                        ),
                      ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(overlayEntry);

    // Fade in
    Future.delayed(const Duration(milliseconds: 10), () {
      opacity = 1.0;
      overlayEntry.markNeedsBuild();
    });

    // Fade out y remover
    Future.delayed(duration, () {
      opacity = 0.0;
      overlayEntry.markNeedsBuild();
      Future.delayed(fadeDuration, () {
        overlayEntry.remove();
      });
    });
  }
}