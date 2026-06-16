package br.com.hidratrack.HidraTrack.controller;

import br.com.hidratrack.HidraTrack.dto.SessaoTreinoDTO;
import br.com.hidratrack.HidraTrack.dto.MetricaSudoreseDTO;
import br.com.hidratrack.HidraTrack.dto.ConsumoAguaDTO;
import br.com.hidratrack.HidraTrack.dto.StatsSessaoDTO;
import br.com.hidratrack.HidraTrack.service.SessaoTreinoService;
import br.com.hidratrack.HidraTrack.service.StatsService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/sessoes")
@CrossOrigin(origins = "*")
public class SessaoTreinoController {

    @Autowired
    private SessaoTreinoService sessaoService;

    @Autowired
    private StatsService statsService;

    /**
     * Cria uma nova sessão de treino para um atleta.
     * POST /api/sessoes/criar
     */
    @PostMapping("/criar")
    public ResponseEntity<SessaoTreinoDTO> criarSessao(@RequestBody SessaoTreinoDTO dto) {
        try {
            SessaoTreinoDTO sessaoCriada = sessaoService.criarSessao(dto);
            return ResponseEntity.status(HttpStatus.CREATED).body(sessaoCriada);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).build();
        }
    }

    /**
     * Obtém a lista de sessões de um atleta.
     * GET /api/sessoes/atleta/{atletaId}
     */
    @GetMapping("/atleta/{atletaId}")
    public ResponseEntity<List<SessaoTreinoDTO>> obterSessoesAtleta(@PathVariable Long atletaId) {
        List<SessaoTreinoDTO> sessoes = sessaoService.obterSessoesAtleta(atletaId);
        return ResponseEntity.ok(sessoes);
    }

    /**
     * Obtém detalhes de uma sessão específica.
     * GET /api/sessoes/{sessaoId}
     */
    @GetMapping("/{sessaoId}")
    public ResponseEntity<SessaoTreinoDTO> obterSessao(@PathVariable Long sessaoId) {
        SessaoTreinoDTO sessao = sessaoService.obterSessao(sessaoId);
        if (sessao != null) {
            return ResponseEntity.ok(sessao);
        }
        return ResponseEntity.notFound().build();
    }

    /**
     * Registra uma métrica de sudorese durante a sessão.
     * POST /api/sessoes/{sessaoId}/metrica
     */
    @PostMapping("/{sessaoId}/metrica")
    public ResponseEntity<String> registrarMetrica(
            @PathVariable Long sessaoId,
            @RequestBody MetricaSudoreseDTO dto) {
        try {
            sessaoService.registrarMetrica(sessaoId, dto);
            return ResponseEntity.ok("Métrica registrada com sucesso");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
        }
    }

    /**
     * Registra um consumo de água durante a sessão.
     * POST /api/sessoes/{sessaoId}/consumo
     */
    @PostMapping("/{sessaoId}/consumo")
    public ResponseEntity<String> registrarConsumo(
            @PathVariable Long sessaoId,
            @RequestBody ConsumoAguaDTO dto) {
        try {
            sessaoService.registrarConsumo(sessaoId, dto);
            return ResponseEntity.ok("Consumo registrado com sucesso");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
        }
    }

    /**
     * Finaliza uma sessão de treino e calcula as estatísticas.
     * PUT /api/sessoes/{sessaoId}/finalizar
     */
    @PutMapping("/{sessaoId}/finalizar")
    public ResponseEntity<SessaoTreinoDTO> finalizarSessao(
            @PathVariable Long sessaoId,
            @RequestParam Integer durationMinutos) {
        try {
            SessaoTreinoDTO sessaoFinalizada = sessaoService.finalizarSessao(sessaoId, durationMinutos);
            return ResponseEntity.ok(sessaoFinalizada);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).build();
        }
    }

    /**
     * Obtém as estatísticas calculadas de uma sessão.
     * GET /api/sessoes/{sessaoId}/stats
     */
    @GetMapping("/{sessaoId}/stats")
    public ResponseEntity<StatsSessaoDTO> obterStats(@PathVariable Long sessaoId) {
        StatsSessaoDTO stats = statsService.obterStats(sessaoId);
        if (stats != null) {
            return ResponseEntity.ok(stats);
        }
        return ResponseEntity.notFound().build();
    }

    /**
     * Atualiza os stats calculados de uma sessão (permite salvar edições manuais).
     * PUT /api/sessoes/{sessaoId}/stats
     */
    @PutMapping("/{sessaoId}/stats")
    public ResponseEntity<StatsSessaoDTO> atualizarStats(@PathVariable Long sessaoId,
                                                         @RequestBody StatsSessaoDTO dto) {
        try {
            StatsSessaoDTO updated = statsService.atualizarStats(sessaoId, dto);
            return ResponseEntity.ok(updated);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.notFound().build();
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).build();
        }
    }

    /**
     * Atualiza dados de pós-sessão (peso, RPE, cor da urina, sintomas).
     * PUT /api/sessoes/{sessaoId}/pos-sessao
     */
    @PutMapping("/{sessaoId}/pos-sessao")
    public ResponseEntity<SessaoTreinoDTO> atualizarPosSessao(
            @PathVariable Long sessaoId,
            @RequestBody SessaoTreinoDTO dto) {
        try {
            SessaoTreinoDTO updated = sessaoService.atualizarPosSessao(sessaoId, dto);
            return ResponseEntity.ok(updated);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.notFound().build();
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).build();
        }
    }
}
