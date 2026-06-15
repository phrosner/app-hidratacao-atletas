package br.com.hidratrack.HidraTrack.util;

import br.com.hidratrack.HidraTrack.model.Usuario;
import br.com.hidratrack.HidraTrack.service.UsuarioService;

import java.util.Optional;

public final class AuthTokenUtil {

    private AuthTokenUtil() {
    }

    public static Optional<Usuario> extrairUsuario(String authorizationHeader, UsuarioService usuarioService) {
        if (authorizationHeader == null || !authorizationHeader.startsWith("Bearer ")) {
            return Optional.empty();
        }
        final String token = authorizationHeader.substring(7).trim();
        final String prefix = "dummy-token-";
        if (!token.startsWith(prefix)) {
            return Optional.empty();
        }
        try {
            final Long userId = Long.parseLong(token.substring(prefix.length()));
            return usuarioService.buscarPorId(userId);
        } catch (NumberFormatException e) {
            return Optional.empty();
        }
    }

    public static boolean isGestor(Usuario usuario) {
        return usuario.getTipoUsuario() == Usuario.TipoUsuario.TREINADOR
                || usuario.getTipoUsuario() == Usuario.TipoUsuario.NUTRICIONISTA;
    }
}
