package br.com.hidratrack.HidraTrack.service;

import br.com.hidratrack.HidraTrack.model.Equipe;
import br.com.hidratrack.HidraTrack.model.EquipeAtleta;
import br.com.hidratrack.HidraTrack.model.Usuario;
import br.com.hidratrack.HidraTrack.repository.EquipeAtletaRepository;
import br.com.hidratrack.HidraTrack.repository.EquipeRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.security.SecureRandom;
import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Service
@Transactional
public class EquipeService {

    private static final String CODIGO_CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    private static final SecureRandom RANDOM = new SecureRandom();

    @Autowired
    private EquipeRepository equipeRepository;

    @Autowired
    private EquipeAtletaRepository equipeAtletaRepository;

    @Autowired
    private HidratacaoService hidratacaoService;

    public String gerarCodigoEquipe() {
        String codigo;
        do {
            StringBuilder sb = new StringBuilder("HT-");
            for (int i = 0; i < 6; i++) {
                sb.append(CODIGO_CHARS.charAt(RANDOM.nextInt(CODIGO_CHARS.length())));
            }
            codigo = sb.toString();
        } while (equipeRepository.existsByCodigoEquipeIgnoreCase(codigo));
        return codigo;
    }

    public Equipe criarEquipe(Usuario gestor, String nome, String categoria, String modalidade, String descricao) {
        Equipe equipe = new Equipe();
        equipe.setNome(nome.trim());
        equipe.setCodigoEquipe(gerarCodigoEquipe());
        equipe.setCategoria(categoria);
        equipe.setModalidade(modalidade);
        equipe.setDescricao(descricao);
        equipe.setGestor(gestor);
        equipe.setCriadoEm(LocalDateTime.now());
        return equipeRepository.save(equipe);
    }

    public List<Equipe> listarPorGestor(Long gestorId) {
        return equipeRepository.findByGestorIdOrderByCriadoEmDesc(gestorId);
    }

    public Optional<Equipe> buscarPorIdEGestor(Long equipeId, Long gestorId) {
        return equipeRepository.findByIdAndGestorId(equipeId, gestorId);
    }

    public Optional<Equipe> buscarPorCodigo(String codigo) {
        return equipeRepository.findByCodigoEquipeIgnoreCase(codigo.trim());
    }

    public Equipe atualizarEquipe(Equipe equipe, String nome, String categoria, String modalidade, String descricao) {
        equipe.setNome(nome.trim());
        equipe.setCategoria(categoria);
        equipe.setModalidade(modalidade);
        equipe.setDescricao(descricao);
        return equipeRepository.save(equipe);
    }

    public void excluirEquipe(Equipe equipe) {
        List<EquipeAtleta> vinculos = equipeAtletaRepository.findByEquipeIdOrderByVinculadoEmDesc(equipe.getId());
        equipeAtletaRepository.deleteAll(vinculos);
        equipeRepository.delete(equipe);
    }

    public List<EquipeAtleta> listarAtletasDaEquipe(Long equipeId) {
        return equipeAtletaRepository.findByEquipeIdOrderByVinculadoEmDesc(equipeId);
    }

    public List<EquipeAtleta> listarAtletasDoGestor(Long gestorId) {
        return equipeAtletaRepository.findByEquipeGestorId(gestorId);
    }

    public void vincularAtleta(Equipe equipe, Usuario atleta) {
        if (equipeAtletaRepository.existsByEquipeIdAndAtletaId(equipe.getId(), atleta.getId())) {
            return;
        }
        EquipeAtleta vinculo = new EquipeAtleta();
        vinculo.setEquipe(equipe);
        vinculo.setAtleta(atleta);
        vinculo.setVinculadoEm(LocalDateTime.now());
        equipeAtletaRepository.save(vinculo);
    }

    public void desvincularAtleta(Long equipeId, Long atletaId) {
        equipeAtletaRepository.deleteByEquipeIdAndAtletaId(equipeId, atletaId);
    }

    public Map<String, Object> toEquipeDto(Equipe equipe) {
        List<EquipeAtleta> vinculos = listarAtletasDaEquipe(equipe.getId());
        List<Long> atletaIds = vinculos.stream()
                .map(v -> v.getAtleta().getId())
                .collect(Collectors.toList());

        double mediaHidratacao = hidratacaoService.mediaHidratacaoEquipe(atletaIds);

        List<String> previewNomes = vinculos.stream()
                .limit(3)
                .map(v -> v.getAtleta().getNome() != null ? v.getAtleta().getNome() : v.getAtleta().getUsuario())
                .collect(Collectors.toList());

        Map<String, Object> dto = new LinkedHashMap<>();
        dto.put("id", equipe.getId());
        dto.put("nome", equipe.getNome());
        dto.put("status", equipe.getModalidade() != null ? equipe.getModalidade().toUpperCase() : "ATIVA");
        dto.put("numeroAtletas", vinculos.size());
        dto.put("percentualHidratacao", mediaHidratacao);
        dto.put("codigoEquipe", equipe.getCodigoEquipe());
        dto.put("categoria", equipe.getCategoria());
        dto.put("modalidade", equipe.getModalidade());
        dto.put("descricao", equipe.getDescricao());
        dto.put("atletasIds", atletaIds);
        dto.put("atletasPreview", previewNomes);
        return dto;
    }

    public Map<String, Object> toEquipeDetalheDto(Equipe equipe) {
        Map<String, Object> dto = toEquipeDto(equipe);

        List<Map<String, Object>> atletas = listarAtletasDaEquipe(equipe.getId()).stream()
                .map(v -> {
                    Usuario atleta = v.getAtleta();
                    Map<String, Object> item = new LinkedHashMap<>();
                    item.put("id", atleta.getId());
                    item.put("nome", atleta.getNome() != null ? atleta.getNome() : atleta.getUsuario());
                    item.put("categoria", equipe.getCategoria() != null ? equipe.getCategoria().toUpperCase() : "");
                    item.put("nivelTreino", atleta.getNivelTreino());
                    return item;
                })
                .collect(Collectors.toList());

        dto.put("atletas", atletas);
        return dto;
    }
}
