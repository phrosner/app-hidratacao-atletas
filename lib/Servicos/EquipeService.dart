import 'package:hidratrack/Modelos/EquipesModels.dart';

class EquipeService {
  // Simulando uma API - substituir com chamadas HTTP reais
  static Future<bool> criarEquipe({
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

      // Aqui você faria uma chamada POST para sua API
      // Exemplo:
      // final response = await http.post(
      //   Uri.parse('$baseUrl/equipes'),
      //   headers: {'Content-Type': 'application/json'},
      //   body: jsonEncode({
      //     'nome': nome,
      //     'categoria': categoria,
      //     'modalidade': modalidade,
      //     'descricao': descricao,
      //     'atletasIds': atletasIds,
      //   }),
      // );
      //
      // if (response.statusCode == 201) {
      //   return true;
      // } else {
      //   throw Exception('Erro ao criar equipe');
      // }

      // Por enquanto retorna true (sucesso simulado)
      return true;
    } catch (e) {
      throw Exception('Erro ao criar equipe: $e');
    }
  }

  static Future<List<Equipe>> listarEquipes() async {
    try {
      await Future.delayed(const Duration(seconds: 1));

      // Aqui você faria uma chamada GET para sua API
      // Exemplo:
      // final response = await http.get(
      //   Uri.parse('$baseUrl/equipes'),
      //   headers: {'Content-Type': 'application/json'},
      // );
      //
      // if (response.statusCode == 200) {
      //   List<dynamic> data = jsonDecode(response.body);
      //   return data.map((item) => Equipe.fromJson(item)).toList();
      // } else {
      //   throw Exception('Erro ao listar equipes');
      // }

      return [];
    } catch (e) {
      throw Exception('Erro ao listar equipes: $e');
    }
  }

  static Future<Equipe?> obterEquipe(int id) async {
    try {
      await Future.delayed(const Duration(seconds: 1));

      // Chamada GET para obter uma equipe específica
      // Exemplo:
      // final response = await http.get(
      //   Uri.parse('$baseUrl/equipes/$id'),
      //   headers: {'Content-Type': 'application/json'},
      // );
      //
      // if (response.statusCode == 200) {
      //   return Equipe.fromJson(jsonDecode(response.body));
      // }

      return null;
    } catch (e) {
      throw Exception('Erro ao obter equipe: $e');
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

      // Chamada PUT para atualizar uma equipe no backend Java
      // Exemplo:
      // final response = await http.put(
      //   Uri.parse('$baseUrl/equipes/$id'),
      //   headers: {
      //     'Content-Type': 'application/json',
      //     'Authorization': 'Bearer $token', // Se necessário
      //   },
      //   body: jsonEncode({
      //     'nome': nome,
      //     'categoria': categoria,
      //     'modalidade': modalidade,
      //     'descricao': descricao,
      //     'atletasIds': atletasIds,
      //   }),
      // );
      //
      // return response.statusCode == 200 || response.statusCode == 204;

      return true;
    } catch (e) {
      throw Exception('Erro ao atualizar equipe: $e');
    }
  }

  static Future<bool> deletarEquipe(int id) async {
    try {
      await Future.delayed(const Duration(seconds: 1));

      // Chamada DELETE para deletar uma equipe
      // Exemplo:
      // final response = await http.delete(
      //   Uri.parse('$baseUrl/equipes/$id'),
      //   headers: {'Content-Type': 'application/json'},
      // );
      //
      // return response.statusCode == 200;

      return true;
    } catch (e) {
      throw Exception('Erro ao deletar equipe: $e');
    }
  }
}
