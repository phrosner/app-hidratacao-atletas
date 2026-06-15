import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  static const _keyToken = 'auth_token';
  static const _keyNome = 'auth_nome';
  static const _keyTipo = 'auth_tipo';
  static const _keyUserId = 'auth_user_id';
  static const _keyRemember = 'auth_remember';

  static String token = '';
  static String nome = '';
  static String tipoUsuario = '';
  static int? userId;
  static bool rememberMe = false;

  static SharedPreferences? _prefs;

  static bool get isAuthenticated => token.isNotEmpty;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    rememberMe = _prefs!.getBool(_keyRemember) ?? false;
    if (!rememberMe) return;

    token = _prefs!.getString(_keyToken) ?? '';
    nome = _prefs!.getString(_keyNome) ?? '';
    tipoUsuario = _prefs!.getString(_keyTipo) ?? '';
    userId = _prefs!.getInt(_keyUserId);
  }

  static Future<void> saveSession({required bool remember}) async {
    rememberMe = remember;
    final prefs = _prefs ?? await SharedPreferences.getInstance();

    await prefs.setBool(_keyRemember, remember);
    if (remember) {
      await prefs.setString(_keyToken, token);
      await prefs.setString(_keyNome, nome);
      await prefs.setString(_keyTipo, tipoUsuario);
      if (userId != null) {
        await prefs.setInt(_keyUserId, userId!);
      } else {
        await prefs.remove(_keyUserId);
      }
    } else {
      await _clearPersisted(prefs);
    }
  }

  static Future<void> clear() async {
    token = '';
    nome = '';
    tipoUsuario = '';
    userId = null;
    rememberMe = false;

    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await _clearPersisted(prefs);
    await prefs.setBool(_keyRemember, false);
  }

  static Future<void> _clearPersisted(SharedPreferences prefs) async {
    await prefs.remove(_keyToken);
    await prefs.remove(_keyNome);
    await prefs.remove(_keyTipo);
    await prefs.remove(_keyUserId);
  }
}
