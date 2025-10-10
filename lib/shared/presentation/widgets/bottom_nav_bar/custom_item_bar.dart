import 'package:find_your_mind/shared/domain/screen_type.dart';
import 'package:find_your_mind/shared/presentation/providers/screen_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomItemBar extends StatefulWidget {
  final IconData icon;
  final Widget screen;
  final ScreenType screenType;
  final VoidCallback? onTap;

  const CustomItemBar({
    super.key, 
    required this.icon, 
    required this.screen,
    required this.screenType,
    this.onTap,
  });

  @override
  State<CustomItemBar> createState() => _CustomItemBarState();
}

class _CustomItemBarState extends State<CustomItemBar> {
  @override
  Widget build(BuildContext context) {
    final ScreensProvider screensProvider = Provider.of<ScreensProvider>(context);
    final Size size = MediaQuery.of(context).size;
    
    // Detectar si este item está seleccionado comparando los tipos de widget
    final bool isSelected = screensProvider.currentScreenType == widget.screenType;

    return GestureDetector(
      onTap: () {
        screensProvider.setScreenWidget(widget.screen, widget.screenType);

        if (widget.onTap != null) {
          widget.onTap!();
        }
      },
      child: _buildButton(size, isSelected)
    );
  }

  Container _buildButton(Size size, bool isSelected) {
    // Color más brillante cuando está seleccionado
    final Color innerColor = isSelected 
        ? const Color(0xFF9A9A9A) // Color más claro cuando está seleccionado
        : const Color(0xFF717171); // Color normal
    
    final Color iconColor = isSelected
        ? const Color.fromARGB(255, 20, 20, 20) // Icono más oscuro cuando está seleccionado
        : const Color.fromARGB(255, 39, 37, 37); // Color normal del icono
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      width: size.width * 0.18,
      height: size.height * 0.1,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF717171).withValues(alpha: 0.73),
      ),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(6),
          padding: const EdgeInsets.all(5),
          width: size.width * 0.15,
          height: size.height * 0.08,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: innerColor,
          ),
          child: FittedBox(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(
                widget.icon,
                weight: 700,
                color: iconColor
              ),
            ),
          ),
        ),
      )
    );
  }
}