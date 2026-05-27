package br.com.hidratrack.HidraTrack.controller;

import br.com.hidratrack.HidraTrack.dto.UsuarioDTO;
import br.com.hidratrack.HidraTrack.model.Usuario;
import br.com.hidratrack.HidraTrack.service.UsuarioService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/atletas")
@CrossOrigin(origins = "*")
public class AtletaController {

    @Autowired
    private UsuarioService usuarioService;

    /**
     * Obter dados do dashboard do atleta autenticado
     * Retorna: nome do atleta, métricas de hidratação, sessões recentes
     */
    @GetMapping("/dashboard")
    public ResponseEntity<?> obterDashboard(
            @RequestHeader("Authorization") String token) {
        try {
            // TODO: Extrair userId do token JWT
            // Long userId = tokenService.extrairUserId(token);
            
            // Dados mock até implementar autenticação JWT
            Map<String, Object> dashboard = new HashMap<>();
            dashboard.put("nomeAtleta", "Ricardo Silva");
            dashboard.put("taxaSuor", 1.2); // L/h
            dashboard.put("hidratacaoRecomendada", 2.4); // L
            dashboard.put("saudeGeral", "Ótimo");
            dashboard.put("ultimaSessao", LocalDateTime.now().minusHours(2));
            dashboard.put("percentualConsumido", 45.0);
            dashboard.put("consumoMedio", 0.8); // L/h
            
            return ResponseEntity.ok(dashboard);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("erro", "Erro ao obter dashboard: " + e.getMessage()));
        }
    }

    /**
     * Obter perfil do atleta autenticado
     */
    @GetMapping("/perfil")
    public ResponseEntity<?> obterPerfil(
            @RequestHeader("Authorization") String token) {
        try {
            // TODO: Extrair userId do token JWT
            Map<String, Object> perfil = new HashMap<>();
            perfil.put("id", 1L);
            perfil.put("nome", "Ricardo Silva");
            perfil.put("email", "ricardo@email.com");
            perfil.put("peso", 75.5);
            perfil.put("altura", 180);
            perfil.put("idade", 25);
            perfil.put("esporte", "Futebol");
            perfil.put("nivelTreino", "Profissional");
            
            return ResponseEntity.ok(perfil);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("erro", "Erro ao obter perfil: " + e.getMessage()));
        }
    }

    /**
     * Obter histórico de consumo de água
     */
    @GetMapping("/consumo")
    public ResponseEntity<?> obterHistoricoConsumo(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime dataInicio,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime dataFim,
            @RequestHeader("Authorization") String token) {
        try {
            // TODO: Implementar busca real no banco de dados
            // TODO: Extrair userId do token
            
            Map<String, Object>[] consumos = {
                Map.of("dataHora", LocalDateTime.now().minusHours(3), "mlConsumidos", 500),
                Map.of("dataHora", LocalDateTime.now().minusHours(2), "mlConsumidos", 400),
                Map.of("dataHora", LocalDateTime.now().minusHours(1), "mlConsumidos", 300),
            };
            
            return ResponseEntity.ok(consumos);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("erro", "Erro ao obter consumo: " + e.getMessage()));
        }
    }

    /**
     * Registrar novo consumo de água
     */
    @PostMapping("/consumo")
    public ResponseEntity<?> registrarConsumo(
            @RequestBody Map<String, Object> consumoData,
            @RequestHeader("Authorization") String token) {
        try {
            Double mlConsumidos = ((Number) consumoData.get("mlConsumidos")).doubleValue();
            String dataHora = (String) consumoData.get("dataHora");
            
            // TODO: Validar dados
            // TODO: Salvar no banco de dados
            // TODO: Extrair userId do token
            
            Map<String, Object> resposta = new HashMap<>();
            resposta.put("sucesso", true);
            resposta.put("mensagem", "Consumo registrado com sucesso");
            resposta.put("mlConsumidos", mlConsumidos);
            
            return ResponseEntity.status(HttpStatus.CREATED).body(resposta);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("erro", "Erro ao registrar consumo: " + e.getMessage()));
        }
    }

    /**
     * Obter métricas de uma sessão específica
     */
    @GetMapping("/sessoes/{sessaoId}")
    public ResponseEntity<?> obterMetricasSessao(
            @PathVariable Long sessaoId,
            @RequestHeader("Authorization") String token) {
        try {
            Map<String, Object> metricas = new HashMap<>();
            metricas.put("sessaoId", sessaoId);
            metricas.put("dataInicio", LocalDateTime.now().minusHours(1));
            metricas.put("duracao", 60); // minutos
            metricas.put("consumoAgua", 1.5); // litros
            metricas.put("mediaHidratacao", 1.0); // L/h
            metricas.put("statusSaude", "Normal");
            
            return ResponseEntity.ok(metricas);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("erro", "Erro ao obter métricas: " + e.getMessage()));
        }
    }
}
