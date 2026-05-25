/// Rotas nomeadas usadas no app.
abstract final class AppRotas {
  /// Tela principal de treinador e nutricionista.
  static const String dashboardTreinador = '/dashboard';

  /// Fluxo exclusivo do atleta.
  static const String dashboardAtleta = '/dashboard-atleta';

  /// Inicio de uma nova sessao de treino do atleta.
  static const String iniciarTreino = '/iniciar-treino';

  /// Registro pos-sessao do atleta.
  static const String posSessao = '/pos-sessao';

  /// Historico de sessoes do atleta.
  static const String historicoAtleta = '/historico-atleta';

  /// Stats e metricas de desempenho do atleta.
  static const String statsAtleta = '/stats-atleta';
}
