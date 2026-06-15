package br.com.hidratrack.HidraTrack.service;

import br.com.hidratrack.HidraTrack.model.Equipe;
import br.com.hidratrack.HidraTrack.model.EquipeAtleta;
import br.com.hidratrack.HidraTrack.model.SessaoTreino;
import br.com.hidratrack.HidraTrack.model.Usuario;
import br.com.hidratrack.HidraTrack.repository.EquipeAtletaRepository;
import br.com.hidratrack.HidraTrack.repository.SessaoTreinoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.time.Period;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class TreinadorService {

    @Autowired
    private EquipeService equipeService;

    @Autowired
    private EquipeAtletaRepository equipeAtletaRepository;

    @Autowired
    private HidratacaoService hidratacaoService;

    @Autowired
    private SessaoTreinoRepository sessaoTreinoRepository;

    public Map<String, Object> obterDashboard(Usuario gestor) {
        List<Equipe> equipes = equipeService.listarPorGestor(gestor.getId());
        List<EquipeAtleta> vinculos = equipeAtletaRepository.findByEquipeGestorId(gestor.getId());

        Set<Long> atletaIds = vinculos.stream()
                .map(v -> v.getAtleta().getId())
                .collect(Collectors.toSet());

        long atletasAtivos = vinculos.stream()
                .map(EquipeAtleta::getAtleta)
                .filter(a -> Boolean.TRUE.equals(a.getAtivo()))
                .count();

        String crescimento = calcularCrescimento(gestor.getId());

        Map<String, Object> clima = obterClimaLocal(vinculos);

        Map<String, Object> dashboard = new LinkedHashMap<>();
        dashboard.put("totalAtletas", atletasAtivos);
        dashboard.put("crescimentoAtletas", crescimento);
        dashboard.put("clima", clima);
        dashboard.put("equipes", equipes.stream()
                .map(equipeService::toEquipeDto)
                .collect(Collectors.toList()));
        dashboard.put("atletas", listarAtletasResumo(gestor.getId()));
        dashboard.put("alertas", listarAlertas(gestor.getId()));
        return dashboard;
    }

    private String calcularCrescimento(Long gestorId) {
        List<EquipeAtleta> vinculos = equipeAtletaRepository.findByEquipeGestorId(gestorId);
        if (vinculos.isEmpty()) {
            return "+0%";
        }

        LocalDateTime agora = LocalDateTime.now();
        LocalDateTime inicioMes = agora.withDayOfMonth(1).withHour(0).withMinute(0).withSecond(0);
        LocalDateTime inicioMesAnterior = inicioMes.minusMonths(1);

        long novosEsteMes = vinculos.stream()
                .filter(v -> v.getVinculadoEm() != null && !v.getVinculadoEm().isBefore(inicioMes))
                .count();

        long totalMesAnterior = vinculos.stream()
                .filter(v -> v.getVinculadoEm() != null && v.getVinculadoEm().isBefore(inicioMes))
                .count();

        if (totalMesAnterior == 0) {
            return novosEsteMes > 0 ? "+" + novosEsteMes * 100 + "%" : "+0%";
        }

        int percentual = (int) Math.round((novosEsteMes * 100.0) / totalMesAnterior);
        return (percentual >= 0 ? "+" : "") + percentual + "%";
    }

    private Map<String, Object> obterClimaLocal(List<EquipeAtleta> vinculos) {
        Map<String, Object> clima = new LinkedHashMap<>();
        clima.put("temperatura", 0.0);
        clima.put("umidade", 0);
        clima.put("condicao", "Sem dados");

        for (EquipeAtleta vinculo : vinculos) {
            List<SessaoTreino> sessoes = sessaoTreinoRepository
                    .findByAtletaIdOrderByDataInicioDesc(vinculo.getAtleta().getId());
            if (!sessoes.isEmpty()) {
                SessaoTreino ultima = sessoes.get(0);
                if (ultima.getTemperaturaAmbiente() != null) {
                    clima.put("temperatura", ultima.getTemperaturaAmbiente());
                }
                if (ultima.getUmidadeRelativa() != null) {
                    int umidade = ultima.getUmidadeRelativa();
                    clima.put("umidade", umidade);
                    String condicao = umidade > 70 ? "Úmido" : umidade < 40 ? "Seco" : "Ameno";
                    clima.put("condicao", condicao);
                }
                return clima;
            }
        }
        return clima;
    }

    public List<Map<String, Object>> listarAtletasResumo(Long gestorId) {
        Map<Long, Map<String, Object>> unicos = new LinkedHashMap<>();
        for (EquipeAtleta vinculo : equipeAtletaRepository.findByEquipeGestorId(gestorId)) {
            Long atletaId = vinculo.getAtleta().getId();
            if (!unicos.containsKey(atletaId)) {
                unicos.put(atletaId, toAtletaListItem(vinculo));
            }
        }
        return unicos.values().stream()
                .sorted(Comparator.comparing(m -> m.get("nome").toString()))
                .collect(Collectors.toList());
    }

    private Map<String, Object> toAtletaListItem(EquipeAtleta vinculo) {
        Usuario atleta = vinculo.getAtleta();
        Equipe equipe = vinculo.getEquipe();
        Map<String, Object> hidratacao = hidratacaoService.resumoHidratacao(atleta.getId());

        Map<String, Object> item = new LinkedHashMap<>();
        item.put("id", atleta.getId());
        item.put("nome", atleta.getNome() != null ? atleta.getNome() : atleta.getUsuario());
        item.put("categoria", equipe.getCategoria() != null ? equipe.getCategoria().toUpperCase() : "");
        item.put("status", hidratacao.get("status"));
        item.put("hidratacao", hidratacao.get("hidratacao"));
        item.put("equipeId", equipe.getId());
        item.put("equipeNome", equipe.getNome());
        return item;
    }

    public List<Map<String, Object>> listarAlertas(Long gestorId) {
        return equipeAtletaRepository.findByEquipeGestorId(gestorId).stream()
                .map(vinculo -> {
                    Usuario atleta = vinculo.getAtleta();
                    Equipe equipe = vinculo.getEquipe();
                    int hidratacao = hidratacaoService.calcularPercentualHidratacao(atleta.getId());
                    String status = hidratacaoService.calcularStatusAtleta(atleta.getId());

                    if (!"DESIDRATACAO CRITICA".equals(status) && !"ATENCAO".equals(status)) {
                        return null;
                    }

                    Map<String, Object> alerta = new LinkedHashMap<>();
                    String nome = atleta.getNome() != null ? atleta.getNome() : atleta.getUsuario();
                    String categoria = equipe.getCategoria() != null ? equipe.getCategoria() : "";
                    alerta.put("id", atleta.getId());
                    alerta.put("nome", nome + (categoria.isBlank() ? "" : " (" + categoria + ")"));
                    alerta.put("situacao", status.equals("DESIDRATACAO CRITICA")
                            ? "Desidratacao critica" : "Atencao");
                    alerta.put("descricao", hidratacao + "% hidratacao");
                    alerta.put("iconType", "DESIDRATACAO CRITICA".equals(status) ? "alerta" : "info");
                    return alerta;
                })
                .filter(Objects::nonNull)
                .limit(10)
                .collect(Collectors.toList());
    }

    public Optional<Map<String, Object>> obterAtletaDetalhe(Long gestorId, Long atletaId) {
        List<EquipeAtleta> vinculos = equipeAtletaRepository.findByEquipeGestorId(gestorId);
        Optional<EquipeAtleta> vinculo = vinculos.stream()
                .filter(v -> v.getAtleta().getId().equals(atletaId))
                .findFirst();

        if (vinculo.isEmpty()) {
            return Optional.empty();
        }

        Usuario atleta = vinculo.get().getAtleta();
        Equipe equipe = vinculo.get().getEquipe();
        Map<String, Object> hidratacao = hidratacaoService.resumoHidratacao(atleta.getId());

        Map<String, Object> detalhe = new LinkedHashMap<>();
        detalhe.put("id", atleta.getId());
        detalhe.put("nome", atleta.getNome() != null ? atleta.getNome() : atleta.getUsuario());
        detalhe.put("idade", calcularIdade(atleta));
        detalhe.put("genero", atleta.getGenero() != null ? atleta.getGenero() : "Nao informado");
        detalhe.put("modalidade", atleta.getEsporte() != null ? atleta.getEsporte() : equipe.getModalidade());
        detalhe.put("equipe", equipe.getNome());
        detalhe.put("categoria", equipe.getCategoria());
        detalhe.put("nivelTreino", atleta.getNivelTreino() != null ? atleta.getNivelTreino() : "Intermediario");
        detalhe.put("peso", atleta.getPeso());
        detalhe.put("altura", atleta.getAltura());
        detalhe.put("hidratacao", hidratacao.get("hidratacao"));
        detalhe.put("status", hidratacao.get("status"));
        return Optional.of(detalhe);
    }

    private Integer calcularIdade(Usuario atleta) {
        if (atleta.getDataNascimento() != null) {
            return Period.between(atleta.getDataNascimento(), java.time.LocalDate.now()).getYears();
        }
        return atleta.getIdade();
    }

    public List<Map<String, Object>> buscarAtletasDisponiveis(Long gestorId, Long equipeId, String query) {
        if (query == null || query.isBlank()) {
            return List.of();
        }

        List<EquipeAtleta> todosVinculos = equipeAtletaRepository.findByEquipeGestorId(gestorId);
        Set<Long> jaNaEquipe = todosVinculos.stream()
                .filter(v -> v.getEquipe().getId().equals(equipeId))
                .map(v -> v.getAtleta().getId())
                .collect(Collectors.toSet());

        String q = query.trim().toLowerCase();
        return todosVinculos.stream()
                .filter(v -> !v.getEquipe().getId().equals(equipeId))
                .filter(v -> {
                    String nome = v.getAtleta().getNome() != null
                            ? v.getAtleta().getNome().toLowerCase()
                            : v.getAtleta().getUsuario().toLowerCase();
                    return nome.contains(q);
                })
                .map(v -> {
                    Map<String, Object> item = new LinkedHashMap<>();
                    item.put("id", v.getAtleta().getId());
                    item.put("nome", v.getAtleta().getNome() != null
                            ? v.getAtleta().getNome() : v.getAtleta().getUsuario());
                    item.put("categoria", v.getEquipe().getCategoria());
                    item.put("equipeOrigem", v.getEquipe().getNome());
                    return item;
                })
                .filter(item -> !jaNaEquipe.contains(item.get("id")))
                .distinct()
                .limit(20)
                .collect(Collectors.toList());
    }
}
