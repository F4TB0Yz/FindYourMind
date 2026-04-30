import 'package:flutter/material.dart';
import 'package:find_your_mind/config/theme/app_colors.dart';
import 'package:shimmer/shimmer.dart';

class CompleteButton extends StatefulWidget {
  const CompleteButton({
    required this.onMarkCompletedTap,
    required this.isCompleted,
    required this.resolvedCardColor,
    required this.cardBorderColor,
    required this.cardFillColor,
    required this.isDark,
    required this.shimmerBaseColor,
    required this.shimmerHighlightColor,
    super.key,
  });

  final VoidCallback? onMarkCompletedTap;
  final bool isCompleted;
  final Color resolvedCardColor;
  final Color cardBorderColor;
  final Color cardFillColor;
  final bool isDark;
  final Color shimmerBaseColor;
  final Color shimmerHighlightColor;

  @override
  State<CompleteButton> createState() => _CompleteButtonState();
}

class _CompleteButtonState extends State<CompleteButton> {
  bool _isButtonPressed = false;

  void _handleCompleteTap() {
    widget.onMarkCompletedTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final Color completeButtonBorderColor = widget.isCompleted
        ? Colors.green.withValues(alpha: 0.55)
        : widget.cardBorderColor;

    final Color completeButtonFillColor = widget.isCompleted
        ? Colors.green.withValues(alpha: widget.isDark ? 0.18 : 0.14)
        : (widget.isDark
              ? Color.lerp(
                  AppColors.darkSurfaceContainer,
                  widget.resolvedCardColor,
                  0.28,
                )!
              : Color.alphaBlend(
                  widget.resolvedCardColor.withValues(alpha: 0.18),
                  AppColors.lightSurfaceContainer,
                ));

    final Color shimmerBaseColor = Color.alphaBlend(
      widget.shimmerBaseColor.withValues(alpha: 0.35),
      completeButtonFillColor,
    );
    final Color shimmerHighlightColor = Color.alphaBlend(
      widget.shimmerHighlightColor.withValues(alpha: 0.55),
      completeButtonFillColor,
    );

    final Color completedShimmerBaseColor = Color.alphaBlend(
      Colors.greenAccent.withValues(alpha: 0.35),
      completeButtonFillColor,
    );
    final Color completedShimmerHighlightColor = Color.alphaBlend(
      Colors.greenAccent.withValues(alpha: 0.75),
      completeButtonFillColor,
    );

    final BorderRadius completeButtonRadius = BorderRadius.circular(12);

    return Listener(
      onPointerDown: (_) => setState(() => _isButtonPressed = true),
      onPointerUp: (_) => setState(() => _isButtonPressed = false),
      onPointerCancel: (_) => setState(() => _isButtonPressed = false),
      child: AnimatedScale(
        scale: _isButtonPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _handleCompleteTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            constraints: const BoxConstraints(minHeight: 48),
            width: double.infinity,
            decoration: BoxDecoration(
              color: completeButtonFillColor,
              borderRadius: completeButtonRadius,
              border: Border.all(width: 2, color: completeButtonBorderColor),
              boxShadow: widget.isDark
                  ? null
                  : [
                      BoxShadow(
                        color: widget.resolvedCardColor.withValues(alpha: 0.24),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
            ),
            child: widget.isCompleted
                ? Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 13,
                          horizontal: 11,
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          child: Text(
                            'Completado',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: widget.isDark
                                      ? Colors.green.shade300
                                      : Colors.green.shade700,
                                ),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: IgnorePointer(
                          child: ClipRRect(
                            borderRadius: completeButtonRadius,
                            child: Shimmer.fromColors(
                              baseColor: completedShimmerBaseColor,
                              highlightColor: completedShimmerHighlightColor,
                              child: Container(
                                color:
                                    (widget.isDark
                                            ? Colors.greenAccent
                                            : Colors.green)
                                        .withValues(
                                          alpha: widget.isDark ? 0.45 : 0.55,
                                        ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 13,
                          horizontal: 11,
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          child: Text(
                            'Marcar como completado',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: IgnorePointer(
                          child: ClipRRect(
                            borderRadius: completeButtonRadius,
                            child: Shimmer.fromColors(
                              baseColor: shimmerBaseColor,
                              highlightColor: shimmerHighlightColor,
                              child: Container(
                                color:
                                    (widget.isDark
                                            ? Colors.white
                                            : const Color.fromARGB(
                                                255,
                                                123,
                                                182,
                                                240,
                                              ))
                                        .withValues(
                                          alpha: widget.isDark ? 0.30 : 0.46,
                                        ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
