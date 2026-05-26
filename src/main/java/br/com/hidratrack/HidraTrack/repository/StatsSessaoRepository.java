package br.com.hidratrack.HidraTrack.repository;

import br.com.hidratrack.HidraTrack.model.StatsSessao;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface StatsSessaoRepository extends JpaRepository<StatsSessao, Long> {
    Optional<StatsSessao> findBySessaoId(Long sessaoId);
}
