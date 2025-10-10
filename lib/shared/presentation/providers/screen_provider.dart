import 'package:find_your_mind/shared/domain/screen_type.dart';
import 'package:flutter/widgets.dart';

class ScreensProvider extends ChangeNotifier {
  Widget _currentScreenWidget;
  ScreenType _currentScreenType;

  ScreensProvider(this._currentScreenWidget, this._currentScreenType);

  Widget get currentPageWidget => _currentScreenWidget;
  ScreenType get currentScreenType => _currentScreenType;

  void setScreenWidget(Widget screen, ScreenType screenType) {
    _currentScreenWidget = screen;
    _currentScreenType = screenType;
    notifyListeners();
  }
}