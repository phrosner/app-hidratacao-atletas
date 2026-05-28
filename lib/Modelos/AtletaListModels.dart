class AtletaListItem {
  final int id;
  final String categoria;
  final String nome;
  final String status;
  final int hidratacao;
  final int idade;
  final String genero;
  final String modalidade;
  final String equipeAtual;
  final String nivel;
  final double pesoKg;
  final int alturaCm;

  AtletaListItem({
    required this.id,
    required this.categoria,
    required this.nome,
    required this.status,
    required this.hidratacao,
    this.idade = 24,
    this.genero = 'Masculino',
    this.modalidade = 'Futebol',
    this.equipeAtual = '',
    this.nivel = 'Avancado',
    this.pesoKg = 78.0,
    this.alturaCm = 180,
  });

  factory AtletaListItem.fromJson(Map<String, dynamic> json) {
    return AtletaListItem(
      id: json['id'] ?? 0,
      categoria: json['categoria'] ?? '',
      nome: json['nome'] ?? '',
      status: json['status'] ?? 'DESCANSO',
      hidratacao: (json['hidratacao'] ?? 0).toInt(),
      idade: (json['idade'] ?? 24).toInt(),
      genero: json['genero'] ?? 'Masculino',
      modalidade: json['modalidade'] ?? 'Futebol',
      equipeAtual: json['equipeAtual'] ?? '',
      nivel: json['nivel'] ?? 'Avancado',
      pesoKg: (json['pesoKg'] ?? 78.0).toDouble(),
      alturaCm: (json['alturaCm'] ?? 180).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoria': categoria,
      'nome': nome,
      'status': status,
      'hidratacao': hidratacao,
      'idade': idade,
      'genero': genero,
      'modalidade': modalidade,
      'equipeAtual': equipeAtual,
      'nivel': nivel,
      'pesoKg': pesoKg,
      'alturaCm': alturaCm,
    };
  }
}
