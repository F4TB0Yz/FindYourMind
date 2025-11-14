class ScreenType {
  static const notes = ScreenType._('NOTAS');
  static const habits = ScreenType._('HABITOS');
  static const tasks = ScreenType._('TAREAS');
  static const newHabit = ScreenType._('NUEVO HABITO');
  static const detailHabit = ScreenType._('DETALLE HABITO');

  final String name;

  const ScreenType._(this.name);
}