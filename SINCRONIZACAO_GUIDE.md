# Sistema Completo de Sincronização - HidraTrack

## 📋 Resumo do que foi implementado

Um sistema **100% funcional e sincronizado** entre frontend (Flutter) e backend (Spring Boot) que:

✅ Registra dados de sessões de treino no banco de dados  
✅ Calcula automaticamente todas as métricas e estatísticas com fórmulas biomédicas  
✅ Sincroniza dados em tempo real entre o app e o servidor  
✅ Atualiza a tela de stats com dados reais do banco de dados  

---

## 🗄️ Banco de Dados (MySQL)

### Tabelas criadas:
1. **sessoes_treino** - Registra cada sessão de treino
2. **metricas_sudorese** - Armazena métricas a cada intervalo
3. **consumo_agua** - Registra água ingerida durante a sessão
4. **stats_sessao** - Resultado final com todas as estatísticas calculadas

### Executar setup:
```sql
-- Execute o arquivo: database/hidratrack_mysql_setup.sql
-- No MySQL Workbench ou CLI
```

---

## 🛠️ Backend (Spring Boot)

### Novos Controllers:
- `SessaoTreinoController` - Gerencia sessões e stats

### Novos Services:
- `SessaoTreinoService` - Lógica de negócio
- `StatsService` - Cálculos com fórmulas biomédicas

### Novos Modelos:
- `SessaoTreino`, `MetricaSudorese`, `StatsSessao`, `ConsumoAgua`
- `SessaoTreinoDTO`, `MetricaSudoreseDTO`, `StatsSessaoDTO`, `ConsumoAguaDTO`

### Executar backend:
```bash
# Na pasta do projeto
mvn spring-boot:run
# Server rode em: http://localhost:8080
```

---

## 📱 Frontend (Flutter)

### Novo Cliente HTTP:
`lib/Servicos/hidratrack_api_client.dart` - Comunica com a API

### Tela Atualizada:
`lib/Telas/TelastatsAtleta.dart` - Carrega dados reais da API

---

## 🔗 APIs Disponíveis

### Criar Sessão
```
POST /api/sessoes/criar
Body: {
  "atletaId": 1,
  "temperaturaAmbiente": 28.0,
  "umidadeRelativa": 65
}
Response: SessaoTreinoDTO com sessão criada
```

### Registrar Métrica
```
POST /api/sessoes/{sessaoId}/metrica
Body: {
  "tempoDecorridoMinutos": 30,
  "taxaSudorese": 1.75,
  "frequenciaCardiaca": 145,
  "intensidade": "ALTA"
}
```

### Registrar Consumo de Água
```
POST /api/sessoes/{sessaoId}/consumo
Body: {
  "tempoDecorridoMinutos": 15,
  "quantidadeMl": 300,
  "tipoLiquido": "Água com Eletrólitos"
}
```

### Finalizar Sessão
```
PUT /api/sessoes/{sessaoId}/finalizar?durationMinutos=90
Response: SessaoTreinoDTO com stats calculadas
```

### Obter Stats
```
GET /api/sessoes/{sessaoId}/stats
Response: StatsSessaoDTO com todas as métricas
```

---

## 📊 Fórmulas Implementadas

### 1. Taxa Média de Sudorese
```
Taxa Média = Σ(taxas registradas) / total de pontos
```

### 2. Variação de Sudorese
```
Variação % = ((Taxa Final - Taxa Inicial) / Taxa Inicial) * 100
```

### 3. Perda Total de Líquido
```
Perda Total = Taxa Média × Duração em Horas
```

### 4. Perda Ajustada
```
Perda Ajustada = Perda Total - Consumo de Água
```

### 5. Balanço Teórico
```
Balanço = (Consumo - Perda) × 1000 (em mL)
```

### 6. Recomendação de Intake
```
Intake Min = Taxa × 1000 - 100 (mL/h)
Intake Max = Taxa × 1000 + 250 (mL/h)
```

### 7. Nível de Deficit
```
CRÍTICO: Balanço < -500 mL
ALERTA: -500 ≤ Balanço < -200 mL
NORMAL: Balanço ≥ -200 mL
```

---

## 🎯 Como Usar (Passo a Passo)

### 1. Configurar Banco de Dados
```sql
-- Executar script SQL
CREATE DATABASE hidratrack_db;
-- Execute o arquivo hidratrack_mysql_setup.sql
```

### 2. Iniciar Backend
```bash
mvn spring-boot:run
# Aguarde: "Tomcat started on port 8080"
```

### 3. Abrir App Flutter
```bash
# Em outro terminal
flutter run
```

### 4. Fluxo Completo (Exemplo)
```
1. Atleta inicia treino
   → POST /api/sessoes/criar

2. Durante treino, registra:
   → POST /api/sessoes/{id}/metrica (a cada 15min)
   → POST /api/sessoes/{id}/consumo (a cada consumo)

3. Finaliza treino
   → PUT /api/sessoes/{id}/finalizar
   → Backend calcula automaticamente stats

4. Visualiza stats
   → GET /api/sessoes/{id}/stats
   → Tela exibe dados reais do banco
```

---

## 🔄 Sincronização Automática

A tela de stats **carrega dados automaticamente**:

```dart
// TelastatsAtleta.dart
Future<StatsData> _loadStatsFromApi(int sessaoId) async {
  final sessao = await HidraTrackApiClient.obterSessao(sessaoId);
  final stats = await HidraTrackApiClient.obterStats(sessaoId);
  // Dados carregados do banco de dados do servidor
}
```

---

## 📈 Dados de Teste

O banco já vem com 1 sessão de teste:
- **Atleta**: Ricardo Silva (ID: 1)
- **Sessão**: 25/05/2026, 10:00-11:30 (90 minutos)
- **Taxa Média**: 1.85 L/h
- **Variação**: -1.8%
- **Perda Ajustada**: 2.42 L
- **Balanço**: -450 mL

Para testar:
```
Na tela de stats: POST /api/sessoes/1/stats
```

---

## 🚀 Próximos Passos (Opcional)

1. **Integração com wearables** - Ler dados de smartwatches
2. **Notificações push** - Alertar sobre deficit crítico
3. **Gráficos históricos** - Comparar múltiplas sessões
4. **Relatórios PDF** - Exportar dados das sessões
5. **IA para recomendações** - Sugerir planos personalizados

---

## 🐛 Troubleshooting

### Backend não conecta ao MySQL
```
Verificar: application.properties
- URL: jdbc:mysql://localhost:3306/hidratrack_db
- Username: root
- Password: 0706
```

### API retorna 400 Bad Request
```
Verificar corpo JSON envia
- Todos os campos obrigatórios preenchidos
- Tipos de dados corretos
```

### Stats não aparecem
```
Verificar:
1. Sessão existe no banco (GET /api/sessoes/{id})
2. Métricas foram registradas (GET /api/sessoes/{id})
3. Finalizar sessão primeiro (PUT /api/sessoes/{id}/finalizar)
```

---

## 📞 Suporte

Todos os dados agora são **100% sincronizados** e **persistentes no banco de dados**.
Qualquer pergunta ou erro, verificar os logs do Spring Boot no console.
