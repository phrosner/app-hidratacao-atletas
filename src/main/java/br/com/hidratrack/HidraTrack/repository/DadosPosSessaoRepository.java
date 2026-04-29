package br.com.hidratrack.HidraTrack.repository;

import br.com.hidratrack.HidraTrack.model.DadosPosSessao;
import br.com.hidratrack.HidraTrack.model.Sessao;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

/**
 * Repository para operações de banco de dados com DadosPosSessao
 */
@Repository
public interface DadosPosSessaoRepository extends JpaRepository<DadosPosSessao, Long> {

    /**
     * Busca dados pós-sessão por sessão
     */
    Optional<DadosPosSessao> findBySessao(Sessao sessao);

    /**
     * Verifica se já existem dados pós-sessão para uma sessão
     */
    boolean existsBySessao(Sessao sessao);
}
