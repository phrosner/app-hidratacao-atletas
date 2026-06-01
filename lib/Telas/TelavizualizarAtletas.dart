import 'package:flutter/material.dart';
import 'package:hidratrack/app_rotas.dart';
import 'package:hidratrack/Modelos/AtletaListModels.dart';

class TelaVisualizarAtletas extends StatefulWidget {
  const TelaVisualizarAtletas({super.key, this.atleta});

  final AtletaListItem? atleta;

  @override
  State<TelaVisualizarAtletas> createState() => _TelaVisualizarAtletasState();
}

class _TelaVisualizarAtletasState extends State<TelaVisualizarAtletas> {
  static const _background = Color(0xFFFFFFFF);
  static const _surface = Color(0xFFF7F7F7);
  static const _surfaceLight = Color(0xFFEDEDED);
  static const _lime = Color(0xFFB32025);
  static const _cyan = Color(0xFF8F171B);
  static const _text = Color(0xFF222222);
  static const _muted = Color(0xFF6B6B6B);

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _idadeController = TextEditingController();
  final TextEditingController _modalidadeController = TextEditingController();
  final TextEditingController _equipeController = TextEditingController();
  final TextEditingController _categoriaController = TextEditingController();
  final TextEditingController _pesoController = TextEditingController();
  final TextEditingController _alturaController = TextEditingController();

  String? _generoSelect;
  String? _nivelSelect;

  final List<String> generos = ['Masculino', 'Feminino'];
  final List<String> niveis = [
    'Iniciante',
    'Intermediario',
    'Avancado',
    'Elite',
  ];

  @override
  void initState() {
    super.initState();
    final atleta = widget.atleta;

    _nomeController.text = atleta?.nome ?? 'Ricardo Santos Oliveira';
    _idadeController.text = (atleta?.idade ?? 24).toString();
    _modalidadeController.text =
        atleta?.modalidade ?? 'Crossfit / Levantamento de Peso';
    _equipeController.text = atleta?.equipeAtual.isNotEmpty == true
        ? atleta!.equipeAtual
        : 'Powerlifting Team';
    _categoriaController.text = atleta?.categoria ?? 'Alpha Performance';
    _pesoController.text = (atleta?.pesoKg ?? 88.5).toStringAsFixed(1);
    _alturaController.text = (atleta?.alturaCm ?? 184).toString();
    _generoSelect = _normalizarValor(atleta?.genero, generos) ?? generos.first;
    _nivelSelect = _normalizarValor(atleta?.nivel, niveis) ?? 'Avancado';
  }

  String? _normalizarValor(String? value, List<String> options) {
    if (value == null || value.trim().isEmpty) return null;
    final normalized = value.toLowerCase();
    for (final option in options) {
      if (option.toLowerCase() == normalized) return option;
    }
    return null;
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _idadeController.dispose();
    _modalidadeController.dispose();
    _equipeController.dispose();
    _categoriaController.dispose();
    _pesoController.dispose();
    _alturaController.dispose();
    super.dispose();
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
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildTopBar(),
                      const SizedBox(height: 22),
                      _buildHydrationStatusCard(),
                      const SizedBox(height: 24),
                      _buildSectionTitle('INFORMACOES PESSOAIS'),
                      const SizedBox(height: 12),
                      _buildPersonalCard(),
                      const SizedBox(height: 24),
                      _buildSectionTitle('PERFIL ESPORTIVO'),
                      const SizedBox(height: 12),
                      _buildSportsCard(),
                      const SizedBox(height: 24),
                      _buildSectionTitle('DADOS FISIOLOGICOS'),
                      const SizedBox(height: 14),
                      _buildPhysiologyCards(),
                      const SizedBox(height: 18),
                      _buildChartButton(),
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
        IconButton(
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints.tightFor(width: 30, height: 30),
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close, color: _text, size: 24),
        ),
        const SizedBox(width: 6),
        const Expanded(
          child: Text(
            'VISUALIZAR ATLETA',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _text,
              fontSize: 21,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          height: 42,
          width: 42,
          decoration: BoxDecoration(
            color: _surfaceLight,
            shape: BoxShape.circle,
            border: Border.all(color: _lime, width: 1.4),
          ),
          alignment: Alignment.center,
          child: Text(
            _initials(_nomeController.text),
            style: const TextStyle(
              color: _lime,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHydrationStatusCard() {
    final atleta = widget.atleta;
    final hidratacao = atleta?.hidratacao ?? 82;
    final isRisk = hidratacao < 50;
    final accent = isRisk ? _lime : _cyan;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: accent, width: 3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'STATUS HIDRICO',
                  style: TextStyle(
                    color: _muted,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.7,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$hidratacao%',
                      style: TextStyle(
                        color: accent,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Text(
                        atleta?.status ?? 'MONITORADO',
                        style: const TextStyle(
                          color: _text,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            width: 96,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: (hidratacao / 100).clamp(0, 1).toDouble(),
                minHeight: 8,
                color: accent,
                backgroundColor: _surfaceLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(width: 4, height: 20, color: _lime),
        const SizedBox(width: 9),
        Text(
          title,
          style: const TextStyle(
            color: _lime,
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.2,
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalCard() {
    return _buildPanel(
      children: [
        _buildLabel('NOME COMPLETO'),
        const SizedBox(height: 8),
        _buildReadOnlyField(_nomeController, 'Nome completo'),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('IDADE'),
                  const SizedBox(height: 8),
                  _buildReadOnlyField(_idadeController, 'Idade'),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('GENERO'),
                  const SizedBox(height: 8),
                  _buildDisabledDropdown(value: _generoSelect, items: generos),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSportsCard() {
    return _buildPanel(
      children: [
        _buildLabel('MODALIDADE'),
        const SizedBox(height: 8),
        _buildReadOnlyField(_modalidadeController, 'Modalidade'),
        const SizedBox(height: 16),
        _buildLabel('CLUBE / EQUIPE ATUAL'),
        const SizedBox(height: 8),
        _buildReadOnlyField(_equipeController, 'Equipe atual'),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('NIVEL'),
                  const SizedBox(height: 8),
                  _buildDisabledDropdown(value: _nivelSelect, items: niveis),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('CATEGORIA'),
                  const SizedBox(height: 8),
                  _buildReadOnlyField(_categoriaController, 'Categoria'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPhysiologyCards() {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            label: 'PESO ATUAL (KG)',
            value: _pesoController.text,
            unit: 'KG',
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _buildMetricCard(
            label: 'ALTURA (CM)',
            value: _alturaController.text,
            unit: 'CM',
          ),
        ),
      ],
    );
  }

  Widget _buildPanel({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: _muted,
        fontSize: 9,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.7,
      ),
    );
  }

  Widget _buildReadOnlyField(
    TextEditingController controller,
    String hint, {
    double? minHeight,
  }) {
    return TextField(
      controller: controller,
      readOnly: true,
      minLines: minHeight == null ? 1 : 2,
      maxLines: minHeight == null ? 1 : 2,
      style: const TextStyle(color: _text, fontSize: 14, height: 1.35),
      decoration: _inputDecoration(hint),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF505050), fontSize: 12),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: const BorderSide(color: _lime),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
      ),
    );
  }

  Widget _buildDisabledDropdown({
    required String? value,
    required List<String> items,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      dropdownColor: Colors.white,
      icon: const Icon(Icons.keyboard_arrow_down, color: _muted, size: 20),
      style: const TextStyle(color: _text, fontSize: 14),
      decoration: _inputDecoration('Selecione'),
      items: items
          .map(
            (item) => DropdownMenuItem<String>(
              value: item,
              child: Text(item, overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(),
      onChanged: null,
      disabledHint: Text(
        value ?? '',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: _text, fontSize: 14),
      ),
    );
  }

  Widget _buildMetricCard({
    required String label,
    required String value,
    required String unit,
  }) {
    return Container(
      height: 96,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel(label),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    value,
                    style: const TextStyle(
                      color: _text,
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  unit,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: FilledButton.icon(
        onPressed: () => Navigator.of(context).pushNamed(AppRotas.taxaMedia),
        style: FilledButton.styleFrom(
          backgroundColor: _lime,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        icon: const Icon(Icons.insert_chart_outlined, size: 19),
        label: const Text(
          'VER GRAFICO',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'AT';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return '${parts.first.characters.first}${parts.last.characters.first}'
        .toUpperCase();
  }
}
