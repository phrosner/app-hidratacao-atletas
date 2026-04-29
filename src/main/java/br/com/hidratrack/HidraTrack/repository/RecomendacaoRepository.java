package br.com.hidratrack.HidraTrack.repository;

import br.com.hidratrack.HidraTrack.model.Recomendacao;
import br.com.hidratrack.HidraTrack.model.Sessao;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * Repository para operações de banco de dados com Recomendacao
 */
@Repository
public interface RecomendacaoRepository extends JpaRepository<Recomendacao, Long> {

    /**
     * Busca recomendações de uma sessão
     */
    List<Recomendacao> findBySessaoOrderByDataCriacaoDesc(Sessao sessao);

    /**
     * Busca recomendações por tipo
     */
    List<Recomendacao> findByTipo(Recomendacao.TipoRecomendacao tipo);

    /**
     * Busca recomendações por nível de alerta
     */
    List<Recomendacao> findByNivelAlerta(Recomendacao.NivelAlerta nivel);

    /**
     * Busca recomendações aplicadas
     */
    List<Recomendacao> findByFoiAplicadaTrue();

    /**
     * Busca recomendações não aplicadas
     */
    List<Recomendacao> findByFoiAplicadaFalse();

    /**
     * Busca recomendações críticas ou urgentes não aplicadas
     */
    @Query("SELECT r FROM Recomendacao r WHERE r.foiAplicada = false " +
           "AND r.nivelAlerta IN ('URGENTE', 'CRITICO')")
    List<Recomendacao> findRecomendacoesPrioridade();

    /**
     * Conta recomendações de uma sessão
     */
    long countBySessao(Sessao sessao);

    /**
     * Conta recomendações por nível de alerta de uma sessão
     */
    long countBySessaoAndNivelAlerta(Sessao sessao, Recomendacao.NivelAlerta nivel);
}
