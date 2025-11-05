import 'package:find_your_mind/core/constants/color_constants.dart';
import 'package:find_your_mind/shared/presentation/widgets/blur_show_dialogs.dart';
import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  const Profile({
    super.key,
    required this.isDarkTheme,
  });

  final bool isDarkTheme;

  @override
  State<Profile> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<Profile> {
  final GlobalKey _widgetKey = GlobalKey();

  @override
  Widget build(BuildContext context) {  
    return GestureDetector(
      key: _widgetKey,
      onTap: () => _showDropdownMenu(context),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: widget.isDarkTheme
            ? AppColors.darkBackground
            : const Color(0xFFFFFFFF),
        ),
        padding: const EdgeInsets.all(5),
        child: const Row(
          children: [
            CircleAvatar(
              radius: 12,
              backgroundColor: Colors.blue,
              child: Text(
                'JF',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.white54,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  void _showDropdownMenu(BuildContext context) {
    // Obtener Posicion del Widget
    final RenderBox? renderBox = _widgetKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final Offset position = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double dialogWidth = screenWidth * 0.5;
    final double dialogHeight = screenHeight * 0.3;
  

    showDialog(
      context: context, 
      builder: (context) {
        return BlurShowDialogs(
          position: position, 
          size: size, 
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(10),
            color: widget.isDarkTheme
              ? AppColors.darkBackground
              : Colors.white,
            child: SizedBox(
              width: dialogWidth,
              height: dialogHeight,
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Icon(
                        Icons.close,
                        size: 16,
                        color: Colors.white54,
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        );
      },
    );
  }
}