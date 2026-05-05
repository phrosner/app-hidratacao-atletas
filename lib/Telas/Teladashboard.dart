import 'package:flutter/material.dart';
import 'package:hidratrack/Modelos/DashboardModels.dart';
import 'package:hidratrack/Componentes/BottomNavBarClass.dart';
import 'package:hidratrack/Componentes/ResponsiveContent.dart';

class TelaDAshboard extends StatefulWidget {
  const TelaDAshboard({super.key});

  @override
  State<TelaDAshboard> createState() => _TelaDAshboardState();
}

class _TelaDAshboardState extends State<TelaDAshboard> {
  late int _currentNavIndex = 0;
  final int _numeroAtletas = 24;
  ClimaDados? _climaDados;
  late bool _carregandoClima = true;

  late List<Atleta> _atletasFeed;

  @override
  void initState() {
    super.initState();
    _atletasFeed = [
      Atleta(
        id: 1,
        nome: "Pedro A.",
        situacao: "Aviso",
        descricao: "Pedro A. registrou atraso da meta (40%).",
        iconType: IconType.alerta,
      ),
      Atleta(
        id: 2,
        nome: "Ana B.",
        situacao: "Info",
        descricao: "Ana B. atingiu recente pessoal de VO2 Max.",
        iconType: IconType.info,
      ),
    ];
    _carregarClima();
  }

  Future<void> _carregarClima() async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _climaDados = ClimaDados(
        temperatura: 28,
        umidade: 65,
        condicao: "Parcialmente Nublado",
      );
      _carregandoClima = false;
    });
  }

  void _navegarTela(int index) {
    switch (index) {
      case 0:
        Navigator.of(context).pushReplacementNamed('/dashboard');
        break;
      case 1:
        Navigator.of(context).pushReplacementNamed('/equipes');
        break;
      case 2:
        Navigator.of(context).pushReplacementNamed('/atletas');
        break;
      case 3:
        Navigator.of(context).pushReplacementNamed('/graficos');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    final isDesktop = size.width >= 900;

    return Scaffold(
      backgroundColor: const Color(0xFF1A0003),
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "TRAINER DASHBOARD",
          style: TextStyle(
            color: Color(0xFFFFD6DA),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: ResponsiveContent(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Olá, Treinador",
                  style: TextStyle(
                    color: const Color(0xFFFFD6DA),
                    fontSize: isDesktop ? 36 : 28,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Bebas Neue',
                    letterSpacing: 1,
                  ),
                ),
                const Text(
                  "Pronto para entregar os limites hoje.",
                  style: TextStyle(color: Color(0xFF8B6B6C), fontSize: 14),
                ),
                const SizedBox(height: 24),

                if (isDesktop)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildAtletasCard(isMobile)),
                      const SizedBox(width: 18),
                      Expanded(child: _buildClimaCard(isMobile)),
                    ],
                  )
                else ...[
                  _buildAtletasCard(isMobile),
                  const SizedBox(height: 16),
                  _buildClimaCard(isMobile),
                ],
                const SizedBox(height: 24),

                const Text(
                  "FEED DE ATLETAS",
                  style: TextStyle(
                    color: Color(0xFF6B9BD1),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 12),

                if (_atletasFeed.isEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    alignment: Alignment.center,
                    child: const Text(
                      "Sem notificações no momento",
                      style: TextStyle(color: Color(0xFF8B6B6C), fontSize: 14),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _atletasFeed.length,
                    itemBuilder: (context, index) {
                      final atleta = _atletasFeed[index];
                      return _buildFeedCard(atleta);
                    },
                  ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          setState(() {
            _currentNavIndex = index;
          });
          _navegarTela(index);
        },
      ),
    );
  }

  Widget _buildAtletasCard(bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2D1B1B),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.people, color: Color(0xFF6B9BD1), size: 16),
              const SizedBox(width: 8),
              const Text(
                "ATLETAS ATIVOS",
                style: TextStyle(
                  color: Color(0xFFFFD6DA),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _numeroAtletas.toString(),
            style: const TextStyle(
              color: Color(0xFFFFD6DA),
              fontSize: 48,
              fontWeight: FontWeight.bold,
              fontFamily: 'Bebas Neue',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClimaCard(bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2D1B1B),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.cloud, color: Color(0xFF6B9BD1), size: 16),
              const SizedBox(width: 8),
              const Text(
                "CLIMA",
                style: TextStyle(
                  color: Color(0xFFFFD6DA),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_carregandoClima)
            const SizedBox(
              height: 60,
              child: Center(
                child: SizedBox(
                  height: 30,
                  width: 30,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF6B9BD1),
                    ),
                    strokeWidth: 2,
                  ),
                ),
              ),
            )
          else if (_climaDados != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${_climaDados!.temperatura}°C",
                          style: const TextStyle(
                            color: Color(0xFFFFD6DA),
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Bebas Neue',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _climaDados!.condicao,
                          style: const TextStyle(
                            color: Color(0xFF8B6B6C),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const Icon(
                      Icons.thermostat,
                      color: Color(0xFFFFD6DA),
                      size: 40,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(
                      Icons.opacity,
                      color: Color(0xFF6B9BD1),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Umidade: ${_climaDados!.umidade}%",
                      style: const TextStyle(
                        color: Color(0xFF8B6B6C),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            )
          else
            const Center(
              child: Text(
                "Erro ao carregar clima",
                style: TextStyle(color: Color(0xFF8B6B6C), fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFeedCard(Atleta atleta) {
    final isAlert = atleta.iconType == IconType.alerta;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2D1B1B),
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(
            color: isAlert ? const Color(0xFFD19CA0) : const Color(0xFF6B9BD1),
            width: 3,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isAlert
                  ? const Color(0xFFD19CA0).withValues(alpha: 0.2)
                  : const Color(0xFF6B9BD1).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Icon(
                isAlert ? Icons.warning : Icons.info,
                color: isAlert
                    ? const Color(0xFFD19CA0)
                    : const Color(0xFF6B9BD1),
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  atleta.situacao,
                  style: TextStyle(
                    color: isAlert
                        ? const Color(0xFFD19CA0)
                        : const Color(0xFF6B9BD1),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  atleta.descricao,
                  style: const TextStyle(
                    color: Color(0xFFFFD6DA),
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
