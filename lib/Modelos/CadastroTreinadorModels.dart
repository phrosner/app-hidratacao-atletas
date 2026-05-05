class CadastroTreinadorRequest {
  final String nomeCompleto;
  final String email;
  final String dataNascimento;
  final String senha;
  final String senhaConfirmacao;

  CadastroTreinadorRequest({
    required this.nomeCompleto,
    required this.email,
    required this.dataNascimento,
    required this.senha,
    required this.senhaConfirmacao,
  });

  Map<String, dynamic> toJson() {
    return {
      'nomeCompleto': nomeCompleto,
      'email': email,
      'dataNascimento': dataNascimento,
      'senha': senha,
      'senhaConfirmacao': senhaConfirmacao,
    };
  }
}

class CadastroTreinadorResponse {
  final int id;
  final String nomeCompleto;
  final String email;
  final String dataNascimento;
  final DateTime dataCadastro;
  final String token;

  CadastroTreinadorResponse({
    required this.id,
    required this.nomeCompleto,
    required this.email,
    required this.dataNascimento,
    required this.dataCadastro,
    required this.token,
  });

  factory CadastroTreinadorResponse.fromJson(Map<String, dynamic> json) {
    return CadastroTreinadorResponse(
      id: json['id'] ?? 0,
      nomeCompleto: json['nomeCompleto'] ?? '',
      email: json['email'] ?? '',
      dataNascimento: json['dataNascimento'] ?? '',
      dataCadastro:
          DateTime.tryParse(json['dataCadastro'] ?? '') ?? DateTime.now(),
      token: json['token'] ?? '',
    );
  }
}
