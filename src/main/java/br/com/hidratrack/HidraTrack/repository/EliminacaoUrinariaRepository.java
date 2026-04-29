package br.com.hidratrack.HidraTrack.repository;

import br.com.hidratrack.HidraTrack.model.EliminacaoUrinaria;
import br.com.hidratrack.HidraTrack.model.Sessao;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * Repository para operações de banco de dados com EliminacaoUrinaria
 */
@Repository
public interface EliminacaoUrinariaRepository extends JpaRepository<EliminacaoUrinaria, Long> {

    /**
     * Busca todas as eliminações de uma sessão
     */
    List<EliminacaoUrinaria> findBySessaoOrderByDataHoraAsc(Sessao sessao);

    /**
     * Calcula o total eliminado em uma sessão
     */
    @Query("SELECT COALESCE(SUM(e.volumeMl), 0) FROM EliminacaoUrinaria e WHERE e.sessao = :sessao")
    Integer calcularTotalEliminacao(@Param("sessao") Sessao sessao);

    /**
     * Conta número de eventos de eliminação em uma sessão
     */
    long countBySessao(Sessao sessao);
}
