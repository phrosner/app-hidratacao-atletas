import 'package:flutter/material.dart';
import 'package:hidratrack/app_rotas.dart';
import 'package:hidratrack/Servicos/AtletaService.dart';
import 'package:hidratrack/Servicos/AuthStorage.dart';

class AtletaDashboardData {
  final String greetingTitle;
  final double sweatRate;
  final double recommendedIntakeLiters;
  final double completedPercent;
  final double averageRate;

  AtletaDashboardData({
    required this.greetingTitle,
    required this.sweatRate,
    required this.recommendedIntakeLiters,
    required this.completedPercent,
    required this.averageRate,
  });

  factory AtletaDashboardData.fromBackend(Map<String, dynamic> data) {
    final nomeAtleta = data['nomeAtleta'] ?? 'Atleta';
    return AtletaDashboardData(
      greetingTitle: 'BOM TREINO, ${nomeAtleta.toString().toUpperCase()}!',
      sweatRate: (data['taxaSuor'] ?? 0.0).toDouble(),
      recommendedIntakeLiters: (data['hidratacaoRecomendada'] ?? 0.0)
          .toDouble(),
      completedPercent: ((data['percentualConsumido'] ?? 0) / 100).toDouble(),
      averageRate: (data['consumoMedio'] ?? 0.0).toDouble(),
    );
  }
}

class TelaDashboardAtletaComBackend extends StatefulWidget {
  final String? tokenAtleta;

  const TelaDashboardAtletaComBackend({super.key, this.tokenAtleta});

  @override
  State<TelaDashboardAtletaComBackend> createState() =>
      _TelaDashboardAtletaComBackendState();
}

class _TelaDashboardAtletaComBackendState
    extends State<TelaDashboardAtletaComBackend> {
  late Future<AtletaDashboardData> _dashboardFuture;

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
        : 'seu_token_aqui';
    _dashboardFuture = AtletaService.obterDashboardAtleta(
      token: token,
    ).then((data) => AtletaDashboardData.fromBackend(data));
  }

  void _recarregarDados() {
    setState(() {
      _carregarDadosDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AtletaDashboardData>(
      future: _dashboardFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFFFFFFFF),
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFFB32025)),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: const Color(0xFFFFFFFF),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Color(0xFFB32025),
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Erro ao carregar dashboard',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF222222), fontSize: 16),
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
        return TelaDashboardAtletaUI(data: data, onRefresh: _recarregarDados);
      },
    );
  }
}

class TelaDashboardAtletaUI extends StatelessWidget {
  const TelaDashboardAtletaUI({
    super.key,
    required this.data,
    required this.onRefresh,
  });

  static const _background = Color(0xFFFFFFFF);
  static const _surface = Color(0xFFF7F7F7);
  static const _surfaceLight = Color(0xFFEDEDED);
  static const _lime = Color(0xFFB32025);
  static const _cyan = Color(0xFF8F171B);
  static const _text = Color(0xFF222222);
  static const _muted = Color(0xFF6B6B6B);

  final AtletaDashboardData data;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      floatingActionButton: _buildActionButton(context),
      bottomNavigationBar: _buildBottomNav(context),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
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
                      _buildWeatherCard(),
                      const SizedBox(height: 26),
                      _buildStatsRow(),
                      const SizedBox(height: 18),
                      _buildWeeklyHydration(),
                    ]),
                  ),
                ),
              ],
            ),
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

  Widget _buildWeatherCard() {
    return Container(
      height: 118,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -8,
            top: -12,
            child: Icon(
              Icons.cloud_outlined,
              color: Colors.white.withValues(alpha: 0.1),
              size: 70,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Clima Local',
                style: TextStyle(
                  color: _muted,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '31°C, Ensolarado',
                style: const TextStyle(
                  color: _text,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              const Text(
                'Condição favorável para treino',
                style: TextStyle(
                  color: _muted,
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            icon: Icons.water_drop_outlined,
            label: 'TAXA DE\nSUOR',
            value: '${data.sweatRate.toStringAsFixed(2)} L/h',
            detail: null,
            accent: _lime,
            progress: data.sweatRate > 0
                ? (data.sweatRate / 2.0).clamp(0, 1)
                : 0,
          ),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: _buildMetricCard(
            icon: Icons.trending_up,
            label: 'VARIACAO',
            value: '+12.5%',
            detail: 'DENTRO DO ALVO',
            accent: _cyan,
            progress: 1.0,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String label,
    required String value,
    required Color accent,
    required double progress,
    String? detail,
  }) {
    return Container(
      height: 130,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: accent, size: 16),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _text,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (detail == null) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 2,
                color: _lime,
                backgroundColor: _surfaceLight,
              ),
            ),
          ] else ...[
            const SizedBox(height: 7),
            Row(
              children: [
                const Icon(Icons.check_circle_outline, color: _lime, size: 11),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    detail,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _lime,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWeeklyHydration() {
    const bars = [0.85, 0.55, 0.95, 0.45, 0.78, 1.0];

    return Container(
      height: 96,
      padding: const EdgeInsets.fromLTRB(22, 16, 22, 16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'HIDRATACAO SEMANAL',
                  style: TextStyle(
                    color: _muted,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  height: 34,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < bars.length; i++) ...[
                        Container(
                          width: 8,
                          height: 34 * bars[i],
                          decoration: BoxDecoration(
                            color: i == 2 ? _surfaceLight : _lime,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        if (i != bars.length - 1) const SizedBox(width: 12),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${(data.completedPercent * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: _text,
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'OBJETIVO',
                style: TextStyle(
                  color: _lime,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return SizedBox(
      height: 56,
      child: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).pushNamed(AppRotas.iniciarTreino);
        },
        backgroundColor: _lime,
        foregroundColor: Colors.white,
        elevation: 12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        icon: const Icon(Icons.add, size: 22),
        label: const Text(
          'NOVA SESSAO',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    const items = [
      (Icons.water_drop, 'SESSAO'),
      (Icons.history_rounded, 'HISTORICO'),
      (Icons.insert_chart_outlined, 'STATUS'),
      (Icons.person, 'PERFIL'),
    ];

    return Container(
      height: 72 + bottomInset,
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (var i = 0; i < items.length; i++)
            InkWell(
              onTap: () {
                if (i == 0) {
                  Navigator.of(
                    context,
                  ).pushReplacementNamed(AppRotas.dashboardAtleta);
                } else if (i == 1) {
                  Navigator.of(
                    context,
                  ).pushReplacementNamed(AppRotas.historicoAtleta);
                } else if (i == 2) {
                  Navigator.of(
                    context,
                  ).pushReplacementNamed(AppRotas.taxaMedia);
                } else if (i == 3) {
                  Navigator.of(
                    context,
                  ).pushReplacementNamed(AppRotas.perfilAtleta);
                }
              },
              child: SizedBox(
                width: 74,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(items[i].$1, color: i == 0 ? _lime : _muted, size: 23),
                    const SizedBox(height: 5),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        items[i].$2,
                        style: TextStyle(
                          color: i == 0 ? _lime : _muted,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.9,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
