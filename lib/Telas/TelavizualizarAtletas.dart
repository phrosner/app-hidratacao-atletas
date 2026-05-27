import 'package:flutter/material.dart';
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
    _idadeController.text = '24';
    _modalidadeController.text = 'Crossfit / Levantamento de Peso';
    _equipeController.text = 'Powerlifting Team';
    _categoriaController.text = atleta?.categoria ?? 'Alpha Performance';
    _pesoController.text = '88.5';
    _alturaController.text = '184';
    _generoSelect = generos.first;
    _nivelSelect = 'Avancado';
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
                      const SizedBox(height: 30),
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

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'AT';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return '${parts.first.characters.first}${parts.last.characters.first}'
        .toUpperCase();
  }
}
