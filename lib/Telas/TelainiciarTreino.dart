import 'package:flutter/material.dart';
import 'package:hidratrack/app_rotas.dart';
import 'package:hidratrack/Modelos/SessaoHidratacaoModels.dart';

class TelaIniciarTreino extends StatefulWidget {
  const TelaIniciarTreino({super.key});

  @override
  State<TelaIniciarTreino> createState() => _TelaIniciarTreinoState();
}

class _TelaIniciarTreinoState extends State<TelaIniciarTreino> {
  static const _background = Color(0xFFFFFFFF);
  static const _surface = Color(0xFFF7F7F7);
  static const _surfaceLight = Color(0xFFEDEDED);
  static const _lime = Color(0xFFB32025);
  static const _text = Color(0xFF222222);
  static const _muted = Color(0xFF6B6B6B);

  final TextEditingController _pesoController = TextEditingController(
    text: '74.5',
  );
  final TextEditingController _duracaoController = TextEditingController(
    text: '60',
  );
  final TextEditingController _temperaturaController = TextEditingController(
    text: '28',
  );
  final TextEditingController _umidadeController = TextEditingController(
    text: '65',
  );

  String _modalidade = 'Corrida';
  String _intensidade = 'Moderada';
  int _corUrina = 1;
  bool _comSede = false;

  final List<Color> _urinaCores = const [
    Color(0xFFF9FFFF),
    Color(0xFFFFF4A8),
    Color(0xFFFFDD3D),
    Color(0xFFE8A51F),
    Color(0xFFD86B1D),
    Color(0xFF6B3A1E),
  ];

  @override
  void dispose() {
    _pesoController.dispose();
    _duracaoController.dispose();
    _temperaturaController.dispose();
    _umidadeController.dispose();
    super.dispose();
  }

  void _iniciarTreino() {
    final pesoInicial = double.tryParse(
      _pesoController.text.replaceAll(',', '.').trim(),
    );
    final duracaoPrevista = int.tryParse(_duracaoController.text.trim()) ?? 60;
    final temperatura = double.tryParse(
          _temperaturaController.text.replaceAll(',', '.').trim(),
        ) ??
        28;
    final umidade = int.tryParse(_umidadeController.text.trim()) ?? 65;

    if (pesoInicial == null || pesoInicial <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe uma massa corporal valida'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final inicio = RegistroInicioSessao(
      pesoInicialKg: pesoInicial,
      iniciadoEm: DateTime.now(),
      modalidade: _modalidade,
      duracaoPrevistaMin: duracaoPrevista,
      intensidade: _intensidade,
      temperaturaC: temperatura,
      umidadeRelativa: umidade.clamp(0, 100).toInt(),
      corUrinaInicial: _corUrina,
      comSede: _comSede,
    );

    Navigator.of(
      context,
    ).pushReplacementNamed(AppRotas.sessaoAtiva, arguments: inicio);
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
                      const SizedBox(height: 42),
                      _buildWeightCard(),
                      const SizedBox(height: 16),
                      _buildSessionContextCard(),
                      const SizedBox(height: 16),
                      _buildBasalStateCard(),
                      const SizedBox(height: 16),
                      _buildInstructionCard(),
                      const SizedBox(height: 24),
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
        color: _surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _surfaceLight),
      ),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(left: BorderSide(color: _lime, width: 3)),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Icon(Icons.info_outline, color: _lime, size: 25),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'INSTRUCAO DE PESAGEM',
                      style: TextStyle(
                        color: _lime,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.4,
                      ),
                    ),
                    SizedBox(height: 9),
                    Text(
                      'Para uma medicao precisa, pese-se utilizando apenas roupas intimas e sem nenhum tipo de calcado.',
                      style: TextStyle(
                        color: _text,
                        fontSize: 13,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSessionContextCard() {
    return _buildPanel(
      title: 'CONTEXTO DO TREINO',
      child: Column(
        children: [
          _buildDropdown(
            label: 'MODALIDADE',
            value: _modalidade,
            values: const ['Corrida', 'Ciclismo', 'Natacao', 'Forca', 'Outro'],
            onChanged: (value) => setState(() => _modalidade = value),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInput(
                  label: 'DURACAO MIN',
                  controller: _duracaoController,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildInput(
                  label: 'TEMP C',
                  controller: _temperaturaController,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildInput(
                    label: 'UMIDADE %', controller: _umidadeController),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (final intensidade in const ['Leve', 'Moderada', 'Alta']) ...[
                Expanded(
                  child: _SegmentButton(
                    label: intensidade.toUpperCase(),
                    selected: _intensidade == intensidade,
                    onTap: () => setState(() => _intensidade = intensidade),
                  ),
                ),
                if (intensidade != 'Alta') const SizedBox(width: 8),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBasalStateCard() {
    return _buildPanel(
      title: 'ESTADO BASAL',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'COR DA URINA',
            style: TextStyle(
              color: _muted,
              fontSize: 8,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 0; i < _urinaCores.length; i++)
                InkWell(
                  onTap: () => setState(() => _corUrina = i),
                  customBorder: const CircleBorder(),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: _urinaCores[i],
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _corUrina == i ? _lime : Colors.white,
                        width: 2,
                      ),
                    ),
                    child: _corUrina == i
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : null,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            value: _comSede,
            onChanged: (value) => setState(() => _comSede = value),
            contentPadding: EdgeInsets.zero,
            activeThumbColor: _lime,
            title: const Text(
              'Sede antes da sessao',
              style: TextStyle(
                color: _text,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPanel({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _surfaceLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: _lime,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.6,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> values,
    required ValueChanged<String> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: _inputDecoration(label),
      dropdownColor: Colors.white,
      items: values
          .map(
            (item) => DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: const TextStyle(fontSize: 12)),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    );
  }

  Widget _buildInput({
    required String label,
    required TextEditingController controller,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(
        color: _text,
        fontSize: 12,
        fontWeight: FontWeight.w800,
      ),
      decoration: _inputDecoration(label),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        color: _muted,
        fontSize: 9,
        fontWeight: FontWeight.w900,
        letterSpacing: 1,
      ),
      filled: true,
      fillColor: Colors.white,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: const BorderSide(color: _lime),
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
          foregroundColor: Colors.white,
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

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
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
    const muted = Color(0xFF6B6B6B);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(7),
      child: Container(
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? lime : Colors.white,
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: selected ? lime : const Color(0xFFEDEDED)),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: selected ? Colors.white : muted,
            fontSize: 8,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }
}
