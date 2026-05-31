package br.com.hidratrack.HidraTrack.controller;



import br.com.hidratrack.HidraTrack.dto.LoginRequest;

import br.com.hidratrack.HidraTrack.model.Usuario;

import br.com.hidratrack.HidraTrack.service.UsuarioService;

import org.springframework.beans.factory.annotation.Autowired;

import org.springframework.http.HttpStatus;

import org.springframework.http.ResponseEntity;

import org.springframework.web.bind.annotation.*;



import java.util.HashMap;

import java.util.Map;

import java.util.Optional;



@RestController

@RequestMapping("/api/auth")

@CrossOrigin(origins = "*")

public class AuthController {



    @Autowired

    private UsuarioService usuarioService;



    @PostMapping("/login")

    public ResponseEntity<?> login(@RequestBody LoginRequest dadosLogin) {

        if (dadosLogin.getUsuario() == null || dadosLogin.getSenha() == null

                || dadosLogin.getUsuario().isBlank() || dadosLogin.getSenha().isBlank()) {

            return ResponseEntity.status(HttpStatus.BAD_REQUEST)

                    .body(Map.of("erro", "Usuario e senha sao obrigatorios"));

        }

        if (dadosLogin.getTipoLogin() == null || dadosLogin.getTipoLogin().isBlank()) {

            return ResponseEntity.status(HttpStatus.BAD_REQUEST)

                    .body(Map.of("erro", "tipoLogin e obrigatorio (ATLETA, TREINADOR ou NUTRICIONISTA)"));

        }



        final Usuario.TipoUsuario tipoTela;

        try {

            tipoTela = Usuario.TipoUsuario.valueOf(dadosLogin.getTipoLogin().trim().toUpperCase());

        } catch (IllegalArgumentException e) {

            return ResponseEntity.status(HttpStatus.BAD_REQUEST)

                    .body(Map.of("erro", "tipoLogin invalido. Use ATLETA, TREINADOR ou NUTRICIONISTA"));

        }



        Optional<Usuario> credencial = usuarioService.buscarPorUsuarioESenha(

                dadosLogin.getUsuario().trim(), dadosLogin.getSenha());



        if (credencial.isEmpty()) {

            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)

                    .body(Map.of("erro", "Usuario ou senha invalidos"));

        }



        Usuario usuario = credencial.get();

        if (Boolean.FALSE.equals(usuario.getAtivo())) {

            return ResponseEntity.status(HttpStatus.FORBIDDEN)

                    .body(Map.of("erro", "Conta inativa"));

        }

        if (usuario.getTipoUsuario() != tipoTela) {

            return ResponseEntity.status(HttpStatus.FORBIDDEN)

                    .body(Map.of("erro", "Este acesso e para outro perfil. Verifique Atleta, Treinador ou Nutricionista."));

        }



        Map<String, Object> response = new HashMap<>();

        response.put("mensagem", "Login bem sucedido");

        response.put("tipoUsuario", usuario.getTipoUsuario().name());

        response.put("id", usuario.getId());

        response.put("nome", usuario.getNome() != null ? usuario.getNome() : "");

        response.put("token", "dummy-token-" + usuario.getId());

        return ResponseEntity.ok(response);

    }



    @PostMapping("/cadastrar")

    public ResponseEntity<?> cadastrar(@RequestBody Usuario novoUsuario) {

        if (novoUsuario.getUsuario() == null || novoUsuario.getSenha() == null) {

            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Map.of("erro", "Usuario e senha sao obrigatorios"));

        }



        if (novoUsuario.getTipoUsuario() == null) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Map.of("erro", "tipoUsuario e obrigatorio"));
        }
        if (novoUsuario.getAtivo() == null) {
            novoUsuario.setAtivo(true);
        }

        Usuario salvo = usuarioService.salvar(novoUsuario);

        return ResponseEntity.status(HttpStatus.CREATED).body(salvo);

    }

}

