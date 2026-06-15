import 'package:hidratrack/Modelos/EquipesModels.dart';
import 'package:hidratrack/Servicos/TreinadorService.dart';

class EquipeService {
  static Future<Equipe> criarEquipe({
    required String nome,
    required String categoria,
    required String modalidade,
    required String descricao,
    required List<int> atletasIds,
  }) async {
    if (nome.isEmpty || categoria.isEmpty || modalidade.isEmpty) {
      throw Exception('Campos obrigatórios não preenchidos');
    }

    return TreinadorService.criarEquipe(
      nome: nome,
      categoria: categoria,
      modalidade: modalidade,
      descricao: descricao,
    );
  }

  static Future<List<Equipe>> listarEquipes() async {
    return TreinadorService.listarEquipes();
  }

  static Future<Equipe?> obterEquipe(int id) async {
    try {
      final detalhe = await TreinadorService.obterEquipeDetalhe(id);
      return Equipe.fromJson(detalhe);
    } catch (_) {
      return null;
    }
  }

  static Future<Equipe?> obterEquipePorCodigo(String codigoEquipe) async {
    final valido = await TreinadorService.validarCodigoEquipe(codigoEquipe);
    if (!valido) return null;
    return null;
  }

  static Future<bool> atualizarEquipe({
    required int id,
    required String nome,
    required String categoria,
    required String modalidade,
    required String descricao,
    required List<int> atletasIds,
  }) async {
    await TreinadorService.atualizarEquipe(
      id: id,
      nome: nome,
      categoria: categoria,
      modalidade: modalidade,
      descricao: descricao,
    );
    return true;
  }

  static Future<bool> deletarEquipe(int id) async {
    throw UnimplementedError('Exclusão de equipe não implementada na UI');
  }
}
