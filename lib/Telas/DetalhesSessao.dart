import 'package:flutter/material.dart';
import 'package:hidratrack/Componentes/ResponsiveLayout.dart';
import 'package:hidratrack/Servicos/AtletaService.dart';
import 'package:hidratrack/Servicos/AuthStorage.dart';
import 'package:hidratrack/app_rotas.dart';

class DetalhesSessao extends StatefulWidget {
  const DetalhesSessao({super.key});

  @override
  State<DetalhesSessao> createState() => _DetalhesSessaoState();
}

class _DetalhesSessaoState extends State<DetalhesSessao> {
  static const _background = Color(0xFFFFFFFF);
  static const _surface = Color(0xFFF7F7F7);
  static const _surfaceLight = Color(0xFFEDEDED);
  static const _lime = Color(0xFFB32025);
  static const _cyan = Color(0xFF8F171B);
  static const _text = Color(0xFF222222);
  static const _muted = Color(0xFF6B6B6B);

  Map<String, dynamic>? _sessaoData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is int && _sessaoData == null) {
      _carregarDetalhesSessao(args);
    }
  }

  Future<void> _carregarDetalhesSessao(int sessaoId) async {
    if (AuthStorage.token.isEmpty) {
      setState(() {
        _errorMessage = 'Token não encontrado';
        _isLoading = false;
      });
      return;
    }

    try {
      final data = await AtletaService.obterMetricasSessao(
        token: AuthStorage.token,
        sessaoId: sessaoId,
      );
      if (mounted) {
        setState(() {
          _sessaoData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Erro ao carregar detalhes: $e';
          _isLoading = false;
        });
      }
    }
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
                      if (_isLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(28),
                            child: CircularProgressIndicator(color: _lime),
                          ),
                        )
                      else if (_errorMessage != null)
                        _buildErrorState()
                      else if (_sessaoData != null)
                        ..._buildSessionDetails(),
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
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, color: _lime, size: 20),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints.tightFor(width: 32, height: 32),
        ),
        const SizedBox(width: 8),
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
      ],
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DETALHES DA SESSAO',
          style: TextStyle(
            color: _text,
            fontSize: 21,
            fontWeight: FontWeight.w900,
            height: 1,
          ),
        ),
        SizedBox(height: 9),
        Text(
          'Visualize todas as informações registradas nesta sessão de treino.',
          style: TextStyle(color: _muted, fontSize: 11, height: 1.35),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: _lime, size: 48),
          const SizedBox(height: 12),
          Text(
            _errorMessage ?? 'Erro desconhecido',
            style: const TextStyle(color: _muted, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSessionDetails() {
    final data = _sessaoData!;
    final List<Widget> widgets = [];

    // Massa Corporal (Body Mass)
    final pesoInicial = data['pesoInicial'] != null
        ? (data['pesoInicial'] is num
            ? (data['pesoInicial'] as num).toDouble()
            : double.tryParse(data['pesoInicial'].toString()))
        : null;
    final pesoFinal = data['pesoFinal'] != null
        ? (data['pesoFinal'] is num
            ? (data['pesoFinal'] as num).toDouble()
            : double.tryParse(data['pesoFinal'].toString()))
        : null;
    
    widgets.add(_buildWeightCard(pesoInicial, pesoFinal));
    widgets.add(const SizedBox(height: 14));

    // Temperatura do Ambiente
    final temperatura = data['temperaturaAmbiente'] != null
        ? (data['temperaturaAmbiente'] is num
            ? (data['temperaturaAmbiente'] as num).toDouble()
            : double.tryParse(data['temperaturaAmbiente'].toString()))
        : null;
    
    if (temperatura != null) {
      widgets.add(_buildTemperatureCard(temperatura));
      widgets.add(const SizedBox(height: 14));
    }

    // Sintomas Gastrointestinais
    List<String> sintomas = [];
    if (data['sintomas'] != null) {
      if (data['sintomas'] is List) {
        sintomas = (data['sintomas'] as List).map((e) => e.toString()).toList();
      } else if (data['sintomas'] is String) {
        final sintomasStr = data['sintomas'] as String;
        if (sintomasStr.contains(',')) {
          sintomas = sintomasStr.split(',').map((s) => s.trim()).toList();
        } else {
          sintomas = [sintomasStr];
        }
      }
    }
    
    widgets.add(_buildSymptomsCard(sintomas));
    widgets.add(const SizedBox(height: 14));

    // RPE (Percepção de Esforço)
    final rpe = data['rpe'] != null
        ? (data['rpe'] is num
            ? (data['rpe'] as num).toInt()
            : int.tryParse(data['rpe'].toString()))
        : null;
    
    if (rpe != null) {
      widgets.add(_buildRpeCard(rpe));
      widgets.add(const SizedBox(height: 14));
    }

    // Cor da Urina
    final corUrina = data['corUrina'] != null
        ? (data['corUrina'] is num
            ? (data['corUrina'] as num).toInt()
            : int.tryParse(data['corUrina'].toString()))
        : null;
    
    if (corUrina != null && corUrina >= 0 && corUrina < 6) {
      widgets.add(_buildUrineCard(corUrina));
      widgets.add(const SizedBox(height: 14));
    }

    // Additional info cards (duration, volume, etc.)
    if (data['durationMinutos'] != null || data['duracaoMinutos'] != null) {
      final duracao = (data['durationMinutos'] ?? data['duracaoMinutos']) != null
          ? ((data['durationMinutos'] ?? data['duracaoMinutos']) is num
              ? ((data['durationMinutos'] ?? data['duracaoMinutos']) as num).toInt()
              : int.tryParse((data['durationMinutos'] ?? data['duracaoMinutos']).toString()))
          : null;
      if (duracao != null) {
        widgets.add(_buildInfoCard(
          'DURACAO DO TREINO',
          '$duracao minutos',
          Icons.access_time,
        ));
        widgets.add(const SizedBox(height: 14));
      }
    }

    // Calculate volume from consumos
    double? volumeLitros;
    if (data['consumos'] != null && data['consumos'] is List) {
      final consumos = data['consumos'] as List;
      int totalMl = 0;
      for (var consumo in consumos) {
        if (consumo is Map && consumo['quantidadeMl'] != null) {
          totalMl += (consumo['quantidadeMl'] is num
              ? (consumo['quantidadeMl'] as num).toInt()
              : int.tryParse(consumo['quantidadeMl'].toString()) ?? 0);
        }
      }
      volumeLitros = totalMl / 1000;
    }

    if (volumeLitros != null && volumeLitros > 0) {
      widgets.add(_buildInfoCard(
        'AGUA CONSUMIDA',
        '${volumeLitros.toStringAsFixed(2)} L',
        Icons.water_drop,
      ));
      widgets.add(const SizedBox(height: 14));
    }

    if (data['stats'] != null && data['stats'] is Map) {
      final stats = data['stats'] as Map;
      final taxaSudorese = stats['taxaSudoreseMedia'];
      if (taxaSudorese != null) {
        final taxa = taxaSudorese is num
            ? taxaSudorese.toDouble()
            : double.tryParse(taxaSudorese.toString());
        if (taxa != null) {
          widgets.add(_buildInfoCard(
            'TAXA DE SUDORESE',
            '${taxa.toStringAsFixed(2)} L/h',
            Icons.show_chart,
          ));
          widgets.add(const SizedBox(height: 14));
        }
      }
    }

    if (data['tipoTreino'] != null) {
      widgets.add(_buildInfoCard(
        'TIPO DE TREINO',
        data['tipoTreino'].toString(),
        Icons.directions_run,
      ));
      widgets.add(const SizedBox(height: 14));
    }

    if (data['dataInicio'] != null) {
      final dataHora = DateTime.tryParse(data['dataInicio'].toString()) ?? DateTime.now();
      widgets.add(_buildInfoCard(
        'DATA E HORA',
        _formatDateTime(dataHora),
        Icons.calendar_today,
      ));
      widgets.add(const SizedBox(height: 14));
    }

    return widgets;
  }

  Widget _buildWeightCard(double? pesoInicial, double? pesoFinal) {
    return _buildPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPanelTitle('MASSA CORPORAL', trailing: Icons.open_in_full),
          const SizedBox(height: 18),
          _buildWeightRow(
            'PRE-SESSAO',
            pesoInicial != null ? pesoInicial.toStringAsFixed(1) : '--',
          ),
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
              Text(
                pesoFinal != null ? pesoFinal.toStringAsFixed(1) : '--',
                style: const TextStyle(
                  color: _text,
                  fontSize: 27,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              const SizedBox(width: 4),
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

  Widget _buildTemperatureCard(double temperatura) {
    return _buildPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPanelTitle('TEMPERATURA DO AMBIENTE', trailing: Icons.thermostat_outlined),
          const SizedBox(height: 18),
          const Text(
            'A temperatura registrada durante a sessão.',
            style: TextStyle(
              color: _muted,
              fontSize: 10,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                temperatura.toStringAsFixed(1),
                style: const TextStyle(
                  color: _text,
                  fontSize: 27,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              const SizedBox(width: 4),
              const Padding(
                padding: EdgeInsets.only(bottom: 5),
                child: Text(
                  '°C',
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

  Widget _buildSymptomsCard(List<String> sintomas) {
    final sintomasList = [
      'Nausea',
      'Refluxo',
      'Colica',
      'Estufamento',
      'Cefaleia',
      'Nenhum',
    ];

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
              for (final sintoma in sintomasList)
                _ChoicePill(
                  label: sintoma.toUpperCase(),
                  selected: sintomas.map((s) => s.toLowerCase()).contains(sintoma.toLowerCase()),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRpeCard(int rpe) {
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
                  '$rpe/10',
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
                    child: Container(
                      height: 27,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: rpe == i ? _lime : _surfaceLight,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '$i',
                        style: TextStyle(
                          color: rpe == i ? Colors.white : _muted,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
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

  Widget _buildUrineCard(int corIndex) {
    final urinaCores = const [
      Color(0xFFF9FFFF),
      Color(0xFFFFF4A8),
      Color(0xFFFFDD3D),
      Color(0xFFE8A51F),
      Color(0xFFD86B1D),
      Color(0xFF6B3A1E),
    ];

    return _buildPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPanelTitle('COR DA URINA'),
          const SizedBox(height: 8),
          const Text(
            'Cor da urina registrada ao final da sessão.',
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
                for (var i = 0; i < urinaCores.length; i++)
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: urinaCores[i],
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: corIndex == i ? _lime : Colors.white,
                        width: 2,
                      ),
                    ),
                    child: corIndex == i
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          )
                        : null,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return _buildPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPanelTitle(title, trailing: icon),
          const SizedBox(height: 14),
          Text(
            value,
            style: const TextStyle(
              color: _text,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              height: 1,
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

  String _formatDateTime(DateTime dateTime) {
    const meses = [
      'JAN', 'FEV', 'MAR', 'ABR', 'MAI', 'JUN',
      'JUL', 'AGO', 'SET', 'OUT', 'NOV', 'DEZ',
    ];
    final dia = dateTime.day.toString().padLeft(2, '0');
    final mes = meses[dateTime.month - 1];
    final ano = dateTime.year;
    final hora = dateTime.hour.toString().padLeft(2, '0');
    final minuto = dateTime.minute.toString().padLeft(2, '0');
    return '$dia $mes, $ano - $hora:$minuto';
  }
}

class _ChoicePill extends StatelessWidget {
  const _ChoicePill({
    required this.label,
    required this.selected,
  });

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    const lime = Color(0xFFB32025);
    const muted = Color(0xFF6B6B6B);

    return Container(
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
    );
  }
}
