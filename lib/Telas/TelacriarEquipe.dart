import 'package:flutter/material.dart';
import 'package:hidratrack/Componentes/BottomNavBarClass.dart';
import 'package:hidratrack/Componentes/ResponsiveContent.dart';
import 'package:hidratrack/Servicos/EquipeService.dart';

class TelacriarEquipe extends StatefulWidget {
  const TelacriarEquipe({super.key});

  @override
  State<TelacriarEquipe> createState() => _TelacriarEquipeState();
}

class _TelacriarEquipeState extends State<TelacriarEquipe> {
  int _currentNavIndex = 1;
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _modalidadeController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  bool _carregando = false;

  String? _categoriaSelect;
  final List<String> categorias = [
    'Selecione...',
    'SUB-17',
    'SUB-20',
    'OLIMPICO',
    'PROFISSIONAL',
    'MASTER',
  ];

  final List<Map<String, dynamic>> todosAtletas = [
    {
      'id': 1,
      'nome': 'Lucas Silva',
      'posicao': 'Atacante',
      'idAtleta': 4892,
      'selecionado': false,
    },
    {
      'id': 2,
      'nome': 'Mateus Costa',
      'posicao': 'Meio-Campo',
      'idAtleta': 1926,
      'selecionado': true,
    },
    {
      'id': 3,
      'nome': 'Rafael Mendes',
      'posicao': 'Zagueiro',
      'idAtleta': 9361,
      'selecionado': false,
    },
    {
      'id': 4,
      'nome': 'Joao Santos',
      'posicao': 'Goleiro',
      'idAtleta': 5127,
      'selecionado': false,
    },
    {
      'id': 5,
      'nome': 'Bruno Oliveira',
      'posicao': 'Lateral',
      'idAtleta': 7823,
      'selecionado': false,
    },
  ];

  late List<Map<String, dynamic>> atletasFiltrados;

  @override
  void initState() {
    super.initState();
    atletasFiltrados = List.of(todosAtletas);
    _categoriaSelect = categorias.first;
  }

  void _filtrarAtletas(String query) {
    setState(() {
      atletasFiltrados = query.isEmpty
          ? List.of(todosAtletas)
          : todosAtletas
                .where(
                  (atleta) =>
                      atleta['nome'].toLowerCase().contains(
                        query.toLowerCase(),
                      ) ||
                      atleta['idAtleta'].toString().contains(query),
                )
                .toList();
    });
  }

  Future<void> _salvarEquipe() async {
    try {
      final atletasSelecionados = todosAtletas
          .where((a) => a['selecionado'])
          .map<int>((a) => a['idAtleta'] as int)
          .toList();

      setState(() {
        _carregando = true;
      });

      final sucesso = await EquipeService.criarEquipe(
        nome: _nomeController.text,
        categoria: _categoriaSelect ?? 'Selecione...',
        modalidade: _modalidadeController.text,
        descricao: _descricaoController.text,
        atletasIds: atletasSelecionados,
      );

      if (sucesso && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Equipe criada com sucesso!'),
            backgroundColor: Color(0xFFFF4D6D),
          ),
        );
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.pop(context);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _carregando = false;
        });
      }
    }
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
    _nomeController.dispose();
    _modalidadeController.dispose();
    _descricaoController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A0003),
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFFFD6DA)),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'CRIAR EQUIPE',
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
            maxWidth: 980,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabel('NOME DA EQUIPE'),
                const SizedBox(height: 8),
                _buildTextField(_nomeController, 'Ex: Elite Strikers'),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('CATEGORIA'),
                          const SizedBox(height: 8),
                          _buildCategoriaDropdown(),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('MODALIDADE'),
                          const SizedBox(height: 8),
                          _buildTextField(_modalidadeController, 'Ex: Futebol'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildLabel('DESCRICAO'),
                const SizedBox(height: 8),
                _buildTextAreaField(
                  _descricaoController,
                  'Objetivos e detalhes da equipe...',
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Icon(
                      Icons.people,
                      color: Color(0xFFFF4D6D),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'SELECIONAR ATLETAS',
                      style: TextStyle(
                        color: Color(0xFFFF4D6D),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSearchBar(),
                const SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: atletasFiltrados.length,
                  itemBuilder: (context, index) {
                    return _buildAtletaItem(atletasFiltrados[index]);
                  },
                ),
                const SizedBox(height: 16),
                const Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_circle_outline,
                        color: Color(0xFFFF4D6D),
                        size: 18,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'CARREGAR MAIS ATLETAS',
                        style: TextStyle(
                          color: Color(0xFFFF4D6D),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _buildSalvarButton(),
                const SizedBox(height: 24),
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

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFFFFD6DA),
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2D1B1B),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF8B6B6C)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildTextAreaField(TextEditingController controller, String hint) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2D1B1B),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        maxLines: 4,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF8B6B6C)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriaDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2D1B1B),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: _categoriaSelect,
        isExpanded: true,
        underline: const SizedBox(),
        style: const TextStyle(color: Colors.white),
        dropdownColor: const Color(0xFF2D1B1B),
        items: categorias.map((value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(value),
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _categoriaSelect = value;
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
        onChanged: _filtrarAtletas,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          hintText: 'Buscar pelo nome ou ID...',
          hintStyle: TextStyle(color: Color(0xFF8B6B6C)),
          prefixIcon: Icon(Icons.search, color: Color(0xFF8B6B6C)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildAtletaItem(Map<String, dynamic> atleta) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: atleta['selecionado']
            ? const Color(0xFFFF4D6D).withValues(alpha: 0.2)
            : const Color(0xFF2D1B1B),
        borderRadius: BorderRadius.circular(8),
        border: atleta['selecionado']
            ? Border.all(color: const Color(0xFFFF4D6D), width: 2)
            : null,
      ),
      child: Row(
        children: [
          const Icon(Icons.person, color: Color(0xFFFF4D6D), size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  atleta['nome'],
                  style: const TextStyle(
                    color: Color(0xFFFFD6DA),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${atleta['posicao']} - ID: ${atleta['idAtleta']}',
                  style: const TextStyle(
                    color: Color(0xFF8B6B6C),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Checkbox(
            value: atleta['selecionado'],
            onChanged: (value) {
              setState(() {
                atleta['selecionado'] = value ?? false;
              });
            },
            activeColor: const Color(0xFFFF4D6D),
            checkColor: Colors.white,
            side: const BorderSide(color: Color(0xFF8B6B6C)),
          ),
        ],
      ),
    );
  }

  Widget _buildSalvarButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _carregando ? null : _salvarEquipe,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF4D6D),
          disabledBackgroundColor: const Color(0xFF8B6B6C),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: _carregando
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 2,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'SALVAR EQUIPE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.check_circle, color: Colors.white, size: 20),
                ],
              ),
      ),
    );
  }
}
