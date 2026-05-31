import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hidratrack/Servicos/AuthStorage.dart';
import 'package:hidratrack/app_rotas.dart';
import 'package:http/http.dart' as http;

class Telalogin extends StatefulWidget {
  const Telalogin({super.key});

  @override
  State<Telalogin> createState() => _TelaloginState();
}

class _TelaloginState extends State<Telalogin> {
  static const _background = Color(0xFFFFFFFF);
  static const _surface = Color(0xFFF7F7F7);
  static const _surfaceLight = Color(0xFFEDEDED);
  static const _lime = Color(0xFFB32025);
  static const _cyan = Color(0xFF8F171B);
  static const _text = Color(0xFF222222);
  static const _muted = Color(0xFF6B6B6B);

  bool mostrarSenha = false;
  bool carregandoLogin = false;
  int _perfilSelecionado = 0;

  final TextEditingController usuarioController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();

  @override
  void dispose() {
    usuarioController.dispose();
    senhaController.dispose();
    super.dispose();
  }

  static String _tipoLoginApi(int perfilIndex) {
    switch (perfilIndex) {
      case 1:
        return 'TREINADOR';
      case 2:
        return 'NUTRICIONISTA';
      case 0:
      default:
        return 'ATLETA';
    }
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

  void _navegarAposLogin(String tipoUsuarioRaw, String token) {
    final tipo = tipoUsuarioRaw.trim().toUpperCase();
    if (tipo == 'TREINADOR' || tipo == 'NUTRICIONISTA') {
      Navigator.pushReplacementNamed(context, AppRotas.dashboardTreinador);
      return;
    }
    Navigator.pushReplacementNamed(
      context,
      AppRotas.dashboardAtleta,
      arguments: token,
    );
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

  Future<void> fazerLogin() async {
    final usuario = usuarioController.text.trim();
    final senha = senhaController.text.trim();

    if (usuario.isEmpty || senha.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha usuario e senha'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => carregandoLogin = true);

    try {
      final response = await http.post(
        Uri.parse('${getApiBaseUrl()}/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'usuario': usuario,
          'senha': senha,
          'tipoLogin': _tipoLoginApi(_perfilSelecionado),
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data is Map ? data['token']?.toString() ?? '' : '';
        final nome = data is Map ? data['nome']?.toString() ?? '' : '';
        final tipo = data is Map && data['tipoUsuario'] != null
            ? data['tipoUsuario'].toString().trim().toUpperCase()
            : _tipoLoginApi(_perfilSelecionado);

        if (token.isNotEmpty) {
          AuthStorage.token = token;
          AuthStorage.nome = nome;
          AuthStorage.tipoUsuario = tipo;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login bem sucedido'),
            backgroundColor: _lime,
            behavior: SnackBarBehavior.floating,
          ),
        );
        _navegarAposLogin(tipo, token);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response.statusCode == 401 ||
                      response.statusCode == 403 ||
                      response.statusCode == 400
                  ? _mensagemErroHttp(response.body)
                  : 'Erro no login (${response.statusCode}): ${_mensagemErroHttp(response.body)}',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Nao foi possivel conectar ao backend em localhost:8080',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => carregandoLogin = false);
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
                  padding: const EdgeInsets.fromLTRB(18, 54, 18, 30),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildBrand(),
                      const SizedBox(height: 82),
                      _buildLoginCard(),
                      const SizedBox(height: 78),
                      _buildFooterStatus(),
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

  Widget _buildBrand() {
    return Column(
      children: const [
        Icon(Icons.water_drop, color: _lime, size: 42),
        SizedBox(height: 20),
        Text(
          'H2OTRACK',
          style: TextStyle(
            color: _lime,
            fontSize: 39,
            fontWeight: FontWeight.w900,
            height: 1,
          ),
        ),
        SizedBox(height: 16),
        Text(
          'CYBER-ATHLETIC PERFORMANCE CNIP',
          style: TextStyle(
            color: _muted,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.4,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(30, 28, 30, 28),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(
            color: _cyan.withValues(alpha: 0.12),
            blurRadius: 50,
            offset: const Offset(0, 34),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildProfileToggle(),
          const SizedBox(height: 26),
          _buildFieldLabel(Icons.person_outline, 'IDENTIFICADOR'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: usuarioController,
            hint: 'Email ou ID',
            obscure: false,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildFieldLabel(Icons.lock_outline, 'SENHA'),
              const Spacer(),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 24),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Esqueceu?',
                  style: TextStyle(
                    color: _cyan,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildTextField(
            controller: senhaController,
            hint: '********',
            obscure: !mostrarSenha,
            suffix: IconButton(
              onPressed: () => setState(() => mostrarSenha = !mostrarSenha),
              icon: Icon(
                mostrarSenha ? Icons.visibility : Icons.visibility_off,
                color: _muted,
                size: 20,
              ),
            ),
          ),
          const SizedBox(height: 28),
          _buildLoginButton(),
        ],
      ),
    );
  }

  Widget _buildProfileToggle() {
    const labels = ['Atleta', 'Nutrição', 'Treinador'];

    return Container(
      height: 50,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(6),
                onTap: () {
                  setState(() {
                    _perfilSelecionado = i == 1 ? 2 : (i == 2 ? 1 : 0);
                  });
                },
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _isToggleSelected(i)
                        ? _surfaceLight
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      labels[i],
                      style: TextStyle(
                        color: _isToggleSelected(i) ? _lime : _muted,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  bool _isToggleSelected(int visualIndex) {
    return switch (visualIndex) {
      0 => _perfilSelecionado == 0,
      1 => _perfilSelecionado == 2,
      2 => _perfilSelecionado == 1,
      _ => false,
    };
  }

  Widget _buildFieldLabel(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: _muted, size: 14),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            color: _muted,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    Widget? suffix,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: _text, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: _muted, fontSize: 14),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: BorderSide(color: _lime.withValues(alpha: 0.22)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: const BorderSide(color: _lime),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 66,
      child: FilledButton(
        onPressed: carregandoLogin ? null : fazerLogin,
        style: FilledButton.styleFrom(
          backgroundColor: _lime,
          disabledBackgroundColor: _muted,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 12,
          shadowColor: _lime.withValues(alpha: 0.55),
        ),
        child: carregandoLogin
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
                    'ACESSAR SISTEMA',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                  SizedBox(width: 10),
                  Icon(Icons.arrow_forward, size: 23),
                ],
              ),
      ),
    );
  }

  Widget _buildFooterStatus() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        _StatusDot(color: _lime, text: 'HYPER ENVINE'),
        SizedBox(width: 46),
        _StatusDot(color: _cyan, text: 'ENCRYPTED SYNC'),
      ],
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.color, required this.text});

  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            color: Color(0xFF6B6B6B),
            fontSize: 8,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}
