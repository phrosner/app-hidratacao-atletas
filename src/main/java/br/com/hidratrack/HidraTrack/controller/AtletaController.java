package br.com.hidratrack.HidraTrack.controller;

import br.com.hidratrack.HidraTrack.dto.SessaoTreinoDTO;
import br.com.hidratrack.HidraTrack.dto.StatsSessaoDTO;
import br.com.hidratrack.HidraTrack.service.StatsService;
import br.com.hidratrack.HidraTrack.model.ConsumoAgua;
import br.com.hidratrack.HidraTrack.model.SessaoTreino;
import br.com.hidratrack.HidraTrack.model.Usuario;
import br.com.hidratrack.HidraTrack.repository.ConsumoAguaRepository;
import br.com.hidratrack.HidraTrack.repository.EquipeAtletaRepository;
import br.com.hidratrack.HidraTrack.repository.SessaoTreinoRepository;
import br.com.hidratrack.HidraTrack.service.SessaoTreinoService;
import br.com.hidratrack.HidraTrack.service.UsuarioService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.io.PrintWriter;
import java.io.StringWriter;
import java.time.Duration;
import java.time.LocalDateTime;
import java.time.OffsetDateTime;
import java.time.format.DateTimeParseException;
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

    @Autowired
    private ConsumoAguaRepository consumoAguaRepository;

    @Autowired
    private SessaoTreinoRepository sessaoTreinoRepository;

    @Autowired
    private StatsService statsService;

    @Autowired
    private EquipeAtletaRepository equipeAtletaRepository;

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
            double percentualVariacao = 0.0;
            Long ultimaSessaoId = null;
            String ultimaSessaoStatus = "DESCONHECIDO";
            double temperatura = 0.0;
            String clima = "Não informado";
            LocalDateTime ultimaSessaoData = null;

            if (usuarioLogado.isPresent()) {
                final Long atletaId = usuarioLogado.get().getId();
                final List<SessaoTreinoDTO> sessoes = sessaoTreinoService.obterSessoesAtleta(atletaId);
                if (!sessoes.isEmpty()) {
                    final SessaoTreinoDTO ultimaSessao = sessoes.get(0);
                    StatsSessaoDTO stats = ultimaSessao.getStats();
                    if (stats == null && ultimaSessao.getId() != null) {
                        stats = statsService.obterStats(ultimaSessao.getId());
                    }

                    if (stats != null) {
                        if (stats.getTaxaSudoreseMedia() != null) {
                            taxaSuor = stats.getTaxaSudoreseMedia();
                        }
                        if (stats.getRecomendacaoIntakeMax() != null) {
                            hidratacaoRecomendada = stats.getRecomendacaoIntakeMax() / 1000.0;
                        }
                        if (ultimaSessao.getConsumos() != null && !ultimaSessao.getConsumos().isEmpty()
                                && stats.getRecomendacaoIntakeMax() != null
                                && stats.getRecomendacaoIntakeMax() > 0) {
                            double totalMl = ultimaSessao.getConsumos().stream()
                                    .mapToDouble(c -> c.getQuantidadeMl() != null ? c.getQuantidadeMl() : 0.0)
                                    .sum();
                            percentualConsumido = (totalMl / stats.getRecomendacaoIntakeMax()) * 100.0;
                        }
                        if (stats.getTaxaSudoreseMedia() != null) {
                            consumoMedio = stats.getTaxaSudoreseMedia();
                        }
                        if (stats.getVariacaoSudorese() != null) {
                            percentualVariacao = stats.getVariacaoSudorese();
                        }
                    }
                    if (ultimaSessao.getTemperaturaAmbiente() != null) {
                        temperatura = ultimaSessao.getTemperaturaAmbiente();
                    }
                    if (ultimaSessao.getUmidadeRelativa() != null) {
                        clima = ultimaSessao.getUmidadeRelativa() > 70 ? "Úmido" : "Ameno";
                    }
                    ultimaSessaoId = ultimaSessao.getId();
                    ultimaSessaoStatus = ultimaSessao.getStatus();
                    ultimaSessaoData = ultimaSessao.getDataInicio();
                }
            }

            Map<String, Object> dashboard = new HashMap<>();
            dashboard.put("nomeAtleta", nomeAtleta);
            dashboard.put("taxaSuor", taxaSuor);
            dashboard.put("hidratacaoRecomendada", hidratacaoRecomendada);
            dashboard.put("saudeGeral", "Ótimo");
            dashboard.put("ultimaSessao", ultimaSessaoData != null
                    ? ultimaSessaoData.toString()
                    : LocalDateTime.now().minusHours(2).toString());
            dashboard.put("ultimaSessaoId", ultimaSessaoId);
            dashboard.put("ultimaSessaoStatus", ultimaSessaoStatus);
            dashboard.put("percentualVariacao", percentualVariacao);
            dashboard.put("percentualConsumido", percentualConsumido);
            dashboard.put("consumoMedio", consumoMedio);
            dashboard.put("temperatura", temperatura);
            dashboard.put("clima", clima);

            return ResponseEntity.ok(dashboard);
        } catch (Exception e) {
            System.err.println("Erro ao obter dashboard: " + e.getMessage());
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of(
                            "erro", "Erro ao obter dashboard: " + e.getMessage(),
                            "excecao", e.getClass().getName(),
                            "stackTrace", getStackTrace(e)
                    ));
        }
    }

    private String getStackTrace(Throwable throwable) {
        StringWriter sw = new StringWriter();
        PrintWriter pw = new PrintWriter(sw);
        throwable.printStackTrace(pw);
        return sw.toString();
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

    private LocalDateTime parseDataHora(String dataHora) {
        try {
            return LocalDateTime.parse(dataHora);
        } catch (DateTimeParseException e) {
            return OffsetDateTime.parse(dataHora).toLocalDateTime();
        }
    }

    private int calcularTempoDecorrido(SessaoTreino sessao, LocalDateTime dataHora) {
        if (sessao.getDataInicio() == null || dataHora == null) {
            return 0;
        }
        final long minutos = Duration.between(sessao.getDataInicio(), dataHora).toMinutes();
        return (int) Math.max(minutos, 0);
    }

    /**
     * Obter perfil do atleta autenticado
     */
    @GetMapping("/perfil")
    public ResponseEntity<?> obterPerfil(
            @RequestHeader("Authorization") String token) {
        try {
            final Optional<Usuario> usuarioLogado = extrairUsuarioDoToken(token);
            if (usuarioLogado.isEmpty()) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                        .body(Map.of("erro", "Token inválido ou não informado"));
            }

            return ResponseEntity.ok(construirPerfil(usuarioLogado.get()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("erro", "Erro ao obter perfil: " + e.getMessage()));
        }
    }

    @PutMapping("/perfil")
    public ResponseEntity<?> atualizarPerfil(
            @RequestBody Map<String, Object> dados,
            @RequestHeader("Authorization") String token) {
        try {
            final Optional<Usuario> usuarioLogado = extrairUsuarioDoToken(token);
            if (usuarioLogado.isEmpty()) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                        .body(Map.of("erro", "Token inválido ou não informado"));
            }

            Usuario usuarioAtual = usuarioLogado.get();
            if (dados.get("nome") instanceof String nome && !nome.isBlank()) {
                usuarioAtual.setNome(nome.trim());
            }
            if (dados.get("email") instanceof String email && !email.isBlank()) {
                usuarioAtual.setEmail(email.trim());
            }
            if (dados.get("senha") instanceof String senha && !senha.isBlank()) {
                usuarioAtual.setSenha(senha);
            }
            if (dados.get("idade") != null) {
                final Object idadeValue = dados.get("idade");
                if (idadeValue instanceof Number number) {
                    usuarioAtual.setIdade(number.intValue());
                } else if (idadeValue instanceof String text && !text.isBlank()) {
                    try {
                        usuarioAtual.setIdade(Integer.parseInt(text.trim()));
                    } catch (NumberFormatException ignored) {
                    }
                }
            }
            if (dados.get("altura") != null) {
                final Object alturaValue = dados.get("altura");
                if (alturaValue instanceof Number number) {
                    usuarioAtual.setAltura(number.intValue());
                } else if (alturaValue instanceof String text && !text.isBlank()) {
                    try {
                        usuarioAtual.setAltura(Integer.parseInt(text.trim()));
                    } catch (NumberFormatException ignored) {
                    }
                }
            }
            if (dados.get("peso") != null) {
                final Object pesoValue = dados.get("peso");
                if (pesoValue instanceof Number number) {
                    usuarioAtual.setPeso(number.doubleValue());
                } else if (pesoValue instanceof String text && !text.isBlank()) {
                    try {
                        usuarioAtual.setPeso(Double.parseDouble(text.trim()));
                    } catch (NumberFormatException ignored) {
                    }
                }
            }
            if (dados.get("esporte") instanceof String esporte && !esporte.isBlank()) {
                usuarioAtual.setEsporte(esporte.trim());
            }
            if (dados.get("nivelTreino") instanceof String nivelTreino && !nivelTreino.isBlank()) {
                usuarioAtual.setNivelTreino(nivelTreino.trim());
            }
            if (dados.get("metaDiaria") instanceof String metaDiaria && !metaDiaria.isBlank()) {
                usuarioAtual.setMetaDiaria(metaDiaria.trim());
            }

            final Usuario usuarioSalvo = usuarioService.salvar(usuarioAtual);
            return ResponseEntity.ok(construirPerfil(usuarioSalvo));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("erro", "Erro ao atualizar perfil: " + e.getMessage()));
        }
    }

    private Map<String, Object> construirPerfil(Usuario usuario) {
        Map<String, Object> perfil = new HashMap<>();
        perfil.put("id", usuario.getId());
        perfil.put("nome", usuario.getNome() != null && !usuario.getNome().isBlank()
                ? usuario.getNome() : usuario.getUsuario());
        perfil.put("email", usuario.getEmail());
        perfil.put("peso", usuario.getPeso());
        perfil.put("altura", usuario.getAltura());
        perfil.put("idade", usuario.getIdade());
        perfil.put("genero", usuario.getGenero());
        perfil.put("dataNascimento", usuario.getDataNascimento());
        perfil.put("esporte", usuario.getEsporte());
        perfil.put("nivelTreino", usuario.getNivelTreino());
        perfil.put("metaDiaria", usuario.getMetaDiaria());

        equipeAtletaRepository.findByAtletaId(usuario.getId()).stream().findFirst()
                .ifPresent(vinculo -> {
                    perfil.put("equipe", vinculo.getEquipe().getNome());
                    perfil.put("categoria", vinculo.getEquipe().getCategoria());
                });

        return perfil;
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
            final Optional<Usuario> usuarioLogado = extrairUsuarioDoToken(token);
            if (usuarioLogado.isEmpty()) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                        .body(Map.of("erro", "Token inválido ou não informado"));
            }

            final Long atletaId = usuarioLogado.get().getId();
            final List<ConsumoAgua> consumos = consumoAguaRepository
                    .findBySessaoAtletaIdAndTimestampBetweenOrderByTimestampDesc(atletaId, dataInicio, dataFim);

            final List<Map<String, Object>> resposta = consumos.stream().map(consumo -> Map.<String, Object>of(
                    "sessaoId", consumo.getSessao().getId(),
                    "dataHora", consumo.getTimestamp(),
                    "mlConsumidos", consumo.getQuantidadeMl(),
                    "tipoLiquido", consumo.getTipoLiquido(),
                    "tempoDecorridoMinutos", consumo.getTempoDecorridoMinutos()
            )).collect(Collectors.toList());

            return ResponseEntity.ok(resposta);
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
            final Optional<Usuario> usuarioLogado = extrairUsuarioDoToken(token);
            if (usuarioLogado.isEmpty()) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                        .body(Map.of("erro", "Token inválido ou não informado"));
            }

            final Long atletaId = usuarioLogado.get().getId();
            final Object quantidadeObj = consumoData.get("mlConsumidos");
            final Object dataHoraObj = consumoData.get("dataHora");
            if (!(quantidadeObj instanceof Number) || dataHoraObj == null) {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                        .body(Map.of("erro", "mlConsumidos e dataHora são obrigatórios"));
            }

            final double mlConsumidos = ((Number) quantidadeObj).doubleValue();
            final String dataHoraStr = dataHoraObj.toString();
            final LocalDateTime dataHora = parseDataHora(dataHoraStr);
            final String tipoLiquido = consumoData.getOrDefault("tipoLiquido", "Água").toString();

            final Optional<SessaoTreino> sessaoAtiva = sessaoTreinoRepository
                    .findByAtletaIdOrderByDataInicioDesc(atletaId)
                    .stream()
                    .filter(sessao -> sessao.getStatus() == SessaoTreino.StatusSessao.EM_ANDAMENTO
                            || sessao.getStatus() == SessaoTreino.StatusSessao.PAUSADA)
                    .findFirst();

            if (sessaoAtiva.isEmpty()) {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                        .body(Map.of("erro", "Nenhuma sessão ativa encontrada para este atleta"));
            }

            ConsumoAgua consumo = new ConsumoAgua();
            consumo.setSessao(sessaoAtiva.get());
            consumo.setQuantidadeMl((int) Math.round(mlConsumidos));
            consumo.setTipoLiquido(tipoLiquido);
            consumo.setTimestamp(dataHora);
            consumo.setTempoDecorridoMinutos(calcularTempoDecorrido(sessaoAtiva.get(), dataHora));

            consumoAguaRepository.save(consumo);

            Map<String, Object> resposta = new HashMap<>();
            resposta.put("sucesso", true);
            resposta.put("mensagem", "Consumo registrado com sucesso");
            resposta.put("mlConsumidos", mlConsumidos);
            resposta.put("sessaoId", sessaoAtiva.get().getId());

            return ResponseEntity.status(HttpStatus.CREATED).body(resposta);
        } catch (DateTimeParseException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(Map.of("erro", "Formato de dataHora inválido"));
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
            final Optional<Usuario> usuarioLogado = extrairUsuarioDoToken(token);
            if (usuarioLogado.isEmpty()) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                        .body(Map.of("erro", "Token inválido ou não informado"));
            }

            final SessaoTreinoDTO sessao = sessaoTreinoService.obterSessao(sessaoId);
            if (sessao == null) {
                return ResponseEntity.notFound().build();
            }

            return ResponseEntity.ok(sessao);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("erro", "Erro ao obter métricas: " + e.getMessage()));
        }
    }
}
