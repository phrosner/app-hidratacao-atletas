import 'package:flutter/material.dart';
import 'package:hidratrack/Componentes/ResponsiveLayout.dart';
import 'package:hidratrack/app_rotas.dart';
import 'package:hidratrack/Modelos/AtletaListModels.dart';
import 'package:hidratrack/Servicos/TreinadorService.dart';
import 'package:hidratrack/Servicos/hidratrack_api_client.dart';

class TelaVisualizarAtletas extends StatefulWidget {
  const TelaVisualizarAtletas({super.key, this.atleta});

  final AtletaListItem? atleta;

  @override
  State<TelaVisualizarAtletas> createState() => _TelaVisualizarAtletasState();
}

class _TelaVisualizarAtletasState extends State<TelaVisualizarAtletas> {
  static const _background = Color(0xFFFFFFFF);
  static const _surface = Color(0xFFF7F7F7);
  static const _surfaceLight = Color(0xFFEDEDED);
  static const _lime = Color(0xFFB32025);
  static const _text = Color(0xFF222222);
  static const _muted = Color(0xFF6B6B6B);

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _idadeController = TextEditingController();
  final TextEditingController _modalidadeController = TextEditingController();
  final TextEditingController _equipeController = TextEditingController();
  final TextEditingController _categoriaController = TextEditingController();
  final TextEditingController _pesoController = TextEditingController();
  final TextEditingController _alturaController = TextEditingController();
  final TextEditingController _nivelTreinoController = TextEditingController();
  final TextEditingController _generoController = TextEditingController();

  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarAtleta();
  }

  Future<void> _carregarAtleta() async {
    final atletaId = widget.atleta?.id;
    if (atletaId == null) {
      setState(() => _carregando = false);
      return;
    }

    try {
      final detalhe = await TreinadorService.obterAtletaDetalhe(atletaId);
      if (!mounted) return;

      _nomeController.text = detalhe['nome']?.toString() ?? '';
      _idadeController.text = detalhe['idade']?.toString() ?? '';
      _modalidadeController.text = detalhe['modalidade']?.toString() ?? '';
      _equipeController.text = detalhe['equipe']?.toString() ?? '';
      _categoriaController.text = detalhe['categoria']?.toString() ?? '';
      _pesoController.text = detalhe['peso']?.toString() ?? '';
      _alturaController.text = detalhe['altura']?.toString() ?? '';
      _nivelTreinoController.text = detalhe['nivelTreino']?.toString() ?? '';
      _generoController.text = detalhe['genero']?.toString() ?? 'Nao informado';

      setState(() => _carregando = false);
    } catch (e) {
      if (!mounted) return;
      setState(() => _carregando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar atleta: $e')),
      );
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _idadeController.dispose();
    _modalidadeController.dispose();
    _equipeController.dispose();
    _categoriaController.dispose();
    _pesoController.dispose();
    _alturaController.dispose();
    _nivelTreinoController.dispose();
    _generoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return const Scaffold(
        backgroundColor: _background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: ResponsiveLayout.contentMaxWidth(context)),
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildTopBar(),
                      const SizedBox(height: 30),
                      _buildSectionTitle('INFORMACOES PESSOAIS'),
                      const SizedBox(height: 12),
                      _buildPersonalCard(),
                      const SizedBox(height: 24),
                      _buildSectionTitle('PERFIL ESPORTIVO'),
                      const SizedBox(height: 12),
                      _buildSportsCard(),
                      const SizedBox(height: 24),
                      _buildSectionTitle('DADOS FISIOLOGICOS'),
                      const SizedBox(height: 14),
                      _buildPhysiologyCards(),
                      const SizedBox(height: 18),
                      _buildChartButton(),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        IconButton(
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints.tightFor(width: 30, height: 30),
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close, color: _text, size: 24),
        ),
        const SizedBox(width: 6),
        const Expanded(
          child: Text(
            'VISUALIZAR ATLETA',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _text,
              fontSize: 21,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          height: 42,
          width: 42,
          decoration: BoxDecoration(
            color: _surfaceLight,
            shape: BoxShape.circle,
            border: Border.all(color: _lime, width: 1.4),
          ),
          alignment: Alignment.center,
          child: Text(
            _initials(_nomeController.text),
            style: const TextStyle(
              color: _lime,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(width: 4, height: 20, color: _lime),
        const SizedBox(width: 9),
        Text(
          title,
          style: const TextStyle(
            color: _lime,
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.2,
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalCard() {
    return _buildPanel(
      children: [
        _buildLabel('NOME COMPLETO'),
        const SizedBox(height: 8),
        _buildReadOnlyField(_nomeController, 'Nome completo'),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('IDADE'),
                  const SizedBox(height: 8),
                  _buildReadOnlyField(_idadeController, 'Idade'),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('GENERO'),
                  const SizedBox(height: 8),
                  _buildReadOnlyField(_generoController, 'Genero'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSportsCard() {
    return _buildPanel(
      children: [
        _buildLabel('MODALIDADE'),
        const SizedBox(height: 8),
        _buildReadOnlyField(_modalidadeController, 'Modalidade'),
        const SizedBox(height: 16),
        _buildLabel('CLUBE / EQUIPE ATUAL'),
        const SizedBox(height: 8),
        _buildReadOnlyField(_equipeController, 'Equipe atual'),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('NIVEL'),
                  const SizedBox(height: 8),
                  _buildReadOnlyField(_nivelTreinoController, 'Nivel de treino'),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('CATEGORIA'),
                  const SizedBox(height: 8),
                  _buildReadOnlyField(_categoriaController, 'Categoria'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPhysiologyCards() {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            label: 'PESO ATUAL (KG)',
            value: _pesoController.text,
            unit: 'KG',
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _buildMetricCard(
            label: 'ALTURA (CM)',
            value: _alturaController.text,
            unit: 'CM',
          ),
        ),
      ],
    );
  }

  Widget _buildPanel({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: _muted,
        fontSize: 9,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.7,
      ),
    );
  }

  Widget _buildReadOnlyField(
    TextEditingController controller,
    String hint, {
    double? minHeight,
  }) {
    return TextField(
      controller: controller,
      readOnly: true,
      minLines: minHeight == null ? 1 : 2,
      maxLines: minHeight == null ? 1 : 2,
      style: const TextStyle(color: _text, fontSize: 14, height: 1.35),
      decoration: _inputDecoration(hint),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF505050), fontSize: 12),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: const BorderSide(color: _lime),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
      ),
    );
  }

  Widget _buildDisabledDropdown({
    required String? value,
    required List<String> items,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      dropdownColor: Colors.white,
      icon: const Icon(Icons.keyboard_arrow_down, color: _muted, size: 20),
      style: const TextStyle(color: _text, fontSize: 14),
      decoration: _inputDecoration('Selecione'),
      items: items
          .map(
            (item) => DropdownMenuItem<String>(
              value: item,
              child: Text(item, overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(),
      onChanged: null,
      disabledHint: Text(
        value ?? '',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: _text, fontSize: 14),
      ),
    );
  }

  Widget _buildMetricCard({
    required String label,
    required String value,
    required String unit,
  }) {
    return Container(
      height: 96,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel(label),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    value,
                    style: const TextStyle(
                      color: _text,
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  unit,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: FilledButton.icon(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => _TelaTaxaMediaTemporaria(atletaId: widget.atleta?.id),
            ),
          );
        },
        style: FilledButton.styleFrom(
          backgroundColor: _lime,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        icon: const Icon(Icons.insert_chart_outlined, size: 19),
        label: const Text(
          'VER GRAFICO',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'AT';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return '${parts.first.characters.first}${parts.last.characters.first}'
        .toUpperCase();
  }
}

class _TelaTaxaMediaTemporaria extends StatefulWidget {
  const _TelaTaxaMediaTemporaria({required this.atletaId});

  final int? atletaId;

  @override
  State<_TelaTaxaMediaTemporaria> createState() => _TelaTaxaMediaTemporariaState();
}

class _TelaTaxaMediaTemporariaState extends State<_TelaTaxaMediaTemporaria> {
  static const _background = Color(0xFFFFFFFF);
  static const _surface = Color(0xFFF7F7F7);
  static const _surfaceLight = Color(0xFFEDEDED);
  static const _lime = Color(0xFFB32025);
  static const _cyan = Color(0xFF8F171B);
  static const _text = Color(0xFF222222);
  static const _muted = Color(0xFF6B6B6B);

  late Future<Map<String, dynamic>> _statsFuture;
  late Future<List<_PerfPoint>> _performanceFuture;
  int? _lastSessaoId;

  @override
  void initState() {
    super.initState();
    _statsFuture = _loadLastSessionStats();
    _performanceFuture = _loadLastSessionPerformance();
  }

  Future<Map<String, dynamic>> _loadLastSessionStats() async {
    try {
      final atletaId = widget.atletaId;
      if (atletaId == null) return {};

      final sessoes = await HidraTrackApiClient.obterSessoesAtleta(atletaId);
      if (sessoes.isEmpty) return {};

      final limit = sessoes.length < 8 ? sessoes.length : 8;
      double sumaTaxa = 0.0;
      double sumaPerda = 0.0;
      double sumaVariacao = 0.0;
      int sumaRecMax = 0;
      int count = 0;
      Map<String, dynamic>? lastSessaoFull;

      for (var i = 0; i < limit; i++) {
        final s = sessoes[i];
        final id = s['id'];
        if (id == null) continue;
        final sessao = await HidraTrackApiClient.obterSessao(id);
        lastSessaoFull = sessao;
        if (_lastSessaoId == null) {
          try {
            _lastSessaoId = (sessao['id'] as int?) ?? (sessao['id'] as num?)?.toInt();
          } catch (_) {}
        }

        Map<String, dynamic> st = {};
        try {
          st = await HidraTrackApiClient.obterStats(id);
        } catch (_) {}

        final taxa = (st['taxaSudoreseMedia'] as num?)?.toDouble();
        final perda = (st['perdaLiquidoAjustada'] as num?)?.toDouble();
        final variacao = (st['variacaoSudorese'] as num?)?.toDouble();
        final recMax = (st['recomendacaoIntakeMax'] as num?)?.toInt();

        if (taxa != null) { sumaTaxa += taxa; }
        if (perda != null) { sumaPerda += perda; }
        if (variacao != null) { sumaVariacao += variacao; }
        if (recMax != null) { sumaRecMax += recMax; }

        count++;
      }

      final combined = <String, dynamic>{};
      if (count > 0) {
        combined['taxaSudoreseMedia'] = sumaTaxa / count;
        combined['perdaLiquidoAjustada'] = sumaPerda / count;
        combined['variacaoSudorese'] = sumaVariacao / count;
        combined['recomendacaoIntakeMax'] = (sumaRecMax / count).round();
      }

      if (lastSessaoFull != null) {
        combined['temperaturaAmbiente'] = lastSessaoFull['temperaturaAmbiente'];
        combined['umidadeRelativa'] = lastSessaoFull['umidadeRelativa'];
        combined['intensidade'] = lastSessaoFull['intensidade'] ?? 'ALTA';
        try {
          _lastSessaoId = (lastSessaoFull['id'] as int?) ?? (lastSessaoFull['id'] as num?)?.toInt() ?? _lastSessaoId;
        } catch (_) {}
      }

      return combined;
    } catch (e) {
      print('Erro ao carregar stats (TelaTaxaMediaTemporaria): $e');
      return {};
    }
  }

  Future<List<_PerfPoint>> _loadLastSessionPerformance() async {
    try {
      final atletaId = widget.atletaId;
      if (atletaId == null) return _defaultPerformanceData();

      final sessoes = await HidraTrackApiClient.obterSessoesAtleta(atletaId);
      if (sessoes.isEmpty) return _defaultPerformanceData();

      final lastSessao = sessoes.first;
      final sessao = await HidraTrackApiClient.obterSessao(lastSessao['id']);
      final metricas = (sessao['metricas'] as List<dynamic>?) ?? [];

      if (metricas.isEmpty) return _defaultPerformanceData();

      final maxTaxa = 1.92;
      metricas.sort((a, b) {
        final ta = a['tempoDecorridoMinutos'] as int? ?? 0;
        final tb = b['tempoDecorridoMinutos'] as int? ?? 0;
        return ta.compareTo(tb);
      });

      return metricas.map((m) {
        final tempo = m['tempoDecorridoMinutos'] as int? ?? 0;
        final taxa = (m['taxaSudorese'] as num?)?.toDouble() ?? 0.0;
        return _PerfPoint(time: '${tempo} MIN', value: (taxa / maxTaxa).clamp(0, 1).toDouble());
      }).toList();
    } catch (e) {
      print('Erro ao carregar performance (TelaTaxaMediaTemporaria): $e');
      return _defaultPerformanceData();
    }
  }

  List<_PerfPoint> _defaultPerformanceData() {
    return [
      _PerfPoint(time: '0 MIN', value: 0.6),
      _PerfPoint(time: '30 MIN', value: 0.75),
      _PerfPoint(time: '60 MIN', value: 0.92),
      _PerfPoint(time: '90 MIN', value: 0.88),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: ResponsiveLayout.contentMaxWidth(context)),
            child: FutureBuilder<Map<String, dynamic>>(
              future: _statsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError || snapshot.data == null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Erro ao carregar dados'),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: () => setState(() {
                            _statsFuture = _loadLastSessionStats();
                            _performanceFuture = _loadLastSessionPerformance();
                          }),
                          child: const Text('Tentar novamente'),
                        ),
                      ],
                    ),
                  );
                }

                final stats = snapshot.data!;
                final sweatRate = (stats['taxaSudoreseMedia'] as num?)?.toDouble() ?? 0.0;
                final waterLoss = (stats['perdaLiquidoAjustada'] as num?)?.toDouble() ?? 0.0;
                final variation = (stats['variacaoSudorese'] as num?)?.toDouble() ?? 0.0;
                final recommended = (stats['recomendacaoIntakeMax'] as num?)?.toInt() ?? 0;

                return CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 26),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          _buildTopBar(),
                          const SizedBox(height: 20),
                          _buildSweatRateCard(sweatRate, stats),
                          const SizedBox(height: 14),
                          FutureBuilder<List<_PerfPoint>>(
                            future: _performanceFuture,
                            builder: (c, perfSnap) {
                              final perf = perfSnap.data ?? _defaultPerformanceData();
                              return _buildPerformanceCard(perf);
                            },
                          ),
                          const SizedBox(height: 14),
                          _buildMetricsGrid(waterLoss, variation, recommended),
                          const SizedBox(height: 14),
                          _buildRepositionPlan(recommended),
                          const SizedBox(height: 20),
                        ]),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        IconButton(
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints.tightFor(width: 30, height: 30),
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close, color: _text, size: 24),
        ),
        const SizedBox(width: 6),
        const Expanded(
          child: Text(
            'STATUS DO ATLETA',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _text,
              fontSize: 21,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSweatRateCard(double sweatRate, Map<String, dynamic> stats) {
    return Container(
      width: double.infinity,
      height: 148,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _lime.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          const Text(
            'TAXA DE SUDORESE MEDIA',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _muted,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                sweatRate.toStringAsFixed(2),
                style: const TextStyle(
                  color: _lime,
                  fontSize: 50,
                  fontWeight: FontWeight.w900,
                  height: 0.9,
                  shadows: [
                    Shadow(color: _lime, blurRadius: 28),
                    Shadow(color: _lime, blurRadius: 10),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Padding(
                padding: EdgeInsets.only(bottom: 6),
                child: Text(
                  'L/h',
                  style: TextStyle(
                    color: _text,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPill((stats['intensidade'] as String?)?.toUpperCase() ?? 'INTENSIDADE', _lime, Colors.white),
              const SizedBox(width: 10),
              _buildPill('21 C / 65% UR', _surfaceLight, _text),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPill(String label, Color background, Color foreground) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontSize: 8,
          fontWeight: FontWeight.w900,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildPerformanceCard(List<_PerfPoint> perfData) {
    return Container(
      height: 218,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'PERFORMANCE TREND',
                style: TextStyle(
                  color: _cyan,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              const Spacer(),
              const Icon(Icons.auto_graph, color: _cyan, size: 20),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: CustomPaint(
              painter: _PerformancePainter(
                intensity: perfData.map((p) => p.value * 100).toList(),
                hydration: perfData.map((p) => p.value * 100).toList(),
                cyan: _cyan,
                lime: _lime,
                grid: Color(0xFF2B2B2B),
              ),
              child: const SizedBox.expand(),
            ),
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _AxisLabel('0 MIN'),
              _AxisLabel('30 MIN'),
              _AxisLabel('60 MIN'),
              _AxisLabel('90 MIN'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(double waterLossLiters, double weightVariation, int recommendedMlHour) {
    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            title: 'PERDA AJUSTADA',
            value: '${waterLossLiters.toStringAsFixed(2)} L',
            accent: _text,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MetricCard(
            title: 'VARIACAO %',
            value: '${weightVariation.toStringAsFixed(1)}%',
            accent: _lime,
            highlighted: true,
          ),
        ),
      ],
    );
  }

  Widget _buildRepositionPlan(int recommendedMlHour) {
    final doseMl = (recommendedMlHour / 4).round();
    final rows = [
      ('00:15', '$doseMl ml', 'Inicio da reposicao'),
      ('00:30', '$doseMl ml', 'Manter ritmo'),
      ('00:45', '$doseMl ml', 'Checar sede'),
      ('01:00', '$doseMl ml', 'Nova avaliacao'),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: _lime,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: _lime.withValues(alpha: 0.24),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.water_drop_outlined,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'PLANO DE REPOSICAO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'RECOMENDACAO HORARIA',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 8,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${recommendedMlHour}ml',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              const SizedBox(width: 5),
              const Padding(
                padding: EdgeInsets.only(bottom: 3),
                child: Text(
                  '/h',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(7),
              border: Border.all(color: Colors.white.withValues(alpha: 0.09)),
            ),
            child: Column(
              children: [
                const _PlanHeader(),
                for (var i = 0; i < rows.length; i++)
                  _PlanRow(
                    time: rows[i].$1,
                    amount: rows[i].$2,
                    note: rows[i].$3,
                    showDivider: i != rows.length - 1,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _buildInstruction(
            Icons.schedule,
            'Fracionar a cada 15 minutos durante o exercicio.',
          ),
          const SizedBox(height: 10),
          _buildInstruction(
            Icons.bolt,
            'Adicionar 400-600mg de sodio por litro de agua.',
          ),
        ],
      ),
    );
  }

  Widget _buildInstruction(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 17),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.accent,
    this.highlighted = false,
  });

  final String title;
  final String value;
  final Color accent;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    const surface = Color(0xFFF7F7F7);
    const muted = Color(0xFF6B6B6B);

    return Container(
      height: 86,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: muted,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.8,
            ),
          ),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    value,
                    style: TextStyle(
                      color: accent,
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlanHeader extends StatelessWidget {
  const _PlanHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
      ),
      child: const Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              'HORARIO',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 8,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'DOSE',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 8,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'OBSERVACAO',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 8,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanRow extends StatelessWidget {
  const _PlanRow({
    required this.time,
    required this.amount,
    required this.note,
    this.showDivider = true,
  });

  final String time;
  final String amount;
  final String note;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  time,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  amount,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  note,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            color: Colors.white.withValues(alpha: 0.08),
          ),
      ],
    );
  }
}

class _AxisLabel extends StatelessWidget {
  const _AxisLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFF6B6B6B),
        fontSize: 7,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _PerfPoint {
  _PerfPoint({required this.time, required this.value});
  final String time;
  final double value;
}

class _PerformancePainter extends CustomPainter {
  _PerformancePainter({
    required this.intensity,
    required this.hydration,
    required this.cyan,
    required this.lime,
    required this.grid,
  });

  final List<double> intensity;
  final List<double> hydration;
  final Color cyan;
  final Color lime;
  final Color grid;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    // Draw grid lines
    final gridPaint = Paint()
      ..color = grid.withValues(alpha: 0.1)
      ..strokeWidth = 1;

    for (int i = 1; i < 4; i++) {
      final y = size.height * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Draw intensity line
    paint.color = cyan;
    final intensityPath = Path();
    for (int i = 0; i < intensity.length; i++) {
      final x = (i / (intensity.length - 1)) * size.width;
      final y = size.height - (intensity[i] / 100) * size.height;
      if (i == 0) {
        intensityPath.moveTo(x, y);
      } else {
        intensityPath.lineTo(x, y);
      }
    }
    canvas.drawPath(intensityPath, paint);

    // Draw hydration line
    paint.color = lime;
    final hydrationPath = Path();
    for (int i = 0; i < hydration.length; i++) {
      final x = (i / (hydration.length - 1)) * size.width;
      final y = size.height - (hydration[i] / 100) * size.height;
      if (i == 0) {
        hydrationPath.moveTo(x, y);
      } else {
        hydrationPath.lineTo(x, y);
      }
    }
    canvas.drawPath(hydrationPath, paint);
  }

  @override
  bool shouldRepaint(_PerformancePainter oldDelegate) => true;
}
