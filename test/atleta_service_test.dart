import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hidratrack/Servicos/AtletaService.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('AtletaService', () {
    test('obterDashboardAtleta retorna dados do backend', () async {
      final client = MockClient((request) async {
        expect(request.url.path, '/api/atletas/dashboard');
        expect(request.headers['Authorization'], 'Bearer test_token_123');

        return http.Response(
          jsonEncode({
            'nomeAtleta': 'Ricardo Silva',
            'taxaSuor': 1.2,
            'hidratacaoRecomendada': 2.4,
            'percentualConsumido': 45.0,
            'consumoMedio': 0.8,
            'saudeGeral': 'Otimo',
          }),
          200,
        );
      });

      final data = await AtletaService.obterDashboardAtleta(
        token: 'test_token_123',
        httpClient: client,
      );

      expect(data['nomeAtleta'], 'Ricardo Silva');
      expect(data['taxaSuor'], 1.2);
      expect(data['hidratacaoRecomendada'], 2.4);
    });

    test('registrarConsumo envia dados corretos', () async {
      final dataHora = DateTime(2026, 5, 30, 15, 0);
      final client = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/api/atletas/consumo');
        expect(request.headers['Authorization'], 'Bearer test_token_123');

        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['mlConsumidos'], 500.0);
        expect(body['dataHora'], dataHora.toIso8601String());

        return http.Response(
          jsonEncode({
            'sucesso': true,
            'mensagem': 'Consumo registrado com sucesso',
            'mlConsumidos': 500.0,
          }),
          201,
        );
      });

      final registrado = await AtletaService.registrarConsumo(
        token: 'test_token_123',
        mlConsumidos: 500.0,
        dataHora: dataHora,
        httpClient: client,
      );

      expect(registrado, isTrue);
    });

    test('obterDashboardAtleta trata token invalido', () async {
      final client = MockClient((request) async {
        return http.Response('Unauthorized', 401);
      });

      expect(
        () => AtletaService.obterDashboardAtleta(
          token: 'invalid_token',
          httpClient: client,
        ),
        throwsException,
      );
    });
  });
}
