import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hidratrack/Telas/Telalogin.dart';
import 'package:http/http.dart' as http;

class TelaCadastroTreinador extends StatefulWidget {
  const TelaCadastroTreinador({super.key});

  @override
  State<TelaCadastroTreinador> createState() => _TelaCadastroTreinadorState();
}

class _TelaCadastroTreinadorState extends State<TelaCadastroTreinador> {
  static const _background = Color(0xFFFFFFFF);
  static const _surface = Color(0xFFF7F7F7);
  static const _lime = Color(0xFFB32025);
  static const _cyan = Color(0xFF8F171B);
  static const _text = Color(0xFF222222);
  static const _muted = Color(0xFF6B6B6B);

  bool _obscureSenha = true;
  bool _obscureConfirmacao = true;
  bool _carregandoCadastro = false;

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nascimentoController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _confirmacaoController = TextEditingController();

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _nascimentoController.dispose();
    _senhaController.dispose();
    _confirmacaoController.dispose();
    super.dispose();
  }

  Future<void> _selecionarData() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 30, now.month, now.day),
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
    _nascimentoController.text =
        '${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}';
  }

  String getApiBaseUrl() {
    if (kIsWeb) {
      return 'http://localhost:8080';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.2.2.246:8080';
    }
    return 'http://localhost:8080';
  }

  String _mensagemErroHttp(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map && decoded['erro'] != null) {
        return decoded['erro'].toString();
      }
    } catch (_) {}
    if (body.isNotEmpty) return body;
    return 'Erro inesperado';
  }

  void _mostrarMensagem(String mensagem) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: _lime,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _salvarCadastro() async {
    final nome = _nomeController.text.trim();
    final email = _emailController.text.trim();
    final dataNascimento = _nascimentoController.text.trim();
    final senha = _senhaController.text.trim();
    final confirmacao = _confirmacaoController.text.trim();

    if (nome.isEmpty) {
      _mostrarMensagem('Informe o nome completo.');
      return;
    }

    if (email.isEmpty) {
      _mostrarMensagem('Informe o e-mail.');
      return;
    }

    if (!email.contains('@') || !email.contains('.')) {
      _mostrarMensagem('Informe um e-mail válido.');
      return;
    }

    if (senha.isEmpty) {
      _mostrarMensagem('Informe a senha.');
      return;
    }

    if (senha != confirmacao) {
      _mostrarMensagem('A senha e a confirmação não coincidem.');
      return;
    }

    setState(() {
      _carregandoCadastro = true;
    });

    try {
      final response = await http.post(
        Uri.parse('${getApiBaseUrl()}/api/auth/cadastrar'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nome': nome,
          'email': email,
          'usuario': email,
          'senha': senha,
          'nascimento': dataNascimento,
          'tipoUsuario': 'TREINADOR',
          'ativo': true,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 201 || response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cadastro salvo com sucesso'),
            backgroundColor: _lime,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Telalogin()),
        );
      } else {
        _mostrarMensagem(
          'Erro no cadastro: ${_mensagemErroHttp(response.body)}',
        );
      }
    } catch (e) {
      _mostrarMensagem('Não foi possível conectar ao backend.');
    } finally {
      if (mounted) {
        setState(() {
          _carregandoCadastro = false;
        });
      }
    }
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
                  padding: const EdgeInsets.fromLTRB(18, 48, 18, 34),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildHeader(),
                      const SizedBox(height: 56),
                      _buildCadastroCard(),
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
    return Column(
      children: const [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.water_drop, color: _lime, size: 30),
            SizedBox(width: 8),
            Text(
              'H2OTRACK',
              style: TextStyle(
                color: _lime,
                fontSize: 23,
                fontWeight: FontWeight.w900,
                height: 1,
              ),
            ),
          ],
        ),
        SizedBox(height: 30),
        Text(
          'CADASTRO TREINADOR',
          style: TextStyle(
            color: _text,
            fontSize: 26,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }

  Widget _buildCadastroCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(32, 36, 32, 32),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: _lime.withValues(alpha: 0.08),
            blurRadius: 80,
            offset: const Offset(0, -42),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.38),
            blurRadius: 40,
            offset: const Offset(0, 24),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildFieldBlock(
            label: 'NOME COMPLETO',
            child: _buildTextField(
              controller: _nomeController,
              hint: 'EX: ARTHUR SILVA',
              icon: Icons.person_outline,
            ),
          ),
          const SizedBox(height: 21),
          _buildFieldBlock(
            label: 'E-MAIL',
            child: _buildTextField(
              controller: _emailController,
              hint: 'COACH@H2OTRACK.COM',
              icon: Icons.alternate_email,
              keyboardType: TextInputType.emailAddress,
            ),
          ),
          const SizedBox(height: 21),
          _buildFieldBlock(
            label: 'NASCIMENTO',
            child: _buildTextField(
              controller: _nascimentoController,
              hint: 'mm/dd/yyyy',
              icon: Icons.calendar_today_outlined,
              readOnly: true,
              onTap: _selecionarData,
            ),
          ),
          const SizedBox(height: 21),
          _buildFieldBlock(
            label: 'SENHA',
            child: _buildTextField(
              controller: _senhaController,
              hint: '********',
              icon: Icons.lock_outline,
              obscureText: _obscureSenha,
              suffix: IconButton(
                onPressed: () => setState(() => _obscureSenha = !_obscureSenha),
                icon: Icon(
                  _obscureSenha ? Icons.visibility_off : Icons.visibility,
                  color: _muted,
                  size: 18,
                ),
              ),
            ),
          ),
          const SizedBox(height: 21),
          _buildFieldBlock(
            label: 'CONFIRMACAO',
            child: _buildTextField(
              controller: _confirmacaoController,
              hint: '********',
              icon: Icons.verified_user_outlined,
              obscureText: _obscureConfirmacao,
              suffix: IconButton(
                onPressed: () =>
                    setState(() => _obscureConfirmacao = !_obscureConfirmacao),
                icon: Icon(
                  _obscureConfirmacao ? Icons.visibility_off : Icons.visibility,
                  color: _muted,
                  size: 18,
                ),
              ),
            ),
          ),
          const SizedBox(height: 48),
          _buildSalvarButton(),
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
        const SizedBox(height: 8),
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
    bool obscureText = false,
    VoidCallback? onTap,
    Widget? suffix,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      obscureText: obscureText,
      onTap: onTap,
      style: const TextStyle(color: _text, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF4E4E4E), fontSize: 13),
        prefixIcon: Icon(icon, color: _muted, size: 17),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: BorderSide(color: _lime.withValues(alpha: 0.28)),
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
      height: 54,
      child: FilledButton(
        onPressed: _carregandoCadastro ? null : _salvarCadastro,
        style: FilledButton.styleFrom(
          backgroundColor: _lime,
          disabledBackgroundColor: _muted,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
          elevation: 10,
          shadowColor: _lime.withValues(alpha: 0.55),
        ),
        child: _carregandoCadastro
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'SALVAR CADASTRO',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.8,
                    ),
                  ),
                  SizedBox(width: 10),
                  Icon(Icons.bolt, size: 17),
                ],
              ),
      ),
    );
  }
}
