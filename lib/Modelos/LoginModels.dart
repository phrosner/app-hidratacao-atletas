enum TipoUsuario { atleta, treinador, nutricionista }

class LoginRequest {
  final String identificador;
  final String senha;
  final TipoUsuario tipoUsuario;

  LoginRequest({
    required this.identificador,
    required this.senha,
    required this.tipoUsuario,
  });

  Map<String, dynamic> toJson() {
    return {
      'identificador': identificador,
      'senha': senha,
      'tipoUsuario': tipoUsuario.toString().split('.').last,
    };
  }
}

class LoginResponse {
  final int id;
  final String nome;
  final String email;
  final TipoUsuario tipoUsuario;
  final String token;

  LoginResponse({
    required this.id,
    required this.nome,
    required this.email,
    required this.tipoUsuario,
    required this.token,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      id: json['id'] ?? 0,
      nome: json['nome'] ?? '',
      email: json['email'] ?? '',
      tipoUsuario: _parseUsuarioType(json['tipoUsuario']),
      token: json['token'] ?? '',
    );
  }

  static TipoUsuario _parseUsuarioType(String? type) {
    switch (type) {
      case 'atleta':
        return TipoUsuario.atleta;
      case 'treinador':
        return TipoUsuario.treinador;
      case 'nutricionista':
        return TipoUsuario.nutricionista;
      default:
        return TipoUsuario.atleta;
    }
  }
}
