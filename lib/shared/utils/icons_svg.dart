
import 'package:flutter/services.dart';

Future<List<String>> loadSvgIcons() async {
  final AssetManifest manifest = await AssetManifest.loadFromAssetBundle(rootBundle);

  // Filtrar los que estan en la carpeta assets/icons y son .svg
  final List<String> icons = manifest.listAssets()
    .where((String key) => key.startsWith('assets/icons/') && key.endsWith('.svg'))
    .toList();

  return icons;
}