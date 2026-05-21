import 'package:flutter/material.dart';
import 'package:hidratrack/Modelos/EquipesModels.dart';

class TeladadosEquipe extends StatefulWidget {
  const TeladadosEquipe({super.key, this.equipe});

  final Equipe? equipe;

  @override
  State<TeladadosEquipe> createState() => _TeladadosEquipeState();
}

class _TeladadosEquipeState extends State<TeladadosEquipe> {
  static const _background = Color(0xFF101010);
  static const _surface = Color(0xFF1B1B1B);
  static const _surfaceLight = Color(0xFF242424);
  static const _lime = Color(0xFFB9FF00);
  static const _cyan = Color(0xFF00E5FF);
  static const _text = Color(0xFFF5F5F5);
  static const _muted = Color(0xFF858585);
  static const _danger = Color(0xFFD58686);

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  int _currentNavIndex = 1;
  String? _categoriaSelect;
  String? _modalidadeSelect;

  final List<String> categorias = [
    'Profissional',
    'Elite Pro',
    'Sub-20',
    'Sub-17',
    'Olimpico',
    'Master',
  ];

  final List<String> modalidades = [
    'CrossFit',
    'Triathlon',
    'Futebol',
    'Natacao',
    'Endurance',
    'Atletismo',
  ];

  final List<Map<String, String>> _atletas = [
    {'nome': 'Marcus V. Silva', 'categoria': 'ELITE PERFORMER'},
    {'nome': 'Elena Rodrigues', 'categoria': 'POWER LIFTER'},
    {'nome': 'Ricardo Neves', 'categoria': 'ENDURANCE PRO'},
  ];

  late List<Map<String, String>> _atletasFiltrados;

  @override
  void initState() {
    super.initState();
    final equipe = widget.equipe;

    _nomeController.text = equipe?.nome ?? 'Alpha Warriors Elite';
    _descricaoController.text =
        equipe?.descricao ??
        'Equipe focada em alto rendimento e competicoes nacionais de endurance. Estrategia baseada em ciclos de intensidade progressiva.';
    _categoriaSelect =
        _normalizarValor(equipe?.categoria, categorias) ?? 'Profissional';
    _modalidadeSelect =
        _normalizarValor(equipe?.modalidade, modalidades) ?? 'CrossFit';
    _atletasFiltrados = List.of(_atletas);
  }

  String? _normalizarValor(String? value, List<String> options) {
    if (value == null || value.trim().isEmpty) return null;
    final normalized = value.toLowerCase();
    for (final option in options) {
      if (option.toLowerCase() == normalized) return option;
    }
    return null;
  }

  void _filtrarAtletas(String query) {
    setState(() {
      _atletasFiltrados = query.isEmpty
          ? List.of(_atletas)
          : _atletas
                .where(
                  (atleta) =>
                      atleta['nome']!.toLowerCase().contains(
                        query.toLowerCase(),
                      ) ||
                      atleta['categoria']!.toLowerCase().contains(
                        query.toLowerCase(),
                      ),
                )
                .toList();
    });
  }

  void _removerAtleta(Map<String, String> atleta) {
    setState(() {
      _atletas.remove(atleta);
      final query = _searchController.text.toLowerCase();
      _atletasFiltrados = query.isEmpty
          ? List.of(_atletas)
          : _atletas
                .where(
                  (item) =>
                      item['nome']!.toLowerCase().contains(query) ||
                      item['categoria']!.toLowerCase().contains(query),
                )
                .toList();
    });
  }

  void _adicionarAtleta() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Busca de novos atletas em breve'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _salvarAlteracoes() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Alteracoes salvas com sucesso'),
        backgroundColor: _lime,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _navegarTela(int index) {
    setState(() => _currentNavIndex = index);

    switch (index) {
      case 0:
        Navigator.of(context).pushReplacementNamed('/dashboard');
        break;
      case 1:
        Navigator.of(context).pushReplacementNamed('/equipes');
        break;
      case 2:
        Navigator.of(context).pushReplacementNamed('/graficos');
        break;
      case 3:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil do treinador em breve')),
        );
        break;
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
      bottomNavigationBar: _buildBottomNav(),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildTopBar(),
                      const SizedBox(height: 20),
                      _buildSectionTitle('DADOS DA EQUIPE'),
                      const SizedBox(height: 10),
                      _buildDadosEquipe(),
                      const SizedBox(height: 22),
                      _buildRecruitmentHeader(),
                      const SizedBox(height: 10),
                      _buildRecruitmentActions(),
                      const SizedBox(height: 14),
                      if (_atletasFiltrados.isEmpty)
                        _buildEmptyState()
                      else
                        for (var i = 0; i < _atletasFiltrados.length; i++)
                          _buildAtletaItem(_atletasFiltrados[i], i),
                      const SizedBox(height: 28),
                      _buildSalvarButton(),
                      const SizedBox(height: 24),
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
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: _text, size: 21),
        ),
        const SizedBox(width: 2),
        const Text(
          'EDITAR EQUIPE',
          style: TextStyle(
            color: _text,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        IconButton(
          visualDensity: VisualDensity.compact,
          onPressed: () {},
          icon: const Icon(Icons.notifications_none, color: _text, size: 21),
        ),
        const SizedBox(width: 6),
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: _lime,
        fontSize: 11,
        fontWeight: FontWeight.w900,
        letterSpacing: 2.2,
      ),
    );
  }

  Widget _buildDadosEquipe() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('NOME DA EQUIPE'),
        const SizedBox(height: 7),
        _buildTextField(_nomeController, 'Nome da equipe', fontSize: 25),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('CATEGORIA'),
                  const SizedBox(height: 7),
                  _buildDropdown(
                    value: _categoriaSelect,
                    items: categorias,
                    onChanged: (value) =>
                        setState(() => _categoriaSelect = value),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('MODALIDADE'),
                  const SizedBox(height: 7),
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
        const SizedBox(height: 7),
        _buildTextAreaField(
          _descricaoController,
          'Descreva o foco e os objetivos da equipe...',
        ),
      ],
    );
  }

  Widget _buildRecruitmentHeader() {
    return Row(
      children: [
        const Text(
          'RECRUTAMENTO DE ATLETAS',
          style: TextStyle(
            color: _lime,
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: _lime,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${_atletas.length.toString().padLeft(2, '0')} ATLETAS',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 8,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecruitmentActions() {
    return Row(
      children: [
        Expanded(child: _buildSearchBar()),
        const SizedBox(width: 8),
        SizedBox(
          height: 44,
          child: FilledButton.icon(
            onPressed: _adicionarAtleta,
            style: FilledButton.styleFrom(
              backgroundColor: _lime,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.add, size: 17),
            label: const Text(
              'ADICIONAR',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900),
            ),
          ),
        ),
      ],
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

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    double fontSize = 13,
  }) {
    return TextField(
      controller: controller,
      style: TextStyle(
        color: _text,
        fontSize: fontSize,
        fontWeight: fontSize > 18 ? FontWeight.w900 : FontWeight.w500,
      ),
      decoration: _inputDecoration(hint),
    );
  }

  Widget _buildTextAreaField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      minLines: 4,
      maxLines: 4,
      style: const TextStyle(color: _text, fontSize: 14, height: 1.35),
      decoration: _inputDecoration(hint),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF505050), fontSize: 12),
      filled: true,
      fillColor: Colors.black,
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
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      dropdownColor: Colors.black,
      icon: const Icon(Icons.keyboard_arrow_down, color: _lime, size: 22),
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
      onChanged: onChanged,
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
          hintText: 'Buscar novo atleta...',
          hintStyle: const TextStyle(color: _muted, fontSize: 12),
          prefixIcon: const Icon(Icons.search, color: _text, size: 18),
          filled: true,
          fillColor: Colors.black,
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

  Widget _buildEmptyState() {
    return Container(
      height: 88,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'Nenhum atleta encontrado',
        style: TextStyle(color: _muted, fontSize: 12),
      ),
    );
  }

  Widget _buildAtletaItem(Map<String, String> atleta, int index) {
    final accents = [_lime, _cyan, const Color(0xFF00A884)];
    final accent = accents[index % accents.length];

    return Container(
      height: 88,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Container(
            height: 54,
            width: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _surfaceLight,
              border: Border.all(color: accent, width: 2),
            ),
            alignment: Alignment.center,
            child: Text(
              _initials(atleta['nome']!),
              style: TextStyle(
                color: accent,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  atleta['nome']!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _text,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  atleta['categoria']!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.4,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Remover atleta',
            onPressed: () => _removerAtleta(atleta),
            icon: const Icon(Icons.delete_outline, color: _danger, size: 23),
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return '${parts.first.characters.first}${parts.last.characters.first}'
        .toUpperCase();
  }

  Widget _buildSalvarButton() {
    return SizedBox(
      width: double.infinity,
      height: 66,
      child: FilledButton.icon(
        onPressed: _salvarAlteracoes,
        style: FilledButton.styleFrom(
          backgroundColor: _lime,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
        ),
        icon: const Icon(Icons.save_outlined, size: 22),
        label: const Text(
          'SALVAR ALTERACOES',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.4,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    const items = [
      (Icons.home_rounded, 'HOME'),
      (Icons.groups_2_outlined, 'EQUIPES'),
      (Icons.history_rounded, 'HISTORICO'),
      (Icons.person_outline_rounded, 'PERFIL'),
    ];

    return Container(
      height: 64,
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
              onTap: () => _navegarTela(i),
              child: SizedBox(
                width: 74,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      items[i].$1,
                      color: _currentNavIndex == i ? _lime : _muted,
                      size: 22,
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        items[i].$2,
                        style: TextStyle(
                          color: _currentNavIndex == i ? _lime : _muted,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
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
