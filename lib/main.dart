import 'package:flutter/material.dart';
import 'package:hidratrack/Telas/Teladashboard.dart';
import 'package:hidratrack/Telas/Telaequipes.dart';
import 'package:hidratrack/Telas/Telalogin.dart';
import 'package:hidratrack/Telas/Telacadastro.dart';
import 'package:hidratrack/Telas/Telacadastrotreinador.dart';

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
        useMaterial3: true
      ),
      home:const TelaEquipes(),

    );
  }
}