import 'package:flutter/material.dart';
import 'package:hidratrack/Telas/TelaSess%C3%A3oAtiva.dart';
import 'package:hidratrack/app_rotas.dart';
import 'package:hidratrack/Telas/TeladashboardTreinador.dart';
import 'package:hidratrack/Telas/TelacriarEquipe.dart';
import 'package:hidratrack/Telas/TeladadosEquipe.dart';
import 'package:hidratrack/Telas/TeladadosAtletas.dart';
import 'package:hidratrack/Telas/Telagraficos.dart';
import 'package:hidratrack/Telas/TeladashboardAtleta.dart';
import 'package:hidratrack/Telas/TelainiciarTreino.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HidraTrack',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const TelaSessaoAtiva(),
      routes: {
        AppRotas.dashboardTreinador: (context) =>
            const TelaDashboardTreinador(),
        '/equipes': (context) =>
            const TelaDashboardTreinador(initialTab: 0, initialNavIndex: 1),
        '/atletas': (context) => const TelaDashboardTreinador(initialTab: 1),
        '/criar-equipe': (context) => const TelacriarEquipe(),
        '/dados-equipe': (context) => const TeladadosEquipe(),
        '/dados-atleta': (context) => const TeladadosAtletas(),
        '/graficos': (context) => const Telagraficos(),
        AppRotas.iniciarTreino: (context) => const TelaIniciarTreino(),
        AppRotas.dashboardAtleta: (context) => TelaDashboardAtleta(
          data: AtletaDashboardData.fromHydrationMetrics(
            athleteName: 'Ricardo',
            sweatRate: 1.2,
            recommendedIntakeLiters: 2.4,
            recommendedWindow: const Duration(hours: 3),
            completedPercent: 0.45,
            averageRate: 0.8,
            variationPercent: 12.5,
          ),
        ),
      },
    );
  }
}
