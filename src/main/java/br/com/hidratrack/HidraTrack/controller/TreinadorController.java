package br.com.hidratrack.HidraTrack.controller;

import br.com.hidratrack.HidraTrack.model.Equipe;
import br.com.hidratrack.HidraTrack.model.Usuario;
import br.com.hidratrack.HidraTrack.service.EquipeService;
import br.com.hidratrack.HidraTrack.service.TreinadorService;
import br.com.hidratrack.HidraTrack.service.UsuarioService;
import br.com.hidratrack.HidraTrack.util.AuthTokenUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/treinadores")
@CrossOrigin(origins = "*")
public class TreinadorController {

    @Autowired
    private TreinadorService treinadorService;

    @Autowired
    private UsuarioService usuarioService;

    private Optional<Usuario> validarGestor(String authorizationHeader) {
        Optional<Usuario> usuario = AuthTokenUtil.extrairUsuario(authorizationHeader, usuarioService);
        if (usuario.isEmpty() || !AuthTokenUtil.isGestor(usuario.get())) {
            return Optional.empty();
        }
        return usuario;
    }

    @GetMapping("/dashboard")
    public ResponseEntity<?> obterDashboard(@RequestHeader("Authorization") String token) {
        Optional<Usuario> gestor = validarGestor(token);
        if (gestor.isEmpty()) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Map.of("erro", "Acesso negado"));
        }
        return ResponseEntity.ok(treinadorService.obterDashboard(gestor.get()));
    }

    @GetMapping("/atletas")
    public ResponseEntity<?> listarAtletas(@RequestHeader("Authorization") String token) {
        Optional<Usuario> gestor = validarGestor(token);
        if (gestor.isEmpty()) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Map.of("erro", "Acesso negado"));
        }
        return ResponseEntity.ok(treinadorService.listarAtletasResumo(gestor.get().getId()));
    }

    @GetMapping("/atletas/{atletaId}")
    public ResponseEntity<?> obterAtleta(
            @PathVariable Long atletaId,
            @RequestHeader("Authorization") String token) {
        Optional<Usuario> gestor = validarGestor(token);
        if (gestor.isEmpty()) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Map.of("erro", "Acesso negado"));
        }
        return treinadorService.obterAtletaDetalhe(gestor.get().getId(), atletaId)
                .<ResponseEntity<?>>map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.status(HttpStatus.NOT_FOUND)
                        .body(Map.of("erro", "Atleta não encontrado")));
    }

    @GetMapping("/alertas")
    public ResponseEntity<?> listarAlertas(@RequestHeader("Authorization") String token) {
        Optional<Usuario> gestor = validarGestor(token);
        if (gestor.isEmpty()) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Map.of("erro", "Acesso negado"));
        }
        return ResponseEntity.ok(treinadorService.listarAlertas(gestor.get().getId()));
    }

    @GetMapping("/atletas/disponiveis")
    public ResponseEntity<?> buscarAtletasDisponiveis(
            @RequestParam Long equipeId,
            @RequestParam String q,
            @RequestHeader("Authorization") String token) {
        Optional<Usuario> gestor = validarGestor(token);
        if (gestor.isEmpty()) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Map.of("erro", "Acesso negado"));
        }
        List<Map<String, Object>> resultados = treinadorService.buscarAtletasDisponiveis(
                gestor.get().getId(), equipeId, q);
        return ResponseEntity.ok(resultados);
    }
}
