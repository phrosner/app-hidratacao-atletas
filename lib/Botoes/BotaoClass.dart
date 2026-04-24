import 'package:flutter/material.dart';

class BotaoToggle extends StatefulWidget {
  const BotaoToggle({super.key});

  @override
  State<BotaoToggle> createState() => _BotaoToggleState();
}

class _BotaoToggleState extends State<BotaoToggle> {
  List<bool> selecionado = [true, false, false];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ToggleButtons(
        isSelected: selecionado,
        onPressed: (int index) {
          setState(() {
            for (int i = 0; i < selecionado.length; i++) {
              selecionado[i] = i == index;
            }
          });
        },
        color: const Color(0xFFE6BCBD),
        selectedColor: const Color(0xFFFCDBDB),
        fillColor: const Color(0xFF2D1B1B),
        children: const [
          Padding(
            padding: EdgeInsets.all(14),
            child: Text("Atleta"),
          ),
          Padding(
            padding: EdgeInsets.all( 14),
            child: Text("Treinador"),
          ),
          Padding(
            padding: EdgeInsets.all(14),
            child: Text("Nutricionista"),
          ),
        ],
      ),
    );
  }
}

class BotaoElevated extends StatefulWidget {
  const BotaoElevated({super.key});

  @override
  State<BotaoElevated> createState() => _BotaoElevatedState();
}

class _BotaoElevatedState extends State<BotaoElevated> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF5167),
          foregroundColor: const Color(0xFF5B0015),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        child: const Row(mainAxisAlignment: MainAxisAlignment.center,//centraliza o texto e o ícone
        children: [Text("Acessar Sistema"),
        SizedBox(width: 8),
        Icon(Icons.arrow_forward),
        ],),
      ),
    );
  }
}
class BotaoText extends StatefulWidget {
  const BotaoText({super.key});

  @override
  State<BotaoText> createState() => _BotaoTextState();
}

class _BotaoTextState extends State<BotaoText> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
  onPressed: () {
    // aqui você coloca a ação
    print("Esqueceu a senha clicado");
  },
  child: const Text(
    "Esqueceu a senha?",
    style: TextStyle(
      color: Colors.blue,
      decoration: TextDecoration.underline,
      fontSize: 10,
    ),
  ),
)
    );
  }
}