package br.com.hidratrack.HidraTrack.controller;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;

import static org.hamcrest.Matchers.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
public class AtletaControllerTest {

    @Autowired
    private MockMvc mockMvc;

    private String token = "Bearer test_token_123";

    @BeforeEach
    public void setUp() {
        // Configurações iniciais se necessário
    }

    @Test
    public void testObterDashboard_Success() throws Exception {
        mockMvc.perform(get("/api/atletas/dashboard")
                .header("Authorization", token)
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.nomeAtleta", notNullValue()))
                .andExpect(jsonPath("$.taxaSuor", notNullValue()))
                .andExpect(jsonPath("$.hidratacaoRecomendada", notNullValue())
                );
    }

    @Test
    public void testObterPerfil_Success() throws Exception {
        mockMvc.perform(get("/api/atletas/perfil")
                .header("Authorization", token)
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id", notNullValue()))
                .andExpect(jsonPath("$.nome", equalTo("Ricardo Silva")))
                .andExpect(jsonPath("$.email", notNullValue())
                );
    }

    @Test
    public void testRegistrarConsumo_Success() throws Exception {
        String payload = "{\n" +
                "  \"mlConsumidos\": 500.0,\n" +
                "  \"dataHora\": \"2024-05-27T14:30:00\"\n" +
                "}";

        mockMvc.perform(post("/api/atletas/consumo")
                .header("Authorization", token)
                .contentType(MediaType.APPLICATION_JSON)
                .content(payload))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.sucesso", equalTo(true)))
                .andExpect(jsonPath("$.mlConsumidos", equalTo(500.0))
                );
    }

    @Test
    public void testObterHistoricoConsumo_Success() throws Exception {
        mockMvc.perform(get("/api/atletas/consumo")
                .param("dataInicio", "2024-05-01T00:00:00")
                .param("dataFim", "2024-05-31T23:59:59")
                .header("Authorization", token)
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk());
    }

    @Test
    public void testObterMetricasSessao_Success() throws Exception {
        mockMvc.perform(get("/api/atletas/sessoes/1")
                .header("Authorization", token)
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.sessaoId", equalTo(1)))
                .andExpect(jsonPath("$.consumoAgua", notNullValue())
                );
    }

    @Test
    public void testMissingAuthorizationHeader() throws Exception {
        mockMvc.perform(get("/api/atletas/dashboard")
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isBadRequest());
    }
}
