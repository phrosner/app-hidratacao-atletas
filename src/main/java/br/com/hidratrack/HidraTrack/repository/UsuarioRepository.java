package br.com.hidratrack.HidraTrack.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import br.com.hidratrack.HidraTrack.model.Usuario;

public interface UsuarioRepository extends JpaRepository<Usuario, Long> {
}