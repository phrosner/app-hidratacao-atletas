class CadastroAtletaRequest {
  final String nomeCompleto;
  final String? codigoIdentificacao;
  final String dataNascimento;
  final double pesoBase;
  final double altura;

  CadastroAtletaRequest({
    required this.nomeCompleto,
    this.codigoIdentificacao,
    required this.dataNascimento,
    required this.pesoBase,
    required this.altura,
  });

  Map<String, dynamic> toJson() {
    return {
      'nomeCompleto': nomeCompleto,
      'codigoIdentificacao': codigoIdentificacao,
      'dataNascimento': dataNascimento,
      'pesoBase': pesoBase,
      'altura': altura,
    };
  }
}

class CadastroAtletaResponse {
  final int id;
  final String nomeCompleto;
  final String dataNascimento;
  final double pesoBase;
  final double altura;
  final DateTime dataCadastro;

  CadastroAtletaResponse({
    required this.id,
    required this.nomeCompleto,
    required this.dataNascimento,
    required this.pesoBase,
    required this.altura,
    required this.dataCadastro,
  });

  factory CadastroAtletaResponse.fromJson(Map<String, dynamic> json) {
    return CadastroAtletaResponse(
      id: json['id'] ?? 0,
      nomeCompleto: json['nomeCompleto'] ?? '',
      dataNascimento: json['dataNascimento'] ?? '',
      pesoBase: (json['pesoBase'] ?? 0.0).toDouble(),
      altura: (json['altura'] ?? 0.0).toDouble(),
      dataCadastro:
          DateTime.tryParse(json['dataCadastro'] ?? '') ?? DateTime.now(),
    );
  }
}
