import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hidratrack/Modelos/DashboardModels.dart';
import 'package:hidratrack/Servicos/AuthStorage.dart';

class AtletaService {
  static String getApiBaseUrl() {
    if (kIsWeb) {
      return 'http://localhost:8080';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.2.2.246:8080';
    }
    return 'http://localhost:8080';
  }

  static String get _baseUrl => '${getApiBaseUrl()}/api';
  
  /// Obter dados do dashboard do atleta autenticado
  static Future<Map<String, dynamic>> obterDashboardAtleta({
    required String token,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/atletas/dashboard'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        print('AtletaService obterDashboardAtleta status=${response.statusCode} body=${response.body}');
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Não autorizado - token inválido');
      } else {
        throw Exception('Erro ao obter dashboard: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro na requisição: $e');
    }
  }

  /// Obter histórico de consumo de água do atleta
  static Future<List<Map<String, dynamic>>> obterHistoricoConsumo({
    required String token,
    required String dataInicio,
    required String dataFim,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/atletas/consumo?dataInicio=$dataInicio&dataFim=$dataFim',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Erro ao obter histórico: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro na requisição: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> obterHistoricoAtleta({
    int? dias,
  }) async {
    final token = AuthStorage.token;
    if (token.isEmpty) {
      throw Exception('Token não encontrado');
    }

    final query = dias != null ? '?dias=$dias' : '';
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/atletas/historico$query'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Erro ao obter histórico: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro na requisição: $e');
    }
  }

  /// Criar uma nova sessão de treino para o atleta autenticado
  static Future<Map<String, dynamic>> criarSessao({
    required int atletaId,
    required double temperaturaAmbiente,
    required int umidadeRelativa,
  }) async {
    final token = AuthStorage.token;
    if (token.isEmpty) {
      throw Exception('Token não encontrado');
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/sessoes/criar'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'atletaId': atletaId,
          'temperaturaAmbiente': temperaturaAmbiente,
          'umidadeRelativa': umidadeRelativa,
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erro ao criar sessão: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro na requisição: $e');
    }
  }

  static Future<Map<String, dynamic>> finalizarSessao({
    required int sessaoId,
    required int durationMinutos,
  }) async {
    final token = AuthStorage.token;
    if (token.isEmpty) {
      throw Exception('Token não encontrado');
    }

    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/sessoes/$sessaoId/finalizar?durationMinutos=$durationMinutos'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erro ao finalizar sessão: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro na requisição: $e');
    }
  }

  static Future<bool> registrarConsumoSessao({
    required int sessaoId,
    required int quantidadeMl,
    int? tempoDecorridoMinutos,
    String? tipoLiquido,
  }) async {
    final token = AuthStorage.token;
    if (token.isEmpty) {
      throw Exception('Token não encontrado');
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/sessoes/$sessaoId/consumo'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'quantidadeMl': quantidadeMl,
          'tempoDecorridoMinutos': tempoDecorridoMinutos,
          'tipoLiquido': tipoLiquido ?? 'Água',
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Erro ao registrar consumo: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro na requisição: $e');
    }
  }

  /// Obter métricas de sessão de treino
  static Future<Map<String, dynamic>> obterMetricasSessao({
    required String token,
    required int sessaoId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/atletas/sessoes/$sessaoId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erro ao obter métricas: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro na requisição: $e');
    }
  }

  /// Registrar consumo de água
  static Future<bool> registrarConsumo({
    required String token,
    required double mlConsumidos,
    required DateTime dataHora,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/atletas/consumo'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'mlConsumidos': mlConsumidos,
          'dataHora': dataHora.toIso8601String(),
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Erro ao registrar consumo: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro na requisição: $e');
    }
  }

  /// Resolves the authenticated athlete ID from token or cached storage.
  static Future<int> obterAtletaIdAutenticado() async {
    if (AuthStorage.userId != null) {
      return AuthStorage.userId!;
    }

    final token = AuthStorage.token;
    if (token.isEmpty) {
      throw Exception('Token não encontrado');
    }

    final perfil = await obterPerfilAtleta(token: token);
    final idValue = perfil['id'] ?? perfil['userId'] ?? perfil['atletaId'];
    final atletaId = idValue is num
        ? idValue.toInt()
        : int.tryParse(idValue?.toString() ?? '');

    if (atletaId == null) {
      throw Exception('ID do atleta não encontrado no perfil');
    }

    AuthStorage.userId = atletaId;
    return atletaId;
  }

  /// Obter perfil do atleta
  static Future<Map<String, dynamic>> obterPerfilAtleta({
    required String token,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/atletas/perfil'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erro ao obter perfil: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro na requisição: $e');
    }
  }
}
