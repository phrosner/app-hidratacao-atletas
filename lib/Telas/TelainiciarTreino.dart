import 'package:flutter/material.dart';

class TelaIniciarTreino extends StatefulWidget {
  const TelaIniciarTreino({super.key});

  @override
  State<TelaIniciarTreino> createState() => _TelaIniciarTreinoState();
}

class _TelaIniciarTreinoState extends State<TelaIniciarTreino> {
  static const _background = Color(0xFF101010);
  static const _surface = Color(0xFF1B1B1B);
  static const _surfaceLight = Color(0xFF242424);
  static const _lime = Color(0xFFB9FF00);
  static const _text = Color(0xFFF5F5F5);
  static const _muted = Color(0xFF858585);

  final TextEditingController _pesoController = TextEditingController(
    text: '74.5',
  );

  @override
  void dispose() {
    _pesoController.dispose();
    super.dispose();
  }

  void _iniciarTreino() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Treino iniciado com ${_pesoController.text} kg'),
        backgroundColor: _lime,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 22, 24, 34),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildTopBar(),
                      const SizedBox(height: 118),
                      _buildWeightCard(),
                      const SizedBox(height: 56),
                      _buildInstructionCard(),
                      const SizedBox(height: 72),
                      _buildStartButton(),
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
        const Icon(Icons.water_drop, color: _lime, size: 24),
        const SizedBox(width: 10),
        const Text(
          'H2OTRACK',
          style: TextStyle(
            color: _lime,
            fontSize: 15,
            fontWeight: FontWeight.w900,
            letterSpacing: 3,
          ),
        ),
        const Spacer(),
        Container(
          height: 36,
          width: 36,
          decoration: BoxDecoration(
            color: _surfaceLight,
            shape: BoxShape.circle,
            border: Border.all(color: _lime.withValues(alpha: 0.28)),
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

  Widget _buildWeightCard() {
    return Container(
      height: 206,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 18),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: _lime.withValues(alpha: 0.24),
            blurRadius: 0,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  border: Border.all(color: _lime.withValues(alpha: 0.4)),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: const Icon(Icons.adjust, color: _lime, size: 9),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'PESO CORPORAL ATUAL',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _lime,
              fontSize: 14,
              fontWeight: FontWeight.w900,
              letterSpacing: 4,
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IntrinsicWidth(
                child: TextField(
                  controller: _pesoController,
                  textAlign: TextAlign.center,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: const TextStyle(
                    color: _text,
                    fontSize: 58,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              const SizedBox(width: 28),
              const Padding(
                padding: EdgeInsets.only(bottom: 7),
                child: Text(
                  'kg',
                  style: TextStyle(
                    color: _muted,
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          const Text(
            'Toque para ajustar seu peso\ninicial',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _muted,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.2,
              height: 0.95,
            ),
          ),
          const SizedBox(height: 8),
          const Align(
            alignment: Alignment.centerRight,
            child: Text(
              '...',
              style: TextStyle(
                color: _lime,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 18, 20, 20),
      decoration: BoxDecoration(
        color: const Color(0xFF19200F),
        borderRadius: BorderRadius.circular(10),
        border: const Border(left: BorderSide(color: _lime, width: 3)),
        boxShadow: [
          BoxShadow(
            color: _lime.withValues(alpha: 0.06),
            blurRadius: 50,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Icon(Icons.info, color: _lime, size: 25),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'INSTRUCAO DE PESAGEM',
                  style: TextStyle(
                    color: _text,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Para uma medicao precisa, pese-se utilizando apenas roupas intimas e sem nenhum tipo de calcado.',
                  style: TextStyle(color: _text, fontSize: 13, height: 1.55),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton() {
    return SizedBox(
      width: double.infinity,
      height: 66,
      child: FilledButton(
        onPressed: _iniciarTreino,
        style: FilledButton.styleFrom(
          backgroundColor: _lime,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 12,
          shadowColor: _lime.withValues(alpha: 0.55),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bolt, size: 27),
            SizedBox(width: 14),
            Text(
              'INICIAR TREINO',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
