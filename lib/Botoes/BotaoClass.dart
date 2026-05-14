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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
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
                borderRadius: BorderRadius.circular(12),
                constraints: const BoxConstraints(minHeight: 44, minWidth: 70),
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    child: Text("Atleta"),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    child: Text("Treinador"),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    child: Text("Nutricionista"),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class BotaoElevated extends StatefulWidget {
  final String texto;
  final VoidCallback? onPressed;
  final IconData? icone;
  final bool carregando;

  const BotaoElevated({
    super.key,
    required this.texto,
    this.onPressed,
    this.icone,
    this.carregando = false,
  });

  @override
  State<BotaoElevated> createState() => _BotaoElevatedState();
}

class _BotaoElevatedState extends State<BotaoElevated> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: widget.carregando ? null : widget.onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF5167),
          foregroundColor: const Color(0xFF5B0015),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.carregando) ...[
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 8),
            ],
            Text(widget.texto),
            if (!widget.carregando && widget.icone != null) ...[
              const SizedBox(width: 8),
              Icon(widget.icone),
            ],
          ],
        ),
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
      ),
    );
  }
}
