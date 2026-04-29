package br.com.hidratrack.HidraTrack.repository;

import br.com.hidratrack.HidraTrack.model.IngestaoFluido;
import br.com.hidratrack.HidraTrack.model.Sessao;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * Repository para operações de banco de dados com IngestaoFluido
 */
@Repository
public interface IngestaoFluidoRepository extends JpaRepository<IngestaoFluido, Long> {

    /**
     * Busca todas as ingestões de uma sessão
     */
    List<IngestaoFluido> findBySessaoOrderByDataHoraAsc(Sessao sessao);

    /**
     * Busca ingestões por tipo de bebida
     */
    List<IngestaoFluido> findByTipoBebida(IngestaoFluido.TipoBebida tipoBebida);

    /**
     * Calcula o total ingerido em uma sessão
     */
    @Query("SELECT COALESCE(SUM(i.volumeMl), 0) FROM IngestaoFluido i WHERE i.sessao = :sessao")
    Integer calcularTotalIngestao(@Param("sessao") Sessao sessao);

    /**
     * Conta número de eventos de ingestão em uma sessão
     */
    long countBySessao(Sessao sessao);

    /**
     * Busca ingestões com eletrólitos
     */
    @Query("SELECT i FROM IngestaoFluido i WHERE i.sessao = :sessao AND i.contemEletroliticos = true")
    List<IngestaoFluido> findIngestoesComEletroliticos(@Param("sessao") Sessao sessao);
}
