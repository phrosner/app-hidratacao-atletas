import 'package:flutter/material.dart';
import 'package:hidratrack/Componentes/BottomNavBarClass.dart';
import 'package:hidratrack/Componentes/ResponsiveContent.dart';
import 'package:hidratrack/Modelos/AtletaListModels.dart';
import 'package:hidratrack/Telas/Telacadastro.dart';
import 'package:hidratrack/Telas/TeladadosAtletas.dart';

class TelaAtletas extends StatefulWidget {
  const TelaAtletas({super.key});

  @override
  State<TelaAtletas> createState() => _TelaAtletasState();
}

class _TelaAtletasState extends State<TelaAtletas> {
  int _currentNavIndex = 2;
  final TextEditingController _searchController = TextEditingController();
  late List<AtletaListItem> _atletas;
  late List<AtletaListItem> _atletasFiltrados;

  @override
  void initState() {
    super.initState();
    _atletas = [
      AtletaListItem(
        id: 1,
        categoria: 'SUB-20',
        nome: 'Gabriel Santos',
        status: 'EM TREINO',
        hidratacao: 85,
      ),
      AtletaListItem(
        id: 2,
        categoria: 'OLÍMPICO',
        nome: 'Matheus Oliveira',
        status: 'DESCANSO',
        hidratacao: 92,
      ),
      AtletaListItem(
        id: 3,
        categoria: 'SUB-17',
        nome: 'Lucas Ferreira',
        status: 'EM TREINO',
        hidratacao: 78,
      ),
      AtletaListItem(
        id: 4,
        categoria: 'MASTER',
        nome: 'Rodrigo Silva',
        status: 'DESCANSO',
        hidratacao: 88,
      ),
      AtletaListItem(
        id: 5,
        categoria: 'OLÍMPICO',
        nome: 'André Costa',
        status: 'EM TREINO',
        hidratacao: 95,
      ),
    ];
    _atletasFiltrados = List.of(_atletas);
  }

  void _filtrarAtletas(String query) {
    setState(() {
      _atletasFiltrados = query.isEmpty
          ? List.of(_atletas)
          : _atletas
                .where(
                  (atleta) =>
                      atleta.nome.toLowerCase().contains(query.toLowerCase()) ||
                      atleta.categoria.toLowerCase().contains(
                        query.toLowerCase(),
                      ),
                )
                .toList();
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
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
        actions: [],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: ResponsiveContent(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "MEUS ATLETAS",
                  style: TextStyle(
                    color: const Color(0xFFFFD6DA),
                    fontSize: isDesktop ? 34 : 28,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Bebas Neue',
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 20),
                _buildSearchBar(),
                const SizedBox(height: 20),
                isDesktop
                    ? GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 18,
                              mainAxisSpacing: 18,
                              childAspectRatio: 4.2,
                            ),
                        itemCount: _atletasFiltrados.length,
                        itemBuilder: (context, index) {
                          final atleta = _atletasFiltrados[index];
                          return _buildAtletaCard(atleta);
                        },
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _atletasFiltrados.length,
                        itemBuilder: (context, index) {
                          final atleta = _atletasFiltrados[index];
                          return _buildAtletaCard(atleta);
                        },
                      ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const TelaCadastroAtleta()),
          );
        },
        backgroundColor: const Color(0xFFFF4D6D),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
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

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2D1B1B),
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _filtrarAtletas,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Buscar atleta...',
          hintStyle: const TextStyle(color: Color(0xFF8B6B6C)),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF8B6B6C)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildAtletaCard(AtletaListItem atleta) {
    final isEmTreino = atleta.status == 'EM TREINO';

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => TeladadosAtletas(atleta: atleta),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2D1B1B),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isEmTreino
                        ? const Color(0xFFFF4D6D)
                        : const Color(0xFF5A3A3F),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    atleta.status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    atleta.nome,
                    style: const TextStyle(
                      color: Color(0xFFFFD6DA),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Bebas Neue',
                      letterSpacing: 1,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.water_drop,
                  color: Color(0xFFFF4D6D),
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  '${atleta.hidratacao}% HIDRATAÇÃO',
                  style: const TextStyle(
                    color: Color(0xFFFFD6DA),
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Color(0xFF8B6B6C),
                  size: 18,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
