import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hidratrack/app_rotas.dart';

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

  double _sweatRate = 1.85;
  double _waterLossLiters = 2.42;
  double _weightVariation = -1.8;
  int _recommendedMlHour = 750;

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

  Future<void> _editarNumero({
    required String titulo,
    required double valorAtual,
    required ValueChanged<double> aoSalvar,
  }) async {
    final controller = TextEditingController(text: valorAtual.toString());

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: _surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: Text(
          titulo,
          style: const TextStyle(color: _text, fontWeight: FontWeight.w900),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
            signed: true,
          ),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[-0-9,.]')),
          ],
          decoration: const InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('CANCELAR'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: _lime),
            onPressed: () {
              final valor = double.tryParse(
                controller.text.trim().replaceAll(',', '.'),
              );
              if (valor == null) return;
              setState(() => aoSalvar(valor));
              Navigator.of(dialogContext).pop();
              _showAction(context, 'Valor atualizado');
            },
            child: const Text('SALVAR'),
          ),
        ],
      ),
    );

    controller.dispose();
  }

  Future<void> _editarInteiro({
    required String titulo,
    required int valorAtual,
    required ValueChanged<int> aoSalvar,
  }) async {
    final controller = TextEditingController(text: valorAtual.toString());

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: _surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: Text(
          titulo,
          style: const TextStyle(color: _text, fontWeight: FontWeight.w900),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('CANCELAR'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: _lime),
            onPressed: () {
              final valor = int.tryParse(controller.text.trim());
              if (valor == null) return;
              setState(() => aoSalvar(valor));
              Navigator.of(dialogContext).pop();
              _showAction(context, 'Valor atualizado');
            },
            child: const Text('SALVAR'),
          ),
        ],
      ),
    );

    controller.dispose();
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
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 26),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildTopBar(),
                      const SizedBox(height: 20),
                      _buildSweatRateCard(),
                      const SizedBox(height: 14),
                      _buildPerformanceCard(),
                      const SizedBox(height: 14),
                      _buildMetricsGrid(),
                      const SizedBox(height: 14),
                      _buildRepositionPlan(),
                      const SizedBox(height: 20),
                      _buildPrimaryButton(context),
                      const SizedBox(height: 12),
                      _buildSecondaryButton(context),
                      const SizedBox(height: 12),
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

  Widget _buildTopBar() {
    return const Text(
      'H2OTRACK',
      style: TextStyle(color: _text, fontSize: 13, fontWeight: FontWeight.w500),
    );
  }

  Widget _buildSweatRateCard() {
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
              _buildEditButton(
                tooltip: 'Editar taxa',
                onPressed: () => _editarNumero(
                  titulo: 'Editar taxa de sudorese',
                  valorAtual: _sweatRate,
                  aoSalvar: (valor) => _sweatRate = valor,
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
                _sweatRate.toStringAsFixed(2),
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
              _buildPill('INTENSIDADE ALTA', _lime, Colors.white),
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

  Widget _buildEditButton({
    required String tooltip,
    required VoidCallback onPressed,
    Color foreground = _muted,
    Color background = Colors.white,
  }) {
    return SizedBox(
      width: 32,
      height: 32,
      child: IconButton(
        tooltip: tooltip,
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.zero,
        style: IconButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
        ),
        onPressed: onPressed,
        icon: const Icon(Icons.edit_outlined, size: 17),
      ),
    );
  }

  Widget _buildPerformanceCard() {
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
              const SizedBox(width: 8),
              _buildEditButton(
                tooltip: 'Editar grafico',
                onPressed: () =>
                    _showAction(context, 'Edicao do grafico em preparacao'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: CustomPaint(
              painter: _PerformancePainter(
                intensity: [42, 54, 49, 64, 58, 73, 44, 38, 79, 68],
                hydration: [39, 46, 52, 50, 61, 55, 46, 59, 81, 43],
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

  Widget _buildMetricsGrid() {
    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            title: 'PERDA AJUSTADA',
            value: '${_waterLossLiters.toStringAsFixed(2)} L',
            accent: _text,
            onEdit: () => _editarNumero(
              titulo: 'Editar perda ajustada',
              valorAtual: _waterLossLiters,
              aoSalvar: (valor) => _waterLossLiters = valor,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MetricCard(
            title: 'VARIACAO %',
            value: '${_weightVariation.toStringAsFixed(1)}%',
            accent: _lime,
            highlighted: true,
            onEdit: () => _editarNumero(
              titulo: 'Editar variacao',
              valorAtual: _weightVariation,
              aoSalvar: (valor) => _weightVariation = valor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRepositionPlan() {
    final doseMl = (_recommendedMlHour / 4).round();
    final rows = [
      ('00:15', '$doseMl ml', 'Inicio da reposicao'),
      ('00:30', '$doseMl ml', 'Manter ritmo'),
      ('00:45', '$doseMl ml', 'Checar sede'),
      ('01:00', '$doseMl ml', 'Nova avaliacao'),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: _lime,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: _lime.withValues(alpha: 0.24),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.water_drop_outlined,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'PLANO DE REPOSICAO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              _buildEditButton(
                tooltip: 'Editar plano',
                foreground: _lime,
                background: Colors.white,
                onPressed: () => _editarInteiro(
                  titulo: 'Editar recomendacao horaria',
                  valorAtual: _recommendedMlHour,
                  aoSalvar: (valor) => _recommendedMlHour = valor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'RECOMENDACAO HORARIA',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 8,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${_recommendedMlHour}ml',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              const SizedBox(width: 5),
              const Padding(
                padding: EdgeInsets.only(bottom: 3),
                child: Text(
                  '/h',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(7),
              border: Border.all(color: Colors.white.withValues(alpha: 0.09)),
            ),
            child: Column(
              children: [
                const _PlanHeader(),
                for (var i = 0; i < rows.length; i++)
                  _PlanRow(
                    time: rows[i].$1,
                    amount: rows[i].$2,
                    note: rows[i].$3,
                    showDivider: i != rows.length - 1,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _buildInstruction(
            Icons.schedule,
            'Fracionar a cada 15 minutos durante o exercicio.',
          ),
          const SizedBox(height: 10),
          _buildInstruction(
            Icons.bolt,
            'Adicionar 400-600mg de sodio por litro de agua.',
          ),
        ],
      ),
    );
  }

  Widget _buildInstruction(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 17),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: FilledButton.icon(
        onPressed: () => _showAction(context, 'Resultado salvo com sucesso'),
        style: FilledButton.styleFrom(
          backgroundColor: _lime,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 12,
          shadowColor: _lime.withValues(alpha: 0.34),
        ),
        icon: const Icon(Icons.save_outlined, size: 18),
        label: const Text(
          'SALVAR RESULTADO',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton.icon(
        onPressed: () => _showAction(context, 'Relatorio PDF em preparacao'),
        style: OutlinedButton.styleFrom(
          foregroundColor: _text,
          side: BorderSide(color: Colors.white.withValues(alpha: 0.13)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
        label: const Text(
          'REPORTAR PDF',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
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
    required this.onEdit,
    this.highlighted = false,
  });

  final String title;
  final String value;
  final Color accent;
  final VoidCallback onEdit;
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
              SizedBox(
                width: 26,
                height: 26,
                child: IconButton(
                  tooltip: 'Editar',
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: muted,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 14),
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

class _PlanHeader extends StatelessWidget {
  const _PlanHeader();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(12, 10, 12, 8),
      child: Row(
        children: [
          Expanded(child: _PlanHeaderText('HORARIO')),
          Expanded(child: _PlanHeaderText('INGERIR')),
          Expanded(flex: 2, child: _PlanHeaderText('OBS')),
        ],
      ),
    );
  }
}

class _PlanHeaderText extends StatelessWidget {
  const _PlanHeaderText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.56),
        fontSize: 8,
        fontWeight: FontWeight.w900,
        letterSpacing: 1,
      ),
    );
  }
}

class _PlanRow extends StatelessWidget {
  const _PlanRow({
    required this.time,
    required this.amount,
    required this.note,
    required this.showDivider,
  });

  final String time;
  final String amount;
  final String note;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: showDivider
            ? Border(
                top: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
              )
            : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      child: Row(
        children: [
          Expanded(child: _PlanCell(time)),
          Expanded(child: _PlanCell(amount)),
          Expanded(flex: 2, child: _PlanCell(note)),
        ],
      ),
    );
  }
}

class _PlanCell extends StatelessWidget {
  const _PlanCell(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 10,
        fontWeight: FontWeight.w800,
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
