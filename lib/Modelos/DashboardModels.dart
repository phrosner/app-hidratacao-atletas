class Atleta {
  final int id;
  final String nome;
  final String situacao;
  final String descricao;
  final IconType iconType;

  Atleta({
    required this.id,
    required this.nome,
    required this.situacao,
    required this.descricao,
    required this.iconType,
  });

  factory Atleta.fromJson(Map<String, dynamic> json) {
    return Atleta(
      id: json['id'] ?? 0,
      nome: json['nome'] ?? '',
      situacao: json['situacao'] ?? 'Info',
      descricao: json['descricao'] ?? '',
      iconType: json['iconType'] == 'alerta' ? IconType.alerta : IconType.info,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'situacao': situacao,
      'descricao': descricao,
      'iconType': iconType == IconType.alerta ? 'alerta' : 'info',
    };
  }
}

enum IconType { alerta, info }

class ClimaDados {
  final double temperatura;
  final int umidade;
  final String condicao;

  ClimaDados({
    required this.temperatura,
    required this.umidade,
    required this.condicao,
  });

  factory ClimaDados.fromJson(Map<String, dynamic> json) {
    return ClimaDados(
      temperatura: (json['temperatura'] ?? 0.0).toDouble(),
      umidade: json['umidade'] ?? 0,
      condicao: json['condicao'] ?? 'Sem informação',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temperatura': temperatura,
      'umidade': umidade,
      'condicao': condicao,
    };
  }
}
