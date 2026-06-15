import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:hidratrack/Modelos/AtletaListModels.dart';
import 'package:hidratrack/Modelos/DashboardModels.dart';
import 'package:hidratrack/Modelos/EquipesModels.dart';
import 'package:hidratrack/Servicos/AtletaService.dart';
import 'package:hidratrack/Servicos/AuthStorage.dart';

class TreinadorService {
  static String get _baseUrl => '${AtletaService.getApiBaseUrl()}/api';

  static Map<String, String> _headers() => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${AuthStorage.token}',
      };

  static Future<Map<String, dynamic>> obterDashboard() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/treinadores/dashboard'),
      headers: _headers(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception(_extrairErro(response, 'Erro ao carregar dashboard'));
  }

  static Future<List<Equipe>> listarEquipes() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/equipes'),
      headers: _headers(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;
      return data
          .map((item) => Equipe.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    throw Exception(_extrairErro(response, 'Erro ao listar equipes'));
  }

  static Future<Equipe> criarEquipe({
    required String nome,
    required String categoria,
    required String modalidade,
    required String descricao,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/equipes'),
      headers: _headers(),
      body: jsonEncode({
        'nome': nome,
        'categoria': categoria,
        'modalidade': modalidade,
        'descricao': descricao,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return Equipe.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception(_extrairErro(response, 'Erro ao criar equipe'));
  }

  static Future<Map<String, dynamic>> obterEquipeDetalhe(int id) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/equipes/$id'),
      headers: _headers(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception(_extrairErro(response, 'Erro ao obter equipe'));
  }

  static Future<Map<String, dynamic>> atualizarEquipe({
    required int id,
    required String nome,
    required String categoria,
    required String modalidade,
    required String descricao,
  }) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/equipes/$id'),
      headers: _headers(),
      body: jsonEncode({
        'nome': nome,
        'categoria': categoria,
        'modalidade': modalidade,
        'descricao': descricao,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception(_extrairErro(response, 'Erro ao atualizar equipe'));
  }

  static Future<void> removerAtletaDaEquipe({
    required int equipeId,
    required int atletaId,
  }) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/equipes/$equipeId/atletas/$atletaId'),
      headers: _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception(_extrairErro(response, 'Erro ao remover atleta'));
    }
  }

  static Future<void> adicionarAtletaNaEquipe({
    required int equipeId,
    required int atletaId,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/equipes/$equipeId/atletas/$atletaId'),
      headers: _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception(_extrairErro(response, 'Erro ao adicionar atleta'));
    }
  }

  static Future<List<Map<String, dynamic>>> buscarAtletasDisponiveis({
    required int equipeId,
    required String query,
  }) async {
    final encoded = Uri.encodeQueryComponent(query);
    final response = await http.get(
      Uri.parse(
        '$_baseUrl/treinadores/atletas/disponiveis?equipeId=$equipeId&q=$encoded',
      ),
      headers: _headers(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;
      return data.cast<Map<String, dynamic>>();
    }
    throw Exception(_extrairErro(response, 'Erro na busca de atletas'));
  }

  static Future<List<AtletaListItem>> listarAtletas() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/treinadores/atletas'),
      headers: _headers(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;
      return data
          .map((item) => AtletaListItem.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    throw Exception(_extrairErro(response, 'Erro ao listar atletas'));
  }

  static Future<Map<String, dynamic>> obterAtletaDetalhe(int atletaId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/treinadores/atletas/$atletaId'),
      headers: _headers(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception(_extrairErro(response, 'Erro ao obter atleta'));
  }

  static Future<List<Atleta>> listarAlertas() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/treinadores/alertas'),
      headers: _headers(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;
      return data
          .map((item) => Atleta.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    throw Exception(_extrairErro(response, 'Erro ao listar alertas'));
  }

  static Future<Map<String, dynamic>> cadastrarAtleta({
    required String nome,
    required String codigoEquipe,
    required String dataNascimento,
    required double peso,
    required int altura,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/cadastrar-atleta'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nome': nome,
        'codigoEquipe': codigoEquipe.trim().toUpperCase(),
        'dataNascimento': dataNascimento,
        'peso': peso,
        'altura': altura,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception(_extrairErro(response, 'Erro no cadastro do atleta'));
  }

  static Future<bool> validarCodigoEquipe(String codigo) async {
    final encoded = Uri.encodeComponent(codigo.trim().toUpperCase());
    final response = await http.get(
      Uri.parse('$_baseUrl/equipes/validar/$encoded'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return body['valido'] == true;
    }
    return false;
  }

  static String _extrairErro(http.Response response, String fallback) {
    try {
      final body = jsonDecode(response.body);
      if (body is Map<String, dynamic> && body['erro'] != null) {
        return body['erro'].toString();
      }
    } catch (_) {}
    return '$fallback (${response.statusCode})';
  }
}
