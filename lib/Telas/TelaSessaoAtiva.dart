import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hidratrack/Componentes/ResponsiveLayout.dart';
import 'package:flutter/services.dart';
import 'package:hidratrack/app_rotas.dart';

class TelaSessaoAtiva extends StatefulWidget {
  const TelaSessaoAtiva({super.key});

  @override
  State<TelaSessaoAtiva> createState() => _TelaSessaoAtivaState();
}

class _TelaSessaoAtivaState extends State<TelaSessaoAtiva> {
  static const _background = Color(0xFFFFFFFF);
  double _pesoInicial = 0.0;
  static const _surfaceLight = Color(0xFFEDEDED);
  static const _lime = Color(0xFFB32025);
  static const _cyan = Color(0xFF8F171B);
  static const _text = Color(0xFF222222);
  static const _muted = Color(0xFF6B6B6B);

  final TextEditingController _manualController = TextEditingController();
  final List<_HydrationLog> _timeline = [];
  final Duration _initialElapsed = Duration.zero;

  late Timer _timer;
  late Duration _elapsed;
  int _totalMl = 0;

  @override
  void initState() {
    super.initState();
    _elapsed = _initialElapsed;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _elapsed += const Duration(seconds: 1));
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      final pesoInicialArg = args['pesoInicial'];
      if (pesoInicialArg is double) {
        _pesoInicial = pesoInicialArg;
      } else if (pesoInicialArg is String) {
        _pesoInicial = double.tryParse(pesoInicialArg.replaceAll(',', '.')) ?? _pesoInicial;
      }
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _manualController.dispose();
    super.dispose();
  }

  void _addHydration({
    required String label,
    required int amountMl,
    required IconData icon,
  }) {
    if (amountMl <= 0) return;

    setState(() {
      _totalMl += amountMl;
      _timeline.insert(
        0,
        _HydrationLog(
          label: label,
          amountMl: amountMl,
          icon: icon,
          elapsed: _elapsed,
        ),
      );
    });

    HapticFeedback.selectionClick();
  }

  void _addManualHydration() {
    final text = _manualController.text.replaceAll(',', '.').trim();
    final amount = double.tryParse(text);

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe uma quantidade valida em ml'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    _addHydration(
      label: '',
      amountMl: amount.round(),
      icon: Icons.edit_outlined,
    );
    _manualController.clear();
  }

  void _endSession() {
    _timer.cancel();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sessao encerrada com ${_formatLiters(_totalMl)}L'),
        backgroundColor: _lime,
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.of(context).pushReplacementNamed(
      AppRotas.posSessao,
      arguments: {
        'totalMl': _totalMl,
        'durationMinutes': _elapsed.inMinutes,
        'pesoInicial': _pesoInicial,
      },
    );
  }

  String _formatElapsed(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  String _formatLiters(int ml) => (ml / 1000).toStringAsFixed(1);

  String _formatLogTime(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: ResponsiveLayout.contentMaxWidth(context)),
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 26),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildTopBar(),
                      const SizedBox(height: 28),
                      _buildStatusPill(),
                      const SizedBox(height: 26),
                      _buildTimer(),
                      const SizedBox(height: 30),
                      _buildQuickHydrationHeader(),
                      const SizedBox(height: 12),
                      _buildQuickHydrationCards(),
                      const SizedBox(height: 22),
                      _buildManualSection(),
                      const SizedBox(height: 22),
                      _buildTimeline(),
                      const SizedBox(height: 24),
                      _buildEndButton(),
                      const SizedBox(height: 16),
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
    return Row(
      children: [
        const Icon(Icons.water_drop, color: _lime, size: 21),
        const SizedBox(width: 8),
        const Text(
          'H2OTRACK',
          style: TextStyle(
            color: _lime,
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.2,
          ),
        ),
        const Spacer(),
        IconButton(
          visualDensity: VisualDensity.compact,
          onPressed: () {},
          icon: const Icon(Icons.notifications_none, color: _text, size: 21),
        ),
        const SizedBox(width: 4),
        Container(
          height: 34,
          width: 34,
          decoration: BoxDecoration(
            color: _surfaceLight,
            shape: BoxShape.circle,
            border: Border.all(color: _cyan.withValues(alpha: 0.5)),
          ),
          alignment: Alignment.center,
          child: const Text(
            'RS',
            style: TextStyle(
              color: _lime,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusPill() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: _cyan.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: _cyan.withValues(alpha: 0.45)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.circle, color: _cyan, size: 7),
            SizedBox(width: 8),
            Text(
              'SESSAO ATIVA',
              style: TextStyle(
                color: _cyan,
                fontSize: 9,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimer() {
    return Column(
      children: [
        Text(
          _formatElapsed(_elapsed),
          style: const TextStyle(
            color: _cyan,
            fontSize: 42,
            fontWeight: FontWeight.w900,
            height: 1,
            shadows: [
              Shadow(color: _cyan, blurRadius: 24),
              Shadow(color: _cyan, blurRadius: 10),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'TEMPO DE MOVIMENTO',
          style: TextStyle(
            color: _muted,
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickHydrationHeader() {
    return Row(
      children: [
        const Text(
          'HIDRATACAO RAPIDA',
          style: TextStyle(
            color: _text,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.8,
          ),
        ),
        const Spacer(),
        Text(
          'META: ${_formatLiters(2500)}L',
          style: const TextStyle(
            color: _lime,
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickHydrationCards() {
    return Row(
      children: [
        Expanded(
          child: _QuickHydrationCard(
            icon: Icons.sports_gymnastics,
            amount: '100ml',
            label: 'SQUEEZE',
            onTap: () => _addHydration(
              label: 'Squeeze',
              amountMl: 100,
              icon: Icons.sports_gymnastics,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuickHydrationCard(
            icon: Icons.local_drink_outlined,
            amount: '300ml',
            label: 'COPO',
            onTap: () => _addHydration(
              label: 'Copo',
              amountMl: 300,
              icon: Icons.local_drink_outlined,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuickHydrationCard(
            icon: Icons.water_drop_outlined,
            amount: '750ml',
            label: 'GARRAFA',
            onTap: () => _addHydration(
              label: 'Garrafa',
              amountMl: 750,
              icon: Icons.water_drop_outlined,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildManualSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'REGISTRO MANUAL',
          style: TextStyle(
            color: _muted,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.8,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: TextField(
                  controller: _manualController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
                  ],
                  style: const TextStyle(color: _text, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Volume em ml',
                    hintStyle: const TextStyle(color: _muted, fontSize: 12),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(9),
                      borderSide: BorderSide(
                        color: Colors.white.withValues(alpha: 0.10),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(9),
                      borderSide: const BorderSide(color: _lime),
                    ),
                  ),
                  onSubmitted: (_) => _addManualHydration(),
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              height: 48,
              width: 48,
              child: FilledButton(
                onPressed: _addManualHydration,
                style: FilledButton.styleFrom(
                  backgroundColor: _lime,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(48, 48),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Icon(Icons.add, size: 23),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeline() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'LINHA DO TEMPO',
          style: TextStyle(
            color: _muted,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.8,
          ),
        ),
        const SizedBox(height: 10),
        for (var i = 0; i < _timeline.length; i++) ...[
          _TimelineItem(
            log: _timeline[i],
            time: _formatLogTime(_timeline[i].elapsed),
            isHighlighted: i == 0,
          ),
          if (i != _timeline.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }

  Widget _buildEndButton() {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: FilledButton.icon(
        onPressed: _endSession,
        style: FilledButton.styleFrom(
          backgroundColor: _lime,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
          elevation: 14,
          shadowColor: _lime.withValues(alpha: 0.42),
        ),
        icon: const Icon(Icons.stop_circle_outlined, size: 22),
        label: const Text(
          'ENCERRAR TREINO',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.2,
          ),
        ),
      ),
    );
  }
}

class _QuickHydrationCard extends StatelessWidget {
  const _QuickHydrationCard({
    required this.icon,
    required this.amount,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String amount;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const lime = Color(0xFFB32025);
    const text = Color(0xFF222222);
    const muted = Color(0xFF6B6B6B);

    return Material(
      color: const Color(0xFFF7F7F7),
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: Container(
          height: 106,
          padding: const EdgeInsets.fromLTRB(8, 14, 8, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: lime, size: 24),
              const SizedBox(height: 10),
              Text(
                amount,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: text,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: muted,
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.log,
    required this.time,
    required this.isHighlighted,
  });

  final _HydrationLog log;
  final String time;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    const surface = Color(0xFFF7F7F7);
    const surfaceLight = Color(0xFFEDEDED);
    const lime = Color(0xFFB32025);
    const text = Color(0xFF222222);
    const muted = Color(0xFF6B6B6B);

    return Container(
      height: 66,
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            decoration: BoxDecoration(
              color: isHighlighted ? lime : lime.withValues(alpha: 0.4),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(9),
                bottomLeft: Radius.circular(9),
              ),
            ),
          ),
          const SizedBox(width: 11),
          Container(
            height: 34,
            width: 34,
            decoration: BoxDecoration(
              color: surfaceLight,
              shape: BoxShape.circle,
              border: Border.all(color: lime.withValues(alpha: 0.45)),
            ),
            child: Icon(log.icon, color: lime, size: 17),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.label.isEmpty
                      ? '${log.amountMl}ml ingeridos'
                      : '${log.label} Adicionado',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: text,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  time,
                  style: const TextStyle(
                    color: muted,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '+${log.amountMl}ml',
            style: const TextStyle(
              color: lime,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}

class _HydrationLog {
  const _HydrationLog({
    required this.label,
    required this.amountMl,
    required this.icon,
    required this.elapsed,
  });

  final String label;
  final int amountMl;
  final IconData icon;
  final Duration elapsed;
}
