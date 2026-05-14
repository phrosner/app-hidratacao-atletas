package br.com.hidratrack.HidraTrack.dto;

public class LoginRequest {

    private String usuario;
    private String senha;
    /** Deve ser ATLETA, TREINADOR ou NUTRICIONISTA (igual ao perfil escolhido na tela). */
    private String tipoLogin;

    public String getUsuario() {
        return usuario;
    }

    public void setUsuario(String usuario) {
        this.usuario = usuario;
    }

    public String getSenha() {
        return senha;
    }

    public void setSenha(String senha) {
        this.senha = senha;
    }

    public String getTipoLogin() {
        return tipoLogin;
    }

    public void setTipoLogin(String tipoLogin) {
        this.tipoLogin = tipoLogin;
    }
}
