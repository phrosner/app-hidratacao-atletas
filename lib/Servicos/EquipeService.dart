import 'dart:math';

import 'package:hidratrack/Modelos/AtletaListModels.dart';
import 'package:hidratrack/Modelos/EquipesModels.dart';

class EquipeService {
  static final List<Equipe> _equipes = [];
  static final List<AtletaListItem> _atletas = [];
  static int _nextId = 1;
  static int _nextAtletaId = 1001;

  static void _ensureSeeded() {
    if (_equipes.isNotEmpty || _atletas.isNotEmpty) return;

    _atletas.addAll([
      AtletaListItem(
        id: 1,
        categoria: 'SUB-20',
        nome: 'Carlos Silva',
        status: 'DESIDRATACAO CRITICA',
        hidratacao: 4,
        idade: 19,
        genero: 'Masculino',
        modalidade: 'Futebol',
        equipeAtual: 'Equipe Sub-20',
        nivel: 'Competitivo',
        pesoKg: 74.2,
        alturaCm: 178,
      ),
      AtletaListItem(
        id: 2,
        categoria: 'OLIMPICO',
        nome: 'Gabriel Santos',
        status: 'EM TREINO',
        hidratacao: 85,
        idade: 23,
        genero: 'Masculino',
        modalidade: 'Natacao',
        equipeAtual: 'Equipe Olimpica',
        nivel: 'Elite',
        pesoKg: 82.4,
        alturaCm: 186,
      ),
      AtletaListItem(
        id: 3,
        categoria: 'SUB-17',
        nome: 'Lucas Ferreira',
        status: 'ATENCAO',
        hidratacao: 62,
        idade: 17,
        genero: 'Masculino',
        modalidade: 'Futebol',
        equipeAtual: 'Equipe Sub-20',
        nivel: 'Intermediario',
        pesoKg: 69.8,
        alturaCm: 174,
      ),
      AtletaListItem(
        id: 4,
        categoria: 'MASTER',
        nome: 'Rodrigo Silva',
        status: 'DESCANSO',
        hidratacao: 88,
        idade: 34,
        genero: 'Masculino',
        modalidade: 'Corrida',
        equipeAtual: 'Equipe Olimpica',
        nivel: 'Avancado',
        pesoKg: 78.0,
        alturaCm: 181,
      ),
      AtletaListItem(
        id: 5,
        categoria: 'ELITE PERFORMER',
        nome: 'Marcus V. Silva',
        status: 'RECUPERACAO',
        hidratacao: 91,
        idade: 27,
        genero: 'Masculino',
        modalidade: 'CrossFit',
        equipeAtual: 'Alpha Warriors Elite',
        nivel: 'Elite',
        pesoKg: 88.5,
        alturaCm: 184,
      ),
      AtletaListItem(
        id: 6,
        categoria: 'POWER LIFTER',
        nome: 'Elena Rodrigues',
        status: 'PRONTO',
        hidratacao: 79,
        idade: 25,
        genero: 'Feminino',
        modalidade: 'Levantamento de Peso',
        equipeAtual: 'Alpha Warriors Elite',
        nivel: 'Avancado',
        pesoKg: 68.7,
        alturaCm: 170,
      ),
      AtletaListItem(
        id: 7,
        categoria: 'ENDURANCE PRO',
        nome: 'Ricardo Neves',
        status: 'EM TREINO',
        hidratacao: 83,
        idade: 29,
        genero: 'Masculino',
        modalidade: 'Triathlon',
        equipeAtual: 'Alpha Warriors Elite',
        nivel: 'Elite',
        pesoKg: 72.9,
        alturaCm: 176,
      ),
    ]);

    _equipes.addAll([
      Equipe(
        id: 1,
        nome: 'Equipe Sub-20',
        status: 'FUTEBOL MASCULINO',
        numeroAtletas: 22,
        percentualHidratacao: 94,
        codigoEquipe: 'HT-AAAA01',
        categoria: 'Sub-20',
        modalidade: 'Futebol',
        descricao: 'Equipe de desenvolvimento com monitoramento semanal.',
        atletasIds: [1, 3],
      ),
      Equipe(
        id: 2,
        nome: 'Equipe Olimpica',
        status: 'NATACAO',
        numeroAtletas: 8,
        percentualHidratacao: 81,
        codigoEquipe: 'HT-AAAA02',
        categoria: 'Olimpico',
        modalidade: 'Natacao',
        descricao: 'Grupo olimpico com foco em endurance e recuperacao.',
        atletasIds: [2, 4],
      ),
      Equipe(
        id: 3,
        nome: 'Base Feminina',
        status: 'FUTEBOL FEMININO',
        numeroAtletas: 16,
        percentualHidratacao: 76,
        codigoEquipe: 'HT-AAAA03',
        categoria: 'Sub-17',
        modalidade: 'Futebol',
        descricao: 'Base formativa com controle de risco por microciclo.',
        atletasIds: [6],
      ),
    ]);

    _nextId = 4;
  }

  static String gerarCodigoEquipe() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    final code = List.generate(
      6,
      (_) => chars[random.nextInt(chars.length)],
    ).join();
    return 'HT-$code';
  }

  static int _mediaHidratacao(List<int> atletasIds) {
    if (atletasIds.isEmpty) return 0;

    final atletas = _atletas
        .where((atleta) => atletasIds.contains(atleta.id))
        .toList(growable: false);
    if (atletas.isEmpty) return 0;

    final total = atletas.fold<int>(
      0,
      (sum, atleta) => sum + atleta.hidratacao,
    );
    return (total / atletas.length).round();
  }

  static int _numeroAtletasVisual(Equipe equipe, List<int> atletasIds) {
    if (atletasIds.isNotEmpty) return atletasIds.length;
    return equipe.numeroAtletas;
  }

  static Future<Equipe> criarEquipe({
    required String nome,
    required String categoria,
    required String modalidade,
    required String descricao,
    required List<int> atletasIds,
  }) async {
    try {
      _ensureSeeded();
      await Future.delayed(const Duration(milliseconds: 500));

      final nomeNormalizado = nome.trim();
      if (nomeNormalizado.isEmpty || categoria.isEmpty || modalidade.isEmpty) {
        throw Exception('Campos obrigatorios nao preenchidos');
      }

      final equipe = Equipe(
        id: _nextId++,
        nome: nomeNormalizado,
        status: modalidade.toUpperCase(),
        numeroAtletas: atletasIds.length,
        percentualHidratacao: _mediaHidratacao(atletasIds).toDouble(),
        codigoEquipe: gerarCodigoEquipe(),
        categoria: categoria,
        modalidade: modalidade,
        descricao: descricao.trim(),
        atletasIds: List<int>.from(atletasIds),
      );

      _equipes.add(equipe);
      return equipe;
    } catch (e) {
      throw Exception('Erro ao criar equipe: $e');
    }
  }

  static Future<List<Equipe>> listarEquipes() async {
    try {
      _ensureSeeded();
      await Future.delayed(const Duration(milliseconds: 250));
      return List<Equipe>.unmodifiable(_equipes);
    } catch (e) {
      throw Exception('Erro ao listar equipes: $e');
    }
  }

  static Future<List<AtletaListItem>> listarAtletas() async {
    try {
      _ensureSeeded();
      await Future.delayed(const Duration(milliseconds: 250));
      return List<AtletaListItem>.unmodifiable(_atletas);
    } catch (e) {
      throw Exception('Erro ao listar atletas: $e');
    }
  }

  static Future<List<AtletaListItem>> listarAtletasPorEquipe(
    List<int> atletasIds,
  ) async {
    try {
      _ensureSeeded();
      await Future.delayed(const Duration(milliseconds: 180));
      return _atletas
          .where((atleta) => atletasIds.contains(atleta.id))
          .toList(growable: false);
    } catch (e) {
      throw Exception('Erro ao listar atletas da equipe: $e');
    }
  }

  static Future<List<AtletaListItem>> buscarAtletas(String query) async {
    try {
      _ensureSeeded();
      await Future.delayed(const Duration(milliseconds: 180));
      final normalized = query.trim().toLowerCase();
      if (normalized.isEmpty) {
        return List<AtletaListItem>.unmodifiable(_atletas);
      }

      return _atletas
          .where(
            (atleta) =>
                atleta.nome.toLowerCase().contains(normalized) ||
                atleta.categoria.toLowerCase().contains(normalized) ||
                atleta.modalidade.toLowerCase().contains(normalized),
          )
          .toList(growable: false);
    } catch (e) {
      throw Exception('Erro ao buscar atletas: $e');
    }
  }

  static Future<Equipe?> obterEquipe(int id) async {
    try {
      _ensureSeeded();
      await Future.delayed(const Duration(milliseconds: 250));
      return _equipes.cast<Equipe?>().firstWhere(
            (equipe) => equipe?.id == id,
            orElse: () => null,
          );
    } catch (e) {
      throw Exception('Erro ao obter equipe: $e');
    }
  }

  static Future<Equipe?> obterEquipePorCodigo(String codigoEquipe) async {
    try {
      _ensureSeeded();
      await Future.delayed(const Duration(milliseconds: 250));
      final normalized = codigoEquipe.trim().toUpperCase();
      final matches = _equipes
          .where((equipe) => equipe.codigoEquipe.toUpperCase() == normalized)
          .toList();
      return matches.isEmpty ? null : matches.first;
    } catch (e) {
      throw Exception('Erro ao obter equipe por codigo: $e');
    }
  }

  static Future<int> adicionarAtletaPorCodigoEquipe({
    required String codigoEquipe,
    required String nomeAtleta,
  }) async {
    final atletaNome = nomeAtleta;
    try {
      final equipe = await obterEquipePorCodigo(codigoEquipe);
      if (equipe == null) {
        throw Exception('Equipe nao encontrada para o codigo informado.');
      }

      final atletaId = _nextAtletaId++;
      final atletasIds = List<int>.from(equipe.atletasIds ?? []);

      if (atletasIds.contains(atletaId)) {
        return atletaId;
      }

      atletasIds.add(atletaId);

      final sucesso = await atualizarEquipe(
        id: equipe.id,
        nome: equipe.nome,
        categoria: equipe.categoria ?? '',
        modalidade: equipe.modalidade ?? '',
        descricao: equipe.descricao ?? '',
        atletasIds: atletasIds,
      );

      if (!sucesso) {
        throw Exception('Falha ao anexar atleta $atletaNome a equipe.');
      }

      return atletaId;
    } catch (e) {
      throw Exception('Erro ao adicionar atleta $atletaNome na equipe: $e');
    }
  }

  static Future<bool> atualizarEquipe({
    required int id,
    required String nome,
    required String categoria,
    required String modalidade,
    required String descricao,
    required List<int> atletasIds,
  }) async {
    try {
      _ensureSeeded();
      await Future.delayed(const Duration(milliseconds: 500));

      final index = _equipes.indexWhere((equipe) => equipe.id == id);
      if (index < 0) return false;

      final existing = _equipes[index];
      _equipes[index] = Equipe(
        id: existing.id,
        nome: nome.trim(),
        status:
            modalidade.isNotEmpty ? modalidade.toUpperCase() : existing.status,
        numeroAtletas: _numeroAtletasVisual(existing, atletasIds),
        percentualHidratacao: atletasIds.isEmpty
            ? existing.percentualHidratacao
            : _mediaHidratacao(atletasIds).toDouble(),
        codigoEquipe: existing.codigoEquipe,
        categoria: categoria,
        modalidade: modalidade,
        descricao: descricao.trim(),
        atletasIds: List<int>.from(atletasIds),
      );

      return true;
    } catch (e) {
      throw Exception('Erro ao atualizar equipe: $e');
    }
  }

  static Future<bool> deletarEquipe(int id) async {
    try {
      _ensureSeeded();
      await Future.delayed(const Duration(milliseconds: 300));
      _equipes.removeWhere((equipe) => equipe.id == id);
      return true;
    } catch (e) {
      throw Exception('Erro ao deletar equipe: $e');
    }
  }
}
