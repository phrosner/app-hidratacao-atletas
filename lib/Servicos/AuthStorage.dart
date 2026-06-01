class AuthStorage {
  static String token = '';
  static String nome = '';
  static String tipoUsuario = '';
  static int? userId;

  static bool get isAuthenticated => token.isNotEmpty;

  static void clear() {
    token = '';
    nome = '';
    tipoUsuario = '';
    userId = null;
  }
}
