package br.com.hidratrack.HidraTrack.repository;

import br.com.hidratrack.HidraTrack.model.ResultadoCalculado;
import br.com.hidratrack.HidraTrack.model.Sessao;
import br.com.hidratrack.HidraTrack.model.Atleta;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

/**
 * Repository para operações de banco de dados com ResultadoCalculado
 */
@Repository
public interface ResultadoCalculadoRepository extends JpaRepository<ResultadoCalculado, Long> {

    /**
     * Busca resultado calculado por sessão
     */
    Optional<ResultadoCalculado> findBySessao(Sessao sessao);

    /**
     * Busca resultados com dados inconsistentes
     */
    List<ResultadoCalculado> findByDadosInconsistentesTrue();

    /**
     * Busca resultados por status de hidratação
     */
    List<ResultadoCalculado> findByStatusHidratacao(ResultadoCalculado.StatusHidratacao status);

    /**
     * Calcula média de taxa de sudorese de um atleta
     */
    @Query("SELECT AVG(r.taxaSudoreseLitroPorHora) FROM ResultadoCalculado r " +
           "JOIN r.sessao s WHERE s.atleta = :atleta AND r.dadosInconsistentes = false")
    BigDecimal calcularMediaTaxaSudorese(@Param("atleta") Atleta atleta);

    /**
     * Calcula desvio padrão da taxa de sudorese
     */
    @Query("SELECT STDDEV(r.taxaSudoreseLitroPorHora) FROM ResultadoCalculado r " +
           "JOIN r.sessao s WHERE s.atleta = :atleta AND r.dadosInconsistentes = false")
    BigDecimal calcularDesvioPadraoTaxaSudorese(@Param("atleta") Atleta atleta);

    /**
     * Busca resultados de um atleta em modalidade específica
     */
    @Query("SELECT r FROM ResultadoCalculado r JOIN r.sessao s " +
           "WHERE s.atleta = :atleta AND s.modalidade = :modalidade " +
           "AND r.dadosInconsistentes = false ORDER BY s.dataHora DESC")
    List<ResultadoCalculado> findByAtletaAndModalidade(
        @Param("atleta") Atleta atleta,
        @Param("modalidade") String modalidade
    );

    /**
     * Verifica se já existe resultado para uma sessão
     */
    boolean existsBySessao(Sessao sessao);
}
