import 'package:flutter/material.dart';
import 'package:hidratrack/Servicos/EquipeService.dart';

class TelacriarEquipe extends StatefulWidget {
  const TelacriarEquipe({super.key});

  @override
  State<TelacriarEquipe> createState() => _TelacriarEquipeState();
}

class _TelacriarEquipeState extends State<TelacriarEquipe> {
  static const _background = Color(0xFF101010);
  static const _surface = Color(0xFF1B1B1B);
  static const _surfaceLight = Color(0xFF242424);
  static const _lime = Color(0xFFB9FF00);
  static const _cyan = Color(0xFF00E5FF);
  static const _text = Color(0xFFF5F5F5);
  static const _muted = Color(0xFF858585);

  int _currentNavIndex = 1;
  bool _carregando = false;

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _modalidadeController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  String? _categoriaSelect;
  String? _modalidadeSelect;

  final List<String> categorias = [
    'Elite Pro',
    'Sub-20',
    'Sub-17',
    'Olimpico',
    'Profissional',
    'Master',
  ];

  final List<String> modalidades = [
    'Triathlon',
    'Futebol',
    'Natacao',
    'Corrida',
    'Ciclismo',
  ];

  final List<Map<String, dynamic>> todosAtletas = [
    {
      'id': 1,
      'nome': 'Marcus V. Silva',
      'posicao': 'Iron Man',
      'idAtleta': 1024,
      'selecionado': false,
    },
    {
      'id': 2,
      'nome': 'Elena Rodrigues',
      'posicao': 'Sprint',
      'idAtleta': 823,
      'selecionado': true,
    },
    {
      'id': 3,
      'nome': 'Ricardo Neves',
      'posicao': 'Meio Fundo',
      'idAtleta': 581,
      'selecionado': false,
    },
    {
      'id': 4,
      'nome': 'Gabriel Santos',
      'posicao': 'Endurance',
      'idAtleta': 489,
      'selecionado': false,
    },
    {
      'id': 5,
      'nome': 'Lucas Ferreira',
      'posicao': 'Velocidade',
      'idAtleta': 762,
      'selecionado': false,
    },
  ];

  late List<Map<String, dynamic>> atletasFiltrados;

  int get _selecionados =>
      todosAtletas.where((atleta) => atleta['selecionado'] == true).length;

  @override
  void initState() {
    super.initState();
    atletasFiltrados = List.of(todosAtletas);
    _categoriaSelect = categorias.first;
    _modalidadeSelect = modalidades.first;
    _modalidadeController.text = _modalidadeSelect ?? '';
  }

  void _filtrarAtletas(String query) {
    setState(() {
      atletasFiltrados = query.isEmpty
          ? List.of(todosAtletas)
          : todosAtletas
                .where(
                  (atleta) =>
                      atleta['nome'].toLowerCase().contains(
                        query.toLowerCase(),
                      ) ||
                      atleta['idAtleta'].toString().contains(query),
                )
                .toList();
    });
  }

  Future<void> _salvarEquipe() async {
    try {
      final atletasSelecionados = todosAtletas
          .where((a) => a['selecionado'])
          .map<int>((a) => a['idAtleta'] as int)
          .toList();

      setState(() => _carregando = true);

      final sucesso = await EquipeService.criarEquipe(
        nome: _nomeController.text,
        categoria: _categoriaSelect ?? categorias.first,
        modalidade: _modalidadeController.text,
        descricao: _descricaoController.text,
        atletasIds: atletasSelecionados,
      );

      if (sucesso && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Equipe criada com sucesso'),
            backgroundColor: _lime,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Future.delayed(const Duration(milliseconds: 900), () {
          if (mounted) Navigator.pop(context);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar equipe: $e'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
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
    _modalidadeController.dispose();
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
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 26),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildTopBar(),
                      const SizedBox(height: 22),
                      _buildHeader(),
                      const SizedBox(height: 24),
                      _buildConfigCard(),
                      const SizedBox(height: 16),
                      _buildRecruitmentCard(),
                      const SizedBox(height: 14),
                      _buildSelectedSummary(),
                      const SizedBox(height: 18),
                      _buildSalvarButton(),
                      const SizedBox(height: 34),
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
          icon: const Icon(Icons.arrow_back, color: _muted, size: 20),
        ),
        const SizedBox(width: 2),
        const Text(
          'H2OTRACK',
          style: TextStyle(
            color: _lime,
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
        const Spacer(),
        IconButton(
          visualDensity: VisualDensity.compact,
          onPressed: () {},
          icon: const Icon(Icons.notifications_none, color: _muted, size: 20),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'HUB DE GERENCIAMENTO',
          style: TextStyle(
            color: _lime,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Criar Equipe',
          style: TextStyle(
            color: _text,
            fontSize: 31,
            fontWeight: FontWeight.w900,
            height: 0.95,
          ),
        ),
        SizedBox(height: 10),
        Text(
          'Configure os parametros tecnicos e recrute atletas de alta performance para sua nova unidade tatica.',
          style: TextStyle(color: _muted, fontSize: 12, height: 1.35),
        ),
      ],
    );
  }

  Widget _buildConfigCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('NOME DA EQUIPE'),
          const SizedBox(height: 8),
          _buildTextField(_nomeController, 'Ex: Squad Alpha 01'),
          const SizedBox(height: 16),
          _buildLabel('CATEGORIA'),
          const SizedBox(height: 8),
          _buildDropdown(
            value: _categoriaSelect,
            items: categorias,
            onChanged: (value) => setState(() => _categoriaSelect = value),
          ),
          const SizedBox(height: 16),
          _buildLabel('MODALIDADE'),
          const SizedBox(height: 8),
          _buildDropdown(
            value: _modalidadeSelect,
            items: modalidades,
            onChanged: (value) {
              setState(() {
                _modalidadeSelect = value;
                _modalidadeController.text = value ?? '';
              });
            },
          ),
          const SizedBox(height: 16),
          _buildLabel('DESCRICAO TATICA'),
          const SizedBox(height: 8),
          _buildTextAreaField(
            _descricaoController,
            'Defina os objetivos e o foco da equipe...',
          ),
        ],
      ),
    );
  }

  Widget _buildRecruitmentCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _cyan.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('RECRUTAMENTO DE ATLETAS'),
          const SizedBox(height: 12),
          _buildSearchBar(),
          const SizedBox(height: 14),
          for (final atleta in atletasFiltrados) _buildAtletaItem(atleta),
        ],
      ),
    );
  }

  Widget _buildSelectedSummary() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: const BoxDecoration(
        color: Color(0xFF171717),
        border: Border(
          left: BorderSide(color: _lime, width: 3),
          right: BorderSide(color: _lime, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'MEMBROS SELECIONADOS',
                  style: TextStyle(
                    color: _lime,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.3,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _selecionados.toString().padLeft(2, '0'),
                      style: const TextStyle(
                        color: _text,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '/ ${todosAtletas.length}',
                      style: const TextStyle(
                        color: _muted,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.groups_2_outlined, color: _lime, size: 22),
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
        letterSpacing: 1.6,
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: _text, fontSize: 13),
      decoration: _inputDecoration(hint),
    );
  }

  Widget _buildTextAreaField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      maxLines: 4,
      style: const TextStyle(color: _text, fontSize: 13),
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
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
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
      icon: const Icon(Icons.keyboard_arrow_down, color: _muted, size: 18),
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
      height: 42,
      child: TextField(
        controller: _searchController,
        onChanged: _filtrarAtletas,
        style: const TextStyle(color: _text, fontSize: 12),
        decoration: InputDecoration(
          hintText: 'Buscar por ID ou Nome...',
          hintStyle: const TextStyle(color: _muted, fontSize: 11),
          prefixIcon: const Icon(Icons.search, color: _text, size: 18),
          filled: true,
          fillColor: Colors.black,
          contentPadding: EdgeInsets.zero,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: const BorderSide(color: _lime),
          ),
        ),
      ),
    );
  }

  Widget _buildAtletaItem(Map<String, dynamic> atleta) {
    final selected = atleta['selecionado'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: selected ? _lime.withValues(alpha: 0.08) : _surfaceLight,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: selected ? _lime.withValues(alpha: 0.36) : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 36,
            width: 36,
            decoration: const BoxDecoration(
              color: Color(0xFF303030),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              atleta['nome'].toString().characters.first,
              style: const TextStyle(
                color: _text,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  atleta['nome'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _text,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${atleta['posicao']} - #${atleta['idAtleta']}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _cyan,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () {
              setState(() {
                atleta['selecionado'] = !selected;
              });
            },
            child: Container(
              height: 28,
              width: 28,
              decoration: const BoxDecoration(
                color: _lime,
                shape: BoxShape.circle,
              ),
              child: Icon(
                selected ? Icons.check : Icons.add,
                color: Colors.black,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalvarButton() {
    return Center(
      child: SizedBox(
        width: 190,
        height: 52,
        child: FilledButton(
          onPressed: _carregando ? null : _salvarEquipe,
          style: FilledButton.styleFrom(
            backgroundColor: _lime,
            disabledBackgroundColor: _muted,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          child: _carregando
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                  ),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'SALVAR EQUIPE',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.bolt, color: Colors.black, size: 16),
                  ],
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
