import 'package:flutter/material.dart';
import 'package:hidratrack/Servicos/AuthStorage.dart';
import 'package:hidratrack/Servicos/TreinadorService.dart';

class TelaCadastroAtleta extends StatefulWidget {
  const TelaCadastroAtleta({super.key});

  @override
  State<TelaCadastroAtleta> createState() => _TelaCadastroAtletaState();
}

class _TelaCadastroAtletaState extends State<TelaCadastroAtleta> {
  static const _background = Color(0xFFFFFFFF);
  static const _surface = Color(0xFFF7F7F7);
  static const _lime = Color(0xFFB32025);
  static const _cyan = Color(0xFF8F171B);
  static const _text = Color(0xFF222222);
  static const _muted = Color(0xFF6B6B6B);

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _codigoController = TextEditingController();
  final TextEditingController _dataController = TextEditingController();
  final TextEditingController _pesoController = TextEditingController();
  final TextEditingController _alturaController = TextEditingController();

  bool _salvando = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _codigoController.dispose();
    _dataController.dispose();
    _pesoController.dispose();
    _alturaController.dispose();
    super.dispose();
  }

  Future<void> _selecionarData() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 20, now.month, now.day),
      firstDate: DateTime(1940),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: _lime,
              onPrimary: Colors.white,
              surface: _surface,
              onSurface: _text,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked == null) return;
    _dataController.text =
        '${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}';
  }

  Future<void> _salvarCadastro() async {
    final nome = _nomeController.text.trim();
    final codigoEquipe = _codigoController.text.trim().toUpperCase();
    final dataNascimento = _dataController.text.trim();
    final peso = double.tryParse(_pesoController.text.replaceAll(',', '.'));
    final altura = int.tryParse(_alturaController.text.trim());

    if (nome.isEmpty) {
      _mostrarMensagem('Informe o nome do atleta.');
      return;
    }

    if (codigoEquipe.isEmpty) {
      _mostrarMensagem('Informe o código da equipe.');
      return;
    }

    if (dataNascimento.isEmpty) {
      _mostrarMensagem('Informe a data de nascimento.');
      return;
    }

    if (peso == null || peso <= 0) {
      _mostrarMensagem('Informe um peso válido.');
      return;
    }

    if (altura == null || altura <= 0) {
      _mostrarMensagem('Informe uma altura válida.');
      return;
    }

    setState(() => _salvando = true);

    try {
      final valido = await TreinadorService.validarCodigoEquipe(codigoEquipe);
      if (!valido) {
        _mostrarMensagem('Código de equipe inválido.');
        return;
      }

      final resultado = await TreinadorService.cadastrarAtleta(
        nome: nome,
        codigoEquipe: codigoEquipe,
        dataNascimento: dataNascimento,
        peso: peso,
        altura: altura,
      );

      if (!mounted) return;

      AuthStorage.token = resultado['token']?.toString() ?? '';
      AuthStorage.nome = resultado['nome']?.toString() ?? nome;
      AuthStorage.tipoUsuario = resultado['tipoUsuario']?.toString() ?? 'ATLETA';
      AuthStorage.userId = (resultado['id'] as num?)?.toInt();

      final senhaGerada = resultado['senhaGerada']?.toString();
      final usuario = resultado['usuario']?.toString() ?? '';

      if (senhaGerada != null) {
        await showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Cadastro concluído'),
            content: Text(
              'Guarde seus dados de acesso:\n\nUsuário: $usuario\nSenha: $senhaGerada',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }

      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        '/dashboard-atleta',
        arguments: AuthStorage.token,
      );
    } catch (e) {
      _mostrarMensagem(
        'Erro no cadastro: ${e.toString().replaceAll("Exception: ", "")}',
      );
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  void _mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 34),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildHeader(),
                      const SizedBox(height: 54),
                      _buildCadastroCard(),
                      const SizedBox(height: 46),
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

  Widget _buildHeader() {
    return Row(
      children: const [
        Icon(Icons.water_drop, color: _lime, size: 21),
        SizedBox(width: 6),
        Text(
          'H2OTRACK',
          style: TextStyle(
            color: _lime,
            fontSize: 21,
            fontWeight: FontWeight.w900,
            height: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildCadastroCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 42, 22, 22),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(9),
        border: const Border(right: BorderSide(color: _lime, width: 2)),
        boxShadow: [
          BoxShadow(
            color: _cyan.withValues(alpha: 0.45),
            blurRadius: 0,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildFieldBlock(
            label: 'NOME COMPLETO',
            child: _buildTextField(
              controller: _nomeController,
              hint: 'Ex: Lucas Silva',
              icon: Icons.badge_outlined,
            ),
          ),
          const SizedBox(height: 24),
          _buildFieldBlock(
            label: 'CODIGO DE IDENTIFICACAO',
            child: _buildTextField(
              controller: _codigoController,
              hint: 'HT-000000',
              icon: Icons.fingerprint,
            ),
          ),
          const SizedBox(height: 24),
          _buildFieldBlock(
            label: 'DATA NASCIMENTO',
            child: _buildTextField(
              controller: _dataController,
              hint: 'mm/dd/yyyy',
              icon: Icons.calendar_today_outlined,
              readOnly: true,
              onTap: _selecionarData,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildFieldBlock(
                  label: 'PESO BASE (KG)',
                  child: _buildTextField(
                    controller: _pesoController,
                    hint: '75.0',
                    icon: Icons.monitor_weight_outlined,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    emphasis: true,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildFieldBlock(
                  label: 'ALTURA (CM)',
                  child: _buildTextField(
                    controller: _alturaController,
                    hint: '185',
                    icon: Icons.straighten,
                    keyboardType: TextInputType.number,
                    emphasis: true,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFieldBlock({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _cyan,
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.9,
          ),
        ),
        const SizedBox(height: 9),
        child,
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool readOnly = false,
    bool emphasis = false,
    VoidCallback? onTap,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      keyboardType: keyboardType,
      style: TextStyle(
        color: emphasis ? _muted : _text,
        fontSize: emphasis ? 21 : 14,
        fontWeight: emphasis ? FontWeight.w900 : FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: emphasis ? _muted.withValues(alpha: 0.5) : _muted,
          fontSize: emphasis ? 21 : 14,
          fontWeight: emphasis ? FontWeight.w900 : FontWeight.w500,
        ),
        suffixIcon: Icon(icon, color: _muted, size: 18),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: BorderSide(color: _lime.withValues(alpha: 0.36)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: const BorderSide(color: _lime),
        ),
      ),
    );
  }

  Widget _buildSalvarButton() {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: FilledButton.icon(
        onPressed: _salvando ? null : _salvarCadastro,
        style: FilledButton.styleFrom(
          backgroundColor: _lime,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
          shadowColor: _lime.withValues(alpha: 0.55),
          elevation: 10,
        ),
        icon: const Icon(Icons.save, size: 20),
        label: const Text(
          'SALVAR CADASTRO',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.4,
          ),
        ),
      ),
    );
  }
}
