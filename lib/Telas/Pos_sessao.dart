import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hidratrack/Servicos/AtletaService.dart';
import 'package:hidratrack/Servicos/AuthStorage.dart';
import 'package:hidratrack/app_rotas.dart';
import 'package:http/http.dart' as http;

class PosSessao extends StatefulWidget {
  const PosSessao({super.key});

  @override
  State<PosSessao> createState() => _PosSessaoState();
}

class _PosSessaoState extends State<PosSessao> {
  static const _background = Color(0xFFFFFFFF);
  static const _surface = Color(0xFFF7F7F7);
  static const _surfaceLight = Color(0xFFEDEDED);
  static const _lime = Color(0xFFB32025);
  static const _cyan = Color(0xFF8F171B);
  static const _text = Color(0xFF222222);
  static const _muted = Color(0xFF6B6B6B);

  int _sessionTotalMl = 0;
  int? _sessionDurationMinutes;
  double? _temperaturaAmbiente;
  bool _temperaturaCarregando = true;
  bool _temperaturaFalha = false;

  final TextEditingController _pesoFinalController = TextEditingController(
    text: '80.5',
  );
  final TextEditingController _temperaturaController = TextEditingController();

  double _pesoInicial = 81.2;
  int _rpe = 9;
  int _urinaSelecionada = 2;
  bool _didLoadArgs = false;

  final Set<String> _sintomasSelecionados = {'Nausea', 'Cefaleia'};
  final List<String> _sintomas = [
    'Nausea',
    'Refluxo',
    'Colica',
    'Estufamento',
    'Cefaleia',
    'Nenhum',
  ];

  final List<Color> _urinaCores = const [
    Color(0xFFF9FFFF),
    Color(0xFFFFF4A8),
    Color(0xFFFFDD3D),
    Color(0xFFE8A51F),
    Color(0xFFD86B1D),
    Color(0xFF6B3A1E),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLoadArgs) return;
    _didLoadArgs = true;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      _sessionTotalMl = args['totalMl'] as int? ?? _sessionTotalMl;
      _sessionDurationMinutes = args['durationMinutes'] as int?;
      final pesoInicialArg = args['pesoInicial'];
      if (pesoInicialArg is double) {
        _pesoInicial = pesoInicialArg;
      } else if (pesoInicialArg is String) {
        _pesoInicial = double.tryParse(pesoInicialArg.replaceAll(',', '.')) ?? _pesoInicial;
      }
    } else if (args is double) {
      _pesoInicial = args;
    } else if (args is String) {
      _pesoInicial = double.tryParse(args.replaceAll(',', '.')) ?? _pesoInicial;
    }

    _carregarTemperaturaAmbiente();
  }

  @override
  void dispose() {
    _pesoFinalController.dispose();
    _temperaturaController.dispose();
    super.dispose();
  }

  Future<void> _carregarTemperaturaAmbiente() async {
    try {
      double? temperature;
      bool backendRequested = false;

      if (AuthStorage.token.isNotEmpty) {
        backendRequested = true;
        final dashboardData = await AtletaService.obterDashboardAtleta(
          token: AuthStorage.token,
        );
        final tempFromDashboard = dashboardData['temperatura'];
        temperature = tempFromDashboard is num
            ? tempFromDashboard.toDouble()
            : double.tryParse(tempFromDashboard?.toString() ?? '');
      }

      if (temperature == null || temperature <= 0) {
        if (backendRequested) {
          throw Exception('Temperatura não disponível no dashboard. Preencha manualmente.');
        }

        final geoResponse = await http
            .get(Uri.parse('https://geolocation-db.com/json/'))
            .timeout(const Duration(seconds: 8));
        if (geoResponse.statusCode != 200) throw Exception('Geolocation failed');

        final geoJson = jsonDecode(geoResponse.body);
        final latitude = (geoJson['latitude'] as num?)?.toDouble();
        final longitude = (geoJson['longitude'] as num?)?.toDouble();
        if (latitude == null || longitude == null) throw Exception('Location missing');

        final weatherResponse = await http
            .get(Uri.parse(
                'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&current_weather=true&temperature_unit=celsius'))
            .timeout(const Duration(seconds: 8));
        if (weatherResponse.statusCode != 200) throw Exception('Weather failed');

        final weatherJson = jsonDecode(weatherResponse.body);
        final current = weatherJson['current_weather'];
        if (current == null) throw Exception('Weather data missing');

        temperature = (current['temperature'] as num?)?.toDouble();
      }

      if (!mounted) return;
      setState(() {
        _temperaturaAmbiente = temperature;
        _temperaturaController.text = temperature?.toStringAsFixed(1) ?? '';
        _temperaturaCarregando = false;
        _temperaturaFalha = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _temperaturaCarregando = false;
        _temperaturaFalha = true;
      });
      debugPrint('Erro ao carregar temperatura ambiente: $error');
    }
  }

  void _toggleSintoma(String sintoma) {
    setState(() {
      if (sintoma == 'Nenhum') {
        _sintomasSelecionados
          ..clear()
          ..add(sintoma);
        return;
      }

      _sintomasSelecionados.remove('Nenhum');
      if (_sintomasSelecionados.contains(sintoma)) {
        _sintomasSelecionados.remove(sintoma);
      } else {
        _sintomasSelecionados.add(sintoma);
      }
    });
  }

  Future<void> _salvarSessao() async {
    final pesoFinal =
        double.tryParse(_pesoFinalController.text.replaceAll(',', '.')) ?? 0;

    final registro = SessaoFinalizada(
      pesoInicial: _pesoInicial,
      pesoFinal: pesoFinal,
      sintomas: _sintomasSelecionados.toList(),
      rpe: _rpe,
      corUrina: _urinaSelecionada,
      criadoEm: DateTime.now(),
    );

    int atletaId;
    try {
      atletaId = await AtletaService.obterAtletaIdAutenticado();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Atleta não autenticado: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      if (_temperaturaCarregando) {
        await _carregarTemperaturaAmbiente();
      }

      if (_temperaturaController.text.trim().isEmpty) {
        await _carregarTemperaturaAmbiente();
      }

      final temperaturaAmbienteText =
          _temperaturaController.text.replaceAll(',', '.').trim();
      final temperaturaAmbiente = double.tryParse(temperaturaAmbienteText) ??
          _temperaturaAmbiente;
      if (temperaturaAmbiente == null) {
        throw Exception('Temperatura ambiente não carregada. Preencha manualmente.');
      }

      final sessaoCriada = await AtletaService.criarSessao(
        atletaId: atletaId,
        temperaturaAmbiente: temperaturaAmbiente,
        umidadeRelativa: 65,
      );

      final int sessaoId = sessaoCriada['id'] is num
          ? (sessaoCriada['id'] as num).toInt()
          : int.tryParse(sessaoCriada['id']?.toString() ?? '') ?? 0;

      if (sessaoId <= 0) {
        throw Exception('ID da sessão inválido');
      }

      if ((_sessionDurationMinutes ?? 0) > 0) {
        await AtletaService.finalizarSessao(
          sessaoId: sessaoId,
          durationMinutos: _sessionDurationMinutes!,
        );
      }

      if (_sessionTotalMl > 0) {
        await AtletaService.registrarConsumoSessao(
          sessaoId: sessaoId,
          quantidadeMl: _sessionTotalMl,
          tempoDecorridoMinutos: _sessionDurationMinutes,
        );
      }

      SessaoStore.salvar(registro);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sessao salva com sucesso'),
          backgroundColor: _lime,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar sessão: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Navigator.of(context).pushReplacementNamed(AppRotas.dashboardAtleta);
  }

  void _descartarRegistro() {
    Navigator.of(context).pushReplacementNamed(AppRotas.dashboardAtleta);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 28),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildTopBar(),
                      const SizedBox(height: 18),
                      _buildHeader(),
                      const SizedBox(height: 18),
                      _buildWeightCard(),
                      const SizedBox(height: 14),
                      _buildTemperatureCard(),
                      const SizedBox(height: 14),
                      _buildSymptomsCard(),
                      const SizedBox(height: 14),
                      _buildRpeCard(),
                      const SizedBox(height: 14),
                      _buildUrineCard(),
                      const SizedBox(height: 20),
                      _buildSaveButton(),
                      const SizedBox(height: 10),
                      _buildDiscardButton(),
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
        const Icon(Icons.water_drop, color: _lime, size: 15),
        const SizedBox(width: 5),
        const Text(
          'H2OTRACK',
          style: TextStyle(
            color: _lime,
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
        const Spacer(),
        Container(
          width: 25,
          height: 25,
          decoration: BoxDecoration(
            color: _surfaceLight,
            shape: BoxShape.circle,
            border: Border.all(color: _cyan.withValues(alpha: 0.3)),
          ),
          alignment: Alignment.center,
          child: const Text(
            'RS',
            style: TextStyle(
              color: _lime,
              fontSize: 7,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'POS-SESSAO',
          style: TextStyle(
            color: _text,
            fontSize: 21,
            fontWeight: FontWeight.w900,
            height: 1,
          ),
        ),
        SizedBox(height: 9),
        Text(
          'Registre os dados vitais e percepcoes imediatamente apos o termino do treino para uma analise de precisao.',
          style: TextStyle(color: _muted, fontSize: 11, height: 1.35),
        ),
      ],
    );
  }

  Widget _buildWeightCard() {
    return _buildPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPanelTitle('MASSA CORPORAL', trailing: Icons.open_in_full),
          const SizedBox(height: 18),
          _buildWeightRow('PRE-SESSAO', _pesoInicial.toStringAsFixed(1)),
          const SizedBox(height: 14),
          const Text(
            'PESO ATUAL',
            style: TextStyle(
              color: _muted,
              fontSize: 8,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.6,
            ),
          ),
          const SizedBox(height: 5),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                width: 92,
                child: TextField(
                  controller: _pesoFinalController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: const TextStyle(
                    color: _text,
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 9,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: const BorderSide(color: _lime),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              const Padding(
                padding: EdgeInsets.only(bottom: 5),
                child: Text(
                  'kg',
                  style: TextStyle(
                    color: _lime,
                    fontSize: 18,
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

  Widget _buildTemperatureCard() {
    return _buildPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPanelTitle('TEMPERATURA DO AMBIENTE', trailing: Icons.thermostat_outlined),
          const SizedBox(height: 18),
          const Text(
            'A temperatura será usada para ajustar a recomendação da sessão.',
            style: TextStyle(
              color: _muted,
              fontSize: 10,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          if (_temperaturaCarregando)
            const Text(
              'Carregando temperatura ambiente...',
              style: TextStyle(color: _muted, fontSize: 12),
            )
          else if (_temperaturaFalha)
            const Text(
              'Falha ao carregar temperatura. Preencha manualmente abaixo.',
              style: TextStyle(color: Colors.red, fontSize: 12),
            )
          else
            const SizedBox.shrink(),
          const SizedBox(height: 8),
          TextField(
            controller: _temperaturaController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              fillColor: Colors.white,
              filled: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 12,
              ),
              hintText: 'Temperatura em °C',
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: const BorderSide(color: _lime),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _muted,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.4,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            color: _text,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _buildSymptomsCard() {
    return _buildPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPanelTitle('SINTOMAS GASTROINTESTINAIS'),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 9,
            children: [
              for (final sintoma in _sintomas)
                _ChoicePill(
                  label: sintoma.toUpperCase(),
                  selected: _sintomasSelecionados.contains(sintoma),
                  onTap: () => _toggleSintoma(sintoma),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRpeCard() {
    return _buildPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildPanelTitle('PERCEPCAO DE ESFORCO (RPE)'),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: _lime,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text(
                  '$_rpe/10',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Row(
            children: [
              Text(
                'MUITO LEVE',
                style: TextStyle(
                  color: _muted,
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Spacer(),
              Text(
                'EXAUSTAO',
                style: TextStyle(
                  color: _muted,
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              for (var i = 1; i <= 10; i++)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: i == 10 ? 0 : 4),
                    child: InkWell(
                      onTap: () => setState(() => _rpe = i),
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        height: 27,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _rpe == i ? _lime : _surfaceLight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '$i',
                          style: TextStyle(
                            color: _rpe == i ? Colors.white : _muted,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
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

  Widget _buildUrineCard() {
    return _buildPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPanelTitle('COR DA URINA'),
          const SizedBox(height: 8),
          const Text(
            'Selecione a tonalidade que mais se aproxima para estimar seu nivel de hidratacao.',
            style: TextStyle(color: _muted, fontSize: 9, height: 1.25),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(7),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (var i = 0; i < _urinaCores.length; i++)
                  InkWell(
                    onTap: () => setState(() => _urinaSelecionada = i),
                    customBorder: const CircleBorder(),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: _urinaCores[i],
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _urinaSelecionada == i ? _lime : Colors.white,
                          width: 2,
                        ),
                      ),
                      child: _urinaSelecionada == i
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            )
                          : null,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPanel({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _surfaceLight),
      ),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(left: BorderSide(color: _lime, width: 2)),
        ),
        child: Padding(padding: const EdgeInsets.only(left: 12), child: child),
      ),
    );
  }

  Widget _buildPanelTitle(String title, {IconData? trailing}) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: _lime,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
        if (trailing != null) ...[
          const Spacer(),
          Icon(trailing, color: _muted, size: 15),
        ],
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 45,
      child: FilledButton.icon(
        onPressed: _salvarSessao,
        style: FilledButton.styleFrom(
          backgroundColor: _lime,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        icon: const Icon(Icons.save_outlined, size: 16),
        label: const Text(
          'SALVAR SESSAO',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildDiscardButton() {
    return SizedBox(
      width: double.infinity,
      height: 42,
      child: OutlinedButton(
        onPressed: _descartarRegistro,
        style: OutlinedButton.styleFrom(
          foregroundColor: _muted,
          side: const BorderSide(color: _surfaceLight),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        child: const Text(
          'DESCARTAR REGISTRO',
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.4,
          ),
        ),
      ),
    );
  }
}

class _ChoicePill extends StatelessWidget {
  const _ChoicePill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const lime = Color(0xFFB32025);
    const muted = Color(0xFF6B6B6B);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? lime.withValues(alpha: 0.18) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: selected ? lime : Colors.transparent),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? lime : muted,
            fontSize: 8,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.6,
          ),
        ),
      ),
    );
  }
}

class SessaoFinalizada {
  const SessaoFinalizada({
    required this.pesoInicial,
    required this.pesoFinal,
    required this.sintomas,
    required this.rpe,
    required this.corUrina,
    required this.criadoEm,
  });

  final double pesoInicial;
  final double pesoFinal;
  final List<String> sintomas;
  final int rpe;
  final int corUrina;
  final DateTime criadoEm;
}

abstract final class SessaoStore {
  static final List<SessaoFinalizada> sessoes = [];

  static void salvar(SessaoFinalizada sessao) {
    sessoes.add(sessao);
  }
}
