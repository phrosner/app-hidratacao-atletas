import 'package:flutter/material.dart';
import 'package:hidratrack/app_rotas.dart';
import 'package:hidratrack/Modelos/SessaoHidratacaoModels.dart';
import 'package:hidratrack/Servicos/hidratrack_api_client.dart';

class TelastatsAtleta extends StatefulWidget {
  const TelastatsAtleta({super.key, this.atletaId = 1, this.sessaoId});

  final int atletaId;
  final int? sessaoId;

  @override
  State<TelastatsAtleta> createState() => _TelastatsAtletaState();
}

class _TelastatsAtletaState extends State<TelastatsAtleta> {
  static const _background = Color(0xFFFFFFFF);
  static const _surface = Color(0xFFF7F7F7);
  static const _lime = Color(0xFFB32025);
  static const _cyan = Color(0xFF8F171B);
  static const _text = Color(0xFF222222);
  static const _muted = Color(0xFF6B6B6B);
  static const _danger = Color(0xFFFF6B6B);
  static const _success = Color(0xFF51CF66);

  late Future<StatsData> _statsDataFuture;
  late Future<List<PerformancePoint>> _performanceDataFuture;

  @override
  void initState() {
    super.initState();
    if (widget.sessaoId != null) {
      _statsDataFuture = _loadStatsFromApi(widget.sessaoId!);
      _performanceDataFuture = _loadPerformanceData(widget.sessaoId!);
    } else {
      // Carregar última sessão do atleta
      _statsDataFuture = _loadLastSessionStats();
      _performanceDataFuture = _loadLastSessionPerformance();
    }
  }

  Future<StatsData> _loadStatsFromApi(int sessaoId) async {
    try {
      final sessao = await HidraTrackApiClient.obterSessao(sessaoId);
      final stats = await HidraTrackApiClient.obterStats(sessaoId);

      return StatsData(
        sweatRate: (stats['taxaSudoroseMedia'] as num?)?.toDouble() ?? 1.85,
        intensity: 'ALTA',
        temperature:
            (sessao['temperaturaAmbiente'] as num?)?.toDouble() ?? 28.0,
        humidity: (sessao['umidadeRelativa'] as num?)?.toInt() ?? 65,
        performanceData: [],
        fluidLoss: (stats['perdaLiquidoAjustada'] as num?)?.toDouble() ?? 2.42,
        variation: (stats['variacaoSudorese'] as num?)?.toDouble() ?? -1.8,
        theoreticalBalance: (stats['balancoTeorico'] as num?)?.toInt() ?? -450,
        recommendedIntakeMin:
            (stats['recomendacaoIntakeMin'] as num?)?.toInt() ?? 500,
        recommendedIntakeMax:
            (stats['recomendacaoIntakeMax'] as num?)?.toInt() ?? 750,
        interval: (stats['intervaloRecomendado'] as num?)?.toInt() ?? 15,
      );
    } catch (e) {
      print('Erro ao carregar stats: $e');
      return StatsData.empty();
    }
  }

  Future<List<PerformancePoint>> _loadPerformanceData(int sessaoId) async {
    try {
      final sessao = await HidraTrackApiClient.obterSessao(sessaoId);
      final metricas = (sessao['metricas'] as List<dynamic>?) ?? [];

      if (metricas.isEmpty) {
        return _defaultPerformanceData();
      }

      return metricas.map((m) {
        final tempo = m['tempoDecorridoMinutos'] as int?;
        final taxa = (m['taxaSudorose'] as num?)?.toDouble() ?? 0.5;
        final maxTaxa = 1.92;

        return PerformancePoint(
          time: '$tempo MIN',
          value: (taxa / maxTaxa).clamp(0, 1),
        );
      }).toList();
    } catch (e) {
      print('Erro ao carregar performance data: $e');
      return _defaultPerformanceData();
    }
  }

  Future<StatsData> _loadLastSessionStats() async {
    final ultimaSessaoLocal = SessaoHidratacaoStore.ultima;
    if (ultimaSessaoLocal != null) {
      return StatsData.fromSessao(ultimaSessaoLocal);
    }

    try {
      final sessoes = await HidraTrackApiClient.obterSessoesAtleta(
        widget.atletaId,
      );
      if (sessoes.isEmpty) {
        return StatsData.empty();
      }

      final lastSessao = sessoes.first;
      return _loadStatsFromApi(lastSessao['id']);
    } catch (e) {
      print('Erro ao carregar última sessão: $e');
      return StatsData.empty();
    }
  }

  Future<List<PerformancePoint>> _loadLastSessionPerformance() async {
    final ultimaSessaoLocal = SessaoHidratacaoStore.ultima;
    if (ultimaSessaoLocal != null) {
      return _performanceFromSessao(ultimaSessaoLocal);
    }

    try {
      final sessoes = await HidraTrackApiClient.obterSessoesAtleta(
        widget.atletaId,
      );
      if (sessoes.isEmpty) {
        return _defaultPerformanceData();
      }

      final lastSessao = sessoes.first;
      return _loadPerformanceData(lastSessao['id']);
    } catch (e) {
      print('Erro ao carregar performance: $e');
      return _defaultPerformanceData();
    }
  }

  List<PerformancePoint> _performanceFromSessao(SessaoFinalizada sessao) {
    if (sessao.ingestoes.isEmpty || sessao.totalIngeridoMl <= 0) {
      return _defaultPerformanceData();
    }

    var acumulado = 0;
    final pontos = <PerformancePoint>[
      PerformancePoint(time: '0 MIN', value: 0),
    ];

    for (final ingestao in sessao.ingestoes) {
      acumulado += ingestao.quantidadeMl;
      pontos.add(
        PerformancePoint(
          time: '${ingestao.tempoDecorrido.inMinutes} MIN',
          value: (acumulado / sessao.totalIngeridoMl).clamp(0, 1).toDouble(),
        ),
      );
    }

    return pontos.length == 1 ? _defaultPerformanceData() : pontos;
  }

  List<PerformancePoint> _defaultPerformanceData() {
    return [
      PerformancePoint(time: '0 MIN', value: 0.6),
      PerformancePoint(time: '30 MIN', value: 0.75),
      PerformancePoint(time: '60 MIN', value: 0.92),
      PerformancePoint(time: '90 MIN', value: 0.88),
    ];
  }

  void _saveResults() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Resultado salvo com sucesso!'),
        backgroundColor: _success,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _reportPDF() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Gerando PDF...'),
        backgroundColor: _cyan,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      bottomNavigationBar: _buildBottomNav(context),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: FutureBuilder<StatsData>(
              future: _statsDataFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: _lime));
                }

                if (snapshot.hasError || snapshot.data == null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Erro ao carregar dados',
                          style: TextStyle(color: _text),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => setState(() {
                            _statsDataFuture = widget.sessaoId != null
                                ? _loadStatsFromApi(widget.sessaoId!)
                                : _loadLastSessionStats();
                          }),
                          child: const Text('Tentar novamente'),
                        ),
                      ],
                    ),
                  );
                }

                final statsData = snapshot.data!;

                return CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 86),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          _buildBrand(),
                          const SizedBox(height: 28),
                          _buildSweatRateCard(statsData),
                          const SizedBox(height: 24),
                          _buildPerformanceTrend(),
                          const SizedBox(height: 24),
                          _buildMetricsRow(statsData),
                          const SizedBox(height: 24),
                          _buildTheoreticalBalance(statsData),
                          const SizedBox(height: 24),
                          _buildRehydrationPlan(statsData),
                          const SizedBox(height: 24),
                          _buildActionButtons(),
                          const SizedBox(height: 20),
                        ]),
                      ),
                    ),
                  ],
                );
              },
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

  Widget _buildSweatRateCard(StatsData data) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TAXA DE SUDORESE MÉDIA',
            style: TextStyle(
              color: _muted,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                data.sweatRate.toStringAsFixed(2),
                style: const TextStyle(
                  color: _lime,
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'L/h',
                style: TextStyle(
                  color: _text,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: _lime.withValues(alpha: 0.3)),
                ),
                child: Text(
                  'INTENSIDADE ${data.intensity}',
                  style: const TextStyle(
                    color: _lime,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: _cyan.withValues(alpha: 0.3)),
                ),
                child: Text(
                  '${data.temperature.toStringAsFixed(0)}°C / ${data.humidity}% UR',
                  style: const TextStyle(
                    color: _cyan,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceTrend() {
    return FutureBuilder<List<PerformancePoint>>(
      future: _performanceDataFuture,
      builder: (context, snapshot) {
        final data = snapshot.data ?? _defaultPerformanceData();

        return Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'PERFORMANCE TREND',
                    style: TextStyle(
                      color: _cyan,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                  Icon(Icons.trending_up, color: _cyan, size: 18),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 120,
                child: CustomPaint(
                  painter: PerformanceChartPainter(
                    data: data,
                    lineColor: _cyan,
                    dotColor: _lime,
                  ),
                  size: const Size(double.infinity, 120),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  data.length,
                  (index) => Text(
                    data[index].time,
                    style: const TextStyle(
                      color: _muted,
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricsRow(StatsData data) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PERDA AJUSTADA',
                  style: TextStyle(
                    color: _muted,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  data.fluidLoss.toStringAsFixed(2),
                  style: const TextStyle(
                    color: _text,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'L',
                  style: TextStyle(
                    color: _muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _lime.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'VARIAÇÃO %',
                  style: TextStyle(
                    color: _muted,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${data.variation.toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: data.variation < 0 ? _lime : _danger,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTheoreticalBalance(StatsData data) {
    final isDeficit = data.theoreticalBalance < 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'BALANÇO TEÓRICO',
                style: TextStyle(
                  color: _muted,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${data.theoreticalBalance} mL',
                style: const TextStyle(
                  color: _text,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'DEFICIT LEVEL',
                style: TextStyle(
                  color: isDeficit ? _danger : _success,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isDeficit ? 'CRÍTICO' : 'NORMAL',
                style: TextStyle(
                  color: isDeficit ? _danger : _success,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRehydrationPlan(StatsData data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _lime,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.opacity, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              const Text(
                'PLANO DE REPOSIÇÃO',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${data.recommendedIntakeMin}-${data.recommendedIntakeMax}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                'mL/h',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildRecommendationItem(
            icon: Icons.schedule,
            text:
                'Fraccionar a cada ${data.interval}-20 minutos durante o exercício.',
          ),
          const SizedBox(height: 12),
          _buildRecommendationItem(
            icon: Icons.local_florist,
            text: 'Adicionar 400-600mg de Sódio por litro de água.',
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationItem({
    required IconData icon,
    required String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.white, size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w500,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: _saveResults,
            style: ElevatedButton.styleFrom(
              backgroundColor: _lime,
              foregroundColor: Colors.white,
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: const Icon(Icons.save, size: 18),
            label: const Text(
              'SALVAR RESULTADO',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: _reportPDF,
            style: OutlinedButton.styleFrom(
              foregroundColor: _text,
              side: BorderSide(color: _text.withValues(alpha: 0.3)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: const Icon(Icons.picture_as_pdf, size: 18),
            label: const Text(
              'REPORTAR PDF',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
      ],
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
                    Icon(items[i].$1, color: i == 2 ? _lime : _muted, size: 23),
                    const SizedBox(height: 5),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        items[i].$2,
                        style: TextStyle(
                          color: i == 2 ? _lime : _muted,
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

class StatsData {
  final double sweatRate;
  final String intensity;
  final double temperature;
  final int humidity;
  final List<PerformancePoint> performanceData;
  final double fluidLoss;
  final double variation;
  final int theoreticalBalance;
  final int recommendedIntakeMin;
  final int recommendedIntakeMax;
  final int interval;

  StatsData({
    required this.sweatRate,
    required this.intensity,
    required this.temperature,
    required this.humidity,
    required this.performanceData,
    required this.fluidLoss,
    required this.variation,
    required this.theoreticalBalance,
    required this.recommendedIntakeMin,
    required this.recommendedIntakeMax,
    required this.interval,
  });

  factory StatsData.fromSessao(SessaoFinalizada sessao) {
    final resultado = sessao.resultado;

    return StatsData(
      sweatRate: resultado.taxaSudoreseLitrosHora,
      intensity: sessao.inicio.intensidade.toUpperCase(),
      temperature: sessao.inicio.temperaturaC,
      humidity: sessao.inicio.umidadeRelativa,
      performanceData: [],
      fluidLoss: resultado.perdaMassaAjustadaLitros,
      variation: resultado.variacaoMassaPercentual,
      theoreticalBalance: resultado.balancoHidricoMl,
      recommendedIntakeMin: resultado.recomendacaoMinMlHora,
      recommendedIntakeMax: resultado.recomendacaoMaxMlHora,
      interval: 15,
    );
  }

  factory StatsData.empty() {
    return StatsData(
      sweatRate: 0.0,
      intensity: 'BAIXA',
      temperature: 0.0,
      humidity: 0,
      performanceData: [],
      fluidLoss: 0.0,
      variation: 0.0,
      theoreticalBalance: 0,
      recommendedIntakeMin: 0,
      recommendedIntakeMax: 0,
      interval: 20,
    );
  }
}

class PerformancePoint {
  final String time;
  final double value;

  PerformancePoint({required this.time, required this.value});
}

class PerformanceChartPainter extends CustomPainter {
  final List<PerformancePoint> data;
  final Color lineColor;
  final Color dotColor;

  PerformanceChartPainter({
    required this.data,
    required this.lineColor,
    required this.dotColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final dotPaint = Paint()
      ..color = dotColor
      ..style = PaintingStyle.fill;

    final dashPaint = Paint()
      ..color = lineColor.withValues(alpha: 0.2)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final maxValue = data.map((p) => p.value).reduce((a, b) => a > b ? a : b);
    final minValue = 0.0;

    // Desenhar linhas tracejadas de grade
    final stepY = size.height / 4;
    for (int i = 1; i < 4; i++) {
      canvas.drawLine(
        Offset(0, stepY * i),
        Offset(size.width, stepY * i),
        dashPaint,
      );
    }

    // Desenhar a curva
    final path = Path();
    for (int i = 0; i < data.length; i++) {
      final x = (size.width / (data.length - 1)) * i;
      final y = size.height -
          ((data[i].value - minValue) / (maxValue - minValue)) * size.height;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    // Desenhar pontos
    for (int i = 0; i < data.length; i++) {
      final x = (size.width / (data.length - 1)) * i;
      final y = size.height -
          ((data[i].value - minValue) / (maxValue - minValue)) * size.height;

      canvas.drawCircle(Offset(x, y), 4, dotPaint);
      canvas.drawCircle(Offset(x, y), 4, paint..style = PaintingStyle.stroke);
    }
  }

  @override
  bool shouldRepaint(PerformanceChartPainter oldDelegate) {
    return oldDelegate.data != data;
  }
}
