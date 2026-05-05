class Equipe {
  final int id;
  final String nome;
  final String status;
  final int numeroAtletas;
  final double percentualHidratacao;

  Equipe({
    required this.id,
    required this.nome,
    required this.status,
    required this.numeroAtletas,
    required this.percentualHidratacao,
  });

  factory Equipe.fromJson(Map<String, dynamic> json) {
    return Equipe(
      id: json['id'] ?? 0,
      nome: json['nome'] ?? '',
      status: json['status'] ?? 'DESCANSO',
      numeroAtletas: json['numeroAtletas'] ?? 0,
      percentualHidratacao: (json['percentualHidratacao'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'status': status,
      'numeroAtletas': numeroAtletas,
      'percentualHidratacao': percentualHidratacao,
    };
  }
}
