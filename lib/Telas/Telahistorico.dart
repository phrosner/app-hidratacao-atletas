import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:hidratrack/Servicos/AtletaService.dart';
import 'package:hidratrack/app_rotas.dart';

class TelaHistorico extends StatefulWidget {
  const TelaHistorico({super.key, this.atletaId = 1});

  final int atletaId;

  @override
  State<TelaHistorico> createState() => _TelaHistoricoState();
}

class _TelaHistoricoState extends State<TelaHistorico> {
  static const _background = Color(0xFFFFFFFF);
  static const _surface = Color(0xFFF7F7F7);
  static const _surfaceLight = Color(0xFFEDEDED);
  static const _lime = Color(0xFFB32025);
  static const _cyan = Color(0xFF8F171B);
  static const _text = Color(0xFF222222);
  static const _muted = Color(0xFF6B6B6B);

  String _filtro = '7 Dias';
  late Future<List<SessaoHistorico>> _sessoesFuture;

  @override
  void initState() {
    super.initState();
    _sessoesFuture = HistoricoSessoesRepository.carregarPorAtleta(
      filtro: _filtro,
    );
  }

  void _trocarFiltro(String filtro) {
    setState(() {
      _filtro = filtro;
      _sessoesFuture = HistoricoSessoesRepository.carregarPorAtleta(
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
                          _buildTrendCard(chartValues, media, sessoes),
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
                          else if (snapshot.hasError)
                            _buildErrorState(snapshot.error.toString())
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

  Widget _buildTrendCard(List<double> values, double media, List<SessaoHistorico> sessoes) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _chartAxisLabels(_filtro, sessoes)
                .map((label) => _AxisLabel(label))
                .toList(),
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
            '${sessao.SudoreseLitrosHora.toStringAsFixed(2)} L',
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

  Widget _buildErrorState(String error) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Erro ao carregar histórico: $error',
        style: const TextStyle(color: _muted, fontSize: 12),
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
        .map((sessao) => sessao.SudoreseLitrosHora)
        .toList()
        .reversed
        .toList();
  }

  List<String> _chartAxisLabels(String filtro, List<SessaoHistorico> sessoes) {
    final now = DateTime.now();
    final start = switch (filtro) {
      '7 Dias' => now.subtract(const Duration(days: 7)),
      '24 Dias' => now.subtract(const Duration(days: 24)),
      _ => sessoes.isNotEmpty
          ? sessoes.last.data
          : now.subtract(const Duration(days: 28)),
    };

    final totalDays = now.difference(start).inDays;
    final labels = List<String>.generate(5, (index) {
      final date = start.add(Duration(
        days: ((totalDays * index) / 4).round(),
      ));
      return index == 4 ? 'HOJE' : _formatChartLabel(date);
    });

    return labels;
  }

  String _formatChartLabel(DateTime date) {
    const months = [
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
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]}';
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
                    Icon(items[i].$1, color: i == 1 ? _lime : _muted, size: 23),
                    const SizedBox(height: 5),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        items[i].$2,
                        style: TextStyle(
                          color: i == 1 ? _lime : _muted,
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

class HistoricoSessoesRepository {
  static Future<List<SessaoHistorico>> carregarPorAtleta({
    required String filtro,
  }) async {
    final dias = filtro == '7 Dias'
        ? 7
        : filtro == '24 Dias'
            ? 24
            : null;

    try {
      final sessoesJson = await AtletaService.obterHistoricoAtleta(dias: dias);
      return sessoesJson
          .map(SessaoHistorico.fromJson)
          .toList()
        ..sort((a, b) => b.data.compareTo(a.data));
    } catch (e) {
      debugPrint('Erro ao carregar histórico: $e');
      return const [];
    }
  }
}

class SessaoHistorico {
  const SessaoHistorico({
    required this.id,
    required this.atletaId,
    required this.data,
    required this.titulo,
    required this.subtitulo,
    required this.SudoreseLitrosHora,
    required this.icon,
    required this.accentColor,
  });

  factory SessaoHistorico.fromJson(Map<String, dynamic> json) {
    final iconName = json['icone']?.toString() ?? 'bolt';
    return SessaoHistorico(
      id: json['id'] is num ? (json['id'] as num).toInt() : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      atletaId: 0,
      data: DateTime.tryParse(json['data']?.toString() ?? '') ?? DateTime.now(),
      titulo: json['tipoTreino']?.toString() ?? 'Treino',
      subtitulo: '',
      SudoreseLitrosHora: (json['volumeLitros'] as num?)?.toDouble() ?? 0.0,
      icon: _iconFromName(iconName),
      accentColor: _accentColorFromName(iconName),
    );
  }

  static IconData _iconFromName(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'bike':
        return Icons.directions_bike;
      case 'pool':
        return Icons.pool;
      case 'fitness_center':
      case 'fitness':
        return Icons.fitness_center;
      case 'access_time':
        return Icons.access_time;
      case 'block':
        return Icons.block;
      default:
        return Icons.bolt;
    }
  }

  static Color _accentColorFromName(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'bike':
        return const Color(0xFF8F171B);
      case 'pool':
      case 'fitness_center':
        return const Color(0xFF6B6B6B);
      default:
        return const Color(0xFFB32025);
    }
  }

  final int id;
  final int atletaId;
  final DateTime data;
  final String titulo;
  final String subtitulo;
  final double SudoreseLitrosHora;
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
    const lime = Color(0xFFB32025);
    const surface = Color(0xFFF7F7F7);
    const muted = Color(0xFF6B6B6B);

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
            color: selected ? Colors.white : muted,
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
        color: Color(0xFF6B6B6B),
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
      ..color = const Color(0xFF8F171B)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final limePaint = Paint()
      ..color = const Color(0xFFB32025)
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
      Paint()..color = const Color(0xFFB32025).withValues(alpha: 0.10),
    );
    canvas.drawPath(cyanPath, cyanPaint);
    canvas.drawPath(limePath, limePaint);
  }

  @override
  bool shouldRepaint(covariant _SweatTrendPainter oldDelegate) {
    return oldDelegate.values != values;
  }
}
