class AtletaListItem {
  final int id;
  final String categoria;
  final String nome;
  final String status;
  final int hidratacao;

  AtletaListItem({
    required this.id,
    required this.categoria,
    required this.nome,
    required this.status,
    required this.hidratacao,
  });

  factory AtletaListItem.fromJson(Map<String, dynamic> json) {
    return AtletaListItem(
      id: json['id'] ?? 0,
      categoria: json['categoria'] ?? '',
      nome: json['nome'] ?? '',
      status: json['status'] ?? 'DESCANSO',
      hidratacao: (json['hidratacao'] is num
              ? json['hidratacao'] as num
              : int.tryParse(json['hidratacao']?.toString() ?? '0') ?? 0)
          .toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoria': categoria,
      'nome': nome,
      'status': status,
      'hidratacao': hidratacao,
    };
  }
}
