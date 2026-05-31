import 'package:flutter/material.dart';
import 'package:hidratrack/Telas/TeladashboardAtleta.dart' as atleta_dashboard;
import 'package:hidratrack/Servicos/AtletaService.dart';
import 'package:hidratrack/Servicos/AuthStorage.dart';

class TelaDashboardAtletaComBackend extends StatefulWidget {
  final String? tokenAtleta;

  const TelaDashboardAtletaComBackend({
    super.key,
    this.tokenAtleta,
  });

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

    _dashboardFuture = AtletaService.obterDashboardAtleta(token: token)
        .then(_mapBackendToDashboardData)
        .catchError((e) {
      setState(() {
        _erro = 'Erro ao carregar dados: $e';
      });
      throw e;
    });
  }

  Future<void> _recarregarDados() async {
    setState(() {
      _erro = null;
    });
    _carregarDadosDashboard();
    await _dashboardFuture;
  }

  atleta_dashboard.AtletaDashboardData _mapBackendToDashboardData(
      Map<String, dynamic> data) {
    final nomeAtleta = (data['nomeAtleta'] ?? 'Atleta').toString();
    final taxaSuor = _parseDouble(data['taxaSuor'], 1.0);
    final hidratacaoRecomendada =
        _parseDouble(data['hidratacaoRecomendada'], 2.0);
    final percentualConsumido =
        _parseDouble(data['percentualConsumido'], 0.0) / 100.0;
    final consumoMedio =
        _parseDouble(data['consumoMedio'], taxaSuor);
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
    );
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
            body: Center(
              child: CircularProgressIndicator(),
            ),
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
