import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hidratrack/Modelos/AtletaListModels.dart';
import 'package:hidratrack/Modelos/DashboardModels.dart';
import 'package:hidratrack/Modelos/EquipesModels.dart';
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
  static const _background = Color(0xFF101010);
  static const _surface = Color(0xFF1B1B1B);
  static const _surfaceLight = Color(0xFF242424);
  static const _lime = Color(0xFFB9FF00);
  static const _cyan = Color(0xFF00E5FF);
  static const _text = Color(0xFFF5F5F5);
  static const _muted = Color(0xFF858585);
  static const _danger = Color(0xFFFF455D);

  late int _selectedTab;
  late int _currentNavIndex;
  bool _carregandoClima = true;
  ClimaDados? _climaDados;

  late final List<Equipe> _equipes;
  late final List<AtletaListItem> _atletas;
  late final List<Atleta> _alertas;

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab;
    _currentNavIndex = widget.initialNavIndex;
    _equipes = [
      Equipe(
        id: 1,
        nome: 'Equipe Sub-20',
        status: 'FUTEBOL MASCULINO',
        numeroAtletas: 22,
        percentualHidratacao: 94,
        codigoEquipe: 'HT-AAAA01',
      ),
      Equipe(
        id: 2,
        nome: 'Equipe Olimpica',
        status: 'NATACAO',
        numeroAtletas: 8,
        percentualHidratacao: 81,
        codigoEquipe: 'HT-AAAA02',
      ),
      Equipe(
        id: 3,
        nome: 'Base Feminina',
        status: 'FUTEBOL FEMININO',
        numeroAtletas: 16,
        percentualHidratacao: 76,
        codigoEquipe: 'HT-AAAA03',
      ),
    ];
    _atletas = [
      AtletaListItem(
        id: 1,
        categoria: 'SUB-20',
        nome: 'Carlos Silva',
        status: 'DESIDRATACAO CRITICA',
        hidratacao: 4,
      ),
      AtletaListItem(
        id: 2,
        categoria: 'OLIMPICO',
        nome: 'Gabriel Santos',
        status: 'EM TREINO',
        hidratacao: 85,
      ),
      AtletaListItem(
        id: 3,
        categoria: 'SUB-17',
        nome: 'Lucas Ferreira',
        status: 'ATENCAO',
        hidratacao: 62,
      ),
      AtletaListItem(
        id: 4,
        categoria: 'MASTER',
        nome: 'Rodrigo Silva',
        status: 'DESCANSO',
        hidratacao: 88,
      ),
    ];
    _alertas = [
      Atleta(
        id: 1,
        nome: 'Carlos Silva (Sub-20)',
        situacao: 'Desidratacao critica',
        descricao: '4% perda',
        iconType: IconType.alerta,
      ),
    ];
    _carregarClima();
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
        setState(() => _selectedTab = 0);
        break;
      case 2:
        Navigator.of(context).pushNamed('/graficos');
        break;
      case 3:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil do treinador em breve')),
        );
        break;
    }
  }

  void _acaoPrincipal() {
    if (_selectedTab == 0) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => const TelacriarEquipe()));
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
                      style: TextStyle(color: Colors.black),
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
        foregroundColor: Colors.black,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 30),
      ),
      bottomNavigationBar: _buildBottomNav(),
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
                          if (_selectedTab == 0)
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
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => TeladadosEquipe(equipe: equipe),
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
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(7),
          border: Border(left: BorderSide(color: accent, width: 3)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 19,
              backgroundColor: _surfaceLight,
              child: Text(
                atleta.nome.characters.first,
                style: const TextStyle(
                  color: _text,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 12),
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
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${atleta.categoria} / ${atleta.status}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _muted,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${atleta.hidratacao}%',
              style: TextStyle(
                color: accent,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
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

  Widget _buildBottomNav() {
    const items = [
      (Icons.home_rounded, 'HOME'),
      (Icons.groups_2_outlined, 'EQUIPES'),
      (Icons.history_rounded, 'HISTORICO'),
      (Icons.person_outline_rounded, 'PERFIL'),
    ];

    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
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
                width: 74,
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
