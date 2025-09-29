import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  static String? get supabaseUrl {
    if (kIsWeb) {
      // En web, priorizar las variables de entorno del compilador
      const String webUrl = String.fromEnvironment('SUPABASE_URL');
      if (webUrl.isNotEmpty) return webUrl;
      
      // Fallback para desarrollo local
      return dotenv.env['SUPABASE_URL'];
    } else {
      // Para móvil, windows usar dotenv
      return dotenv.env['SUPABASE_URL'];
    }
  }

  static String? get supabaseAnonKey {
    if (kIsWeb) {
      const String webKey = String.fromEnvironment('SUPABASE_ANON_KEY');
      if (webKey.isNotEmpty) return webKey;
      
      return dotenv.env['SUPABASE_ANON_KEY'];
    } else {
      return dotenv.env['SUPABASE_ANON_KEY'];
    }
  }

  static void validateConfig() {
    if (supabaseUrl == null || supabaseUrl!.isEmpty) {
      throw Exception('Supabase URL is not configured.');
    }
    if (supabaseAnonKey == null || supabaseAnonKey!.isEmpty) {
      throw Exception('Supabase Anon Key is not configured.');
    }
  }
}