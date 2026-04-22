import 'package:find_your_mind/config/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class SoonWidget extends StatelessWidget {
  final String nameFeature;

  const SoonWidget({super.key, required this.nameFeature});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 120
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              nameFeature,
              style: AppTextStyles.achievementTitle(context).copyWith(
                color: Colors.lime,
                fontSize: 42,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.8),
                    offset: const Offset(0, 4),
                    blurRadius: 18,
                  ),
                  Shadow(
                    color: Colors.lime.withValues(alpha: 0.5),
                    offset: const Offset(0, 2),
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
      
            Text(
              'PROXIMAMENTE',
              style: AppTextStyles.h2(context).copyWith(
                color: Colors.yellow.shade300.withValues(alpha: 0.6),
                fontSize: 24,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedContainer extends StatefulWidget {
  final Widget child;
  
  const _AnimatedContainer({
    required this.child,
  });

  @override
  State<_AnimatedContainer> createState() => _AnimatedContainerState();
}

class _AnimatedContainerState extends State<_AnimatedContainer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Alignment> _topAlignmentAnimation;
  late Animation<Alignment> _bottomAlignmentAnimation;

  @override
  void initState() { 
    super.initState();
    _controller = AnimationController(
      vsync: this, 
      duration: const Duration(seconds:  5)
    );

    _topAlignmentAnimation = TweenSequence<Alignment>(
      [
        TweenSequenceItem(
          weight: 1,
          tween: Tween<Alignment>(
            begin: Alignment.topLeft,
            end: Alignment.topRight
          ), 
        ),
        TweenSequenceItem(
          weight: 1,
          tween: Tween<Alignment>(
            begin: Alignment.topRight,
            end: Alignment.bottomRight
          ), 
        ),
        TweenSequenceItem(
          weight: 1,
          tween: Tween<Alignment>(
            begin: Alignment.bottomRight,
            end: Alignment.bottomLeft
          ), 
        ),
        TweenSequenceItem(
          weight: 1,
          tween: Tween<Alignment>(
            begin: Alignment.bottomLeft,
            end: Alignment.topLeft
          ), 
        ),
      ]
    )
    .animate(_controller);

    _bottomAlignmentAnimation = TweenSequence<Alignment>(
      [
        TweenSequenceItem(
          weight: 1,
          tween: Tween<Alignment>(
            begin: Alignment.bottomRight,
            end: Alignment.bottomLeft
          ), 
        ),
        TweenSequenceItem(
          weight: 1,
          tween: Tween<Alignment>(
            begin: Alignment.bottomLeft,
            end: Alignment.topLeft
          ), 
        ),
        TweenSequenceItem(
          weight: 1,
          tween: Tween<Alignment>(
            begin: Alignment.topLeft,
            end: Alignment.topRight
          ), 
        ),
        TweenSequenceItem(
          weight: 1,
          tween: Tween<Alignment>(
            begin: Alignment.topRight,
            end: Alignment.bottomRight
          ), 
        ),
      ]
    )
    .animate(_controller);

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Container(
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                border: Border.all( color: const Color(0xFF4D4D4D) ),
                borderRadius: BorderRadius.circular(15),
                gradient: LinearGradient(
                  colors: const [
                    Color.fromARGB(255, 122, 74, 29),
                    Color.fromARGB(174, 61, 47, 28)
                  ],
                  begin: _topAlignmentAnimation.value,
                  end: _bottomAlignmentAnimation.value,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromARGB(38, 198, 187, 187),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: widget.child,
            );
          }
        );
      }
    );
  }
}