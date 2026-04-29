import 'package:flutter/material.dart';
import 'package:hidratrack/Botoes/BotaoClass.dart';
import 'package:hidratrack/Telas/Telalogin.dart';

class TelaCadastroAtleta extends StatefulWidget {
  const TelaCadastroAtleta({super.key});

  @override
  State<TelaCadastroAtleta> createState() => _TelaCadastroAtletaState();
}

class _TelaCadastroAtletaState extends State<TelaCadastroAtleta> {
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
  MaterialPageRoute(
    builder: (context) => const Telalogin(),
  ),
);
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.pinkAccent,
          ),
        ),
        title: const Text(
          "CADASTRO DE ATLETA",
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
                "INFORMAÇÕES BÁSICAS",
                [
                  _buildInput("NOME COMPLETO", "Ex: João Silva"),
                  _buildInput(
                    "CÓDIGO DE IDENTIFICAÇÃO",
                    "ID Atleta (Opcional)",
                  ),
                  _buildInput(
                    "DATA DE NASCIMENTO",
                    "mm/dd/yyyy",
                  ),
                ],
              ),

              const SizedBox(height: 20),

              _buildSection(
                "DADOS INICIAIS",
                [
                  Row(
                    children: [
                      Expanded(
                        child: _buildInput(
                          "PESO BASE",
                          "00.0 KG",
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInput(
                          "ALTURA",
                          "000 CM",
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 30),

              BotaoElevated(
                texto: "SALVAR CADASTRO",
                icone: Icons.check_circle_outline,
                onPressed: () {
                  print("Cadastro salvo");
                },
              ),
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
          const Divider(
            color: Colors.white12,
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInput(String label, String hint) {
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
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: Colors.white38,
              ),
              filled: true,
              fillColor: const Color(0xFF5A3A3F),
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