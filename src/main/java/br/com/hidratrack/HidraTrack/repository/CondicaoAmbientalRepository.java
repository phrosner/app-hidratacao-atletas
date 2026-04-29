package br.com.hidratrack.HidraTrack.repository;

import br.com.hidratrack.HidraTrack.model.CondicaoAmbiental;
import br.com.hidratrack.HidraTrack.model.Sessao;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

/**
 * Repository para operações de banco de dados com CondicaoAmbiental
 */
@Repository
public interface CondicaoAmbientalRepository extends JpaRepository<CondicaoAmbiental, Long> {

    /**
     * Busca condição ambiental por sessão
     */
    Optional<CondicaoAmbiental> findBySessao(Sessao sessao);

    /**
     * Verifica se já existe condição ambiental para uma sessão
     */
    boolean existsBySessao(Sessao sessao);
}
