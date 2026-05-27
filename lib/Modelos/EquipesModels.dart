class Equipe {
  final int id;
  final String nome;
  final String status;
  final int numeroAtletas;
  final double percentualHidratacao;
  final String codigoEquipe;
  final String? categoria;
  final String? modalidade;
  final String? descricao;
  final List<int>? atletasIds;

  Equipe({
    required this.id,
    required this.nome,
    required this.status,
    required this.numeroAtletas,
    required this.percentualHidratacao,
    required this.codigoEquipe,
    this.categoria,
    this.modalidade,
    this.descricao,
    this.atletasIds,
  });

  factory Equipe.fromJson(Map<String, dynamic> json) {
    return Equipe(
      id: json['id'] ?? 0,
      nome: json['nome'] ?? '',
      status: json['status'] ?? 'ATIVA',
      numeroAtletas: json['numeroAtletas'] ?? 0,
      percentualHidratacao: (json['percentualHidratacao'] ?? 0.0).toDouble(),
      codigoEquipe: json['codigoEquipe'] ?? '',
      categoria: json['categoria'],
      modalidade: json['modalidade'],
      descricao: json['descricao'],
      atletasIds: List<int>.from(json['atletasIds'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'status': status,
      'numeroAtletas': numeroAtletas,
      'percentualHidratacao': percentualHidratacao,
      'codigoEquipe': codigoEquipe,
      'categoria': categoria,
      'modalidade': modalidade,
      'descricao': descricao,
      'atletasIds': atletasIds,
    };
  }
}
