import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:hidratrack/Servicos/AtletaService.dart';
import 'dart:convert';

void main() {
  group('AtletaService Tests', () {
    test('obterDashboardAtleta retorna dados corretamente', () async {
      const String token = 'test_token_123';
      final mockResponse = http.Response(
        jsonEncode({
          'nomeAtleta': 'Ricardo Silva',
          'taxaSuor': 1.2,
          'hidratacaoRecomendada': 2.4,
          'percentualConsumido': 45.0,
          'consumoMedio': 0.8,
          'saudeGeral': 'Ótimo',
        }),
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );

      late http.Request sentRequest;
      final mockClient = MockClient((http.Request request) async {
        sentRequest = request;
        return mockResponse;
      });

      final data = await AtletaService.obterDashboardAtleta(
        token: token,
        client: mockClient,
      );

      expect(data['nomeAtleta'], 'Ricardo Silva');
      expect(data['taxaSuor'], 1.2);
      expect(data['hidratacaoRecomendada'], 2.4);
      expect(data['percentualConsumido'], 45.0);
      expect(sentRequest.method, 'GET');
      expect(sentRequest.url.path, '/api/atletas/dashboard');
      expect(sentRequest.url.scheme, 'http');
      expect(sentRequest.headers['Authorization'], 'Bearer $token');
    });

    test('registrarConsumo envia dados corretos', () async {
      const String token = 'test_token_123';
      const double mlConsumidos = 500.0;
      final dataHora = DateTime.now().toIso8601String();

      final mockResponse = http.Response(
        jsonEncode({
          'sucesso': true,
          'mensagem': 'Consumo registrado com sucesso',
          'mlConsumidos': mlConsumidos,
        }),
        201,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );

      late http.Request sentRequest;
      final mockClient = MockClient((http.Request request) async {
        sentRequest = request;
        return mockResponse;
      });

      final result = await AtletaService.registrarConsumo(
        token: token,
        mlConsumidos: mlConsumidos,
        dataHora: DateTime.parse(dataHora),
        client: mockClient,
      );

      expect(result, isTrue);
      expect(sentRequest.method, 'POST');
      expect(sentRequest.url.path, '/api/atletas/consumo');
      expect(sentRequest.url.scheme, 'http');
      expect(sentRequest.headers['Authorization'], 'Bearer $token');
      expect(jsonDecode(sentRequest.body), {
        'mlConsumidos': mlConsumidos,
        'dataHora': dataHora,
      });
    });

    test('tratamento de erro 401 - token inválido', () async {
      const String tokenInvalido = 'invalid_token';
      final mockResponse = http.Response('Unauthorized', 401);

      final mockClient = MockClient((http.Request request) async {
        return mockResponse;
      });

      expect(
        () async => await AtletaService.obterDashboardAtleta(
          token: tokenInvalido,
          client: mockClient,
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
