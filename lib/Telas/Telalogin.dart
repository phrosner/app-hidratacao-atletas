import 'package:flutter/material.dart';
import 'package:hidratrack/Botoes/BotaoClass.dart';

class Telalogin extends StatefulWidget {
  const Telalogin({super.key});

  @override
  State<Telalogin> createState() => _TelaloginState();
}

class _TelaloginState extends State<Telalogin> {
  bool mostrarSenha = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF1F0F10),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 40),

                    // ===== TÍTULO =====
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: const Text(
                        'SÃO CAMILO',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFFFFD6DA),
                          fontSize: 54,
                          fontFamily: 'Bebas Neue',
                          letterSpacing: 2,
                          height: 1,
                        ),
                      ),
                    ),

                    const Text(
                      'SPORT',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFFFF4D6D),
                        fontSize: 54,
                        fontFamily: 'Bebas Neue',
                        letterSpacing: 2,
                        height: 0.9,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // ===== CARD =====
                    Container(
                      width: size.width > 600 ? 420 : double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2B1718),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 25,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ===== TOGGLE COM FUNDO RESTAURADO =====
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF442F30),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const BotaoToggle(),
                          ),

                          const SizedBox(height: 20),

                          // ===== IDENTIFICADOR =====
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

                          // ===== SENHA HEADER =====
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

                          // ===== INPUT SENHA =====
                          TextFormField(
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

                          // ===== ESQUECEU SENHA =====
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

                          // ===== BOTÃO LOGIN =====
                          const BotaoElevated(),
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
