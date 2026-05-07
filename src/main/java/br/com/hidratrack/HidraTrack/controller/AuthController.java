package br.com.hidratrack.HidraTrack.controller;

import br.com.hidratrack.HidraTrack.model.Usuario;
import br.com.hidratrack.HidraTrack.service.UsuarioService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "*")
public class AuthController {

    @Autowired
    private UsuarioService usuarioService;

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody Usuario dadosLogin) {
        if (dadosLogin.getUsuario() == null || dadosLogin.getSenha() == null) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Usuario e senha sao obrigatorios");
        }

        if (usuarioService.autenticar(dadosLogin.getUsuario(), dadosLogin.getSenha()).isPresent()) {
            Map<String, String> response = new HashMap<>();
            response.put("mensagem", "Login bem sucedido");
            return ResponseEntity.ok(response);
        }
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Login inválido");
    }

    @PostMapping("/cadastrar")
    public ResponseEntity<?> cadastrar(@RequestBody Usuario novoUsuario) {
        if (novoUsuario.getUsuario() == null || novoUsuario.getSenha() == null) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Usuario e senha sao obrigatorios");
        }

        Usuario salvo = usuarioService.salvar(novoUsuario);
        return ResponseEntity.status(HttpStatus.CREATED).body(salvo);
    }
}