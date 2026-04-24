import 'package:flutter/material.dart';
import 'package:hidratrack/Botoes/BotaoClass.dart';


class Telalogin extends StatefulWidget {
  const Telalogin({super.key});

  @override
  State<Telalogin> createState() => _TelaloginState();
}

class _TelaloginState extends State<Telalogin> {
  bool mostrarSenha = false;//variável para controlar a exibição da senha
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F0F10),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
      'SÃO CAMILO',
      style: TextStyle(
        color: Color(0xFFFCDBDB),
        fontSize: 64,
        fontFamily: 'Bebas Neue' 
      ),
    ),

    const SizedBox(height: 0),

    const Text(
      'SPORT',
      style: TextStyle(
        color: Color(0xFFFF5167),
        fontSize: 64,
        height: 0.4,
        fontFamily: 'Bebas Neue'
        
      ),
    ),
    const SizedBox(height: 60),
  

          Container(
            padding: const EdgeInsets.all(40),
            height: 400,
            width: double.infinity,
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xFF2E1C1C),
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [ Container(
                padding: const EdgeInsets.all(0),
                decoration: BoxDecoration(
                  color: const Color(0xFF442F30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: BotaoToggle(),
              ),
                Row(
                  children:[
                    Icon( 
                      Icons.person_outline,
                      color: Color(0xFFE6BCBD),
                      size: 12,
                    ),
                Text(
                  'Identificador',
                  style: TextStyle(
                    color: Color(0xFFE6BCBD),
                    fontSize: 10,
                  ),
                ),
                ],
                ),

                const SizedBox(height: 8),

                TextFormField(
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(12),
                      ),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Color(0xFF442F30),
                    labelText: 'Email ou ID',
                    labelStyle: TextStyle(
                      color: Color(0xAAE6BCBD),
                      fontSize: 10,
                    ),
                    floatingLabelBehavior:
                        FloatingLabelBehavior.never,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                Row(
                  children:[
                    Icon( 
                      Icons.lock_outline,
                      color: Color(0xFFE6BCBD),
                      size: 12,
                    ),  
                Text(
                  'Senha',
                  style: TextStyle(
                    color: Color(0xFFE6BCBD),
                    fontSize: 10,
                  ),
                ),
                Spacer(),
                BotaoText(),
                ],
                ),

                TextFormField(
                  style: const TextStyle(color: Colors.white),
                  obscureText:!mostrarSenha,//controla mostrar senha
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(12),
                      ),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Color(0xFF442F30),
                    labelText: 'Senha',
                    labelStyle: TextStyle(
                      color: Color(0xAAE6BCBD),
                      fontSize: 10,
                    ),
                    floatingLabelBehavior:
                        FloatingLabelBehavior.never,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        mostrarSenha
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Color(0xAAE6BCBD),
                        size: 12,
                      ),
                      onPressed: () {
                        setState(() {
                          mostrarSenha = !mostrarSenha;//alterna a exibição da senha
                        });
                      },
                    ),
                  ),
                ),
                BotaoElevated()
              ],
            ),
          ),
        ],
      ),
    );
  }
}