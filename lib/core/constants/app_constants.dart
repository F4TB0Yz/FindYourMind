/// Archivo barrel para importar todas las constantes de la aplicación
/// 
/// Uso: import 'package:find_your_mind/core/constants/app_constants.dart';
/// 
/// Esto permite acceder a todas las constantes desde un solo import:
/// - AnimationConstants.fastAnimation
/// - AppStrings.habitsTitle
/// 
/// Los colores ya no se importan desde aquí. Usar Theme.of(context).colorScheme.*
library;

export 'animation_constants.dart';
export 'string_constants.dart';
