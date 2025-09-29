import 'dart:convert';

import 'package:flutter/services.dart';

Future<List<String>> loadSvgIcons() async {
  final String manifestContent = await rootBundle.loadString('AssetManifest.json');
  final Map<String, dynamic> manifiestMap = json.decode(manifestContent);

  // Filtrar los que estan en la carpeta assets/icons y son .svg
  final List<String> icons = manifiestMap.keys
    .where((String key) => key.startsWith('assets/icons/') && key.endsWith('.svg'))
    .toList();

  return icons;
}