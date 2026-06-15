import 'package:flutter/material.dart';
import 'package:hidratrack/Modelos/AtletaDashboardWithBackend.dart';
import 'package:hidratrack/Servicos/AuthStorage.dart';
import 'package:hidratrack/Telas/TeladashboardTreinador.dart';
import 'package:hidratrack/Telas/Telalogin.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    if (!AuthStorage.isAuthenticated) {
      return const Telalogin();
    }

    final tipo = AuthStorage.tipoUsuario.toUpperCase();
    if (tipo == 'TREINADOR' || tipo == 'NUTRICIONISTA') {
      return const TelaDashboardTreinador();
    }

    return TelaDashboardAtletaComBackend(tokenAtleta: AuthStorage.token);
  }
}
