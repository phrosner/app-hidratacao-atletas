package br.com.hidratrack.HidraTrack.repository;

import br.com.hidratrack.HidraTrack.model.Atleta;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

/**
 * Repository para operações de banco de dados com Atletas
 */
@Repository
public interface AtletaRepository extends JpaRepository<Atleta, Long> {

    /**
     * Busca atleta por código único
     */
    Optional<Atleta> findByCodigo(String codigo);

    /**
     * Busca atletas por modalidade principal
     */
    List<Atleta> findByModalidadePrincipal(String modalidade);

    /**
     * Busca atletas ativos
     */
    List<Atleta> findByAtivoTrue();

    /**
     * Busca atletas ativos por modalidade
     */
    List<Atleta> findByAtivoTrueAndModalidadePrincipal(String modalidade);

    /**
     * Busca atletas por categoria
     */
    List<Atleta> findByCategoria(String categoria);

    /**
     * Verifica se código já existe
     */
    boolean existsByCodigo(String codigo);

    /**
     * Busca atletas com sessões registradas
     */
    @Query("SELECT DISTINCT a FROM Atleta a JOIN a.sessoes s WHERE a.ativo = true")
    List<Atleta> findAtletasComSessoes();

    /**
     * Busca atletas por nome (busca parcial)
     */
    @Query("SELECT a FROM Atleta a WHERE LOWER(a.nome) LIKE LOWER(CONCAT('%', :nome, '%')) AND a.ativo = true")
    List<Atleta> searchByNome(@Param("nome") String nome);

    /**
     * Conta atletas ativos por modalidade
     */
    long countByAtivoTrueAndModalidadePrincipal(String modalidade);
}
