import 'package:flutter/material.dart';
import 'package:hidratrack/Telas/Telaatletas.dart';
import 'package:hidratrack/Telas/Teladashboard.dart';
import 'package:hidratrack/Telas/Telaequipes.dart';
import 'package:hidratrack/Telas/TelacriarEquipe.dart';
import 'package:hidratrack/Telas/TeladadosEquipe.dart';
import 'package:hidratrack/Telas/TeladadosAtletas.dart';
import 'package:hidratrack/Telas/Telagraficos.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tela de Login',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const TelaDAshboard(),
      routes: {
        '/dashboard': (context) => const TelaDAshboard(),
        '/equipes': (context) => const TelaEquipes(),
        '/atletas': (context) => const TelaAtletas(),
        '/criar-equipe': (context) => const TelacriarEquipe(),
        '/dados-equipe': (context) => const TeladadosEquipe(),
        '/dados-atleta': (context) => const TeladadosAtletas(),
        '/graficos': (context) => const Telagraficos(),
      },
    );
  }
}
