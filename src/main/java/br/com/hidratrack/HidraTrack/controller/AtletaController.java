package br.com.hidratrack.HidraTrack.controller;

import br.com.hidratrack.HidraTrack.dto.SessaoTreinoDTO;
import br.com.hidratrack.HidraTrack.model.Usuario;
import br.com.hidratrack.HidraTrack.service.SessaoTreinoService;
import br.com.hidratrack.HidraTrack.service.UsuarioService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;
import java.util.List;

@RestController
@RequestMapping("/api/atletas")
@CrossOrigin(origins = "*")
public class AtletaController {

    @Autowired
    private UsuarioService usuarioService;

    @Autowired
    private SessaoTreinoService sessaoTreinoService;

    private Optional<Usuario> extrairUsuarioDoToken(String authorizationHeader) {
        if (authorizationHeader == null || !authorizationHeader.startsWith("Bearer ")) {
            return Optional.empty();
        }
        final String token = authorizationHeader.substring(7).trim();
        final String prefix = "dummy-token-";
        if (!token.startsWith(prefix)) {
            return Optional.empty();
        }
        try {
            final Long userId = Long.parseLong(token.substring(prefix.length()));
            return usuarioService.buscarPorId(userId);
        } catch (NumberFormatException e) {
            return Optional.empty();
        }
    }

    /**
     * Obter dados do dashboard do atleta autenticado
     * Retorna: nome do atleta, métricas de hidratação, sessões recentes
     */
    @GetMapping("/dashboard")
    public ResponseEntity<?> obterDashboard(
            @RequestHeader("Authorization") String token) {
        try {
            final Optional<Usuario> usuarioLogado = extrairUsuarioDoToken(token);
            final String nomeAtleta = usuarioLogado
                    .map(u -> u.getNome() != null && !u.getNome().isBlank() ? u.getNome() : u.getUsuario())
                    .orElse("Atleta");

            double taxaSuor = 0.0;
            double hidratacaoRecomendada = 0.0;
            double percentualConsumido = 0.0;
            double consumoMedio = 0.0;
            double temperatura = 0.0;
            String clima = "Não informado";

            if (usuarioLogado.isPresent()) {
                final Long atletaId = usuarioLogado.get().getId();
                final List<SessaoTreinoDTO> sessoes = sessaoTreinoService.obterSessoesAtleta(atletaId);
                if (!sessoes.isEmpty()) {
                    final SessaoTreinoDTO ultimaSessao = sessoes.get(0);
                    if (ultimaSessao.getStats() != null) {
                        if (ultimaSessao.getStats().getTaxaSudoroseMedia() != null) {
                            taxaSuor = ultimaSessao.getStats().getTaxaSudoroseMedia();
                        }
                        if (ultimaSessao.getStats().getRecomendacaoIntakeMax() != null) {
                            hidratacaoRecomendada = ultimaSessao.getStats().getRecomendacaoIntakeMax() / 1000.0;
                        }
                        if (ultimaSessao.getConsumos() != null && !ultimaSessao.getConsumos().isEmpty()
                                && ultimaSessao.getStats().getRecomendacaoIntakeMax() != null
                                && ultimaSessao.getStats().getRecomendacaoIntakeMax() > 0) {
                            double totalMl = ultimaSessao.getConsumos().stream()
                                    .mapToDouble(c -> c.getQuantidadeMl() != null ? c.getQuantidadeMl() : 0.0)
                                    .sum();
                            percentualConsumido = (totalMl / ultimaSessao.getStats().getRecomendacaoIntakeMax()) * 100.0;
                        }
                        if (ultimaSessao.getStats().getTaxaSudoroseMedia() != null) {
                            consumoMedio = ultimaSessao.getStats().getTaxaSudoroseMedia();
                        }
                    }
                    if (ultimaSessao.getTemperaturaAmbiente() != null) {
                        temperatura = ultimaSessao.getTemperaturaAmbiente();
                    }
                    if (ultimaSessao.getUmidadeRelativa() != null) {
                        clima = ultimaSessao.getUmidadeRelativa() > 70 ? "Úmido" : "Ameno";
                    }
                }
            }

            Map<String, Object> dashboard = new HashMap<>();
            dashboard.put("nomeAtleta", nomeAtleta);
            dashboard.put("taxaSuor", taxaSuor);
            dashboard.put("hidratacaoRecomendada", hidratacaoRecomendada);
            dashboard.put("saudeGeral", "Ótimo");
            dashboard.put("ultimaSessao", LocalDateTime.now().minusHours(2));
            dashboard.put("percentualConsumido", percentualConsumido);
            dashboard.put("consumoMedio", consumoMedio);
            dashboard.put("temperatura", temperatura);
            dashboard.put("clima", clima);

            return ResponseEntity.ok(dashboard);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("erro", "Erro ao obter dashboard: " + e.getMessage()));
        }
    }

    /**
     * Obter histórico de treino do atleta autenticado
     */
    @GetMapping("/historico")
    public ResponseEntity<?> obterHistorico(
            @RequestParam(required = false) Integer dias,
            @RequestHeader("Authorization") String token) {
        try {
            final Optional<Usuario> usuarioLogado = extrairUsuarioDoToken(token);
            if (usuarioLogado.isEmpty()) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                        .body(Map.of("erro", "Token inválido ou não informado"));
            }

            final Long atletaId = usuarioLogado.get().getId();
            final List<SessaoTreinoDTO> sessoes = sessaoTreinoService.obterHistoricoPorAtleta(atletaId, dias);

            final List<Map<String, Object>> historico = sessoes.stream().map(sessao -> {
                final double volumeLitros = sessao.getConsumos() == null
                        ? 0.0
                        : sessao.getConsumos().stream()
                                .mapToDouble(c -> c.getQuantidadeMl() != null ? c.getQuantidadeMl() : 0.0)
                                .sum() / 1000.0;

                final Map<String, Object> item = new HashMap<>();
                item.put("id", sessao.getId());
                item.put("data", sessao.getDataInicio().toString());
                item.put("tipoTreino", sessao.getStatus() != null
                        ? formatTipoTreino(sessao.getStatus())
                        : "Sessão de treino");
                item.put("volumeLitros", Math.round(volumeLitros * 100.0) / 100.0);
                item.put("icone", escolherIcone(sessao));
                return item;
            }).collect(Collectors.toList());

            return ResponseEntity.ok(historico);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("erro", "Erro ao obter histórico: " + e.getMessage()));
        }
    }

    private String formatTipoTreino(String status) {
        return switch (status) {
            case "CONCLUIDA" -> "Treino de Intervalo";
            case "PAUSADA" -> "Treino parcial";
            case "CANCELADA" -> "Treino cancelado";
            default -> "Treino de sessão";
        };
    }

    private String escolherIcone(SessaoTreinoDTO sessao) {
        return switch (sessao.getStatus()) {
            case "CONCLUIDA" -> "bolt";
            case "PAUSADA" -> "access_time";
            case "CANCELADA" -> "block";
            default -> "bolt";
        };
    }

    /**
     * Obter perfil do atleta autenticado
     */
    @GetMapping("/perfil")
    public ResponseEntity<?> obterPerfil(
            @RequestHeader("Authorization") String token) {
        try {
            final Optional<Usuario> usuarioLogado = extrairUsuarioDoToken(token);
            Map<String, Object> perfil = new HashMap<>();
            perfil.put("id", usuarioLogado.map(Usuario::getId).orElse(1L));
            perfil.put("nome", usuarioLogado
                    .map(u -> u.getNome() != null && !u.getNome().isBlank() ? u.getNome() : u.getUsuario())
                    .orElse("Atleta Silva"));
            perfil.put("email", usuarioLogado.map(Usuario::getEmail).orElse(""));
            perfil.put("peso", 75.5);
            perfil.put("altura", 180);
            perfil.put("idade", 25);
            perfil.put("esporte", "Futebol");
            perfil.put("nivelTreino", "Profissional");
            
            return ResponseEntity.ok(perfil);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("erro", "Erro ao obter perfil: " + e.getMessage()));
        }
    }

    /**
     * Obter histórico de consumo de água
     */
    @GetMapping("/consumo")
    public ResponseEntity<?> obterHistoricoConsumo(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime dataInicio,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime dataFim,
            @RequestHeader("Authorization") String token) {
        try {
            // TODO: Implementar busca real no banco de dados
            // TODO: Extrair userId do token
            
            List<Map<String, Object>> consumos = List.of(
                Map.of(
                    "dataHora", LocalDateTime.now().minusHours(3),
                    "mlConsumidos", 500
                ),
                Map.of(
                    "dataHora", LocalDateTime.now().minusHours(2),
                    "mlConsumidos", 400
                ),
                Map.of(
                    "dataHora", LocalDateTime.now().minusHours(1),
                    "mlConsumidos", 300
                )
            );
            
            return ResponseEntity.ok(consumos);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("erro", "Erro ao obter consumo: " + e.getMessage()));
        }
    }

    /**
     * Registrar novo consumo de água
     */
    @PostMapping("/consumo")
    public ResponseEntity<?> registrarConsumo(
            @RequestBody Map<String, Object> consumoData,
            @RequestHeader("Authorization") String token) {
        try {
            Double mlConsumidos = ((Number) consumoData.get("mlConsumidos")).doubleValue();
            String dataHora = (String) consumoData.get("dataHora");
            
            // TODO: Validar dados
            // TODO: Salvar no banco de dados
            // TODO: Extrair userId do token
            
            Map<String, Object> resposta = new HashMap<>();
            resposta.put("sucesso", true);
            resposta.put("mensagem", "Consumo registrado com sucesso");
            resposta.put("mlConsumidos", mlConsumidos);
            
            return ResponseEntity.status(HttpStatus.CREATED).body(resposta);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("erro", "Erro ao registrar consumo: " + e.getMessage()));
        }
    }

    /**
     * Obter métricas de uma sessão específica
     */
    @GetMapping("/sessoes/{sessaoId}")
    public ResponseEntity<?> obterMetricasSessao(
            @PathVariable Long sessaoId,
            @RequestHeader("Authorization") String token) {
        try {
            Map<String, Object> metricas = new HashMap<>();
            metricas.put("sessaoId", sessaoId);
            metricas.put("dataInicio", LocalDateTime.now().minusHours(1));
            metricas.put("duracao", 60); // minutos
            metricas.put("consumoAgua", 1.5); // litros
            metricas.put("mediaHidratacao", 1.0); // L/h
            metricas.put("statusSaude", "Normal");
            
            return ResponseEntity.ok(metricas);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("erro", "Erro ao obter métricas: " + e.getMessage()));
        }
    }
}
