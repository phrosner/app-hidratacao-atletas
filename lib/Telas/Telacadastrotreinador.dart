import 'package:flutter/material.dart';
import 'package:hidratrack/Botoes/BotaoClass.dart'; 
import 'package:hidratrack/Telas/Telalogin.dart';

class TelaCadastroTreinador extends StatefulWidget {
  const TelaCadastroTreinador({super.key});

  @override
  State<TelaCadastroTreinador> createState() => _TelaCadastroTreinadorState();
}

class _TelaCadastroTreinadorState extends State<TelaCadastroTreinador> {
  
  bool _obscureSenha = true;
  bool _obscureConfirmacao = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A0003),
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Telalogin()),
            );
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.pinkAccent,
          ),
        ),
        title: const Text(
          "CADASTRO DE TREINADOR",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              
              _buildSection(
                "INFORMAÇÕES PESSOAIS",
                [
                  _buildInput("NOME COMPLETO", "Seu nome completo"),
                  _buildInput("E-MAIL", "treinador@exemplo.com"),
                  _buildInput("NASCIMENTO", "mm/dd/yyyy"),
                ],
              ),

              const SizedBox(height: 20),

              
              _buildSection(
                "ACESSO",
                [
                  _buildInput(
                    "SENHA",
                    "........",
                    isObscure: _obscureSenha,
                    suffix: IconButton(
                      icon: Icon(
                        _obscureSenha ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: Colors.white38,
                      ),
                      onPressed: () => setState(() => _obscureSenha = !_obscureSenha),
                    ),
                  ),
                  _buildInput(
                    "CONFIRMAÇÃO DE SENHA",
                    "........",
                    isObscure: _obscureConfirmacao,
                    suffix: IconButton(
                      icon: Icon(
                        _obscureConfirmacao ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: Colors.white38,
                      ),
                      onPressed: () => setState(() => _obscureConfirmacao = !_obscureConfirmacao),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              
              BotaoElevated(
                texto: "SALVAR CADASTRO",
                icone: Icons.check_circle_outline,
                onPressed: () {
                  print("Cadastro salvo com sucesso!");
                },
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  

  Widget _buildSection(String titulo, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF2A0D11),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              color: Color(0xFFE89CA6),
              fontSize: 24, 
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(color: Colors.white12),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInput(String label, String hint, {bool isObscure = false, Widget? suffix}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            obscureText: isObscure,
            obscuringCharacter: '•', // Ponto para ocultar a senha
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.white38),
              filled: true,
              fillColor: const Color(0xFF5A3A3F), 
              suffixIcon: suffix,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}