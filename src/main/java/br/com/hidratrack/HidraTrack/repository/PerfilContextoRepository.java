package br.com.hidratrack.HidraTrack.repository;

import br.com.hidratrack.HidraTrack.model.PerfilContexto;
import br.com.hidratrack.HidraTrack.model.Atleta;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

/**
 * Repository para operações de banco de dados com PerfilContexto
 */
@Repository
public interface PerfilContextoRepository extends JpaRepository<PerfilContexto, Long> {

    /**
     * Busca perfis de um atleta
     */
    List<PerfilContexto> findByAtleta(Atleta atleta);

    /**
     * Busca perfis por modalidade
     */
    List<PerfilContexto> findByModalidade(String modalidade);

    /**
     * Busca perfis de um atleta por modalidade
     */
    List<PerfilContexto> findByAtletaAndModalidade(Atleta atleta, String modalidade);

    /**
     * Busca perfil específico por atleta, modalidade e tipo de clima
     */
    Optional<PerfilContexto> findByAtletaAndModalidadeAndTipoClima(
        Atleta atleta,
        String modalidade,
        PerfilContexto.TipoClima tipoClima
    );

    /**
     * Busca perfis por tipo de clima
     */
    List<PerfilContexto> findByTipoClima(PerfilContexto.TipoClima tipoClima);

    /**
     * Busca perfis com número mínimo de sessões
     */
    @Query("SELECT p FROM PerfilContexto p WHERE p.atleta = :atleta AND p.numeroSessoes >= :minSessoes")
    List<PerfilContexto> findPerfisConsolidados(
        @Param("atleta") Atleta atleta,
        @Param("minSessoes") Integer minSessoes
    );

    /**
     * Conta perfis de um atleta
     */
    long countByAtleta(Atleta atleta);
}
