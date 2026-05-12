import 'package:flutter/material.dart';
import 'package:hidratrack/Componentes/ResponsiveContent.dart';
import 'package:hidratrack/Modelos/AtletaListModels.dart';

class TelaVisualizarAtletas extends StatefulWidget {
  const TelaVisualizarAtletas({super.key, this.atleta});

  final AtletaListItem? atleta;

  @override
  State<TelaVisualizarAtletas> createState() => _TelaVisualizarAtletasState();
}

class _TelaVisualizarAtletasState extends State<TelaVisualizarAtletas> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _idadeController = TextEditingController();
  final TextEditingController _modalidadeController = TextEditingController();
  final TextEditingController _posicaoController = TextEditingController();
  final TextEditingController _equipeController = TextEditingController();
  final TextEditingController _pesoController = TextEditingController();
  final TextEditingController _alturaController = TextEditingController();
  final TextEditingController _gorduraController = TextEditingController();
  final TextEditingController _vo2Controller = TextEditingController();
  final TextEditingController _frequenciaController = TextEditingController();

  String? _sexoSelect;
  String? _nivelSelect;

  final List<String> sexo = ['Masculino', 'Feminino'];
  final List<String> niveis = [
    'Iniciante',
    'Intermediario',
    'Avancado',
    'Elite',
  ];

  @override
  void initState() {
    super.initState();
    final atleta = widget.atleta;

    _nomeController.text = atleta?.nome ?? 'Ricardo Santos Oliveira';
    _idadeController.text = '24';
    _modalidadeController.text = 'Crossfit / Levantamento de Peso';
    _posicaoController.text = atleta?.categoria ?? 'Powerlifting';
    _equipeController.text = 'Alpha Performance';
    _pesoController.text = '88.5';
    _alturaController.text = '184';
    _gorduraController.text = '12';
    _vo2Controller.text = '54.2';
    _frequenciaController.text = '48';
    _sexoSelect = sexo.first;
    _nivelSelect = 'Avancado';
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _idadeController.dispose();
    _modalidadeController.dispose();
    _posicaoController.dispose();
    _equipeController.dispose();
    _pesoController.dispose();
    _alturaController.dispose();
    _gorduraController.dispose();
    _vo2Controller.dispose();
    _frequenciaController.dispose();
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
          icon: const Icon(Icons.close, color: Color(0xFFFFD6DA)),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'VISUALIZAR ATLETA',
          style: TextStyle(
            color: Color(0xFFFFD6DA),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFFFF4D6D),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFF2D1B1B),
                child: Text(
                  _nomeController.text.isEmpty ? 'A' : _nomeController.text[0],
                  style: const TextStyle(
                    color: Color(0xFFFFD6DA),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: ResponsiveContent(
            maxWidth: 1040,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isDesktop)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle(
                              color: const Color(0xFFFF4D6D),
                              title: 'INFORMACOES PESSOAIS',
                            ),
                            const SizedBox(height: 16),
                            _buildPersonalCard(),
                          ],
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle(
                              color: const Color(0xFF6B9BD1),
                              title: 'PERFIL ESPORTIVO',
                            ),
                            const SizedBox(height: 16),
                            _buildSportsCard(),
                          ],
                        ),
                      ),
                    ],
                  )
                else ...[
                  _buildSectionTitle(
                    color: const Color(0xFFFF4D6D),
                    title: 'INFORMACOES PESSOAIS',
                  ),
                  const SizedBox(height: 16),
                  _buildPersonalCard(),
                  const SizedBox(height: 24),
                  _buildSectionTitle(
                    color: const Color(0xFF6B9BD1),
                    title: 'PERFIL ESPORTIVO',
                  ),
                  const SizedBox(height: 16),
                  _buildSportsCard(),
                ],
                const SizedBox(height: 24),
                _buildSectionTitle(
                  color: const Color(0xFFFF4D6D),
                  title: 'DADOS FISIOLOGICOS',
                ),
                const SizedBox(height: 16),
                _buildPhysiologyCards(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle({required Color color, required String title}) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFFFFD6DA),
            fontSize: 15,
            fontWeight: FontWeight.bold,
            fontFamily: 'Bebas Neue',
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalCard() {
    return _buildCard(
      children: [
        _buildLabel('NOME COMPLETO'),
        const SizedBox(height: 8),
        _buildTextField(_nomeController, 'Nome completo'),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('IDADE'),
                  const SizedBox(height: 8),
                  _buildTextField(_idadeController, 'Idade'),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('SEXO'),
                  const SizedBox(height: 8),
                  _buildDropdown(
                    value: _sexoSelect,
                    items: sexo,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSportsCard() {
    return _buildCard(
      children: [
        _buildLabel('MODALIDADE'),
        const SizedBox(height: 8),
        _buildTextField(_modalidadeController, 'Modalidade'),
        const SizedBox(height: 16),
        _buildLabel('POSICAO / ESPECIALIDADE'),
        const SizedBox(height: 8),
        _buildTextField(_posicaoController, 'Especialidade'),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('NIVEL'),
                  const SizedBox(height: 8),
                  _buildDropdown(
                    value: _nivelSelect,
                    items: niveis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('EQUIPE'),
                  const SizedBox(height: 8),
                  _buildTextField(_equipeController, 'Equipe'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPhysiologyCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                label: 'PESO (KG)',
                controller: _pesoController,
                unit: 'KG',
                color: const Color(0xFFFF4D6D),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                label: 'ALTURA (CM)',
                controller: _alturaController,
                unit: 'CM',
                color: const Color(0xFF6B9BD1),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildCard(
          children: [
            Row(
              children: [
                _buildLabel('GORDURA CORPORAL (BF%)'),
                const Spacer(),
                Text(
                  '${_gorduraController.text}%',
                  style: const TextStyle(
                    color: Color(0xFF6B9BD1),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(
                value: (_parseDouble(_gorduraController.text) / 40).clamp(0, 1),
                minHeight: 8,
                color: const Color(0xFF6B9BD1),
                backgroundColor: const Color(0xFF3A2A2A),
              ),
            ),
            const SizedBox(height: 20),
            _buildInfoRow('VO2 Maximo', '${_vo2Controller.text} ml/kg/min'),
            const SizedBox(height: 18),
            _buildInfoRow('Frequencia de Repouso', '${_frequenciaController.text} bpm'),
          ],
        ),
      ],
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2D1B1B),
        borderRadius: BorderRadius.circular(12),
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
        color: Color(0xFF8B6B6C),
        fontSize: 10,
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
        readOnly: true,
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
        items: items.map((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(item),
            ),
          );
        }).toList(),
        onChanged: null,
        disabledHint: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            value ?? '',
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String label,
    required TextEditingController controller,
    required String unit,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF2D1B1B),
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel(label),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  readOnly: true,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    color: Color(0xFFFFD6DA),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              Text(
                unit,
                style: const TextStyle(color: Color(0xFF8B6B6C), fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: Color(0xFF8B6B6C), fontSize: 14),
          ),
        ),
        Text(
          value,
          style: const TextStyle(color: Color(0xFFFFD6DA), fontSize: 14),
        ),
      ],
    );
  }

  double _parseDouble(String value) {
    return double.tryParse(value.replaceAll(',', '.')) ?? 0;
  }
}
