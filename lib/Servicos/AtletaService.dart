import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hidratrack/Servicos/AuthStorage.dart';
import 'package:http/http.dart' as http;

class AtletaService {
  static String getApiBaseUrl() {
    if (kIsWeb) {
      return 'http://localhost:8080';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8080';
    }
    return 'http://localhost:8080';
  }

  static String get _baseUrl => '${getApiBaseUrl()}/api';

  static Map<String, String> _headers(String token) => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };

  static http.Client _clientOrDefault(http.Client? httpClient) =>
      httpClient ?? http.Client();

  static void _closeIfOwned(http.Client client, http.Client? provided) {
    if (provided == null) {
      client.close();
    }
  }

  static Future<Map<String, dynamic>> obterDashboardAtleta({
    required String token,
    http.Client? httpClient,
  }) async {
    final client = _clientOrDefault(httpClient);

    try {
      final response = await client.get(
        Uri.parse('$_baseUrl/atletas/dashboard'),
        headers: _headers(token),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      if (response.statusCode == 401) {
        throw Exception('Nao autorizado - token invalido');
      }
      throw Exception('Erro ao obter dashboard: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erro na requisicao: $e');
    } finally {
      _closeIfOwned(client, httpClient);
    }
  }

  static Future<List<Map<String, dynamic>>> obterHistoricoConsumo({
    required String token,
    required String dataInicio,
    required String dataFim,
    http.Client? httpClient,
  }) async {
    final client = _clientOrDefault(httpClient);

    try {
      final response = await client.get(
        Uri.parse(
          '$_baseUrl/atletas/consumo?dataInicio=$dataInicio&dataFim=$dataFim',
        ),
        headers: _headers(token),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        return data.cast<Map<String, dynamic>>();
      }
      throw Exception('Erro ao obter historico: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erro na requisicao: $e');
    } finally {
      _closeIfOwned(client, httpClient);
    }
  }

  static Future<List<Map<String, dynamic>>> obterHistoricoAtleta({
    int? dias,
    http.Client? httpClient,
  }) async {
    final token = AuthStorage.token;
    if (token.isEmpty) {
      throw Exception('Token nao encontrado');
    }

    final client = _clientOrDefault(httpClient);
    final query = dias != null ? '?dias=$dias' : '';

    try {
      final response = await client.get(
        Uri.parse('$_baseUrl/atletas/historico$query'),
        headers: _headers(token),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        return data.cast<Map<String, dynamic>>();
      }
      throw Exception('Erro ao obter historico: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erro na requisicao: $e');
    } finally {
      _closeIfOwned(client, httpClient);
    }
  }

  static Future<Map<String, dynamic>> criarSessao({
    required int atletaId,
    required double temperaturaAmbiente,
    required int umidadeRelativa,
    http.Client? httpClient,
  }) async {
    final token = AuthStorage.token;
    if (token.isEmpty) {
      throw Exception('Token nao encontrado');
    }

    final client = _clientOrDefault(httpClient);

    try {
      final response = await client.post(
        Uri.parse('$_baseUrl/sessoes/criar'),
        headers: _headers(token),
        body: jsonEncode({
          'atletaId': atletaId,
          'temperaturaAmbiente': temperaturaAmbiente,
          'umidadeRelativa': umidadeRelativa,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception('Erro ao criar sessao: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erro na requisicao: $e');
    } finally {
      _closeIfOwned(client, httpClient);
    }
  }

  static Future<Map<String, dynamic>> finalizarSessao({
    required int sessaoId,
    required int durationMinutos,
    http.Client? httpClient,
  }) async {
    final token = AuthStorage.token;
    if (token.isEmpty) {
      throw Exception('Token nao encontrado');
    }

    final client = _clientOrDefault(httpClient);

    try {
      final response = await client.put(
        Uri.parse(
          '$_baseUrl/sessoes/$sessaoId/finalizar?durationMinutos=$durationMinutos',
        ),
        headers: _headers(token),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception('Erro ao finalizar sessao: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erro na requisicao: $e');
    } finally {
      _closeIfOwned(client, httpClient);
    }
  }

  static Future<bool> registrarConsumoSessao({
    required int sessaoId,
    required int quantidadeMl,
    int? tempoDecorridoMinutos,
    String? tipoLiquido,
    http.Client? httpClient,
  }) async {
    final token = AuthStorage.token;
    if (token.isEmpty) {
      throw Exception('Token nao encontrado');
    }

    final client = _clientOrDefault(httpClient);

    try {
      final response = await client.post(
        Uri.parse('$_baseUrl/sessoes/$sessaoId/consumo'),
        headers: _headers(token),
        body: jsonEncode({
          'quantidadeMl': quantidadeMl,
          'tempoDecorridoMinutos': tempoDecorridoMinutos,
          'tipoLiquido': tipoLiquido ?? 'Agua',
        }),
      );

      if (response.statusCode == 200) {
        return true;
      }
      throw Exception('Erro ao registrar consumo: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erro na requisicao: $e');
    } finally {
      _closeIfOwned(client, httpClient);
    }
  }

  static Future<Map<String, dynamic>> obterMetricasSessao({
    required String token,
    required int sessaoId,
    http.Client? httpClient,
  }) async {
    final client = _clientOrDefault(httpClient);

    try {
      final response = await client.get(
        Uri.parse('$_baseUrl/atletas/sessoes/$sessaoId'),
        headers: _headers(token),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception('Erro ao obter metricas: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erro na requisicao: $e');
    } finally {
      _closeIfOwned(client, httpClient);
    }
  }

  static Future<bool> registrarConsumo({
    required String token,
    required double mlConsumidos,
    required DateTime dataHora,
    http.Client? httpClient,
  }) async {
    final client = _clientOrDefault(httpClient);

    try {
      final response = await client.post(
        Uri.parse('$_baseUrl/atletas/consumo'),
        headers: _headers(token),
        body: jsonEncode({
          'mlConsumidos': mlConsumidos,
          'dataHora': dataHora.toIso8601String(),
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      }
      throw Exception('Erro ao registrar consumo: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erro na requisicao: $e');
    } finally {
      _closeIfOwned(client, httpClient);
    }
  }

  static Future<int> obterAtletaIdAutenticado({http.Client? httpClient}) async {
    if (AuthStorage.userId != null) {
      return AuthStorage.userId!;
    }

    final token = AuthStorage.token;
    if (token.isEmpty) {
      throw Exception('Token nao encontrado');
    }

    final perfil = await obterPerfilAtleta(
      token: token,
      httpClient: httpClient,
    );
    final idValue = perfil['id'] ?? perfil['userId'] ?? perfil['atletaId'];
    final atletaId = idValue is num
        ? idValue.toInt()
        : int.tryParse(idValue?.toString() ?? '');

    if (atletaId == null) {
      throw Exception('ID do atleta nao encontrado no perfil');
    }

    AuthStorage.userId = atletaId;
    return atletaId;
  }

  static Future<Map<String, dynamic>> obterPerfilAtleta({
    required String token,
    http.Client? httpClient,
  }) async {
    final client = _clientOrDefault(httpClient);

    try {
      final response = await client.get(
        Uri.parse('$_baseUrl/atletas/perfil'),
        headers: _headers(token),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception('Erro ao obter perfil: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erro na requisicao: $e');
    } finally {
      _closeIfOwned(client, httpClient);
    }
  }
}
