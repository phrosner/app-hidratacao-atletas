package br.com.hidratrack.HidraTrack.repository;

import br.com.hidratrack.HidraTrack.model.DadosPreSessao;
import br.com.hidratrack.HidraTrack.model.Sessao;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

/**
 * Repository para operações de banco de dados com DadosPreSessao
 */
@Repository
public interface DadosPreSessaoRepository extends JpaRepository<DadosPreSessao, Long> {

    /**
     * Busca dados pré-sessão por sessão
     */
    Optional<DadosPreSessao> findBySessao(Sessao sessao);

    /**
     * Verifica se já existem dados pré-sessão para uma sessão
     */
    boolean existsBySessao(Sessao sessao);
}
