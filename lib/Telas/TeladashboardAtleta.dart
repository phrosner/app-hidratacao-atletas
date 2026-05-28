import 'package:flutter/material.dart';
import 'package:hidratrack/app_rotas.dart';
import 'package:hidratrack/Modelos/SessaoHidratacaoModels.dart';

class TelaDashboardAtleta extends StatelessWidget {
  const TelaDashboardAtleta({
    super.key,
    required this.data,
    this.onStartSession,
  });

  static const _background = Color(0xFFFFFFFF);
  static const _surface = Color(0xFFF7F7F7);
  static const _surfaceLight = Color(0xFFEDEDED);
  static const _lime = Color(0xFFB32025);
  static const _cyan = Color(0xFF8F171B);
  static const _text = Color(0xFF222222);
  static const _muted = Color(0xFF6B6B6B);

  final AtletaDashboardData data;
  final VoidCallback? onStartSession;

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

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            icon: Icons.water_drop_outlined,
            label: 'TAXA DE\nSUOR',
            value: data.averageRateValue,
            detail: null,
            accent: _lime,
          ),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: _buildMetricCard(
            icon: Icons.trending_up,
            label: 'VARIACAO',
            value: data.variationValue,
            detail: 'DENTRO DO ALVO',
            accent: _cyan,
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
                value: data.progress,
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
                data.weeklyHydration,
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
                  letterSpacing: 1.8,
                ),
              ),
              const Spacer(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        '31C',
                        style: TextStyle(
                          color: _text,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        'SP, BR - Seco',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _muted,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.water_drop_outlined, color: _cyan, size: 14),
                  const SizedBox(width: 5),
                  const Text(
                    'UMIDADE 42%',
                    style: TextStyle(
                      color: _muted,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                ],
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
        onPressed: onStartSession ??
            () {
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
                  ).pushReplacementNamed('/dashboard-atleta');
                } else if (i == 1) {
                  Navigator.of(
                    context,
                  ).pushReplacementNamed(AppRotas.historicoAtleta);
                } else if (i == 2) {
                  Navigator.of(
                    context,
                  ).pushReplacementNamed(AppRotas.statsAtleta);
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

class AtletaDashboardData {
  const AtletaDashboardData({
    required this.greetingTitle,
    required this.subtitle,
    required this.alertTitle,
    required this.alertSubtitle,
    required this.alertMessage,
    this.hasAlert = false,
    required this.progress,
    required this.progressLabel,
    required this.progressPercentage,
    required this.averageRateLabel,
    required this.averageRateValue,
    required this.variationLabel,
    required this.variationValue,
    required this.variationColor,
    this.weeklyHydration = '88%',
  });

  final String greetingTitle;
  final String subtitle;
  final String alertTitle;
  final String alertSubtitle;
  final String alertMessage;
  final bool hasAlert;
  final double progress;
  final String progressLabel;
  final String progressPercentage;
  final String averageRateLabel;
  final String averageRateValue;
  final String variationLabel;
  final String variationValue;
  final Color variationColor;
  final String weeklyHydration;

  factory AtletaDashboardData.fromHydrationMetrics({
    required String athleteName,
    required double sweatRate,
    required double recommendedIntakeLiters,
    required Duration recommendedWindow,
    required double completedPercent,
    required double averageRate,
    required double variationPercent,
    bool hasHydrationAlert = true,
  }) {
    final variationPositive = variationPercent >= 0;
    final variationString = variationPositive
        ? '+${variationPercent.toStringAsFixed(1)}%'
        : '${variationPercent.toStringAsFixed(1)}%';

    return AtletaDashboardData(
      greetingTitle: 'BOM TREINO, ${athleteName.toUpperCase()}!',
      subtitle: 'Seu foco hoje: Hidratacao e Recuperacao.',
      alertTitle: 'ALERTA DE HIDRATACAO',
      alertSubtitle: 'Sua taxa de suor na ultima sessao foi alta.',
      alertMessage:
          'Sua taxa de suor na ultima sessao foi alta. Recomenda-se ingestao de ${recommendedIntakeLiters.toStringAsFixed(1)}L nas proximas ${recommendedWindow.inHours} horas.',
      hasAlert: hasHydrationAlert,
      progress: completedPercent.clamp(0, 1),
      progressLabel: 'COMPLETADO',
      progressPercentage:
          '${(completedPercent * 100).toStringAsFixed(0)}% COMPLETADO',
      averageRateLabel: 'TAXA DE SUOR',
      averageRateValue: '${sweatRate.toStringAsFixed(1)} L/h',
      variationLabel: 'VARIACAO',
      variationValue: variationString,
      variationColor:
          variationPositive ? const Color(0xFFB32025) : const Color(0xFF8F171B),
      weeklyHydration: '88%',
    );
  }

  factory AtletaDashboardData.fromSessao({
    required String athleteName,
    required SessaoFinalizada sessao,
  }) {
    final resultado = sessao.resultado;
    final perdaMl = (resultado.perdaMassaAjustadaLitros * 1000).round();
    final progresso = perdaMl <= 0 ? 0.0 : sessao.totalIngeridoMl / perdaMl;

    return AtletaDashboardData(
      greetingTitle: 'BOM TREINO, ${athleteName.toUpperCase()}!',
      subtitle: 'Ultima sessao registrada: ${sessao.inicio.modalidade}.',
      alertTitle: 'ALERTA DE HIDRATACAO',
      alertSubtitle: resultado.alertaOperacional,
      alertMessage:
          'Recomendacao atual: ${resultado.recomendacaoMinMlHora}-${resultado.recomendacaoMaxMlHora} mL/h.',
      hasAlert: resultado.alertaOperacional != 'Dentro do alvo operacional',
      progress: progresso.clamp(0, 1).toDouble(),
      progressLabel: 'COMPLETADO',
      progressPercentage:
          '${(progresso * 100).clamp(0, 100).toStringAsFixed(0)}% COMPLETADO',
      averageRateLabel: 'TAXA DE SUOR',
      averageRateValue:
          '${resultado.taxaSudoreseLitrosHora.toStringAsFixed(2)} L/h',
      variationLabel: 'VARIACAO',
      variationValue:
          '${resultado.variacaoMassaPercentual.toStringAsFixed(1)}%',
      variationColor: resultado.variacaoMassaPercentual <= -2
          ? const Color(0xFFB32025)
          : const Color(0xFF8F171B),
      weeklyHydration: '${(progresso * 100).clamp(0, 100).toStringAsFixed(0)}%',
    );
  }
}
