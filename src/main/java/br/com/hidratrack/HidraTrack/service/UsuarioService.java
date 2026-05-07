package br.com.hidratrack.HidraTrack.service;


import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

import br.com.hidratrack.HidraTrack.model.Usuario;
import br.com.hidratrack.HidraTrack.repository.UsuarioRepository;

@Service
public class UsuarioService {

    @Autowired
    private UsuarioRepository repository;

    public List<Usuario> listarTodos() {
        return repository.findAll();
    }

    public Usuario salvar(Usuario usuario) {
        return repository.save(usuario);
    }

    public Optional<Usuario> autenticar(String usuario, String senha) {
        return repository.findByUsuarioAndSenha(usuario, senha);
    }
}

