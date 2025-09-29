import 'package:find_your_mind/shared/presentation/providers/screen_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomItemBar extends StatefulWidget {
  final IconData icon;
  final String label;
  final Widget screen;
  final VoidCallback? onTap;

  const CustomItemBar({
    super.key, 
    required this.icon, 
    required this.label,
    required this.screen,
    this.onTap,
  });

  @override
  State<CustomItemBar> createState() => _CustomItemBarState();
}

class _CustomItemBarState extends State<CustomItemBar> {
  Color backgroundColor = const Color(0xFF717171);

  @override
  Widget build(BuildContext context) {
    final ScreensProvider screensProvider = Provider.of<ScreensProvider>(context);

    return MouseRegion(
      onHover: (_) => setState(() {
        backgroundColor = const Color(0xFF97cdf0).withValues(alpha: 0.5);
      }),
      onExit: (_) => setState(() {
        backgroundColor = const Color(0xFF717171);
      }),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          screensProvider.setScreenWidget(widget.screen);
          if (widget.onTap != null) {
            widget.onTap!();
          }
        },
        child: _buildButton()
      )
    );
  }

  Container _buildButton() {
    return Container(
    width: 50,
    height: 50,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: const Color(0xFF717171).withValues(alpha: 0.73),
    ),
    child: Center(
      child: Container(
        padding: const EdgeInsets.all(5),
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: backgroundColor,
        ),
        child: FittedBox(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 2, left: 1, right: 1),
            child: Column(
              children: [
                Icon(widget.icon, color: Colors.black),
                Text(
                  widget.label,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.w700         
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    )
  );
  }
}