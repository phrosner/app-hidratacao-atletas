import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:hidratrack/Componentes/BottomNavBarClass.dart';
import 'package:hidratrack/Componentes/ResponsiveContent.dart';

class Telagraficos extends StatefulWidget {
  const Telagraficos({super.key});

  @override
  State<Telagraficos> createState() => _TelagraficosState();
}

class _TelagraficosState extends State<Telagraficos> {
  final int _currentNavIndex = 3;

  List<double> _hidratacaoPorHora = [
    0.45,
    0.52,
    0.48,
    0.33,
    0.42,
    0.72,
    0.90,
    0.78,
    0.31,
    0.22,
    0.58,
    0.86,
  ];
  List<double> _desempenhoCarga = [48, 66, 82, 58, 74, 92, 62];

  double get _taxaMedia {
    final total = _hidratacaoPorHora.fold<double>(
      0,
      (sum, value) => sum + value,
    );
    return total / _hidratacaoPorHora.length;
  }

  double get _picoCarga => _desempenhoCarga.reduce(math.max);

  void atualizarHidratacao(List<double> novosDados) {
    setState(() {
      _hidratacaoPorHora = List.of(novosDados);
    });
  }

  void atualizarDesempenho(List<double> novosDados) {
    setState(() {
      _desempenhoCarga = List.of(novosDados);
    });
  }

  void _navegarTela(int index) {
    switch (index) {
      case 0:
        Navigator.of(context).pushReplacementNamed('/dashboard');
        break;
      case 1:
        Navigator.of(context).pushReplacementNamed('/equipes');
        break;
      case 2:
        Navigator.of(context).pushReplacementNamed('/atletas');
        break;
      case 3:
        Navigator.of(context).pushReplacementNamed('/graficos');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 900;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0D),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'ANALISE',
          style: TextStyle(
            color: Color(0xFFB32025),
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: ResponsiveContent(
            child: Column(
              children: [
                if (isDesktop)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildLineChartCard(chartHeight: 220)),
                      const SizedBox(width: 18),
                      Expanded(child: _buildBarChartCard(chartHeight: 220)),
                    ],
                  )
                else ...[
                  _buildLineChartCard(),
                  const SizedBox(height: 16),
                  _buildBarChartCard(),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        title: 'MEDIA EQUIPE',
                        value: '8.4',
                        detail: '+12% vs semana ant.',
                        icon: Icons.trending_up,
                        color: const Color(0xFF4EE28A),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSummaryCard(
                        title: 'ALERTAS DE RISCO',
                        value: '03',
                        detail: 'Fadiga muscular alta',
                        icon: Icons.warning_amber,
                        color: const Color(0xFFFFD6DA),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: _navegarTela,
      ),
    );
  }

  Widget _buildLineChartCard({double chartHeight = 150}) {
    return _buildChartCard(
      icon: Icons.water_drop_outlined,
      iconColor: const Color(0xFF00B9FF),
      children: [
        _buildChartHeader(
          title: 'TAXA DE HIDRATACAO (L/H)',
          value: _taxaMedia.toStringAsFixed(2),
          suffix: 'AVG',
          valueColor: const Color(0xFF00B9FF),
        ),
        const SizedBox(height: 18),
        SizedBox(
          height: chartHeight,
          child: CustomPaint(
            painter: LineChartPainter(
              values: _hidratacaoPorHora,
              lineColor: const Color(0xFF00B9FF),
              fillColor: const Color(0xFF00B9FF).withValues(alpha: 0.20),
              gridColor: const Color(0xFF3A2A2A),
            ),
            child: const SizedBox.expand(),
          ),
        ),
        const SizedBox(height: 8),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _AxisLabel('08:00'),
            _AxisLabel('09:00'),
            _AxisLabel('10:00'),
            _AxisLabel('11:00'),
          ],
        ),
      ],
    );
  }

  Widget _buildBarChartCard({double chartHeight = 150}) {
    return _buildChartCard(
      icon: Icons.bolt,
      iconColor: const Color(0xFFFF2E5F),
      children: [
        _buildChartHeader(
          title: 'DESEMPENHO / CARGA',
          value: '${_picoCarga.toInt()}%',
          suffix: 'PICO',
          valueColor: const Color(0xFFFF2E5F),
        ),
        const SizedBox(height: 18),
        SizedBox(
          height: chartHeight,
          child: CustomPaint(
            painter: BarChartPainter(
              values: _desempenhoCarga,
              barColor: const Color(0xFFFF2E5F),
              gridColor: const Color(0xFF3A2A2A),
            ),
            child: const SizedBox.expand(),
          ),
        ),
        const SizedBox(height: 8),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _AxisLabel('SEG'),
            _AxisLabel('TER'),
            _AxisLabel('QUA'),
            _AxisLabel('QUI'),
            _AxisLabel('SEX'),
            _AxisLabel('SAB'),
            _AxisLabel('DOM'),
          ],
        ),
      ],
    );
  }

  Widget _buildChartCard({
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF171719),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Icon(icon, color: iconColor, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildChartHeader({
    required String title,
    required String value,
    required String suffix,
    required Color valueColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF8B6B6C),
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              value,
              style: TextStyle(
                color: valueColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              suffix,
              style: const TextStyle(
                color: Color(0xFF8B6B6C),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required String detail,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      height: 92,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF171719),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF8B6B6C),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFFFFD6DA),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 6),
              Icon(icon, color: color, size: 14),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            detail,
            style: const TextStyle(color: Color(0xFF8B6B6C), fontSize: 10),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class LineChartPainter extends CustomPainter {
  LineChartPainter({
    required this.values,
    required this.lineColor,
    required this.fillColor,
    required this.gridColor,
  });

  final List<double> values;
  final Color lineColor;
  final Color fillColor;
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) {
      return;
    }

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    for (var i = 1; i <= 3; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final maxValue = values.reduce(math.max);
    final minValue = values.reduce(math.min);
    final range = math.max(maxValue - minValue, 1);
    final step = size.width / (values.length - 1);

    Offset pointAt(int index) {
      final normalized = (values[index] - minValue) / range;
      return Offset(
        step * index,
        size.height - (normalized * size.height * 0.78) - 14,
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

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(fillPath, Paint()..color = fillColor);

    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3;

    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant LineChartPainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.fillColor != fillColor ||
        oldDelegate.gridColor != gridColor;
  }
}

class BarChartPainter extends CustomPainter {
  BarChartPainter({
    required this.values,
    required this.barColor,
    required this.gridColor,
  });

  final List<double> values;
  final Color barColor;
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) {
      return;
    }

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    for (var i = 1; i <= 3; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final maxValue = math.max(values.reduce(math.max), 1);
    final slot = size.width / values.length;
    final barWidth = math.min(18.0, slot * 0.42);
    final paint = Paint()..color = barColor;

    for (var i = 0; i < values.length; i++) {
      final height = (values[i] / maxValue) * size.height * 0.82;
      final left = slot * i + (slot - barWidth) / 2;
      final top = size.height - height;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, barWidth, height),
        const Radius.circular(3),
      );
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant BarChartPainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.barColor != barColor ||
        oldDelegate.gridColor != gridColor;
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
        color: Color(0xFF8B6B6C),
        fontSize: 9,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
