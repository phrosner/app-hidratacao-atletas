import 'package:flutter/material.dart';
import 'package:hidratrack/Componentes/ResponsiveLayout.dart';
import 'package:hidratrack/Modelos/EquipesModels.dart';
import 'package:hidratrack/Servicos/AuthStorage.dart';
import 'package:hidratrack/Servicos/TreinadorService.dart';

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
  static const _danger = Color(0xFFD58686);

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  String? _categoriaSelect;
  String? _modalidadeSelect;
  bool _carregando = true;
  bool _salvando = false;
  String? _codigoEquipe;

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

  List<Map<String, dynamic>> _atletas = [];
  List<Map<String, dynamic>> _atletasFiltrados = [];
  List<Map<String, dynamic>> _resultadosBusca = [];

  @override
  void initState() {
    super.initState();
    _carregarEquipe();
  }

  Future<void> _carregarEquipe() async {
    final equipeId = widget.equipe?.id;
    if (equipeId == null) {
      setState(() => _carregando = false);
      return;
    }

    try {
      final detalhe = await TreinadorService.obterEquipeDetalhe(equipeId);
      if (!mounted) return;

      _nomeController.text = detalhe['nome']?.toString() ?? '';
      _descricaoController.text = detalhe['descricao']?.toString() ?? '';
      _codigoEquipe = detalhe['codigoEquipe']?.toString();
      _categoriaSelect =
          _normalizarValor(detalhe['categoria']?.toString(), categorias) ??
              categorias.first;
      _modalidadeSelect =
          _normalizarValor(detalhe['modalidade']?.toString(), modalidades) ??
              modalidades.first;

      final atletas = (detalhe['atletas'] as List<dynamic>? ?? [])
          .map((a) => Map<String, dynamic>.from(a as Map))
          .toList();

      setState(() {
        _atletas = atletas;
        _atletasFiltrados = List.of(atletas);
        _carregando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _carregando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar equipe: $e')),
      );
    }
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
                  (atleta) => atleta['nome']
                      .toString()
                      .toLowerCase()
                      .contains(query.toLowerCase()),
                )
                .toList();
    });
  }

  Future<void> _buscarNovosAtletas(String query) async {
    final equipeId = widget.equipe?.id;
    if (equipeId == null || query.trim().length < 2) {
      setState(() => _resultadosBusca = []);
      return;
    }

    try {
      final resultados = await TreinadorService.buscarAtletasDisponiveis(
        equipeId: equipeId,
        query: query,
      );
      if (!mounted) return;
      setState(() => _resultadosBusca = resultados);
    } catch (_) {
      if (!mounted) return;
      setState(() => _resultadosBusca = []);
    }
  }

  Future<void> _removerAtleta(Map<String, dynamic> atleta) async {
    final equipeId = widget.equipe?.id;
    final atletaId = (atleta['id'] as num?)?.toInt();
    if (equipeId == null || atletaId == null) return;

    try {
      await TreinadorService.removerAtletaDaEquipe(
        equipeId: equipeId,
        atletaId: atletaId,
      );
      await _carregarEquipe();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao remover atleta: $e')),
      );
    }
  }

  Future<void> _adicionarAtleta(Map<String, dynamic> atleta) async {
    final equipeId = widget.equipe?.id;
    final atletaId = (atleta['id'] as num?)?.toInt();
    if (equipeId == null || atletaId == null) return;

    try {
      await TreinadorService.adicionarAtletaNaEquipe(
        equipeId: equipeId,
        atletaId: atletaId,
      );
      _searchController.clear();
      setState(() => _resultadosBusca = []);
      await _carregarEquipe();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Atleta adicionado à equipe')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao adicionar atleta: $e')),
      );
    }
  }

  Future<void> _salvarAlteracoes() async {
    final equipeId = widget.equipe?.id;
    if (equipeId == null) return;

    setState(() => _salvando = true);
    try {
      await TreinadorService.atualizarEquipe(
        id: equipeId,
        nome: _nomeController.text.trim(),
        categoria: _categoriaSelect ?? categorias.first,
        modalidade: _modalidadeSelect ?? modalidades.first,
        descricao: _descricaoController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Alterações salvas com sucesso'),
          backgroundColor: _lime,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar: $e')),
      );
    } finally {
      if (mounted) setState(() => _salvando = false);
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
    if (_carregando) {
      return const Scaffold(
        backgroundColor: _background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildTopBar(),
                      if (_codigoEquipe != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Código: $_codigoEquipe',
                          style: const TextStyle(
                            color: _lime,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      _buildSectionTitle('DADOS DA EQUIPE'),
                      const SizedBox(height: 10),
                      _buildDadosEquipe(),
                      const SizedBox(height: 22),
                      _buildRecruitmentHeader(),
                      const SizedBox(height: 10),
                      _buildRecruitmentActions(),
                      const SizedBox(height: 14),
                      if (_resultadosBusca.isNotEmpty)
                        ..._resultadosBusca.map(_buildResultadoBusca),
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
    final initials = AuthStorage.nome.isNotEmpty
        ? AuthStorage.nome
              .trim()
              .split(RegExp(r'\s+'))
              .map((p) => p.characters.first)
              .take(2)
              .join()
              .toUpperCase()
        : 'TR';

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
        Container(
          height: 34,
          width: 34,
          decoration: BoxDecoration(
            color: _surfaceLight,
            shape: BoxShape.circle,
            border: Border.all(color: _cyan.withValues(alpha: 0.5)),
          ),
          alignment: Alignment.center,
          child: Text(
            initials,
            style: const TextStyle(
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
              color: Colors.white,
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
        Expanded(
          child: SizedBox(
            height: 44,
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                _filtrarAtletas(value);
                _buscarNovosAtletas(value);
              },
              style: const TextStyle(color: _text, fontSize: 12),
              decoration: InputDecoration(
                hintText: 'Buscar novo atleta...',
                hintStyle: const TextStyle(color: _muted, fontSize: 12),
                prefixIcon: const Icon(Icons.search, color: _text, size: 18),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.zero,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(7),
                  borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.16),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(7),
                  borderSide: const BorderSide(color: _lime),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultadoBusca(Map<String, dynamic> atleta) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _lime.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  atleta['nome']?.toString() ?? '',
                  style: const TextStyle(
                    color: _text,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'De: ${atleta['equipeOrigem'] ?? ''}',
                  style: const TextStyle(color: _muted, fontSize: 11),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _adicionarAtleta(atleta),
            child: const Text('ADICIONAR'),
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
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      dropdownColor: Colors.white,
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

  Widget _buildEmptyState() {
    return Container(
      height: 88,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'Nenhum atleta na equipe',
        style: TextStyle(color: _muted, fontSize: 12),
      ),
    );
  }

  Widget _buildAtletaItem(Map<String, dynamic> atleta, int index) {
    final accents = [_lime, _cyan, const Color(0xFF00A884)];
    final accent = accents[index % accents.length];
    final nome = atleta['nome']?.toString() ?? '';
    final categoria = atleta['categoria']?.toString() ??
        atleta['nivelTreino']?.toString() ??
        '';

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
              _initials(nome),
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
                  nome,
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
                  categoria.toUpperCase(),
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
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return '${parts.first.characters.first}${parts.last.characters.first}'
        .toUpperCase();
  }

  Widget _buildSalvarButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: FilledButton.icon(
        onPressed: _salvando ? null : _salvarAlteracoes,
        style: FilledButton.styleFrom(
          backgroundColor: _lime,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
        ),
        icon: _salvando
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.save_outlined, size: 18),
        label: const Text(
          'SALVAR ALTERACOES',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.4,
          ),
        ),
      ),
    );
  }
}
