package br.com.hidratrack.HidraTrack.repository;

import br.com.hidratrack.HidraTrack.model.Usuario;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

/**
 * Repository para operações de banco de dados com Usuários
 */
@Repository
public interface UsuarioRepository extends JpaRepository<Usuario, Long> {

    /**
     * Busca usuário por email
     */
    Optional<Usuario> findByEmail(String email);

    /**
     * Busca usuários por tipo
     */
    List<Usuario> findByTipo(Usuario.TipoUsuario tipo);

    /**
     * Busca usuários ativos
     */
    List<Usuario> findByAtivoTrue();

    /**
     * Busca usuários ativos por tipo
     */
    List<Usuario> findByAtivoTrueAndTipo(Usuario.TipoUsuario tipo);

    /**
     * Verifica se email já existe
     */
    boolean existsByEmail(String email);

    /**
     * Conta usuários por tipo
     */
    @Query("SELECT COUNT(u) FROM Usuario u WHERE u.tipo = :tipo AND u.ativo = true")
    long countByTipoAndAtivo(Usuario.TipoUsuario tipo);
}
