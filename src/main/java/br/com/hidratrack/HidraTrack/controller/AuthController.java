package br.com.hidratrack.HidraTrack.controller;



import br.com.hidratrack.HidraTrack.dto.CadastroAtletaRequest;
import br.com.hidratrack.HidraTrack.dto.LoginRequest;
import br.com.hidratrack.HidraTrack.model.Equipe;
import br.com.hidratrack.HidraTrack.model.Usuario;
import br.com.hidratrack.HidraTrack.service.EquipeService;
import br.com.hidratrack.HidraTrack.service.UsuarioService;

import org.springframework.beans.factory.annotation.Autowired;

import org.springframework.http.HttpStatus;

import org.springframework.http.ResponseEntity;

import org.springframework.web.bind.annotation.*;



import java.util.HashMap;
import java.util.Map;
import java.util.Optional;
import java.time.LocalDate;
import java.time.Period;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.Locale;



@RestController

@RequestMapping("/api/auth")

@CrossOrigin(origins = "*")

public class AuthController {



    @Autowired

    private UsuarioService usuarioService;

    @Autowired

    private EquipeService equipeService;



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

    @PostMapping("/cadastrar-atleta")

    public ResponseEntity<?> cadastrarAtleta(@RequestBody CadastroAtletaRequest request) {

        if (request.getNome() == null || request.getNome().isBlank()) {

            return ResponseEntity.badRequest().body(Map.of("erro", "Nome e obrigatorio"));

        }

        if (request.getCodigoEquipe() == null || request.getCodigoEquipe().isBlank()) {

            return ResponseEntity.badRequest().body(Map.of("erro", "Codigo da equipe e obrigatorio"));

        }

        Optional<Equipe> equipeOpt = equipeService.buscarPorCodigo(request.getCodigoEquipe());

        if (equipeOpt.isEmpty()) {

            return ResponseEntity.status(HttpStatus.NOT_FOUND)

                    .body(Map.of("erro", "Equipe nao encontrada para o codigo informado"));

        }

        Equipe equipe = equipeOpt.get();

        String usuario = request.getUsuario();

        if (usuario == null || usuario.isBlank()) {

            usuario = gerarUsuario(request.getNome());

        } else {

            usuario = usuario.trim().toLowerCase(Locale.ROOT);

        }

        if (usuarioService.usuarioExiste(usuario)) {

            usuario = gerarUsuario(request.getNome());

        }

        String senha = request.getSenha();

        boolean senhaGerada = false;

        if (senha == null || senha.isBlank()) {

            senha = gerarSenhaInicial(request.getCodigoEquipe(), request.getDataNascimento());

            senhaGerada = true;

        }

        LocalDate dataNascimento = parseDataNascimento(request.getDataNascimento());

        Usuario atleta = new Usuario();

        atleta.setNome(request.getNome().trim());

        atleta.setUsuario(usuario);

        atleta.setSenha(senha);

        atleta.setTipoUsuario(Usuario.TipoUsuario.ATLETA);

        atleta.setAtivo(true);

        atleta.setPeso(request.getPeso());

        atleta.setAltura(request.getAltura());

        atleta.setDataNascimento(dataNascimento);

        if (dataNascimento != null) {

            atleta.setIdade(Period.between(dataNascimento, LocalDate.now()).getYears());

        }

        if (request.getGenero() != null && !request.getGenero().isBlank()) {

            atleta.setGenero(request.getGenero().trim());

        }

        if (equipe.getModalidade() != null) {

            atleta.setEsporte(equipe.getModalidade());

        }

        atleta.setNivelTreino("INTERMEDIARIO");

        Usuario salvo = usuarioService.salvar(atleta);

        equipeService.vincularAtleta(equipe, salvo);

        Map<String, Object> response = new HashMap<>();

        response.put("mensagem", "Cadastro realizado com sucesso");

        response.put("id", salvo.getId());

        response.put("nome", salvo.getNome());

        response.put("usuario", salvo.getUsuario());

        response.put("equipe", equipe.getNome());

        response.put("codigoEquipe", equipe.getCodigoEquipe());

        response.put("token", "dummy-token-" + salvo.getId());

        response.put("tipoUsuario", salvo.getTipoUsuario().name());

        if (senhaGerada) {

            response.put("senhaGerada", senha);

        }

        return ResponseEntity.status(HttpStatus.CREATED).body(response);

    }

    private String gerarUsuario(String nome) {

        String base = nome.trim().toLowerCase(Locale.ROOT)

                .replaceAll("[^a-z0-9\\s]", "")

                .replaceAll("\\s+", ".");

        if (base.isBlank()) {

            base = "atleta";

        }

        String candidato = base;

        int tentativa = 0;

        while (usuarioService.usuarioExiste(candidato)) {

            tentativa++;

            candidato = base + tentativa;

        }

        return candidato;

    }

    private String gerarSenhaInicial(String codigoEquipe, String dataNascimento) {

        String codigo = codigoEquipe != null ? codigoEquipe.replaceAll("[^A-Za-z0-9]", "") : "HT";

        String sufixo = codigo.length() >= 4 ? codigo.substring(codigo.length() - 4) : codigo;

        LocalDate nascimento = parseDataNascimento(dataNascimento);

        String ano = nascimento != null ? String.valueOf(nascimento.getYear()) : "2024";

        return sufixo + ano;

    }

    private LocalDate parseDataNascimento(String data) {

        if (data == null || data.isBlank()) {

            return null;

        }

        String value = data.trim();

        DateTimeFormatter[] formatters = {

                DateTimeFormatter.ofPattern("MM/dd/yyyy"),

                DateTimeFormatter.ofPattern("dd/MM/yyyy"),

                DateTimeFormatter.ISO_LOCAL_DATE

        };

        for (DateTimeFormatter formatter : formatters) {

            try {

                return LocalDate.parse(value, formatter);

            } catch (DateTimeParseException ignored) {

            }

        }

        return null;

    }

}

