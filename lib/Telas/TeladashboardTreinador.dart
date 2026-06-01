import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hidratrack/Modelos/AtletaListModels.dart';
import 'package:hidratrack/Modelos/DashboardModels.dart';
import 'package:hidratrack/Modelos/EquipesModels.dart';
import 'package:hidratrack/Servicos/EquipeService.dart';
import 'package:hidratrack/Telas/Telacadastro.dart';
import 'package:hidratrack/Telas/TelacriarEquipe.dart';
import 'package:hidratrack/Telas/TeladadosEquipe.dart';
import 'package:hidratrack/Telas/TelavizualizarAtletas.dart';
import 'package:share_plus/share_plus.dart';

class TelaDashboardTreinador extends StatefulWidget {
  const TelaDashboardTreinador({
    super.key,
    this.initialTab = 0,
    this.initialNavIndex = 0,
  });

  final int initialTab;
  final int initialNavIndex;

  @override
  State<TelaDashboardTreinador> createState() => _TelaDashboardTreinadorState();
}

class _TelaDashboardTreinadorState extends State<TelaDashboardTreinador> {
  static const _background = Color(0xFFFFFFFF);
  static const _surface = Color(0xFFF7F7F7);
  static const _surfaceLight = Color(0xFFEDEDED);
  static const _lime = Color(0xFFB32025);
  static const _cyan = Color(0xFF8F171B);
  static const _text = Color(0xFF222222);
  static const _muted = Color(0xFF6B6B6B);
  static const _danger = Color(0xFFB32025);

  late int _selectedTab;
  late int _currentNavIndex;
  bool _carregandoClima = true;
  ClimaDados? _climaDados;

  bool _carregandoDados = true;
  List<Equipe> _equipes = [];
  List<AtletaListItem> _atletas = [];
  List<Atleta> _alertas = [];

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab;
    _currentNavIndex = widget.initialNavIndex;
    _carregarClima();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    final equipes = await EquipeService.listarEquipes();
    final atletas = await EquipeService.listarAtletas();
    final alertas = atletas
        .where((atleta) => atleta.hidratacao < 50)
        .map(
          (atleta) => Atleta(
            id: atleta.id,
            nome: '${atleta.nome} (${atleta.categoria})',
            situacao: atleta.status,
            descricao: '${100 - atleta.hidratacao}% deficit',
            iconType: IconType.alerta,
          ),
        )
        .toList();

    if (!mounted) return;
    setState(() {
      _equipes = equipes;
      _atletas = atletas;
      _alertas = alertas;
      _carregandoDados = false;
    });
  }

  Future<void> _carregarClima() async {
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() {
      _climaDados = ClimaDados(
        temperatura: 31,
        umidade: 42,
        condicao: 'SP, BR - Seco',
      );
      _carregandoClima = false;
    });
  }

  int get _totalAtletas =>
      _equipes.fold<int>(0, (total, equipe) => total + equipe.numeroAtletas);

  void _selecionarNav(int index) {
    setState(() => _currentNavIndex = index);

    switch (index) {
      case 0:
        setState(() => _selectedTab = 0);
        break;
      case 1:
        Navigator.of(context).pushNamed('/graficos');
        break;
    }
  }

  Future<void> _acaoPrincipal() async {
    if (_selectedTab == 0) {
      final mudou = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (context) => const TelacriarEquipe()),
      );
      if (mudou == true) {
        await _carregarDados();
      }
      return;
    }

    _mostrarPopupCadastroAtleta();
  }

  void _mostrarPopupCadastroAtleta() {
    const linkUrl = 'https://hidratrack.app/cadastro-atleta';

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: _surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Compartilhar cadastro',
              style: TextStyle(
                color: _text,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            const SelectableText(
              linkUrl,
              style: TextStyle(
                color: _cyan,
                decoration: TextDecoration.underline,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: _lime),
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      await Clipboard.setData(
                        const ClipboardData(text: linkUrl),
                      );
                      if (!dialogContext.mounted || !context.mounted) return;
                      Navigator.of(dialogContext).pop();
                      messenger.showSnackBar(
                        const SnackBar(content: Text('Link copiado')),
                      );
                    },
                    child: const Text(
                      'COPIAR',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _text,
                      side: const BorderSide(color: _muted),
                    ),
                    onPressed: () =>
                        SharePlus.instance.share(ShareParams(text: linkUrl)),
                    child: const Text('ENVIAR'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const TelaCadastroAtleta(),
                    ),
                  );
                },
                child: const Text('ABRIR CADASTRO'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      floatingActionButton: FloatingActionButton(
        onPressed: _acaoPrincipal,
        backgroundColor: _lime,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 30),
      ),
      bottomNavigationBar: _buildBottomNav(context),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth >= 600 ? 24.0 : 16.0;
            final contentWidth = constraints.maxWidth >= 760
                ? 520.0
                : double.infinity;

            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: contentWidth),
                child: CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        14,
                        horizontalPadding,
                        24,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          _buildHeader(),
                          const SizedBox(height: 22),
                          _buildMetricCards(),
                          const SizedBox(height: 22),
                          _buildTabs(),
                          const SizedBox(height: 14),
                          if (_carregandoDados)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(24),
                                child: CircularProgressIndicator(color: _lime),
                              ),
                            )
                          else if (_selectedTab == 0)
                            ..._equipes.map(_buildEquipeCard)
                          else
                            ..._atletas.map(_buildAtletaCard),
                          const SizedBox(height: 16),
                          _buildSectionTitle('ALERTAS RECENTES'),
                          const SizedBox(height: 10),
                          ..._alertas.map(_buildAlertaCard),
                          const SizedBox(height: 64),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'H2OTRACK',
          style: TextStyle(
            color: _text,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 34),
        Text(
          'DASHBOARD',
          style: TextStyle(
            color: _lime,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Painel do Treinador',
          style: TextStyle(
            color: _text,
            fontSize: 24,
            fontWeight: FontWeight.w800,
            height: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCards() {
    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            label: 'Atletas Ativos',
            value: _totalAtletas.toString().padLeft(2, '0'),
            accent: '+12%',
            accentColor: _lime,
            icon: Icons.groups_2_outlined,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MetricCard(
            label: 'Clima Local',
            value: _carregandoClima
                ? '--'
                : '${_climaDados!.temperatura.toStringAsFixed(0)}C',
            accent: _carregandoClima ? 'carregando' : _climaDados!.condicao,
            accentColor: _muted,
            icon: Icons.cloud_outlined,
          ),
        ),
      ],
    );
  }

  Widget _buildTabs() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildTabButton('MINHAS EQUIPES', 0)),
            Expanded(child: _buildTabButton('MEUS ATLETAS', 1)),
          ],
        ),
        Container(height: 1, color: _surfaceLight),
      ],
    );
  }

  Widget _buildTabButton(String label, int index) {
    final selected = _selectedTab == index;

    return InkWell(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected ? _lime : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? _lime : _text,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: _muted,
        fontSize: 11,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.6,
      ),
    );
  }

  Widget _buildEquipeCard(Equipe equipe) {
    final isPrimary = equipe.id == 1;
    final accent = isPrimary ? _lime : _cyan;

    return InkWell(
      borderRadius: BorderRadius.circular(7),
      onTap: () async {
        final mudou = await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (context) => TeladadosEquipe(equipe: equipe),
          ),
        );
        if (mudou == true) {
          await _carregarDados();
        }
      },
      child: Container(
        height: 166,
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.fromLTRB(18, 16, 12, 14),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(7),
          border: Border(left: BorderSide(color: accent, width: 3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        equipe.nome,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _text,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        equipe.status,
                        style: const TextStyle(
                          color: _text,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.more_vert, color: _text, size: 19),
              ],
            ),
            const Spacer(),
            Row(
              children: [
                _buildSmallStat(
                  'ATLETAS',
                  equipe.numeroAtletas.toString().padLeft(2, '0'),
                ),
                const SizedBox(width: 54),
                _buildSmallStat(
                  'HIDRATACAO AVG',
                  '${equipe.percentualHidratacao.toStringAsFixed(0)}%',
                  color: accent,
                ),
              ],
            ),
            const Spacer(),
            Row(
              children: [
                _buildAvatarStrip(equipe.id),
                const Spacer(),
                Icon(Icons.chevron_right, color: accent, size: 24),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAtletaCard(AtletaListItem atleta) {
    final isCritical = atleta.hidratacao < 50;
    final accent = isCritical ? _danger : _cyan;

    return InkWell(
      borderRadius: BorderRadius.circular(7),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => TelaVisualizarAtletas(atleta: atleta),
          ),
        );
      },
      child: Container(
        height: 166,
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.fromLTRB(18, 16, 12, 14),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(7),
          border: Border(left: BorderSide(color: accent, width: 3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        atleta.nome,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _text,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        atleta.status,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _text,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.more_vert, color: _text, size: 19),
              ],
            ),
            const Spacer(),
            Row(
              children: [
                _buildSmallStat('CATEGORIA', atleta.categoria),
                const SizedBox(width: 54),
                _buildSmallStat(
                  'HIDRATACAO',
                  '${atleta.hidratacao.toStringAsFixed(0)}%',
                  color: accent,
                ),
              ],
            ),
            const Spacer(),
            Row(
              children: [
                CircleAvatar(
                  radius: 13,
                  backgroundColor: _surfaceLight,
                  child: Text(
                    atleta.nome.characters.first,
                    style: const TextStyle(
                      color: _text,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(Icons.chevron_right, color: accent, size: 24),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallStat(String label, String value, {Color color = _text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _muted,
            fontSize: 8,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarStrip(int seed) {
    final colors = [
      const Color(0xFF1E5D66),
      const Color(0xFF263A68),
      const Color(0xFF245C4A),
      const Color(0xFF303030),
    ];

    return SizedBox(
      height: 26,
      width: 92,
      child: Stack(
        children: [
          for (var i = 0; i < 3; i++)
            Positioned(
              left: i * 18,
              child: Container(
                height: 26,
                width: 26,
                decoration: BoxDecoration(
                  color: colors[(i + seed) % colors.length],
                  shape: BoxShape.circle,
                  border: Border.all(color: _surface, width: 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  String.fromCharCode(65 + seed + i),
                  style: const TextStyle(
                    color: _text,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          Positioned(
            left: 54,
            child: Container(
              height: 26,
              width: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF343434),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _surface, width: 2),
              ),
              alignment: Alignment.center,
              child: Text(
                '+${seed == 1 ? 19 : 6}',
                style: const TextStyle(
                  color: _text,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertaCard(Atleta alerta) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _surfaceLight),
      ),
      child: Row(
        children: [
          Container(
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              color: _danger.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.warning_amber_rounded, color: _danger),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alerta.nome,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _text,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${alerta.situacao.toUpperCase()} - ${alerta.descricao.toUpperCase()}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _text,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _danger,
              borderRadius: BorderRadius.circular(3),
            ),
            child: const Text(
              'AGIR',
              style: TextStyle(
                color: Colors.white,
                fontSize: 8,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    const items = [
      (Icons.home_rounded, 'HOME'),
      (Icons.analytics_outlined, 'ANALISE'),
    ];

    return Container(
      height: 72 + bottomInset,
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (var i = 0; i < items.length; i++)
            InkWell(
              onTap: () => _selecionarNav(i),
              child: SizedBox(
                width: 104,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      items[i].$1,
                      color: _currentNavIndex == i ? _lime : _muted,
                      size: 22,
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        items[i].$2,
                        style: TextStyle(
                          color: _currentNavIndex == i ? _lime : _muted,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
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
    required this.label,
    required this.value,
    required this.accent,
    required this.accentColor,
    required this.icon,
  });

  final String label;
  final String value;
  final String accent;
  final Color accentColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 118,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _TelaDashboardTreinadorState._surface,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -8,
            top: -12,
            child: Icon(
              icon,
              color: Colors.white.withValues(alpha: 0.1),
              size: 70,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: _TelaDashboardTreinadorState._muted,
                  fontSize: 10,
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
                        style: const TextStyle(
                          color: _TelaDashboardTreinadorState._text,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        accent,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: accentColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
