import 'package:find_your_mind/shared/presentation/providers/screen_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomItemBar extends StatefulWidget {
  final IconData icon;
  final Widget screen;
  final VoidCallback? onTap;

  const CustomItemBar({
    super.key, 
    required this.icon, 
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
    final Size size = MediaQuery.of(context).size;

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
        child: _buildButton(size)
      )
    );
  }

  Container _buildButton(Size size) {
    return Container(
    width: size.width * 0.18,
    height: size.height * 0.1,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: const Color(0xFF717171).withValues(alpha: 0.73),
    ),
    child: Center(
      child: Container(
        padding: const EdgeInsets.all(5),
        width: size.width * 0.15,
        height: size.height * 0.08,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: backgroundColor,
        ),
        child: FittedBox(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(
              widget.icon,
              weight: 700,
              color: const Color.fromARGB(255, 39, 37, 37)
            ),
          ),
        ),
      ),
    )
  );
  }
}