import 'package:find_your_mind/shared/presentation/widgets/icon_picker/icon_picker.dart';
import 'package:find_your_mind/shared/utils/icons_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AddIcon extends StatefulWidget {
  final ValueChanged<String> saveIcon;
  final bool withText;
  final String? initialIcon;
  final double size;

  const AddIcon({
    super.key, 
    required this.saveIcon, 
    this.withText = true,
    this.initialIcon,
    this.size = 32,
  });

  @override
  State<AddIcon> createState() => _AddIconState();
}

class _AddIconState extends State<AddIcon> {
  late String selectedIcon;

  @override
  void initState() {
    super.initState();
    selectedIcon = widget.initialIcon ?? 'assets/icons/mind.svg';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => _onTapChangeIcon(context: context),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return ScaleTransition(
                scale: animation,
                child: child,
              );
            },
            child: SvgPicture.asset(
              selectedIcon,
              key: ValueKey<String>(selectedIcon), // Para que detecte el cambio
              width: widget.size,
              height: widget.size,
            ),
          ),
        ),

        const SizedBox(width: 15),

        if (widget.withText)
          GestureDetector(
            onTap: () => _onTapChangeIcon(context: context),
            child: const Text(
              'Agregar Icono',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white38
              ),
            ),
          )
      ],
    );
  }

  void _onTapChangeIcon({required BuildContext context}) async {
    final icons = await loadSvgIcons();
    // Verificar si el contexto esta montado (por el async)
    if (!context.mounted) return;
    
    final String? selectedIcon = await IconPicker.showSvgIconPicker(context: context, icons: icons);
    if (selectedIcon != null) {
      setState(() {
        this.selectedIcon = selectedIcon;
        widget.saveIcon(selectedIcon);
      });
    }
  }
}