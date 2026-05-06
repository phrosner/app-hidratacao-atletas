import 'package:flutter/material.dart';
import 'package:hidratrack/Componentes/ResponsiveContent.dart';
import 'package:hidratrack/Modelos/EquipesModels.dart';

class TeladadosEquipe extends StatefulWidget {
  const TeladadosEquipe({super.key, this.equipe});

  final Equipe? equipe;

  @override
  State<TeladadosEquipe> createState() => _TeladadosEquipeState();
}

class _TeladadosEquipeState extends State<TeladadosEquipe> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  String? _categoriaSelect;
  String? _modalidadeSelect;

  final List<String> categorias = [
    'SUB-17',
    'SUB-20',
    'OLIMPICO',
    'PROFISSIONAL',
    'MASTER',
  ];

  final List<String> modalidades = [
    'Futebol',
    'Crossfit',
    'Endurance',
    'Natacao',
    'Atletismo',
  ];

  final List<Map<String, String>> _atletas = [
    {'nome': 'Ricardo Santos', 'categoria': 'PESO PESADO'},
    {'nome': 'Mariana Lima', 'categoria': 'ENDURANCE'},
    {'nome': 'Bruno Oliveira', 'categoria': 'ELITE TRAINER'},
  ];

  late List<Map<String, String>> _atletasFiltrados;

  @override
  void initState() {
    super.initState();
    final equipe = widget.equipe;

    _nomeController.text = equipe?.nome ?? 'Alpha Warriors Elite';
    _descricaoController.text =
        equipe?.descricao ??
        'Equipe focada em alto rendimento e competicoes nacionais de endurance.';
    _categoriaSelect = equipe?.categoria ?? 'PROFISSIONAL';
    _modalidadeSelect = equipe?.modalidade ?? 'Crossfit';
    _atletasFiltrados = List.of(_atletas);
  }

  void _filtrarAtletas(String query) {
    setState(() {
      _atletasFiltrados = query.isEmpty
          ? List.of(_atletas)
          : _atletas
                .where(
                  (atleta) =>
                      atleta['nome']!.toLowerCase().contains(
                        query.toLowerCase(),
                      ) ||
                      atleta['categoria']!.toLowerCase().contains(
                        query.toLowerCase(),
                      ),
                )
                .toList();
    });
  }

  void _removerAtleta(Map<String, String> atleta) {
    setState(() {
      _atletas.remove(atleta);
      final query = _searchController.text;
      _atletasFiltrados = query.isEmpty
          ? List.of(_atletas)
          : _atletas
                .where(
                  (atleta) =>
                      atleta['nome']!.toLowerCase().contains(
                        query.toLowerCase(),
                      ) ||
                      atleta['categoria']!.toLowerCase().contains(
                        query.toLowerCase(),
                      ),
                )
                .toList();
    });
  }

  void _salvarAlteracoes() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Alteracoes salvas com sucesso!'),
        backgroundColor: Color(0xFFFF4D6D),
      ),
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFFFD6DA)),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'EDITAR EQUIPE',
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
                _buildSectionTitle(
                  icon: Icons.info,
                  title: 'DADOS DA EQUIPE',
                  counter: null,
                ),
                const SizedBox(height: 16),
                _buildDadosCard(isDesktop: isDesktop),
                const SizedBox(height: 24),
                _buildSectionTitle(
                  icon: Icons.groups,
                  title: 'ATLETAS NA EQUIPE',
                  counter: '${_atletas.length} atletas',
                ),
                const SizedBox(height: 16),
                _buildSearchBar(),
                const SizedBox(height: 16),
                if (_atletasFiltrados.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Text(
                        'Nenhum atleta encontrado',
                        style: TextStyle(color: Color(0xFF8B6B6C)),
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _atletasFiltrados.length,
                    itemBuilder: (context, index) {
                      return _buildAtletaItem(_atletasFiltrados[index], index);
                    },
                  ),
                const SizedBox(height: 24),
                _buildSalvarButton(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle({
    required IconData icon,
    required String title,
    required String? counter,
  }) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFFF4D6D), size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFFFFD6DA),
            fontSize: 14,
            fontWeight: FontWeight.bold,
            fontFamily: 'Bebas Neue',
            letterSpacing: 1,
          ),
        ),
        if (counter != null) ...[
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF5A3A3F),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              counter,
              style: const TextStyle(
                color: Color(0xFFFFD6DA),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDadosCard({required bool isDesktop}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2D1B1B),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('NOME DA EQUIPE'),
          const SizedBox(height: 8),
          _buildTextField(_nomeController, 'Nome da equipe'),
          const SizedBox(height: 16),
          if (isDesktop)
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('CATEGORIA'),
                      const SizedBox(height: 8),
                      _buildDropdown(
                        value: _categoriaSelect,
                        items: categorias,
                        onChanged: (value) {
                          setState(() {
                            _categoriaSelect = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('MODALIDADE'),
                      const SizedBox(height: 8),
                      _buildDropdown(
                        value: _modalidadeSelect,
                        items: modalidades,
                        onChanged: (value) {
                          setState(() {
                            _modalidadeSelect = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('CATEGORIA'),
                    const SizedBox(height: 8),
                    _buildDropdown(
                      value: _categoriaSelect,
                      items: categorias,
                      onChanged: (value) {
                        setState(() {
                          _categoriaSelect = value;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('MODALIDADE'),
                    const SizedBox(height: 8),
                    _buildDropdown(
                      value: _modalidadeSelect,
                      items: modalidades,
                      onChanged: (value) {
                        setState(() {
                          _modalidadeSelect = value;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          const SizedBox(height: 16),
          _buildLabel('DESCRICAO'),
          const SizedBox(height: 8),
          _buildTextAreaField(
            _descricaoController,
            'Objetivos e detalhes da equipe...',
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF8B6B6C),
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF3A2A2A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white, fontSize: 14),
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
        color: const Color(0xFF3A2A2A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        maxLines: 4,
        style: const TextStyle(color: Colors.white, fontSize: 14),
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

  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF3A2A2A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        underline: const SizedBox(),
        iconEnabledColor: const Color(0xFF8B6B6C),
        style: const TextStyle(color: Colors.white, fontSize: 14),
        dropdownColor: const Color(0xFF2D1B1B),
        items: items.map((value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(value),
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2D1B1B),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _filtrarAtletas,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          hintText: 'Buscar atleta para adicionar...',
          hintStyle: TextStyle(color: Color(0xFF8B6B6C)),
          prefixIcon: Icon(Icons.search, color: Color(0xFF8B6B6C)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildAtletaItem(Map<String, String> atleta, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2D1B1B),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFF3A2A2A),
            child: Text(
              atleta['nome']![0],
              style: const TextStyle(
                color: Color(0xFFFFD6DA),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  atleta['nome']!,
                  style: const TextStyle(
                    color: Color(0xFFFFD6DA),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  atleta['categoria']!,
                  style: const TextStyle(
                    color: Color(0xFF8B6B6C),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _removerAtleta(atleta),
            icon: const Icon(
              Icons.delete_outline,
              color: Color(0xFFFFD6DA),
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalvarButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _salvarAlteracoes,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF4D6D),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text(
          'SALVAR ALTERACOES',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}
