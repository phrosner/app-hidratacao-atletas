import 'package:flutter/material.dart';
import 'package:hidratrack/Modelos/AtletaListModels.dart';
import 'package:hidratrack/Servicos/EquipeService.dart';

class TelacriarEquipe extends StatefulWidget {
  const TelacriarEquipe({super.key});

  @override
  State<TelacriarEquipe> createState() => _TelacriarEquipeState();
}

class _TelacriarEquipeState extends State<TelacriarEquipe> {
  static const _background = Color(0xFFFFFFFF);
  static const _surface = Color(0xFFF7F7F7);
  static const _surfaceLight = Color(0xFFEDEDED);
  static const _lime = Color(0xFFB32025);
  static const _cyan = Color(0xFF8F171B);
  static const _text = Color(0xFF222222);
  static const _muted = Color(0xFF6B6B6B);

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _buscaController = TextEditingController();

  bool _carregando = false;
  bool _carregandoAtletas = true;
  String _categoriaSelect = 'Elite Pro';
  String _modalidadeSelect = 'Futebol';
  List<AtletaListItem> _atletasDisponiveis = [];
  final List<AtletaListItem> _atletasSelecionados = [];

  final List<String> categorias = [
    'Elite Pro',
    'Sub-20',
    'Sub-17',
    'Olimpico',
    'Profissional',
    'Master',
  ];

  final List<String> modalidades = [
    'Futebol',
    'Natacao',
    'Triathlon',
    'CrossFit',
    'Corrida',
    'Ciclismo',
  ];

  @override
  void initState() {
    super.initState();
    _carregarAtletas();
  }

  Future<void> _carregarAtletas([String query = '']) async {
    final atletas = await EquipeService.buscarAtletas(query);
    if (!mounted) return;
    setState(() {
      _atletasDisponiveis = atletas;
      _carregandoAtletas = false;
    });
  }

  Future<void> _salvarEquipe() async {
    if (_nomeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe o nome da equipe'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      setState(() => _carregando = true);

      final equipe = await EquipeService.criarEquipe(
        nome: _nomeController.text,
        categoria: _categoriaSelect,
        modalidade: _modalidadeSelect,
        descricao: _descricaoController.text,
        atletasIds: _atletasSelecionados.map((atleta) => atleta.id).toList(),
      );

      if (!mounted) return;
      await _mostrarCodigoEquipeDialog(equipe.codigoEquipe);
      if (!mounted) return;
      Navigator.pop(context, true);
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

  void _toggleAtleta(AtletaListItem atleta) {
    setState(() {
      final index = _atletasSelecionados.indexWhere(
        (item) => item.id == atleta.id,
      );
      if (index >= 0) {
        _atletasSelecionados.removeAt(index);
      } else {
        _atletasSelecionados.add(atleta);
      }
    });
  }

  bool _isSelecionado(AtletaListItem atleta) {
    return _atletasSelecionados.any((item) => item.id == atleta.id);
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _buscaController.dispose();
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
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildTopBar(),
                      const SizedBox(height: 24),
                      _buildHeader(),
                      const SizedBox(height: 24),
                      _buildConfigCard(),
                      const SizedBox(height: 18),
                      _buildRecruitmentCard(),
                      const SizedBox(height: 14),
                      _buildSelectedSummary(),
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
          icon: const Icon(Icons.arrow_back, color: _text, size: 22),
        ),
        const SizedBox(width: 2),
        const Text(
          'H2OTRACK',
          style: TextStyle(
            color: _text,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        IconButton(
          tooltip: 'Notificacoes',
          onPressed: () {},
          icon: const Icon(Icons.notifications_none, color: _muted, size: 21),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'HUB DE GERENCIAMENTO',
          style: TextStyle(
            color: _lime,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
        SizedBox(height: 5),
        Text(
          'Criar Equipe',
          style: TextStyle(
            color: _text,
            fontSize: 34,
            fontWeight: FontWeight.w900,
            height: 0.95,
          ),
        ),
        SizedBox(height: 10),
        Text(
          'Configure os parametros tecnicos e selecione atletas para compor uma unidade de acompanhamento.',
          style: TextStyle(color: _muted, fontSize: 12, height: 1.35),
        ),
      ],
    );
  }

  Widget _buildConfigCard() {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('NOME DA EQUIPE'),
          const SizedBox(height: 8),
          _buildTextField(_nomeController, 'Ex: Equipe Sub-20'),
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
            'Defina os objetivos e o foco da equipe...',
          ),
        ],
      ),
    );
  }

  Widget _buildRecruitmentCard() {
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
              _CountPill('${_atletasSelecionados.length} selecionados'),
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
          else
            for (final atleta in _atletasDisponiveis.take(5))
              _buildAtletaRow(atleta),
        ],
      ),
    );
  }

  Widget _buildSelectedSummary() {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _lime.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.groups_2_outlined, color: _lime, size: 22),
          const SizedBox(width: 12),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'MEMBROS SELECIONADOS',
                style: TextStyle(
                  color: _muted,
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '${_atletasSelecionados.length.toString().padLeft(2, '0')} / ${_atletasDisponiveis.length.toString().padLeft(2, '0')}',
                style: const TextStyle(
                  color: _text,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const Spacer(),
          _buildAvatarPreview(),
        ],
      ),
    );
  }

  Widget _buildAvatarPreview() {
    final selecionados = _atletasSelecionados.take(3).toList();
    if (selecionados.isEmpty) {
      return const Text(
        'Nenhum atleta',
        style: TextStyle(color: _muted, fontSize: 11),
      );
    }

    return SizedBox(
      height: 30,
      width: 88,
      child: Stack(
        children: [
          for (var i = 0; i < selecionados.length; i++)
            Positioned(
              left: i * 20,
              child: _SmallAvatar(
                label: _initials(selecionados[i].nome),
                color: i.isEven ? _lime : _cyan,
              ),
            ),
          if (_atletasSelecionados.length > 3)
            Positioned(
              left: 60,
              child: _SmallAvatar(
                label: '+${_atletasSelecionados.length - 3}',
                color: const Color(0xFF343434),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return SizedBox(
      height: 44,
      child: TextField(
        controller: _buscaController,
        onChanged: _carregarAtletas,
        style: const TextStyle(color: _text, fontSize: 12),
        decoration: InputDecoration(
          hintText: 'Buscar por nome, modalidade ou categoria',
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

  Widget _buildAtletaRow(AtletaListItem atleta) {
    final selected = _isSelecionado(atleta);

    return Container(
      height: 60,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: selected ? _lime : _surfaceLight,
          width: selected ? 1.3 : 1,
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 10),
          _SmallAvatar(label: _initials(atleta.nome), color: _cyan),
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
                  '${atleta.categoria} - ${atleta.hidratacao}% hidratacao',
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
              selected ? Icons.check_circle : Icons.add_circle,
              color: selected ? _lime : _muted,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalvarButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton.icon(
        onPressed: _carregando ? null : _salvarEquipe,
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
            : const Icon(Icons.bolt, size: 18),
        label: const Text(
          'SALVAR EQUIPE',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.4,
          ),
        ),
      ),
    );
  }

  Future<void> _mostrarCodigoEquipeDialog(String codigoEquipe) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: _surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: const Text('Equipe criada'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Codigo de acesso da equipe:'),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _lime.withValues(alpha: 0.3)),
                ),
                child: Text(
                  codigoEquipe,
                  style: const TextStyle(
                    color: _lime,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'O atleta usa este codigo no cadastro para entrar diretamente na equipe.',
                style: TextStyle(color: _muted, fontSize: 12, height: 1.4),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('FECHAR'),
            ),
          ],
        );
      },
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
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
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
        color: _TelacriarEquipeState._surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _TelacriarEquipeState._surfaceLight),
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
        color: _TelacriarEquipeState._lime,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 8,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.6,
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
      height: 30,
      width: 30,
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
