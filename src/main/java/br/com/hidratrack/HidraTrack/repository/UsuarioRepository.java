package br.com.hidratrack.HidraTrack.repository;

import br.com.hidratrack.HidraTrack.model.Usuario;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface UsuarioRepository extends JpaRepository<Usuario, Long> {
    Optional<Usuario> findByUsuario(String usuario);

    List<Usuario> findByTipoUsuarioAndNomeContainingIgnoreCase(
            Usuario.TipoUsuario tipoUsuario, String nome);

    @Query("SELECT COUNT(u) FROM Usuario u JOIN EquipeAtleta ea ON ea.atleta.id = u.id " +
           "JOIN Equipe e ON ea.equipe.id = e.id WHERE e.gestor.id = :gestorId " +
           "AND u.tipoUsuario = 'ATLETA' AND u.ativo = true")
    long countAtletasAtivosByGestorId(@Param("gestorId") Long gestorId);
}