import 'package:flutter/material.dart';
import 'package:hidratrack/Modelos/AtletaListModels.dart';
import 'package:hidratrack/Modelos/EquipesModels.dart';
import 'package:hidratrack/Servicos/EquipeService.dart';

class TeladadosEquipe extends StatefulWidget {
  const TeladadosEquipe({super.key, this.equipe});

  final Equipe? equipe;

  @override
  State<TeladadosEquipe> createState() => _TeladadosEquipeState();
}

class _TeladadosEquipeState extends State<TeladadosEquipe> {
  static const _background = Color(0xFFFFFFFF);
  static const _surface = Color(0xFFF7F7F7);
  static const _surfaceLight = Color(0xFFEDEDED);
  static const _lime = Color(0xFFB32025);
  static const _cyan = Color(0xFF8F171B);
  static const _text = Color(0xFF222222);
  static const _muted = Color(0xFF6B6B6B);
  static const _danger = Color(0xFFB32025);

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  bool _carregando = false;
  bool _carregandoAtletas = true;
  String _categoriaSelect = 'Profissional';
  String _modalidadeSelect = 'Futebol';
  List<AtletaListItem> _atletasEquipe = [];
  List<AtletaListItem> _atletasBusca = [];

  final List<String> categorias = [
    'Profissional',
    'Elite Pro',
    'Sub-20',
    'Sub-17',
    'Olimpico',
    'Master',
  ];

  final List<String> modalidades = [
    'Futebol',
    'Natacao',
    'CrossFit',
    'Triathlon',
    'Endurance',
    'Atletismo',
  ];

  @override
  void initState() {
    super.initState();
    final equipe = widget.equipe;

    _nomeController.text = equipe?.nome ?? 'Alpha Warriors Elite';
    _descricaoController.text = equipe?.descricao ??
        'Equipe focada em alto rendimento e competicoes nacionais.';
    _categoriaSelect =
        _normalizarValor(equipe?.categoria, categorias) ?? categorias.first;
    _modalidadeSelect =
        _normalizarValor(equipe?.modalidade, modalidades) ?? modalidades.first;

    _carregarAtletas();
  }

  Future<void> _carregarAtletas() async {
    final ids = widget.equipe?.atletasIds ?? const <int>[];
    final atletasEquipe = await EquipeService.listarAtletasPorEquipe(ids);
    final atletasBusca = await EquipeService.listarAtletas();
    if (!mounted) return;

    setState(() {
      _atletasEquipe = atletasEquipe;
      _atletasBusca = atletasBusca;
      _carregandoAtletas = false;
    });
  }

  String? _normalizarValor(String? value, List<String> options) {
    if (value == null || value.trim().isEmpty) return null;
    final normalized = value.toLowerCase();
    for (final option in options) {
      if (option.toLowerCase() == normalized) return option;
    }
    return null;
  }

  Future<void> _filtrarAtletas(String query) async {
    final atletas = await EquipeService.buscarAtletas(query);
    if (!mounted) return;
    setState(() => _atletasBusca = atletas);
  }

  void _toggleAtleta(AtletaListItem atleta) {
    setState(() {
      final index = _atletasEquipe.indexWhere((item) => item.id == atleta.id);
      if (index >= 0) {
        _atletasEquipe.removeAt(index);
      } else {
        _atletasEquipe.add(atleta);
      }
    });
  }

  bool _isSelecionado(AtletaListItem atleta) {
    return _atletasEquipe.any((item) => item.id == atleta.id);
  }

  Future<void> _salvarAlteracoes() async {
    final equipe = widget.equipe;
    if (equipe == null) {
      Navigator.pop(context, false);
      return;
    }

    if (_nomeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe o nome da equipe'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _carregando = true);
    final sucesso = await EquipeService.atualizarEquipe(
      id: equipe.id,
      nome: _nomeController.text,
      categoria: _categoriaSelect,
      modalidade: _modalidadeSelect,
      descricao: _descricaoController.text,
      atletasIds: _atletasEquipe.map((atleta) => atleta.id).toList(),
    );

    if (!mounted) return;
    setState(() => _carregando = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          sucesso ? 'Alteracoes salvas com sucesso' : 'Equipe nao encontrada',
        ),
        backgroundColor: sucesso ? _lime : Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );

    if (sucesso) {
      Navigator.pop(context, true);
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _searchController.dispose();
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
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildTopBar(),
                      const SizedBox(height: 22),
                      _buildHeader(),
                      const SizedBox(height: 20),
                      _buildDadosEquipe(),
                      const SizedBox(height: 18),
                      _buildRecruitmentPanel(),
                      const SizedBox(height: 18),
                      _buildSalvarButton(),
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
          constraints: const BoxConstraints.tightFor(width: 32, height: 32),
          onPressed: () => Navigator.pop(context, false),
          icon: const Icon(Icons.close, color: _text, size: 22),
        ),
        const SizedBox(width: 2),
        const Expanded(
          child: Text(
            'EDITAR EQUIPE',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _text,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Container(
          height: 34,
          width: 34,
          decoration: BoxDecoration(
            color: _surfaceLight,
            shape: BoxShape.circle,
            border: Border.all(color: _lime.withValues(alpha: 0.5)),
          ),
          alignment: Alignment.center,
          child: const Text(
            'TR',
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

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'DADOS DA EQUIPE',
          style: TextStyle(
            color: _lime,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          widget.equipe?.nome ?? 'Equipe',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: _text,
            fontSize: 30,
            fontWeight: FontWeight.w900,
            height: 1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.equipe?.codigoEquipe ?? 'HT-000000',
          style: const TextStyle(
            color: _muted,
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildDadosEquipe() {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('NOME DA EQUIPE'),
          const SizedBox(height: 8),
          _buildTextField(_nomeController, 'Nome da equipe'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('CATEGORIA'),
                    const SizedBox(height: 8),
                    _buildDropdown(
                      value: _categoriaSelect,
                      items: categorias,
                      onChanged: (value) =>
                          setState(() => _categoriaSelect = value),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('MODALIDADE'),
                    const SizedBox(height: 8),
                    _buildDropdown(
                      value: _modalidadeSelect,
                      items: modalidades,
                      onChanged: (value) =>
                          setState(() => _modalidadeSelect = value),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildLabel('DESCRICAO TATICA'),
          const SizedBox(height: 8),
          _buildTextAreaField(
            _descricaoController,
            'Descreva o foco e os objetivos da equipe...',
          ),
        ],
      ),
    );
  }

  Widget _buildRecruitmentPanel() {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'RECRUTAMENTO DE ATLETAS',
                  style: TextStyle(
                    color: _lime,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.4,
                  ),
                ),
              ),
              _CountPill('${_atletasEquipe.length} atletas'),
            ],
          ),
          const SizedBox(height: 12),
          _buildSearchBar(),
          const SizedBox(height: 12),
          if (_carregandoAtletas)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(18),
                child: CircularProgressIndicator(color: _lime),
              ),
            )
          else ...[
            _buildSubLabel('ATLETAS DA EQUIPE'),
            const SizedBox(height: 8),
            if (_atletasEquipe.isEmpty)
              _buildEmptyState('Nenhum atleta selecionado')
            else
              for (final atleta in _atletasEquipe) _buildAtletaRow(atleta),
            const SizedBox(height: 8),
            _buildSubLabel('ADICIONAR ATLETAS'),
            const SizedBox(height: 8),
            for (final atleta in _atletasBusca
                .where(
                  (item) => !_isSelecionado(item),
                )
                .take(4))
              _buildAtletaRow(atleta),
          ],
        ],
      ),
    );
  }

  Widget _buildSubLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: _muted,
        fontSize: 8,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.4,
      ),
    );
  }

  Widget _buildSearchBar() {
    return SizedBox(
      height: 44,
      child: TextField(
        controller: _searchController,
        onChanged: _filtrarAtletas,
        style: const TextStyle(color: _text, fontSize: 12),
        decoration: InputDecoration(
          hintText: 'Buscar atleta por nome ou modalidade',
          hintStyle: const TextStyle(color: _muted, fontSize: 12),
          prefixIcon: const Icon(Icons.search, color: _muted, size: 19),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.zero,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.16)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),
            borderSide: const BorderSide(color: _lime),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      height: 72,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(message, style: const TextStyle(color: _muted, fontSize: 12)),
    );
  }

  Widget _buildAtletaRow(AtletaListItem atleta) {
    final selected = _isSelecionado(atleta);

    return Container(
      height: 64,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: selected ? _lime.withValues(alpha: 0.32) : _surfaceLight,
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 10),
          _SmallAvatar(
            label: _initials(atleta.nome),
            color: selected ? _lime : _cyan,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  atleta.nome,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _text,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${atleta.categoria} - ${atleta.status}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.7,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: selected ? 'Remover atleta' : 'Adicionar atleta',
            onPressed: () => _toggleAtleta(atleta),
            icon: Icon(
              selected ? Icons.delete_outline : Icons.add_circle,
              color: selected ? _danger : _lime,
              size: selected ? 22 : 24,
            ),
          ),
        ],
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
        letterSpacing: 1.4,
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      style: const TextStyle(
        color: _text,
        fontSize: 15,
        fontWeight: FontWeight.w800,
      ),
      decoration: _inputDecoration(hint),
    );
  }

  Widget _buildTextAreaField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      minLines: 3,
      maxLines: 4,
      style: const TextStyle(color: _text, fontSize: 13, height: 1.35),
      decoration: _inputDecoration(hint),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF777777), fontSize: 12),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.16)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: const BorderSide(color: _lime),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      dropdownColor: Colors.white,
      icon: const Icon(Icons.keyboard_arrow_down, color: _muted, size: 20),
      style: const TextStyle(color: _text, fontSize: 13),
      decoration: _inputDecoration('Selecione'),
      items: items
          .map(
            (item) => DropdownMenuItem<String>(
              value: item,
              child: Text(item, overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    );
  }

  Widget _buildSalvarButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton.icon(
        onPressed: _carregando ? null : _salvarAlteracoes,
        style: FilledButton.styleFrom(
          backgroundColor: _lime,
          disabledBackgroundColor: _muted,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
        ),
        icon: _carregando
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.save_outlined, size: 18),
        label: const Text(
          'SALVAR ALTERACOES',
          style: TextStyle(
            fontSize: 13,
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
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _TeladadosEquipeState._surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _TeladadosEquipeState._surfaceLight),
      ),
      child: child,
    );
  }
}

class _CountPill extends StatelessWidget {
  const _CountPill(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: _TeladadosEquipeState._lime,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 8,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.7,
        ),
      ),
    );
  }
}

class _SmallAvatar extends StatelessWidget {
  const _SmallAvatar({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      width: 32,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
