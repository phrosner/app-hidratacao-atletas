import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:hidratrack/Telas/Pos_sessao.dart';
import 'package:hidratrack/app_rotas.dart';

class TelaHistorico extends StatefulWidget {
  const TelaHistorico({super.key, this.atletaId = 1});

  final int atletaId;

  @override
  State<TelaHistorico> createState() => _TelaHistoricoState();
}

class _TelaHistoricoState extends State<TelaHistorico> {
  static const _background = Color(0xFF101010);
  static const _surface = Color(0xFF1B1B1B);
  static const _surfaceLight = Color(0xFF242424);
  static const _lime = Color(0xFFB9FF00);
  static const _cyan = Color(0xFF00E5FF);
  static const _text = Color(0xFFF5F5F5);
  static const _muted = Color(0xFF858585);

  String _filtro = '7 Dias';
  late Future<List<SessaoHistorico>> _sessoesFuture;

  @override
  void initState() {
    super.initState();
    _sessoesFuture = HistoricoSessoesRepository.carregarPorAtleta(
      atletaId: widget.atletaId,
      filtro: _filtro,
    );
  }

  void _trocarFiltro(String filtro) {
    setState(() {
      _filtro = filtro;
      _sessoesFuture = HistoricoSessoesRepository.carregarPorAtleta(
        atletaId: widget.atletaId,
        filtro: filtro,
      );
    });
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
            child: FutureBuilder<List<SessaoHistorico>>(
              future: _sessoesFuture,
              builder: (context, snapshot) {
                final sessoes = snapshot.data ?? const <SessaoHistorico>[];
                final chartValues = _chartValues(sessoes);
                final media = chartValues.isEmpty
                    ? 0.0
                    : chartValues.reduce((a, b) => a + b) / chartValues.length;

                return CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 86),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          _buildBrand(),
                          const SizedBox(height: 28),
                          _buildFilters(),
                          const SizedBox(height: 28),
                          _buildTrendCard(chartValues, media),
                          const SizedBox(height: 24),
                          _buildSectionLabel('SESSOES ANTERIORES'),
                          const SizedBox(height: 12),
                          if (snapshot.connectionState ==
                              ConnectionState.waiting)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(28),
                                child: CircularProgressIndicator(color: _lime),
                              ),
                            )
                          else if (sessoes.isEmpty)
                            _buildEmptyState()
                          else
                            for (final sessao in sessoes)
                              _buildSessionCard(sessao),
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
    return Row(
      children: const [
        Icon(Icons.water_drop, color: _lime, size: 18),
        SizedBox(width: 6),
        Text(
          'H2OTRACK',
          style: TextStyle(
            color: _lime,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('FILTROS DE PERFORMANCE'),
        const SizedBox(height: 12),
        Row(
          children: [
            for (final filtro in const ['7 Dias', '24 Dias', 'Todos']) ...[
              Expanded(
                child: _FilterChipButton(
                  label: filtro,
                  selected: _filtro == filtro,
                  onTap: () => _trocarFiltro(filtro),
                ),
              ),
              if (filtro != 'Todos') const SizedBox(width: 12),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildTrendCard(List<double> values, double media) {
    return Container(
      height: 226,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TENDENCIA TAXA DE SUOR',
                      style: TextStyle(
                        color: _cyan,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.7,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          media.toStringAsFixed(2),
                          style: const TextStyle(
                            color: _text,
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                            height: 1,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Padding(
                          padding: EdgeInsets.only(bottom: 2),
                          child: Text(
                            'L/h media',
                            style: TextStyle(
                              color: _muted,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: _lime.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const Text(
                  '+4.2% ESTE MES',
                  style: TextStyle(
                    color: _lime,
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Expanded(
            child: CustomPaint(
              painter: _SweatTrendPainter(values: values),
              child: const SizedBox.expand(),
            ),
          ),
          const SizedBox(height: 10),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _AxisLabel('01 MAI'),
              _AxisLabel('08 MAI'),
              _AxisLabel('15 MAI'),
              _AxisLabel('22 MAI'),
              _AxisLabel('HOJE'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard(SessaoHistorico sessao) {
    return Container(
      height: 74,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: sessao.accentColor, width: 3)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          Container(
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              color: _surfaceLight,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(sessao.icon, color: sessao.accentColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sessao.dataLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  sessao.titulo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _text,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  sessao.subtitulo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _text,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${sessao.sudoroseLitrosHora.toStringAsFixed(2)} L',
            style: const TextStyle(
              color: _text,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 14),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'Nenhuma sessao encontrada para este atleta.',
        style: TextStyle(color: _muted, fontSize: 12),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: _muted,
        fontSize: 9,
        fontWeight: FontWeight.w900,
        letterSpacing: 2,
      ),
    );
  }

  List<double> _chartValues(List<SessaoHistorico> sessoes) {
    if (sessoes.isEmpty) return const [];
    return sessoes
        .map((sessao) => sessao.sudoroseLitrosHora)
        .toList()
        .reversed
        .toList();
  }

  Widget _buildBottomNav(BuildContext context) {
    const items = [
      (Icons.water_drop_outlined, 'SESSION'),
      (Icons.history_rounded, 'HISTORY'),
      (Icons.insert_chart_outlined, 'STATS'),
      (Icons.track_changes, 'GOALS'),
    ];

    return Container(
      height: 58,
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
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
                }
              },
              child: SizedBox(
                width: 68,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(items[i].$1, color: i == 1 ? _lime : _muted, size: 18),
                    const SizedBox(height: 3),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        items[i].$2,
                        style: TextStyle(
                          color: i == 1 ? _lime : _muted,
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.7,
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

class HistoricoSessoesRepository {
  static Future<List<SessaoHistorico>> carregarPorAtleta({
    required int atletaId,
    required String filtro,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));

    final sessoesSalvas = SessaoStore.sessoes.map((sessao) {
      final perda = math.max(0.0, sessao.pesoInicial - sessao.pesoFinal);
      return SessaoHistorico(
        atletaId: atletaId,
        data: sessao.criadoEm,
        titulo: 'Treino',
        subtitulo: 'Sessao registrada',
        sudoroseLitrosHora: perda,
        icon: Icons.bolt,
        accentColor: const Color(0xFFB9FF00),
      );
    }).toList();

    final sessoes = sessoesSalvas.isEmpty
        ? _mockSessoes(atletaId)
        : sessoesSalvas;

    final limite = switch (filtro) {
      '7 Dias' => DateTime.now().subtract(const Duration(days: 7)),
      '24 Dias' => DateTime.now().subtract(const Duration(days: 24)),
      _ => DateTime(1900),
    };

    return sessoes
        .where((sessao) => sessao.atletaId == atletaId)
        .where((sessao) => sessao.data.isAfter(limite))
        .toList()
      ..sort((a, b) => b.data.compareTo(a.data));
  }

  static List<SessaoHistorico> _mockSessoes(int atletaId) {
    final now = DateTime.now();
    return [
      SessaoHistorico(
        atletaId: atletaId,
        data: now.subtract(const Duration(days: 1, hours: 2)),
        titulo: 'Treino de',
        subtitulo: 'Intervalo',
        sudoroseLitrosHora: 2.45,
        icon: Icons.bolt,
        accentColor: const Color(0xFFB9FF00),
      ),
      SessaoHistorico(
        atletaId: atletaId,
        data: now.subtract(const Duration(days: 3, hours: 5)),
        titulo: 'Ciclismo HIIT',
        subtitulo: '',
        sudoroseLitrosHora: 1.80,
        icon: Icons.directions_bike,
        accentColor: const Color(0xFF00E5FF),
      ),
      SessaoHistorico(
        atletaId: atletaId,
        data: now.subtract(const Duration(days: 5, hours: 4)),
        titulo: 'Forca',
        subtitulo: 'Explosiva',
        sudoroseLitrosHora: 0.95,
        icon: Icons.fitness_center,
        accentColor: const Color(0xFFB9FF00),
      ),
      SessaoHistorico(
        atletaId: atletaId,
        data: now.subtract(const Duration(days: 6, hours: 1)),
        titulo: 'Natacao',
        subtitulo: 'Endurance',
        sudoroseLitrosHora: 1.20,
        icon: Icons.pool,
        accentColor: const Color(0xFF858585),
      ),
    ];
  }
}

class SessaoHistorico {
  const SessaoHistorico({
    required this.atletaId,
    required this.data,
    required this.titulo,
    required this.subtitulo,
    required this.sudoroseLitrosHora,
    required this.icon,
    required this.accentColor,
  });

  final int atletaId;
  final DateTime data;
  final String titulo;
  final String subtitulo;
  final double sudoroseLitrosHora;
  final IconData icon;
  final Color accentColor;

  String get dataLabel {
    const meses = [
      'JAN',
      'FEV',
      'MAR',
      'ABR',
      'MAI',
      'JUN',
      'JUL',
      'AGO',
      'SET',
      'OUT',
      'NOV',
      'DEZ',
    ];
    final dia = data.day.toString().padLeft(2, '0');
    final mes = meses[data.month - 1];
    final hora = data.hour.toString().padLeft(2, '0');
    final minuto = data.minute.toString().padLeft(2, '0');
    return '$dia $mes, ${data.year} - $hora:$minuto';
  }
}

class _FilterChipButton extends StatelessWidget {
  const _FilterChipButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const lime = Color(0xFFB9FF00);
    const surface = Color(0xFF1B1B1B);
    const muted = Color(0xFF858585);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 31,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? lime : surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.black : muted,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
          ),
        ),
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
        color: Color(0xFF858585),
        fontSize: 8,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.7,
      ),
    );
  }
}

class _SweatTrendPainter extends CustomPainter {
  const _SweatTrendPainter({required this.values});

  final List<double> values;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final normalizedValues = values.length == 1
        ? [values.first, values.first]
        : values;
    final maxValue = math.max(normalizedValues.reduce(math.max), 0.1);
    final minValue = normalizedValues.reduce(math.min);
    final range = math.max(maxValue - minValue, 0.1);
    final step = size.width / (normalizedValues.length - 1);

    Offset pointAt(int index) {
      final normalized = (normalizedValues[index] - minValue) / range;
      return Offset(
        step * index,
        size.height - (normalized * size.height * 0.72) - 14,
      );
    }

    final cyanPaint = Paint()
      ..color = const Color(0xFF00E5FF)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final limePaint = Paint()
      ..color = const Color(0xFFB9FF00)
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke;

    final cyanPath = Path();
    final limePath = Path();
    final split = math.max(1, normalizedValues.length ~/ 3);

    for (var i = 0; i < normalizedValues.length; i++) {
      final point = pointAt(i);
      if (i == 0) {
        cyanPath.moveTo(point.dx, point.dy);
        limePath.moveTo(point.dx, point.dy);
      } else if (i <= split) {
        cyanPath.lineTo(point.dx, point.dy);
        limePath.moveTo(point.dx, point.dy);
      } else {
        limePath.lineTo(point.dx, point.dy);
      }
    }

    final fillPath = Path.from(limePath)
      ..lineTo(size.width, size.height)
      ..lineTo(step * split, size.height)
      ..close();

    canvas.drawPath(
      fillPath,
      Paint()..color = const Color(0xFFB9FF00).withValues(alpha: 0.10),
    );
    canvas.drawPath(cyanPath, cyanPaint);
    canvas.drawPath(limePath, limePaint);
  }

  @override
  bool shouldRepaint(covariant _SweatTrendPainter oldDelegate) {
    return oldDelegate.values != values;
  }
}
