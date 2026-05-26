import 'dart:math';

import 'package:hidratrack/Modelos/EquipesModels.dart';

class EquipeService {
  static final List<Equipe> _equipes = [];
  static int _nextId = 1;
  static int _nextAtletaId = 1001;

  static String gerarCodigoEquipe() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    final code = List.generate(
      6,
      (_) => chars[random.nextInt(chars.length)],
    ).join();
    return 'HT-$code';
  }

  // Simulando uma API - substituir com chamadas HTTP reais
  static Future<Equipe> criarEquipe({
    required String nome,
    required String categoria,
    required String modalidade,
    required String descricao,
    required List<int> atletasIds,
  }) async {
    try {
      // Simular delay de rede
      await Future.delayed(const Duration(seconds: 2));

      // Validações básicas
      if (nome.isEmpty || categoria.isEmpty || modalidade.isEmpty) {
        throw Exception('Campos obrigatórios não preenchidos');
      }

      final equipe = Equipe(
        id: _nextId++,
        nome: nome,
        status: categoria.isNotEmpty ? categoria : 'ATIVA',
        numeroAtletas: atletasIds.length,
        percentualHidratacao: 0.0,
        codigoEquipe: gerarCodigoEquipe(),
        categoria: categoria,
        modalidade: modalidade,
        descricao: descricao,
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
      await Future.delayed(const Duration(seconds: 1));
      return List<Equipe>.unmodifiable(_equipes);
    } catch (e) {
      throw Exception('Erro ao listar equipes: $e');
    }
  }

  static Future<Equipe?> obterEquipe(int id) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
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
      await Future.delayed(const Duration(milliseconds: 500));
      final normalized = codigoEquipe.trim().toUpperCase();
      final matches = _equipes
          .where((equipe) => equipe.codigoEquipe.toUpperCase() == normalized)
          .toList();
      return matches.isEmpty ? null : matches.first;
    } catch (e) {
      throw Exception('Erro ao obter equipe por código: $e');
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
        throw Exception('Equipe não encontrada para o código informado.');
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
        throw Exception('Falha ao anexar atleta $atletaNome à equipe.');
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
      await Future.delayed(const Duration(seconds: 2));

      final index = _equipes.indexWhere((equipe) => equipe.id == id);
      if (index < 0) return false;

      final existing = _equipes[index];
      _equipes[index] = Equipe(
        id: existing.id,
        nome: nome,
        status: categoria.isNotEmpty ? categoria : existing.status,
        numeroAtletas: atletasIds.length,
        percentualHidratacao: existing.percentualHidratacao,
        codigoEquipe: existing.codigoEquipe,
        categoria: categoria,
        modalidade: modalidade,
        descricao: descricao,
        atletasIds: List<int>.from(atletasIds),
      );

      return true;
    } catch (e) {
      throw Exception('Erro ao atualizar equipe: $e');
    }
  }

  static Future<bool> deletarEquipe(int id) async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      _equipes.removeWhere((equipe) => equipe.id == id);
      return true;
    } catch (e) {
      throw Exception('Erro ao deletar equipe: $e');
    }
  }
}
