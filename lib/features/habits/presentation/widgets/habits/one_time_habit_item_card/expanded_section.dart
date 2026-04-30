import 'package:flutter/material.dart';

class ExpandedSection extends StatelessWidget {
  const ExpandedSection({
    required this.isExpanded,
    required this.cardFillColor,
    required this.expandedSectionFillColor,
    super.key,
  });

  final bool isExpanded;
  final Color cardFillColor;
  final Color expandedSectionFillColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      duration: const Duration(milliseconds: 180),
      crossFadeState:
          isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      firstChild: const SizedBox.shrink(),
      secondChild: Column(
        children: [
          Divider(
            height: 1,
            thickness: 1,
            color: Color.alphaBlend(
              Colors.black.withValues(alpha: 0.12),
              cardFillColor,
            ),
          ),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: expandedSectionFillColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(18),
                bottomRight: Radius.circular(18),
              ),
            ),
            child: const Padding(
              padding: EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: SizedBox(height: 60),
            ),
          ),
        ],
      ),
    );
  }
}
