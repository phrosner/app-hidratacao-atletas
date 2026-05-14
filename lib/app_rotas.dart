/// Rotas nomeadas usadas no app (evita strings espalhadas e documenta o fluxo).
abstract final class AppRotas {
  /// Tela principal de **treinador e nutricionista** — mesmas telas e funções (`TelaDAshboard`).
  static const String dashboardTreinador = '/dashboard';

  /// Fluxo exclusivo do atleta.
  static const String dashboardAtleta = '/dashboard-atleta';
}
