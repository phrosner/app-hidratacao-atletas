import 'package:http/http.dart' as http;
import 'dart:convert';

/// Cliente HTTP para comunicação com o backend HidraTrack.
/// Todas as chamadas são feitas para o servidor Spring Boot na porta 8080.
class HidraTrackApiClient {
  static const String baseUrl = 'http://localhost:8080/api';
  static const Duration timeout = Duration(seconds: 30);

  // Headers padrão para todas as requisições
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// ============== SESSÕES ==============

  /// Cria uma nova sessão de treino
  static Future<Map<String, dynamic>> criarSessao({
    required int atletaId,
    required double temperaturaAmbiente,
    required int umidadeRelativa,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/sessoes/criar'),
        headers: _headers,
        body: jsonEncode({
          'atletaId': atletaId,
          'temperaturaAmbiente': temperaturaAmbiente,
          'umidadeRelativa': umidadeRelativa,
        }),
      ).timeout(timeout);

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw 'Erro ao criar sessão: ${response.statusCode}';
      }
    } catch (e) {
      throw 'Erro na conexão: $e';
    }
  }

  /// Obtém todas as sessões de um atleta
  static Future<List<Map<String, dynamic>>> obterSessoesAtleta(int atletaId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/sessoes/atleta/$atletaId'),
        headers: _headers,
      ).timeout(timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw 'Erro ao obter sessões: ${response.statusCode}';
      }
    } catch (e) {
      throw 'Erro na conexão: $e';
    }
  }

  /// Obtém detalhes de uma sessão específica
  static Future<Map<String, dynamic>> obterSessao(int sessaoId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/sessoes/$sessaoId'),
        headers: _headers,
      ).timeout(timeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw 'Sessão não encontrada: ${response.statusCode}';
      }
    } catch (e) {
      throw 'Erro na conexão: $e';
    }
  }

  /// Finaliza uma sessão e calcula as estatísticas
  static Future<Map<String, dynamic>> finalizarSessao({
    required int sessaoId,
    required int durationMinutos,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/sessoes/$sessaoId/finalizar?durationMinutos=$durationMinutos'),
        headers: _headers,
      ).timeout(timeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw 'Erro ao finalizar sessão: ${response.statusCode}';
      }
    } catch (e) {
      throw 'Erro na conexão: $e';
    }
  }

  /// ============== MÉTRICAS ==============

  /// Registra uma métrica de sudorese durante a sessão
  static Future<void> registrarMetrica({
    required int sessaoId,
    required int tempoDecorridoMinutos,
    required double taxaSudorese,
    int? frequenciaCardiaca,
    double? velocidadeMedia,
    String? intensidade,
    String? observacoes,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/sessoes/$sessaoId/metrica'),
        headers: _headers,
        body: jsonEncode({
          'tempoDecorridoMinutos': tempoDecorridoMinutos,
          'taxaSudorose': taxaSudorese,
          'frequenciaCardiaca': frequenciaCardiaca,
          'velocidadeMedia': velocidadeMedia,
          'intensidade': intensidade,
          'observacoes': observacoes,
        }),
      ).timeout(timeout);

      if (response.statusCode != 200) {
        throw 'Erro ao registrar métrica: ${response.statusCode}';
      }
    } catch (e) {
      throw 'Erro na conexão: $e';
    }
  }

  /// ============== CONSUMO DE ÁGUA ==============

  /// Registra um consumo de água durante a sessão
  static Future<void> registrarConsumo({
    required int sessaoId,
    required int quantidadeMl,
    int? tempoDecorridoMinutos,
    String? tipoLiquido,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/sessoes/$sessaoId/consumo'),
        headers: _headers,
        body: jsonEncode({
          'tempoDecorridoMinutos': tempoDecorridoMinutos,
          'quantidadeMl': quantidadeMl,
          'tipoLiquido': tipoLiquido ?? 'Água',
        }),
      ).timeout(timeout);

      if (response.statusCode != 200) {
        throw 'Erro ao registrar consumo: ${response.statusCode}';
      }
    } catch (e) {
      throw 'Erro na conexão: $e';
    }
  }

  /// ============== STATS ==============

  /// Obtém as estatísticas calculadas de uma sessão
  static Future<Map<String, dynamic>> obterStats(int sessaoId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/sessoes/$sessaoId/stats'),
        headers: _headers,
      ).timeout(timeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw 'Stats não encontrados: ${response.statusCode}';
      }
    } catch (e) {
      throw 'Erro na conexão: $e';
    }
  }
}
