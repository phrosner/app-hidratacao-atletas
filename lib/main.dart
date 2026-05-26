import 'package:flutter/material.dart';
import 'package:hidratrack/app_rotas.dart';
import 'package:hidratrack/Telas/TeladashboardTreinador.dart';
import 'package:hidratrack/Telas/Telalogin.dart';
import 'package:hidratrack/Telas/TelacriarEquipe.dart';
import 'package:hidratrack/Telas/TeladadosEquipe.dart';
import 'package:hidratrack/Telas/TeladadosAtletas.dart';
import 'package:hidratrack/Telas/Telagraficos.dart';
import 'package:hidratrack/Telas/TeladashboardAtleta.dart';
import 'package:hidratrack/Telas/TelainiciarTreino.dart';
<<<<<<< HEAD
import 'package:hidratrack/Telas/TelaTaxaMedia.dart';
import 'package:hidratrack/Telas/TelaSessãoAtiva.dart';
=======
import 'package:hidratrack/Telas/Pos_sessao.dart';
import 'package:hidratrack/Telas/Telahistorico.dart';
import 'package:hidratrack/Telas/TelastatsAtleta.dart';
>>>>>>> 1a4012a5f06ba933925f63d0dff0ce46d853eb46

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
<<<<<<< HEAD
      home: const TelaTaxaMedia(),
=======
      home: const Telalogin(),
>>>>>>> 1a4012a5f06ba933925f63d0dff0ce46d853eb46
      routes: {
        '/login': (context) => const Telalogin(),
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
<<<<<<< HEAD
        AppRotas.taxaMedia: (context) => const TelaTaxaMedia(),
=======
        AppRotas.posSessao: (context) => const PosSessao(),
        AppRotas.historicoAtleta: (context) => const TelaHistorico(),
        AppRotas.statsAtleta: (context) => const TelastatsAtleta(),
>>>>>>> 1a4012a5f06ba933925f63d0dff0ce46d853eb46
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
