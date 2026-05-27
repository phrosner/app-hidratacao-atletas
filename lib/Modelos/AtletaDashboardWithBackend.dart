import 'package:flutter/material.dart';
import 'package:hidratrack/app_rotas.dart';
import 'package:hidratrack/Servicos/AtletaService.dart';

class AtletaDashboardData {
  final String greetingTitle;
  final double sweatRate;
  final double recommendedIntakeLiters;
  final Duration recommendedWindow;
  final double completedPercent;
  final double averageRate;

  AtletaDashboardData({
    required this.greetingTitle,
    required this.sweatRate,
    required this.recommendedIntakeLiters,
    required this.recommendedWindow,
    required this.completedPercent,
    required this.averageRate,
  });

  factory AtletaDashboardData.fromHydrationMetrics({
    required String athleteName,
    required double sweatRate,
    required double recommendedIntakeLiters,
    required Duration recommendedWindow,
    required double completedPercent,
    required double averageRate,
  }) {
    return AtletaDashboardData(
      greetingTitle: 'Bem-vindo, $athleteName',
      sweatRate: sweatRate,
      recommendedIntakeLiters: recommendedIntakeLiters,
      recommendedWindow: recommendedWindow,
      completedPercent: completedPercent,
      averageRate: averageRate,
    );
  }

  // Converter dados do backend para o modelo local
  factory AtletaDashboardData.fromBackend(Map<String, dynamic> data) {
    return AtletaDashboardData(
      greetingTitle: 'Bem-vindo, ${data['nomeAtleta'] ?? 'Atleta'}',
      sweatRate: (data['taxaSuor'] ?? 1.0).toDouble(),
      recommendedIntakeLiters: (data['hidratacaoRecomendada'] ?? 2.0).toDouble(),
      recommendedWindow: const Duration(hours: 3),
      completedPercent: (data['percentualConsumido'] ?? 0) / 100,
      averageRate: (data['consumoMedio'] ?? 0.8).toDouble(),
    );
  }
}

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
  late Future<AtletaDashboardData> _dashboardFuture;
  bool _isLoading = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregarDadosDashboard();
  }

  void _carregarDadosDashboard() {
    final token = widget.tokenAtleta ?? 'seu_token_aqui';
    _dashboardFuture = AtletaService.obterDashboardAtleta(token: token)
        .then((data) => AtletaDashboardData.fromBackend(data))
        .catchError((e) {
          setState(() {
            _erro = 'Erro ao carregar dados: $e';
            _isLoading = false;
          });
          throw e;
        });
  }

  void _recarregarDados() {
    setState(() {
      _isLoading = true;
      _erro = null;
    });
    _carregarDadosDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AtletaDashboardData>(
      future: _dashboardFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF101010),
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFFB9FF00)),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: const Color(0xFF101010),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Color(0xFFB9FF00),
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _erro ?? 'Erro ao carregar dashboard',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFFF5F5F5),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _recarregarDados,
                    child: const Text('Tentar Novamente'),
                  ),
                ],
              ),
            ),
          );
        }

        final data = snapshot.data!;
        return TelaDashboardAtletaUI(
          data: data,
          onRefresh: _recarregarDados,
        );
      },
    );
  }
}

// UI do dashboard (mova seu código visual aqui)
class TelaDashboardAtletaUI extends StatelessWidget {
  const TelaDashboardAtletaUI({
    super.key,
    required this.data,
    required this.onRefresh,
  });

  static const _background = Color(0xFF101010);
  static const _surface = Color(0xFF1B1B1B);
  static const _lime = Color(0xFFB9FF00);
  static const _cyan = Color(0xFF00E5FF);
  static const _text = Color(0xFFF5F5F5);

  final AtletaDashboardData data;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => onRefresh(),
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 116),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildBrand(),
                    const SizedBox(height: 54),
                    _buildGreeting(),
                    const SizedBox(height: 28),
                    _buildSessionCard(),
                    const SizedBox(height: 26),
                    _buildStatsRow(),
                    const SizedBox(height: 18),
                    _buildWeeklyHydration(),
                    const SizedBox(height: 30),
                    _buildTrackerCard(),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrand() {
    return const Text(
      'H2OTRACK',
      style: TextStyle(color: _text, fontSize: 13, fontWeight: FontWeight.w500),
    );
  }

  Widget _buildGreeting() {
    return Text(
      data.greetingTitle,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: _text,
        fontSize: 24,
        fontWeight: FontWeight.w900,
        height: 1.05,
      ),
    );
  }

  Widget _buildSessionCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Taxa de Suor',
            style: TextStyle(color: _text, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Text(
            '${data.sweatRate.toStringAsFixed(2)} L/h',
            style: const TextStyle(
              color: _lime,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Recomendado: ${data.recommendedIntakeLiters.toStringAsFixed(1)}L',
            style: const TextStyle(color: _text, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            label: 'Consumido',
            value: '${(data.completedPercent * 100).toStringAsFixed(0)}%',
            color: _lime,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            label: 'Média',
            value: '${data.averageRate.toStringAsFixed(2)}L',
            color: _cyan,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: _text, fontSize: 12)),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyHydration() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hidratação Semanal',
            style: TextStyle(color: _text, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: data.completedPercent,
            backgroundColor: Colors.grey[800],
            valueColor: const AlwaysStoppedAnimation<Color>(_lime),
            minHeight: 6,
          ),
        ],
      ),
    );
  }

  Widget _buildTrackerCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white12),
      ),
      child: const Column(
        children: [
          Text(
            'Seu tracker está funcionando',
            style: TextStyle(color: _text, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
