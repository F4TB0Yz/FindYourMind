import 'package:find_your_mind/shared/domain/entities/screen_type.dart';
import 'package:find_your_mind/shared/presentation/widgets/container_border_screens.dart';
import 'package:find_your_mind/shared/presentation/widgets/soon_widget.dart';
import 'package:flutter/material.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ContainerBorderScreens(
      screenType: ScreenType.tasks,
      child: SoonWidget(
        nameFeature: 'TAREAS',
      ),
    );
  }
}