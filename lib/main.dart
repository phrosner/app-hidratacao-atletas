import 'package:flutter/material.dart';
import 'package:hidratrack/app_rotas.dart';
import 'package:hidratrack/Telas/TeladashboardTreinador.dart';
import 'package:hidratrack/Telas/TelacriarEquipe.dart';
import 'package:hidratrack/Telas/TeladadosEquipe.dart';
import 'package:hidratrack/Telas/TeladadosAtletas.dart';
import 'package:hidratrack/Telas/Telagraficos.dart';
import 'package:hidratrack/Modelos/AtletaDashboardWithBackend.dart';
import 'package:hidratrack/Telas/Telahistorico.dart';
import 'package:hidratrack/Telas/TelainiciarTreino.dart';
import 'package:hidratrack/Telas/Telalogin.dart';
import 'package:hidratrack/Telas/Telaperfil.dart';
import 'package:hidratrack/Telas/TelaTaxaMedia.dart';
import 'package:hidratrack/Telas/TelastatsAtleta.dart';
import 'package:hidratrack/Telas/TelaSessaoAtiva.dart';
import 'package:hidratrack/Telas/Pos_sessao.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const String _fontFamily = 'Roboto';

  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData.light(useMaterial3: true);

    return MaterialApp(
      title: 'HidraTrack',
      debugShowCheckedModeBanner: false,
      theme: baseTheme.copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFB32025),
          brightness: Brightness.light,
        ),
        textTheme: baseTheme.textTheme.apply(fontFamily: _fontFamily),
        primaryTextTheme: baseTheme.primaryTextTheme.apply(
          fontFamily: _fontFamily,
        ),
      ),
      home: const Telalogin(),
      routes: {
        AppRotas.dashboardTreinador: (context) =>
            const TelaDashboardTreinador(),
        '/equipes': (context) => const TelaDashboardTreinador(initialTab: 0),
        '/atletas': (context) => const TelaDashboardTreinador(initialTab: 1),
        '/criar-equipe': (context) => const TelacriarEquipe(),
        '/dados-equipe': (context) => const TeladadosEquipe(),
        '/dados-atleta': (context) => const TeladadosAtletas(),
        '/graficos': (context) => const Telagraficos(),
        AppRotas.iniciarTreino: (context) => const TelaIniciarTreino(),
        AppRotas.sessaoAtiva: (context) => const TelaSessaoAtiva(),
        AppRotas.posSessao: (context) => const PosSessao(),
        AppRotas.historicoAtleta: (context) => const TelaHistorico(),
        AppRotas.taxaMedia: (context) => const TelaTaxaMedia(),
        AppRotas.statsAtleta: (context) => const TelastatsAtleta(),
        AppRotas.perfilAtleta: (context) => const Telaperfil(),
        AppRotas.dashboardAtleta: (context) {
          final token = ModalRoute.of(context)?.settings.arguments as String?;
          return TelaDashboardAtletaComBackend(tokenAtleta: token);
        },
      },
    );
  }
}
