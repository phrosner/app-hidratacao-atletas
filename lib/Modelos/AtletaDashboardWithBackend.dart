import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hidratrack/Modelos/DashboardModels.dart';
import 'package:hidratrack/Servicos/AtletaService.dart';
import 'package:hidratrack/Servicos/AuthStorage.dart';
import 'package:hidratrack/Servicos/hidratrack_api_client.dart';
import 'package:hidratrack/Telas/TeladashboardAtleta.dart' as atleta_dashboard;

class TelaDashboardAtletaComBackend extends StatefulWidget {
  final String? tokenAtleta;

  const TelaDashboardAtletaComBackend({super.key, this.tokenAtleta});

  @override
  State<TelaDashboardAtletaComBackend> createState() =>
      _TelaDashboardAtletaComBackendState();
}

class _TelaDashboardAtletaComBackendState
    extends State<TelaDashboardAtletaComBackend> {
  late Future<atleta_dashboard.AtletaDashboardData> _dashboardFuture;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregarDadosDashboard();
  }

  void _carregarDadosDashboard() {
    final token = widget.tokenAtleta?.isNotEmpty == true
        ? widget.tokenAtleta!
        : AuthStorage.token.isNotEmpty
        ? AuthStorage.token
        : '';

    _dashboardFuture = _loadDashboardData(token);
  }

  Future<atleta_dashboard.AtletaDashboardData> _loadDashboardData(
    String token,
  ) async {
    try {
      final backendData = await AtletaService.obterDashboardAtleta(
        token: token,
      );
      final temperaturaDashboard = _parseDouble(
        backendData['temperatura'],
        0.0,
      );
      final climaDashboard = backendData['clima']?.toString().trim() ?? '';
      final climaDashboardSemDados =
          climaDashboard.isEmpty ||
          climaDashboard.toLowerCase() == 'sem informação' ||
          climaDashboard.toLowerCase() == 'não informado' ||
          climaDashboard.toLowerCase() == 'nao informado';
      ClimaDados? clima;

      if (temperaturaDashboard > 0 || !climaDashboardSemDados) {
        clima = ClimaDados(
          temperatura: temperaturaDashboard,
          umidade: 0,
          condicao: climaDashboardSemDados ? 'Sem informação' : climaDashboard,
        );
      }

      if (clima == null) {
        clima = await _loadClimaDados();
      }
      if (clima == null) {
        clima = await _loadCurrentWeatherByIp();
      }

      return _mapBackendToDashboardData(backendData, clima);
    } catch (e) {
      setState(() {
        _erro = 'Erro ao carregar dados: $e';
      });
      rethrow;
    }
  }

  Future<ClimaDados?> _loadClimaDados() async {
    var atletaId = AuthStorage.userId;
    if (atletaId == null) {
      atletaId = await _resolveAtletaId();
    }
    if (atletaId == null) return null;

    try {
      final sessoes = await HidraTrackApiClient.obterSessoesAtleta(atletaId);
      if (sessoes.isEmpty) return null;

      final sessionIdValue = sessoes.first['id'];
      final sessionId = sessionIdValue is num
          ? sessionIdValue.toInt()
          : int.tryParse(sessionIdValue?.toString() ?? '');
      if (sessionId == null) return null;

      final lastSessao = await HidraTrackApiClient.obterSessao(sessionId);
      final temperatura = (lastSessao['temperaturaAmbiente'] as num?)
          ?.toDouble();
      final umidade = (lastSessao['umidadeRelativa'] as num?)?.toInt();
      if (temperatura == null || temperatura == 0) return null;

      return ClimaDados(
        temperatura: temperatura,
        umidade: umidade ?? 0,
        condicao: lastSessao['condicao']?.toString() ?? 'Ambiente',
      );
    } catch (e) {
      print('Erro ao carregar clima do atleta: $e');
      return null;
    }
  }

  Future<ClimaDados?> _loadCurrentWeatherByIp() async {
    try {
      final geoResponse = await http
          .get(Uri.parse('https://geolocation-db.com/json/'))
          .timeout(const Duration(seconds: 8));
      if (geoResponse.statusCode != 200) return null;

      final geoJson = jsonDecode(geoResponse.body);
      final latitude = (geoJson['latitude'] as num?)?.toDouble();
      final longitude = (geoJson['longitude'] as num?)?.toDouble();
      if (latitude == null || longitude == null) return null;

      final weatherResponse = await http
          .get(
            Uri.parse(
              'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&current_weather=true&temperature_unit=celsius',
            ),
          )
          .timeout(const Duration(seconds: 8));
      if (weatherResponse.statusCode != 200) return null;

      final weatherJson = jsonDecode(weatherResponse.body);
      final current = weatherJson['current_weather'];
      if (current == null) return null;

      final temperature = (current['temperature'] as num?)?.toDouble();
      final weatherCode = (current['weathercode'] as int?) ?? -1;
      if (temperature == null) return null;

      return ClimaDados(
        temperatura: temperature,
        umidade: 0,
        condicao: _describeWeatherCode(weatherCode),
      );
    } catch (e) {
      print('Erro ao carregar clima atual por IP: $e');
      return null;
    }
  }

  String _describeWeatherCode(int code) {
    if (code == 0) return 'Ensolarado';
    if (code == 1 || code == 2) return 'Parcialmente nublado';
    if (code == 3) return 'Nublado';
    if (code == 45 || code == 48) return 'Neblina';
    if (code >= 51 && code <= 67) return 'Chuva leve';
    if (code >= 71 && code <= 77) return 'Neve';
    if (code >= 80 && code <= 82) return 'Chuva';
    if (code >= 95 && code <= 99) return 'Tempestade';
    return 'Clima atual';
  }

  Future<void> _recarregarDados() async {
    setState(() {
      _erro = null;
    });
    _carregarDadosDashboard();
    await _dashboardFuture;
  }

  atleta_dashboard.AtletaDashboardData _mapBackendToDashboardData(
    Map<String, dynamic> data,
    ClimaDados? clima,
  ) {
    final nomeAtleta = (data['nomeAtleta'] ?? 'Atleta').toString();
    final taxaSuor = _parseDouble(data['taxaSuor'], 1.0);
    final hidratacaoRecomendada = _parseDouble(
      data['hidratacaoRecomendada'],
      2.0,
    );
    final percentualConsumido =
        _parseDouble(data['percentualConsumido'], 0.0) / 100.0;
    final consumoMedio = _parseDouble(data['consumoMedio'], taxaSuor);
    final variationPercent = _parseDouble(
      data['percentualVariacao'] ?? data['variacaoPercentual'],
      0.0,
    );

    return atleta_dashboard.AtletaDashboardData.fromHydrationMetrics(
      athleteName: nomeAtleta,
      sweatRate: taxaSuor,
      recommendedIntakeLiters: hidratacaoRecomendada,
      recommendedWindow: const Duration(hours: 3),
      completedPercent: percentualConsumido,
      averageRate: consumoMedio,
      variationPercent: variationPercent,
      hasHydrationAlert: percentualConsumido < 0.5,
      clima: clima,
    );
  }

  Future<int?> _resolveAtletaId() async {
    final token = AuthStorage.token;
    if (token.isEmpty) return null;

    try {
      final perfil = await AtletaService.obterPerfilAtleta(token: token);
      final idValue = perfil['id'] ?? perfil['atletaId'] ?? perfil['userId'];
      final atletaId = idValue is num
          ? idValue.toInt()
          : int.tryParse(idValue?.toString() ?? '');
      if (atletaId != null) {
        AuthStorage.userId = atletaId;
      }
      return atletaId;
    } catch (_) {
      return null;
    }
  }

  double _parseDouble(dynamic value, double fallback) {
    if (value == null) return fallback;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? fallback;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<atleta_dashboard.AtletaDashboardData>(
      future: _dashboardFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasError) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Color(0xFFB32025),
                      size: 64,
                    ),
                    const SizedBox(height: 18),
                    Text(
                      _erro ?? 'Erro ao carregar dashboard.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF222222),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _recarregarDados,
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final data = snapshot.data;
        if (data == null) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(child: Text('Nenhum dado disponível.')),
          );
        }

        return atleta_dashboard.TelaDashboardAtleta(data: data);
      },
    );
  }
}
