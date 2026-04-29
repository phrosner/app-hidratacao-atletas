package br.com.hidratrack.HidraTrack.repository;

import br.com.hidratrack.HidraTrack.model.Usuario;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface UsuarioRepository extends JpaRepository<Usuario, Long> {

    Optional<Usuario> findByEmail(String email);

    List<Usuario> findByTipo(Usuario.TipoUsuario tipo);

    List<Usuario> findByAtivoTrue();

    List<Usuario> findByAtivoTrueAndTipo(Usuario.TipoUsuario tipo);

    boolean existsByEmail(String email);

    @Query("SELECT COUNT(u) FROM Usuario u WHERE u.tipo = :tipo AND u.ativo = true")
    long countByTipoAndAtivo(@Param("tipo") Usuario.TipoUsuario tipo);

    @Query("SELECT u FROM Usuario u WHERE u.email = :usuario AND u.senha = :senha")
    Optional<Usuario> findByUsuarioAndSenha(
            @Param("usuario") String usuario,
            @Param("senha") String senha
    );
}
