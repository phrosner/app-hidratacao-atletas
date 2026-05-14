import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hidratrack/Botoes/BotaoClass.dart';

class Telalogin extends StatefulWidget {
  const Telalogin({super.key});

  @override
  State<Telalogin> createState() => _TelaloginState();
}

class _TelaloginState extends State<Telalogin> {
  bool mostrarSenha = false;
  bool carregandoLogin = false;
  /// 0 = Atleta, 1 = Treinador, 2 = Nutricionista (deve bater com o cadastro no banco).
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

  void _navegarAposLogin(String tipoUsuario) {
    switch (tipoUsuario) {
      case 'TREINADOR':
      case 'NUTRICIONISTA':
        Navigator.pushReplacementNamed(context, '/dashboard');
        break;
      case 'ATLETA':
      default:
        Navigator.pushReplacementNamed(context, '/dashboard-atleta');
        break;
    }
  }

  String getApiBaseUrl() {
    if (kIsWeb) {
      return 'http://localhost:8080';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8080';
    }
    return 'http://localhost:8080';
  }

  Future<void> fazerLogin() async {
    final usuario = usuarioController.text.trim();
    final senha = senhaController.text.trim();

    if (usuario.isEmpty || senha.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha usuário e senha')),
      );
      return;
    }

    setState(() {
      carregandoLogin = true;
    });

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
        final tipo = data is Map && data['tipoUsuario'] != null
            ? data['tipoUsuario'].toString()
            : _tipoLoginApi(_perfilSelecionado);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login bem sucedido')),
        );
        _navegarAposLogin(tipo);
      } else if (response.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_mensagemErroHttp(response.body))),
        );
      } else if (response.statusCode == 403) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_mensagemErroHttp(response.body))),
        );
      } else if (response.statusCode == 400) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_mensagemErroHttp(response.body))),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erro no login (${response.statusCode}): ${_mensagemErroHttp(response.body)}',
            ),
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível conectar ao backend em localhost:8080'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          carregandoLogin = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 900;

    return Scaffold(
      backgroundColor: const Color(0xFF1F0F10),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1040),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 32 : 20,
                  vertical: isDesktop ? 28 : 0,
                ),
                child: Column(
                  children: [
                    SizedBox(height: isDesktop ? 56 : 40),
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Text(
                        'HYDRA',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color(0xFFFFD6DA),
                          fontSize: isDesktop ? 72 : 54,
                          fontFamily: 'Bebas Neue',
                          letterSpacing: 2,
                          height: 1,
                        ),
                      ),
                    ),
                    Text(
                      'TRACK',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFFFF4D6D),
                        fontSize: isDesktop ? 72 : 54,
                        fontFamily: 'Bebas Neue',
                        letterSpacing: 2,
                        height: 0.9,
                      ),
                    ),
                    SizedBox(height: isDesktop ? 52 : 40),
                    Container(
                      width: size.width > 600 ? 460 : double.infinity,
                      padding: EdgeInsets.all(isDesktop ? 28 : 24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2B1718),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.4),
                            blurRadius: 25,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF442F30),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: BotaoToggle(
                              selectedIndex: _perfilSelecionado,
                              onChanged: (i) {
                                setState(() => _perfilSelecionado = i);
                              },
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: const [
                              Icon(
                                Icons.person_outline,
                                color: Color(0xFFE6BCBD),
                                size: 14,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Identificador',
                                style: TextStyle(
                                  color: Color(0xFFE6BCBD),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: usuarioController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFF3A2223),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              labelText: 'Email ou ID',
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.never,
                              labelStyle: const TextStyle(
                                color: Color(0xAAE6BCBD),
                                fontSize: 11,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 16,
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: const [
                              Icon(
                                Icons.lock_outline,
                                color: Color(0xFFE6BCBD),
                                size: 14,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Senha',
                                style: TextStyle(
                                  color: Color(0xFFE6BCBD),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: senhaController,
                            obscureText: !mostrarSenha,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFF3A2223),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              labelText: 'Senha',
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.never,
                              labelStyle: const TextStyle(
                                color: Color(0xAAE6BCBD),
                                fontSize: 11,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 16,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  mostrarSenha
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: const Color(0xAAE6BCBD),
                                  size: 18,
                                ),
                                onPressed: () {
                                  setState(() {
                                    mostrarSenha = !mostrarSenha;
                                  });
                                },
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {},
                              child: const Text(
                                'Esqueceu a senha?',
                                style: TextStyle(
                                  color: Color(0xFF82CFFF),
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          BotaoElevated(
                            texto: 'Acessar Sistema',
                            icone: Icons.arrow_forward,
                            onPressed: fazerLogin,
                            carregando: carregandoLogin,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
