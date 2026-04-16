import 'package:find_your_mind/shared/presentation/widgets/layouts/feature_layout.dart';
import 'package:find_your_mind/shared/presentation/widgets/soon_widget.dart';
import 'package:flutter/material.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeatureLayout(
      child: SoonWidget(
        nameFeature: 'TAREAS',
      ),
    );
  }
}