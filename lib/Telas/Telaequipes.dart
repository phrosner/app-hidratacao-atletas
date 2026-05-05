import 'package:flutter/material.dart';
import 'package:hidratrack/Modelos/EquipesModels.dart';
import 'package:hidratrack/Componentes/BottomNavBarClass.dart';

class TelaEquipes extends StatefulWidget {
  const TelaEquipes({super.key});

  @override
  State<TelaEquipes> createState() => _TelaEquipesState();
}

class _TelaEquipesState extends State<TelaEquipes> {
  late int _currentNavIndex = 1;
  late List<Equipe> _equipes;
  final TextEditingController _searchController = TextEditingController();
  late List<Equipe> _equipeFiltrada;

  @override
  void initState() {
    super.initState();
    _equipes = [
      Equipe(
        id: 1,
        nome: "EQUIPE SUB-20",
        status: "EM TREINO",
        numeroAtletas: 24,
        percentualHidratacao: 82,
      ),
      Equipe(
        id: 2,
        nome: "EQUIPE OLÍMPICA",
        status: "DESCANSO",
        numeroAtletas: 12,
        percentualHidratacao: 95,
      ),
      Equipe(
        id: 3,
        nome: "BASE MASCULINA",
        status: "EM TREINO",
        numeroAtletas: 36,
        percentualHidratacao: 78,
      ),
      Equipe(
        id: 4,
        nome: "PROFISSIONAL FEM",
        status: "DESCANSO",
        numeroAtletas: 18,
        percentualHidratacao: 88,
      ),
    ];
    _equipeFiltrada = _equipes;
  }

  void _filtrarEquipes(String query) {
    setState(() {
      if (query.isEmpty) {
        _equipeFiltrada = _equipes;
      } else {
        _equipeFiltrada = _equipes
            .where((equipe) =>
                equipe.nome.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;

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
        actions: [
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : 24,
              vertical: isMobile ? 16 : 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "MINHAS EQUIPES",
                  style: TextStyle(
                    color: Color(0xFFFFD6DA),
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Bebas Neue',
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 20),
                _buildSearchBar(),
                const SizedBox(height: 20),
                if (_equipeFiltrada.isEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    alignment: Alignment.center,
                    child: const Text(
                      "Nenhuma equipe encontrada",
                      style: TextStyle(
                        color: Color(0xFF8B6B6C),
                        fontSize: 14,
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _equipeFiltrada.length,
                    itemBuilder: (context, index) {
                      final equipe = _equipeFiltrada[index];
                      return _buildEquipeCard(equipe, isMobile);
                    },
                  ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFFFF4D6D),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 28,
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          setState(() {
            _currentNavIndex = index;
          });
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
        onChanged: _filtrarEquipes,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: "Buscar equipes...",
          hintStyle: const TextStyle(
            color: Color(0xFF8B6B6C),
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: Color(0xFF8B6B6C),
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildEquipeCard(Equipe equipe, bool isMobile) {
    final isEmTreino = equipe.status == "EM TREINO";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2D1B1B),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
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
                        equipe.status,
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
                        equipe.nome,
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
                      Icons.people,
                      color: Color(0xFF6B9BD1),
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "${equipe.numeroAtletas} ATLETAS",
                      style: const TextStyle(
                        color: Color(0xFFFFD6DA),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Icon(
            Icons.arrow_forward_ios,
            color: Color(0xFF8B6B6C),
            size: 18,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
