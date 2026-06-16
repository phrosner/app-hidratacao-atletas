import 'dart:math' as math;



import 'package:flutter/material.dart';

import 'package:flutter/services.dart';

import 'package:hidratrack/app_rotas.dart';

import 'package:hidratrack/Servicos/hidratrack_api_client.dart';

import 'package:hidratrack/Servicos/AtletaService.dart';

import 'package:hidratrack/Servicos/AuthStorage.dart';



class TelaTaxaMedia extends StatefulWidget {

  const TelaTaxaMedia({super.key});



  @override

  State<TelaTaxaMedia> createState() => _TelaTaxaMediaState();

}



class _TelaTaxaMediaState extends State<TelaTaxaMedia> {



  static const _background = Color(0xFFFFFFFF);

  static const _surface = Color(0xFFF7F7F7);

  static const _surfaceLight = Color(0xFFEDEDED);

  static const _lime = Color(0xFFB32025);

  static const _cyan = Color(0xFF8F171B);

  static const _text = Color(0xFF222222);

  static const _muted = Color(0xFF6B6B6B);



  late Future<Map<String, dynamic>> _statsFuture;

  late Future<List<_PerfPoint>> _performanceFuture;

  int? _lastSessaoId;



  // Local temporary values while loading

  static const double _initialDouble = 0.0;

  static const int _initialInt = 0;



  // Simple local performance point model

  // (kept minimal to avoid adding cross-file dependencies)

  

  @override

  void initState() {

    super.initState();

    _statsFuture = _loadLastSessionStats();

    _performanceFuture = _loadLastSessionPerformance();

  }



  Future<Map<String, dynamic>> _loadLastSessionStats() async {

    try {

      int atletaId;

      try {

        atletaId = await AtletaService.obterAtletaIdAutenticado();

      } catch (_) {

        atletaId = AuthStorage.userId ?? 1;

      }



      final sessoes = await HidraTrackApiClient.obterSessoesAtleta(atletaId);

      if (sessoes.isEmpty) return {};



      // We'll average stats across the last up to 8 sessions

      final limit = sessoes.length < 8 ? sessoes.length : 8;

      double sumaTaxa = 0.0;

      double sumaPerda = 0.0;

      double sumaVariacao = 0.0;

      int sumaRecMax = 0;

      int count = 0;

      Map<String, dynamic>? lastSessaoFull;



      for (var i = 0; i < limit; i++) {

        final s = sessoes[i];

        final id = s['id'];

        if (id == null) continue;

        final sessao = await HidraTrackApiClient.obterSessao(id);

        lastSessaoFull = sessao;

        // store the most recent sessao id for save operations

        if (_lastSessaoId == null) {

          try {

            _lastSessaoId = (sessao['id'] as int?) ?? (sessao['id'] as num?)?.toInt();

          } catch (_) {}

        }



        Map<String, dynamic> st = {};

        try {

          st = await HidraTrackApiClient.obterStats(id);

        } catch (_) {}



        final taxa = (st['taxaSudoreseMedia'] as num?)?.toDouble();

        final perda = (st['perdaLiquidoAjustada'] as num?)?.toDouble();

        final variacao = (st['variacaoSudorese'] as num?)?.toDouble();

        final recMax = (st['recomendacaoIntakeMax'] as num?)?.toInt();



        if (taxa != null) { sumaTaxa += taxa; }

        if (perda != null) { sumaPerda += perda; }

        if (variacao != null) { sumaVariacao += variacao; }

        if (recMax != null) { sumaRecMax += recMax; }



        count++;

      }



      final combined = <String, dynamic>{};

      if (count > 0) {

        combined['taxaSudoreseMedia'] = sumaTaxa / count;

        combined['perdaLiquidoAjustada'] = sumaPerda / count;

        combined['variacaoSudorese'] = sumaVariacao / count;

        combined['recomendacaoIntakeMax'] = (sumaRecMax / count).round();

      }



      // Add last session contextual values (temperature, humidity, intensidade)

      if (lastSessaoFull != null) {

        combined['temperaturaAmbiente'] = lastSessaoFull['temperaturaAmbiente'];

        combined['umidadeRelativa'] = lastSessaoFull['umidadeRelativa'];

        combined['intensidade'] = lastSessaoFull['intensidade'] ?? 'ALTA';

        // ensure lastSessaoId is also set from the last session fetched

        try {

          _lastSessaoId = (lastSessaoFull['id'] as int?) ?? (lastSessaoFull['id'] as num?)?.toInt() ?? _lastSessaoId;

        } catch (_) {}

      }



      return combined;

    } catch (e) {

      print('Erro ao carregar stats (TelaTaxaMedia): $e');

      return {};

    }

  }



  Future<List<_PerfPoint>> _loadLastSessionPerformance() async {

    try {

      int atletaId;

      try {

        atletaId = await AtletaService.obterAtletaIdAutenticado();

      } catch (_) {

        atletaId = AuthStorage.userId ?? 1;

      }



      final sessoes = await HidraTrackApiClient.obterSessoesAtleta(atletaId);

      if (sessoes.isEmpty) return _defaultPerformanceData();



      final lastSessao = sessoes.first;

      final sessao = await HidraTrackApiClient.obterSessao(lastSessao['id']);

      final metricas = (sessao['metricas'] as List<dynamic>?) ?? [];



      if (metricas.isEmpty) return _defaultPerformanceData();



      final maxTaxa = 1.92;

      // Sort metricas by tempoDecorridoMinutos

      metricas.sort((a, b) {

        final ta = a['tempoDecorridoMinutos'] as int? ?? 0;

        final tb = b['tempoDecorridoMinutos'] as int? ?? 0;

        return ta.compareTo(tb);

      });



      return metricas.map((m) {

        final tempo = m['tempoDecorridoMinutos'] as int? ?? 0;

        final taxa = (m['taxaSudorese'] as num?)?.toDouble() ?? 0.0;

        return _PerfPoint(time: '${tempo} MIN', value: (taxa / maxTaxa).clamp(0, 1).toDouble());

      }).toList();

    } catch (e) {

      print('Erro ao carregar performance (TelaTaxaMedia): $e');

      return _defaultPerformanceData();

    }

  }



  List<_PerfPoint> _defaultPerformanceData() {

    return [

      _PerfPoint(time: '0 MIN', value: 0.6),

      _PerfPoint(time: '30 MIN', value: 0.75),

      _PerfPoint(time: '60 MIN', value: 0.92),

      _PerfPoint(time: '90 MIN', value: 0.88),

    ];

  }



  

 

  void _showAction(BuildContext context, String message) {

    HapticFeedback.selectionClick();

    ScaffoldMessenger.of(context).showSnackBar(

      SnackBar(

        content: Text(message),

        backgroundColor: _surfaceLight,

        behavior: SnackBarBehavior.floating,

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

            child: FutureBuilder<Map<String, dynamic>>(

              future: _statsFuture,

              builder: (context, snapshot) {

                if (snapshot.connectionState == ConnectionState.waiting) {

                  return const Center(child: CircularProgressIndicator());

                }



                if (snapshot.hasError || snapshot.data == null) {

                  return Center(

                    child: Column(

                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [

                        const Text('Erro ao carregar dados'),

                        const SizedBox(height: 12),

                        FilledButton(

                          onPressed: () => setState(() {

                            _statsFuture = _loadLastSessionStats();

                            _performanceFuture = _loadLastSessionPerformance();

                          }),

                          child: const Text('Tentar novamente'),

                        ),

                      ],

                    ),

                  );

                }



                final stats = snapshot.data!;



                // extract values

                final sweatRate = (stats['taxaSudoreseMedia'] as num?)?.toDouble() ?? _initialDouble;

                final waterLoss = (stats['perdaLiquidoAjustada'] as num?)?.toDouble() ?? _initialDouble;

                final variation = (stats['variacaoSudorese'] as num?)?.toDouble() ?? _initialDouble;

                final recommended = (stats['recomendacaoIntakeMax'] as num?)?.toInt() ?? _initialInt;



                return CustomScrollView(

                  slivers: [

                    SliverPadding(

                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 26),

                      sliver: SliverList(

                        delegate: SliverChildListDelegate([

                          _buildTopBar(),

                          const SizedBox(height: 20),

                          _buildSweatRateCard(sweatRate, stats),

                          const SizedBox(height: 14),

                          FutureBuilder<List<_PerfPoint>>(

                            future: _performanceFuture,

                            builder: (c, perfSnap) {

                              final perf = perfSnap.data ?? _defaultPerformanceData();

                              return _buildPerformanceCard(perf);

                            },

                          ),

                          const SizedBox(height: 14),

                          _buildMetricsGrid(waterLoss, variation, recommended),

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



  Widget _buildTopBar() {

    return const Text(

      'H2OTRACK',

      style: TextStyle(color: _text, fontSize: 13, fontWeight: FontWeight.w500),

    );

  }



  Widget _buildSweatRateCard(double sweatRate, Map<String, dynamic> stats) {

    return Container(

      width: double.infinity,

      height: 148,

      padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),

      decoration: BoxDecoration(

        color: _surface,

        borderRadius: BorderRadius.circular(8),

        border: Border.all(color: _lime.withValues(alpha: 0.08)),

      ),

      child: Column(

        children: [

          Row(

            children: [

              const Expanded(

                child: Text(

                  'TAXA DE SUDORESE MEDIA',

                  textAlign: TextAlign.center,

                  style: TextStyle(

                    color: _muted,

                    fontSize: 9,

                    fontWeight: FontWeight.w900,

                    letterSpacing: 2,

                  ),

                ),

              ),

            ],

          ),

          const SizedBox(height: 4),

          Row(

            mainAxisAlignment: MainAxisAlignment.center,

            crossAxisAlignment: CrossAxisAlignment.end,

            children: [

              Text(

                sweatRate.toStringAsFixed(2),

                style: const TextStyle(

                  color: _lime,

                  fontSize: 50,

                  fontWeight: FontWeight.w900,

                  height: 0.9,

                  shadows: [

                    Shadow(color: _lime, blurRadius: 28),

                    Shadow(color: _lime, blurRadius: 10),

                  ],

                ),

              ),

              const SizedBox(width: 8),

              const Padding(

                padding: EdgeInsets.only(bottom: 6),

                child: Text(

                  'L/h',

                  style: TextStyle(

                    color: _text,

                    fontSize: 18,

                    fontWeight: FontWeight.w800,

                  ),

                ),

              ),

            ],

          ),

          const Spacer(),

          Row(

            mainAxisAlignment: MainAxisAlignment.center,

            children: [

              _buildPill((stats['intensidade'] as String?)?.toUpperCase() ?? 'INTENSIDADE', _lime, Colors.white),

              const SizedBox(width: 10),

              _buildPill('21 C / 65% UR', _surfaceLight, _text),

            ],

          ),

        ],

      ),

    );

  }



  Widget _buildPill(String label, Color background, Color foreground) {

    return Container(

      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),

      decoration: BoxDecoration(

        color: background,

        borderRadius: BorderRadius.circular(6),

      ),

      child: Text(

        label,

        style: TextStyle(

          color: foreground,

          fontSize: 8,

          fontWeight: FontWeight.w900,

          letterSpacing: 1,

        ),

      ),

    );

  }






  Widget _buildPerformanceCard(List<_PerfPoint> perfData) {

    return Container(

      height: 218,

      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),

      decoration: BoxDecoration(

        color: _surface,

        borderRadius: BorderRadius.circular(8),

      ),

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Row(

            children: [

              const Text(

                'PERFORMANCE TREND',

                style: TextStyle(

                  color: _cyan,

                  fontSize: 9,

                  fontWeight: FontWeight.w900,

                  letterSpacing: 2,

                ),

              ),

              const Spacer(),

              const Icon(Icons.auto_graph, color: _cyan, size: 20),

            ],

          ),

          const SizedBox(height: 16),

          Expanded(

            child: CustomPaint(

              painter: _PerformancePainter(

                intensity: perfData.map((p) => p.value * 100).toList(),

                hydration: perfData.map((p) => p.value * 100).toList(),

                cyan: _cyan,

                lime: _lime,

                grid: Color(0xFF2B2B2B),

              ),

              child: const SizedBox.expand(),

            ),

          ),

          const SizedBox(height: 8),

          const Row(

            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [

              _AxisLabel('0 MIN'),

              _AxisLabel('30 MIN'),

              _AxisLabel('60 MIN'),

              _AxisLabel('90 MIN'),

            ],

          ),

        ],

      ),

    );

  }



  Widget _buildMetricsGrid(double waterLossLiters, double weightVariation, int recommendedMlHour) {

    return Row(

      children: [

        Expanded(

          child: _MetricCard(

            title: 'PERDA AJUSTADA',

            value: '${waterLossLiters.toStringAsFixed(2)} L',

            accent: _text,

          ),

        ),

        const SizedBox(width: 10),

        Expanded(

          child: _MetricCard(

            title: 'VARIACAO %',

            value: '${weightVariation.toStringAsFixed(1)}%',

            accent: _lime,

            highlighted: true,

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

                  ).pushReplacementNamed(AppRotas.dashboardAtleta);

                } else if (i == 1) {

                  Navigator.of(

                    context,

                  ).pushReplacementNamed(AppRotas.historicoAtleta);

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



class _MetricCard extends StatelessWidget {

  const _MetricCard({

    required this.title,

    required this.value,

    required this.accent,

    this.highlighted = false,

  });



  final String title;

  final String value;

  final Color accent;

  final bool highlighted;



  @override

  Widget build(BuildContext context) {

    const lime = Color(0xFFB32025);

    const surface = Color(0xFFF7F7F7);

    const muted = Color(0xFF6B6B6B);



    return Container(

      height: 86,

      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(

        color: surface,

        borderRadius: BorderRadius.circular(8),

        border: highlighted

            ? Border.all(color: lime, width: 1.4)

            : Border.all(color: Colors.white.withValues(alpha: 0.05)),

      ),

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Row(

            children: [

              Expanded(

                child: Text(

                  title,

                  maxLines: 1,

                  overflow: TextOverflow.ellipsis,

                  style: const TextStyle(

                    color: muted,

                    fontSize: 8,

                    fontWeight: FontWeight.w900,

                    letterSpacing: 1.5,

                  ),

                ),

              ),

            ],

          ),

          const Spacer(),

          Text(

            value,

            style: TextStyle(

              color: accent,

              fontSize: 20,

              fontWeight: FontWeight.w900,

            ),

          ),

        ],

      ),

    );

  }

}



class _AxisLabel extends StatelessWidget {

  const _AxisLabel(this.text);



  final String text;



  @override

  Widget build(BuildContext context) {

    return Text(

      text,

      style: const TextStyle(

        color: Color(0xFF6B6B6B),

        fontSize: 8,

        fontWeight: FontWeight.w900,

        letterSpacing: 0.8,

      ),

    );

  }

}





class _PerfPoint {

  final String time;

  final double value;

  _PerfPoint({required this.time, required this.value});



}



class _PerformancePainter extends CustomPainter {

  const _PerformancePainter({

    required this.intensity,

    required this.hydration,

    required this.cyan,

    required this.lime,

    required this.grid,

  });



  final List<double> intensity;

  final List<double> hydration;

  final Color cyan;

  final Color lime;

  final Color grid;



  @override

  void paint(Canvas canvas, Size size) {

    final gridPaint = Paint()

      ..color = grid

      ..strokeWidth = 1;



    for (var i = 1; i <= 3; i++) {

      final y = size.height * i / 4;

      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);

    }



    _drawSeries(canvas, size, hydration, cyan, true);

    _drawSeries(canvas, size, intensity, lime, false);

  }



  void _drawSeries(

    Canvas canvas,

    Size size,

    List<double> values,

    Color color,

    bool fill,

  ) {

    if (values.length < 2) return;



    final maxValue = math.max(values.reduce(math.max), 1);

    final minValue = values.reduce(math.min);

    final range = math.max(maxValue - minValue, 1);

    final step = size.width / (values.length - 1);



    Offset pointAt(int index) {

      final normalized = (values[index] - minValue) / range;

      return Offset(

        step * index,

        size.height - (normalized * size.height * 0.78) - 12,

      );

    }



    final path = Path()..moveTo(pointAt(0).dx, pointAt(0).dy);

    for (var i = 1; i < values.length; i++) {

      final previous = pointAt(i - 1);

      final current = pointAt(i);

      final controlX = (previous.dx + current.dx) / 2;

      path.cubicTo(

        controlX,

        previous.dy,

        controlX,

        current.dy,

        current.dx,

        current.dy,

      );

    }



    if (fill) {

      final fillPath = Path.from(path)

        ..lineTo(size.width, size.height)

        ..lineTo(0, size.height)

        ..close();

      canvas.drawPath(fillPath, Paint()..color = color.withValues(alpha: 0.18));

    }



    final linePaint = Paint()

      ..color = color

      ..style = PaintingStyle.stroke

      ..strokeCap = StrokeCap.round

      ..strokeWidth = fill ? 2.5 : 1.4;



    canvas.drawPath(path, linePaint);

  }



  @override

  bool shouldRepaint(covariant _PerformancePainter oldDelegate) {

    return oldDelegate.intensity != intensity ||

        oldDelegate.hydration != hydration ||

        oldDelegate.cyan != cyan ||

        oldDelegate.lime != lime ||

        oldDelegate.grid != grid;

  }

}

