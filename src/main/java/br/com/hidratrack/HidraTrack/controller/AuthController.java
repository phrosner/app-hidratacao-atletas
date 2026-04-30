package br.com.hidratrack.HidraTrack.controller;

import br.com.hidratrack.HidraTrack.model.Usuario;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "*")
public class AuthController {

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody Usuario dadosLogin) {
        // Credencial de teste para permitir validação rápida do frontend.
        if ("teste".equals(dadosLogin.getUsuario()) && "teste".equals(dadosLogin.getSenha())) {
            Map<String, String> response = new HashMap<>();
            response.put("mensagem", "Login bem sucedido");
            return ResponseEntity.ok(response);
        }
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Login inválido");
    }

    @PostMapping("/cadastrar")
    public ResponseEntity<?> cadastrar(@RequestBody Usuario novoUsuario) {
        return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE)
                .body("Cadastro temporariamente indisponível: integração com banco em andamento.");
    }
}