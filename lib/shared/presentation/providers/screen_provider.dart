import 'package:find_your_mind/features/notes/presentation/screens/notes_screen.dart';
import 'package:flutter/widgets.dart';

class ScreensProvider extends ChangeNotifier {
  Widget _currentScreenWidget = const NotesScreen();

  Widget get currentPageWidget => _currentScreenWidget;

  void setScreenWidget(Widget screen) {
    _currentScreenWidget = screen;
    notifyListeners();
  }
}