package br.com.hidratrack.HidraTrack.controller;

import br.com.hidratrack.HidraTrack.dto.SessaoTreinoDTO;
import br.com.hidratrack.HidraTrack.model.Usuario;
import br.com.hidratrack.HidraTrack.service.SessaoTreinoService;
import br.com.hidratrack.HidraTrack.service.UsuarioService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

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

    @GetMapping("/dashboard")
    public ResponseEntity<?> obterDashboard(@RequestHeader("Authorization") String token) {
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
            String clima = "Nao informado";

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
                        if (ultimaSessao.getConsumos() != null
                                && !ultimaSessao.getConsumos().isEmpty()
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
                        clima = ultimaSessao.getUmidadeRelativa() > 70 ? "Umido" : "Ameno";
                    }
                }
            }

            Map<String, Object> dashboard = new HashMap<>();
            dashboard.put("nomeAtleta", nomeAtleta);
            dashboard.put("taxaSuor", taxaSuor);
            dashboard.put("hidratacaoRecomendada", hidratacaoRecomendada);
            dashboard.put("saudeGeral", "Otimo");
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

    @GetMapping("/historico")
    public ResponseEntity<?> obterHistorico(
            @RequestParam(required = false) Integer dias,
            @RequestHeader("Authorization") String token) {
        try {
            final Optional<Usuario> usuarioLogado = extrairUsuarioDoToken(token);
            if (usuarioLogado.isEmpty()) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                        .body(Map.of("erro", "Token invalido ou nao informado"));
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
                item.put("data", sessao.getDataInicio() != null ? sessao.getDataInicio().toString() : LocalDateTime.now().toString());
                item.put("tipoTreino", sessao.getStatus() != null
                        ? formatTipoTreino(sessao.getStatus())
                        : "Sessao de treino");
                item.put("volumeLitros", Math.round(volumeLitros * 100.0) / 100.0);
                item.put("icone", escolherIcone(sessao));
                return item;
            }).collect(Collectors.toList());

            return ResponseEntity.ok(historico);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("erro", "Erro ao obter historico: " + e.getMessage()));
        }
    }

    private String formatTipoTreino(String status) {
        return switch (status) {
            case "CONCLUIDA" -> "Treino de Intervalo";
            case "PAUSADA" -> "Treino parcial";
            case "CANCELADA" -> "Treino cancelado";
            default -> "Treino de sessao";
        };
    }

    private String escolherIcone(SessaoTreinoDTO sessao) {
        return switch (sessao.getStatus() != null ? sessao.getStatus() : "") {
            case "PAUSADA" -> "access_time";
            case "CANCELADA" -> "block";
            default -> "bolt";
        };
    }

    @GetMapping("/perfil")
    public ResponseEntity<?> obterPerfil(@RequestHeader("Authorization") String token) {
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

    @GetMapping("/consumo")
    public ResponseEntity<?> obterHistoricoConsumo(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime dataInicio,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime dataFim,
            @RequestHeader("Authorization") String token) {
        try {
            List<Map<String, Object>> consumos = List.of(
                    Map.of("dataHora", LocalDateTime.now().minusHours(3), "mlConsumidos", 500),
                    Map.of("dataHora", LocalDateTime.now().minusHours(2), "mlConsumidos", 400),
                    Map.of("dataHora", LocalDateTime.now().minusHours(1), "mlConsumidos", 300)
            );

            return ResponseEntity.ok(consumos);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("erro", "Erro ao obter consumo: " + e.getMessage()));
        }
    }

    @PostMapping("/consumo")
    public ResponseEntity<?> registrarConsumo(
            @RequestBody Map<String, Object> consumoData,
            @RequestHeader("Authorization") String token) {
        try {
            Double mlConsumidos = ((Number) consumoData.get("mlConsumidos")).doubleValue();

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

    @GetMapping("/sessoes/{sessaoId}")
    public ResponseEntity<?> obterMetricasSessao(
            @PathVariable Long sessaoId,
            @RequestHeader("Authorization") String token) {
        try {
            Map<String, Object> metricas = new HashMap<>();
            metricas.put("sessaoId", sessaoId);
            metricas.put("dataInicio", LocalDateTime.now().minusHours(1));
            metricas.put("duracao", 60);
            metricas.put("consumoAgua", 1.5);
            metricas.put("mediaHidratacao", 1.0);
            metricas.put("statusSaude", "Normal");

            return ResponseEntity.ok(metricas);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("erro", "Erro ao obter metricas: " + e.getMessage()));
        }
    }
}
