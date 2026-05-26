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
  static const _lime = Color(0xFFB9FF00);
  static const _text = Color(0xFFF5F5F5);
  static const _muted = Color(0xFF858585);

  int _currentNavIndex = 1;
  bool _carregando = false;

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();

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

  @override
  void initState() {
    super.initState();
    _categoriaSelect = categorias.first;
    _modalidadeSelect = modalidades.first;
  }

  Future<void> _salvarEquipe() async {
    try {
      setState(() => _carregando = true);

      final equipe = await EquipeService.criarEquipe(
        nome: _nomeController.text,
        categoria: _categoriaSelect ?? categorias.first,
        modalidade: _modalidadeSelect ?? modalidades.first,
        descricao: _descricaoController.text,
        atletasIds: [],
      );

      if (mounted) {
        await _mostrarCodigoEquipeDialog(equipe.codigoEquipe);
        if (!mounted) return;
        Navigator.pop(context);
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
    _descricaoController.dispose();
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
              setState(() => _modalidadeSelect = value);
            },
          ),
          const SizedBox(height: 16),
          _buildLabel('DESCRIÇÃO TÁTICA'),
          const SizedBox(height: 8),
          _buildTextAreaField(
            _descricaoController,
            'Defina os objetivos e o foco da equipe...',
          ),
          const SizedBox(height: 14),
          const Text(
            'Um código de equipe será gerado automaticamente após salvar a equipe. O atleta usará esse código no cadastro para entrar diretamente.',
            style: TextStyle(color: _muted, fontSize: 11, height: 1.4),
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

  Future<void> _mostrarCodigoEquipeDialog(String codigoEquipe) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: _surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          title: const Text('Equipe criada'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Código de acesso da equipe:'),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.black,
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
                'Peça para o atleta usar este código no cadastro para entrar na equipe.',
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
