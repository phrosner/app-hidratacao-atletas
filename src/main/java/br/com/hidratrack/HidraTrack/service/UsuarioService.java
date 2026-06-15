package br.com.hidratrack.HidraTrack.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

import br.com.hidratrack.HidraTrack.model.Usuario;
import br.com.hidratrack.HidraTrack.repository.UsuarioRepository;

@Service
public class UsuarioService {

    @Autowired
    private UsuarioRepository repository;

    private final PasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

    public List<Usuario> listarTodos() {
        return repository.findAll();
    }

    public Usuario salvar(Usuario usuario) {
        if (usuario.getSenha() != null &&
                !usuario.getSenha().startsWith("$2a$") &&
                !usuario.getSenha().startsWith("$2b$") &&
                !usuario.getSenha().startsWith("$2y$")) {
            usuario.setSenha(passwordEncoder.encode(usuario.getSenha()));
        }
        return repository.save(usuario);
    }

    /** Credenciais validas (usuario + senha), sem checar perfil da tela. */
    public Optional<Usuario> buscarPorUsuarioESenha(String usuario, String senha) {
        final Optional<Usuario> candidato = repository.findByUsuario(usuario);
        if (candidato.isEmpty()) {
            return Optional.empty();
        }
        final Usuario usuarioSalvo = candidato.get();
        if (usuarioSalvo.getSenha() == null) {
            return Optional.empty();
        }

        final String senhaSalva = usuarioSalvo.getSenha();
        if (senhaSalva.startsWith("$2a$") || senhaSalva.startsWith("$2b$") || senhaSalva.startsWith("$2y$")) {
            if (!passwordEncoder.matches(senha, senhaSalva)) {
                return Optional.empty();
            }
            return Optional.of(usuarioSalvo);
        }

        // Senha antiga em texto plano: valida e migra para BCrypt ao primeiro login.
        if (senhaSalva.equals(senha)) {
            usuarioSalvo.setSenha(passwordEncoder.encode(senha));
            repository.save(usuarioSalvo);
            return Optional.of(usuarioSalvo);
        }

        return Optional.empty();
    }

    public Optional<Usuario> buscarPorId(Long id) {
        return repository.findById(id);
    }

    public Optional<Usuario> buscarPorUsuario(String usuario) {
        return repository.findByUsuario(usuario);
    }

    public boolean usuarioExiste(String usuario) {
        return repository.findByUsuario(usuario).isPresent();
    }
}
