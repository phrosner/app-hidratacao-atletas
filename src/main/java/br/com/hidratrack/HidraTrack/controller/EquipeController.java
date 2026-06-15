package br.com.hidratrack.HidraTrack.controller;

import br.com.hidratrack.HidraTrack.model.Equipe;
import br.com.hidratrack.HidraTrack.model.Usuario;
import br.com.hidratrack.HidraTrack.repository.EquipeAtletaRepository;
import br.com.hidratrack.HidraTrack.service.EquipeService;
import br.com.hidratrack.HidraTrack.service.UsuarioService;
import br.com.hidratrack.HidraTrack.util.AuthTokenUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/equipes")
@CrossOrigin(origins = "*")
public class EquipeController {

    @Autowired
    private EquipeService equipeService;

    @Autowired
    private UsuarioService usuarioService;

    @Autowired
    private EquipeAtletaRepository equipeAtletaRepository;

    private Optional<Usuario> validarGestor(String authorizationHeader) {
        Optional<Usuario> usuario = AuthTokenUtil.extrairUsuario(authorizationHeader, usuarioService);
        if (usuario.isEmpty() || !AuthTokenUtil.isGestor(usuario.get())) {
            return Optional.empty();
        }
        return usuario;
    }

    @GetMapping
    public ResponseEntity<?> listarEquipes(@RequestHeader("Authorization") String token) {
        Optional<Usuario> gestor = validarGestor(token);
        if (gestor.isEmpty()) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Map.of("erro", "Acesso negado"));
        }
        List<Map<String, Object>> equipes = equipeService.listarPorGestor(gestor.get().getId()).stream()
                .map(equipeService::toEquipeDto)
                .collect(Collectors.toList());
        return ResponseEntity.ok(equipes);
    }

    @PostMapping
    public ResponseEntity<?> criarEquipe(
            @RequestBody Map<String, Object> dados,
            @RequestHeader("Authorization") String token) {
        Optional<Usuario> gestor = validarGestor(token);
        if (gestor.isEmpty()) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Map.of("erro", "Acesso negado"));
        }

        String nome = dados.get("nome") != null ? dados.get("nome").toString().trim() : "";
        if (nome.isBlank()) {
            return ResponseEntity.badRequest().body(Map.of("erro", "Nome da equipe é obrigatório"));
        }

        String categoria = dados.get("categoria") != null ? dados.get("categoria").toString() : "";
        String modalidade = dados.get("modalidade") != null ? dados.get("modalidade").toString() : "";
        String descricao = dados.get("descricao") != null ? dados.get("descricao").toString() : "";

        Equipe equipe = equipeService.criarEquipe(gestor.get(), nome, categoria, modalidade, descricao);
        return ResponseEntity.status(HttpStatus.CREATED).body(equipeService.toEquipeDto(equipe));
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> obterEquipe(
            @PathVariable Long id,
            @RequestHeader("Authorization") String token) {
        Optional<Usuario> gestor = validarGestor(token);
        if (gestor.isEmpty()) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Map.of("erro", "Acesso negado"));
        }

        Optional<Equipe> equipe = equipeService.buscarPorIdEGestor(id, gestor.get().getId());
        if (equipe.isEmpty()) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(Map.of("erro", "Equipe não encontrada"));
        }
        return ResponseEntity.ok(equipeService.toEquipeDetalheDto(equipe.get()));
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> atualizarEquipe(
            @PathVariable Long id,
            @RequestBody Map<String, Object> dados,
            @RequestHeader("Authorization") String token) {
        Optional<Usuario> gestor = validarGestor(token);
        if (gestor.isEmpty()) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Map.of("erro", "Acesso negado"));
        }

        Optional<Equipe> equipeOpt = equipeService.buscarPorIdEGestor(id, gestor.get().getId());
        if (equipeOpt.isEmpty()) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(Map.of("erro", "Equipe não encontrada"));
        }

        String nome = dados.get("nome") != null ? dados.get("nome").toString().trim() : equipeOpt.get().getNome();
        String categoria = dados.get("categoria") != null ? dados.get("categoria").toString() : equipeOpt.get().getCategoria();
        String modalidade = dados.get("modalidade") != null ? dados.get("modalidade").toString() : equipeOpt.get().getModalidade();
        String descricao = dados.get("descricao") != null ? dados.get("descricao").toString() : equipeOpt.get().getDescricao();

        Equipe atualizada = equipeService.atualizarEquipe(equipeOpt.get(), nome, categoria, modalidade, descricao);
        return ResponseEntity.ok(equipeService.toEquipeDetalheDto(atualizada));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> excluirEquipe(
            @PathVariable Long id,
            @RequestHeader("Authorization") String token) {
        Optional<Usuario> gestor = validarGestor(token);
        if (gestor.isEmpty()) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Map.of("erro", "Acesso negado"));
        }

        Optional<Equipe> equipeOpt = equipeService.buscarPorIdEGestor(id, gestor.get().getId());
        if (equipeOpt.isEmpty()) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(Map.of("erro", "Equipe não encontrada"));
        }

        equipeService.excluirEquipe(equipeOpt.get());
        return ResponseEntity.ok(Map.of("sucesso", true));
    }

    @PostMapping("/{id}/atletas/{atletaId}")
    public ResponseEntity<?> adicionarAtleta(
            @PathVariable Long id,
            @PathVariable Long atletaId,
            @RequestHeader("Authorization") String token) {
        Optional<Usuario> gestor = validarGestor(token);
        if (gestor.isEmpty()) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Map.of("erro", "Acesso negado"));
        }

        Optional<Equipe> equipeOpt = equipeService.buscarPorIdEGestor(id, gestor.get().getId());
        if (equipeOpt.isEmpty()) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(Map.of("erro", "Equipe não encontrada"));
        }

        Optional<Usuario> atletaOpt = usuarioService.buscarPorId(atletaId);
        if (atletaOpt.isEmpty() || atletaOpt.get().getTipoUsuario() != Usuario.TipoUsuario.ATLETA) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(Map.of("erro", "Atleta não encontrado"));
        }

        boolean pertenceAoGestor = equipeAtletaRepository.findByEquipeGestorId(gestor.get().getId()).stream()
                .anyMatch(v -> v.getAtleta().getId().equals(atletaId));
        if (!pertenceAoGestor) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                    .body(Map.of("erro", "Atleta não pertence às suas equipes"));
        }

        equipeService.vincularAtleta(equipeOpt.get(), atletaOpt.get());
        return ResponseEntity.ok(equipeService.toEquipeDetalheDto(equipeOpt.get()));
    }

    @DeleteMapping("/{id}/atletas/{atletaId}")
    public ResponseEntity<?> removerAtleta(
            @PathVariable Long id,
            @PathVariable Long atletaId,
            @RequestHeader("Authorization") String token) {
        Optional<Usuario> gestor = validarGestor(token);
        if (gestor.isEmpty()) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Map.of("erro", "Acesso negado"));
        }

        Optional<Equipe> equipeOpt = equipeService.buscarPorIdEGestor(id, gestor.get().getId());
        if (equipeOpt.isEmpty()) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(Map.of("erro", "Equipe não encontrada"));
        }

        equipeService.desvincularAtleta(id, atletaId);
        return ResponseEntity.ok(equipeService.toEquipeDetalheDto(equipeOpt.get()));
    }

    @GetMapping("/validar/{codigo}")
    public ResponseEntity<?> validarCodigo(@PathVariable String codigo) {
        Optional<Equipe> equipe = equipeService.buscarPorCodigo(codigo);
        if (equipe.isEmpty()) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(Map.of("valido", false, "erro", "Código de equipe inválido"));
        }
        return ResponseEntity.ok(Map.of(
                "valido", true,
                "nomeEquipe", equipe.get().getNome(),
                "codigoEquipe", equipe.get().getCodigoEquipe()
        ));
    }
}
