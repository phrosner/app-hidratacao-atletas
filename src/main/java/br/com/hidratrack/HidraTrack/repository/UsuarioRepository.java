package br.com.hidratrack.HidraTrack.repository;

import br.com.hidratrack.HidraTrack.model.Usuario;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface UsuarioRepository extends JpaRepository<Usuario, Long> {
    // Busca um usuário pelo nome e pela senha (para o login)
    Optional<Usuario> findByUsuarioAndSenha(String usuario, String senha);
}