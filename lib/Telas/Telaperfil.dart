import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hidratrack/Servicos/AtletaService.dart';
import 'package:hidratrack/Servicos/AuthHelper.dart';
import 'package:hidratrack/Servicos/AuthStorage.dart';
import 'package:hidratrack/app_rotas.dart';

class Telaperfil extends StatefulWidget {
  const Telaperfil({super.key});

  @override
  State<Telaperfil> createState() => _TelaperfilState();
}

class _TelaperfilState extends State<Telaperfil> {
  static const _background = Color(0xFFFFFFFF);
  static const _surface = Color(0xFFF7F7F7);
  static const _surfaceLight = Color(0xFFEDEDED);
  static const _lime = Color(0xFFB32025);
  static const _cyan = Color(0xFF8F171B);
  static const _text = Color(0xFF222222);
  static const _muted = Color(0xFF6B6B6B);

  bool _isSaving = false;
  bool _isSavingSenha = false;
  bool _isLoading = true;
  bool _hasError = false;
  bool _mostrarSenha = false;
  bool _mostrarConfirmarSenha = false;
  String _errorMessage = '';
  Map<String, dynamic>? _perfil;

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _confirmSenhaController = TextEditingController();
  final TextEditingController _idadeController = TextEditingController();
  final TextEditingController _alturaController = TextEditingController();
  final TextEditingController _pesoController = TextEditingController();
  final TextEditingController _esporteController = TextEditingController();
  final TextEditingController _nivelTreinoController = TextEditingController();
  final TextEditingController _metaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _carregarPerfil();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmSenhaController.dispose();
    _idadeController.dispose();
    _alturaController.dispose();
    _pesoController.dispose();
    _esporteController.dispose();
    _nivelTreinoController.dispose();
    _metaController.dispose();
    super.dispose();
  }

  Future<void> _carregarPerfil() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    if (AuthStorage.token.isEmpty) {
      AuthHelper.logout(context);
      return;
    }

    try {
      final perfil = await AtletaService.obterPerfilAtleta(
        token: AuthStorage.token,
      );

      if (!mounted) return;

      setState(() {
        _perfil = perfil;
        _nomeController.text = perfil['nome']?.toString() ?? '';
        _emailController.text = perfil['email']?.toString() ?? '';
        _idadeController.text = perfil['idade']?.toString() ?? '';
        _alturaController.text = perfil['altura']?.toString() ?? '';
        _pesoController.text = perfil['peso']?.toString() ?? '';
        _esporteController.text = perfil['esporte']?.toString() ?? '';
        _nivelTreinoController.text = perfil['nivelTreino']?.toString() ?? '';
        _metaController.text = _obterNumeroMeta(perfil['metaDiaria']?.toString()) ?? '2';
        if (_metaController.text.isEmpty) {
          _metaController.text = '2';
        }
        _senhaController.clear();
        _confirmSenhaController.clear();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Falha ao carregar perfil: $_errorMessage'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _salvarAlteracoes() async {
    if (_isSaving || _isLoading) return;
    FocusManager.instance.primaryFocus?.unfocus();

    final nome = _nomeController.text.trim();
    final email = _emailController.text.trim();
    final metaValor = _metaController.text.trim();
    final metaDiaria = _obterNumeroMeta(metaValor) ?? '2';

    if (nome.isEmpty) {
      _mostrarMensagem('Informe o nome completo.');
      return;
    }
    if (email.isEmpty) {
      _mostrarMensagem('Informe o email.');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final perfilAtualizado = <String, dynamic>{
      'nome': nome,
      'email': email,
      'idade': int.tryParse(_idadeController.text.trim()),
      'altura': int.tryParse(_alturaController.text.trim()),
      'peso': double.tryParse(_pesoController.text.trim()),
      'esporte': _esporteController.text.trim(),
      'nivelTreino': _nivelTreinoController.text.trim(),
      'metaDiaria': '${metaDiaria}L de água por dia',
    }..removeWhere((key, value) => value == null || value == '');

    try {
      final perfil = await AtletaService.atualizarPerfil(
        token: AuthStorage.token,
        perfil: perfilAtualizado,
      );

      if (!mounted) return;

      setState(() {
        _perfil = perfil;
        _nomeController.text = perfil['nome']?.toString() ?? nome;
        _emailController.text = perfil['email']?.toString() ?? email;
        _idadeController.text =
            perfil['idade']?.toString() ?? _idadeController.text;
        _alturaController.text =
            perfil['altura']?.toString() ?? _alturaController.text;
        _pesoController.text =
            perfil['peso']?.toString() ?? _pesoController.text;
        _esporteController.text =
            perfil['esporte']?.toString() ?? _esporteController.text;
        _nivelTreinoController.text =
            perfil['nivelTreino']?.toString() ?? _nivelTreinoController.text;
        _metaController.text =
            _obterNumeroMeta(perfil['metaDiaria']?.toString()) ?? metaDiaria;
        _senhaController.clear();
        _confirmSenhaController.clear();
        _isSaving = false;
      });

      AuthStorage.nome = perfil['nome']?.toString() ?? AuthStorage.nome;
      if (AuthStorage.rememberMe) {
        await AuthStorage.saveSession(remember: true);
      }
      _mostrarMensagem('Perfil atualizado com sucesso.');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
      });
      _mostrarMensagem('Erro ao atualizar perfil: $e');
    }
  }

  Future<void> _salvarSenha() async {
    if (_isSavingSenha || _isLoading) return;
    FocusManager.instance.primaryFocus?.unfocus();

    final senha = _senhaController.text;
    final confirmSenha = _confirmSenhaController.text;

    if (senha.isEmpty) {
      _mostrarMensagem('Informe a nova senha.');
      return;
    }
    if (senha.length < 6) {
      _mostrarMensagem('A senha deve ter pelo menos 6 caracteres.');
      return;
    }
    if (senha != confirmSenha) {
      _mostrarMensagem('A senha e a confirmação não coincidem.');
      return;
    }

    setState(() => _isSavingSenha = true);

    try {
      await AtletaService.atualizarPerfil(
        token: AuthStorage.token,
        perfil: {'senha': senha},
      );

      if (!mounted) return;

      setState(() {
        _senhaController.clear();
        _confirmSenhaController.clear();
        _isSavingSenha = false;
      });

      _mostrarMensagem('Senha atualizada com sucesso.');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSavingSenha = false);
      _mostrarMensagem('Erro ao atualizar senha: $e');
    }
  }

  void _logout() {
    AuthHelper.logout(context);
  }

  void _mostrarMensagem(String mensagem) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem), behavior: SnackBarBehavior.floating),
    );
  }

  String? _obterNumeroMeta(String? metaDiaria) {
    if (metaDiaria == null || metaDiaria.isEmpty) {
      return null;
    }
    final match = RegExp(r'([0-9]+(?:\.[0-9]+)?)').firstMatch(metaDiaria);
    return match?.group(1);
  }

  String get _nomeCompleto {
    final nome = _perfil?['nome']?.toString();
    return nome == null || nome.isEmpty ? AuthStorage.nome : nome;
  }

  String get _codigoPrincipal {
    final idValue = _perfil?['id'];
    if (idValue is num) {
      return 'HT-${idValue.toInt().toString().padLeft(6, '0')}';
    }
    return 'HT-000000';
  }

  String get _email {
    return _perfil?['email']?.toString() ?? 'não disponível';
  }

  String get _idade {
    return _perfil?['idade']?.toString() ?? 'N/A';
  }

  String get _altura {
    return _perfil?['altura']?.toString() ?? 'N/A';
  }

  String get _peso {
    return _perfil?['peso']?.toString() ?? 'N/A';
  }

  String get _esporte {
    return _perfil?['esporte']?.toString() ?? 'N/A';
  }

  String get _nivelTreino {
    return _perfil?['nivelTreino']?.toString() ?? 'N/A';
  }

  String get _tipoUsuario {
    return AuthStorage.tipoUsuario.isNotEmpty
        ? AuthStorage.tipoUsuario
        : _perfil?['tipoUsuario']?.toString() ?? 'ATLETA';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      bottomNavigationBar: _buildBottomNav(context),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 92),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildBrand(),
                      const SizedBox(height: 30),
                      _buildHeader(),
                      const SizedBox(height: 18),
                      _buildActionButtons(),
                      const SizedBox(height: 28),
                      _buildSectionTitle('INFORMAÇÕES DO ATLETA'),
                      const SizedBox(height: 10),
                      _buildPersonalInfo(),
                      const SizedBox(height: 22),
                      _buildSectionTitle('DADOS DE LOGIN'),
                      const SizedBox(height: 12),
                      _buildCredentialsCard(),
                      const SizedBox(height: 18),
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

  Widget _buildBrand() {
    return Row(
      children: [
        const Icon(Icons.water_drop_outlined, color: _lime, size: 18),
        const SizedBox(width: 6),
        const Text(
          'H2OTRACK',
          style: TextStyle(
            color: _lime,
            fontSize: 15,
            fontWeight: FontWeight.w900,
            height: 1,
          ),
        ),
        const Spacer(),
        TextButton.icon(
          onPressed: _logout,
          style: TextButton.styleFrom(
            foregroundColor: _lime,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          icon: const Icon(Icons.logout, size: 16),
          label: const Text(
            'SAIR',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    if (_isLoading) {
      return Column(
        children: const [
          SizedBox(height: 80),
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Carregando perfil...'),
        ],
      );
    }

    if (_hasError) {
      return Column(
        children: [
          const SizedBox(height: 80),
          const Icon(Icons.error_outline, size: 72, color: _lime),
          const SizedBox(height: 16),
          Text(
            'Não foi possível carregar o perfil.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _text,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _errorMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(color: _muted, fontSize: 12),
          ),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: _carregarPerfil,
            style: FilledButton.styleFrom(
              backgroundColor: _lime,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(46),
            ),
            child: const Text('TENTAR NOVAMENTE'),
          ),
        ],
      );
    }

    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 86,
              height: 86,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _lime, width: 2),
                color: _surfaceLight,
              ),
              child: ClipOval(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF2A2A2A), Color(0xFF050505)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: const Icon(Icons.person, color: _text, size: 58),
                ),
              ),
            ),
            Positioned(
              right: -2,
              bottom: 4,
              child: Container(
                width: 25,
                height: 25,
                decoration: const BoxDecoration(
                  color: _lime,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.edit, color: Colors.white, size: 13),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          _nomeCompleto,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: _text,
            fontSize: 23,
            fontWeight: FontWeight.w900,
            height: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'ID: ${_perfil?['id'] ?? '-'}',
          style: const TextStyle(
            color: _muted,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: _carregarPerfil,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('ATUALIZAR'),
            style: FilledButton.styleFrom(
              backgroundColor: _lime,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(46),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout, size: 18),
            label: const Text('SAIR'),
            style: OutlinedButton.styleFrom(
              foregroundColor: _lime,
              side: const BorderSide(color: _lime),
              minimumSize: const Size.fromHeight(46),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(width: 4, height: 17, color: _cyan),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: _cyan,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(label: 'NOME COMPLETO', controller: _nomeController),
        const SizedBox(height: 14),
        _buildTextField(
          label: 'EMAIL DE LOGIN',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                label: 'IDADE',
                controller: _idadeController,
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                label: 'ALTURA (CM)',
                controller: _alturaController,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                label: 'PESO (KG)',
                controller: _pesoController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                label: 'ESPORTE',
                controller: _esporteController,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _buildTextField(
          label: 'NÍVEL DE TREINO',
          controller: _nivelTreinoController,
        ),
        const SizedBox(height: 14),
        _buildLabel('META DIÁRIA'),
        const SizedBox(height: 7),
        _buildGoalCard(),
        const SizedBox(height: 12),
        _buildSaveChangesButton(),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, {required IconData icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 7),
        _buildValueBox(text: value, icon: icon, emphasized: true),
      ],
    );
  }

  Widget _buildGoalCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: _lime.withOpacity(0.16)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _lime.withOpacity(0.10),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.water_drop_outlined,
              color: _lime,
              size: 23,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'META DIÁRIA',
                  style: TextStyle(
                    color: _muted,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.6,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _metaController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                          ],
                          style: const TextStyle(
                            color: _text,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: '2',
                            hintStyle: TextStyle(color: _muted.withOpacity(0.6)),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: _surfaceLight),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: _surfaceLight),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: _lime),
                            ),
                          ),
                        ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'L de água por dia',
                      style: TextStyle(
                        color: _text,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveChangesButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: FilledButton.icon(
        onPressed: (_isSaving || _isLoading) ? null : _salvarAlteracoes,
        style: FilledButton.styleFrom(
          backgroundColor: _lime,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        icon: const Icon(Icons.save_outlined, size: 18),
        label: const Text(
          'SALVAR ALTERAÇÕES',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildCredentialsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 20, 16, 20),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(
            label: 'SENHA NOVA',
            controller: _senhaController,
            obscureText: true,
            showPasswordToggle: true,
            passwordVisible: _mostrarSenha,
            onTogglePassword: () =>
                setState(() => _mostrarSenha = !_mostrarSenha),
            hintText: 'Digite a nova senha',
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'CONFIRMAR SENHA',
            controller: _confirmSenhaController,
            obscureText: true,
            showPasswordToggle: true,
            passwordVisible: _mostrarConfirmarSenha,
            onTogglePassword: () => setState(
              () => _mostrarConfirmarSenha = !_mostrarConfirmarSenha,
            ),
            hintText: 'Confirme a nova senha',
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: FilledButton.icon(
              onPressed: (_isSavingSenha || _isLoading) ? null : _salvarSenha,
              style: FilledButton.styleFrom(
                backgroundColor: _lime,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: _isSavingSenha
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.lock_reset, size: 18),
              label: const Text(
                'SALVAR NOVA SENHA',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _logout,
              style: OutlinedButton.styleFrom(
                foregroundColor: _lime,
                side: const BorderSide(color: _lime),
                minimumSize: const Size.fromHeight(44),
              ),
              icon: const Icon(Icons.logout, size: 18),
              label: const Text(
                'ENCERRAR SESSÃO',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildCredentialItem(
            icon: Icons.badge_outlined,
            label: 'TIPO DE USUÁRIO',
            value: _tipoUsuario,
          ),
          const SizedBox(height: 20),
          _buildCredentialItem(
            icon: Icons.fingerprint,
            label: 'ID DO ATLETA',
            value: _perfil?['id']?.toString() ?? 'N/A',
          ),
        ],
      ),
    );
  }

  Widget _buildCredentialItem({
    required IconData icon,
    required String label,
    required String value,
    Widget? trailing,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Icon(icon, color: _muted, size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel(label),
              const SizedBox(height: 7),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _text,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    bool showPasswordToggle = false,
    bool passwordVisible = false,
    VoidCallback? onTogglePassword,
    String? hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 7),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText && !passwordVisible,
          style: const TextStyle(
            color: _text,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: _muted.withOpacity(0.75),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 16,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: _surfaceLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: _lime, width: 1.5),
            ),
            suffixIcon: showPasswordToggle
                ? IconButton(
                    onPressed: onTogglePassword,
                    icon: Icon(
                      passwordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: _muted,
                      size: 20,
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: _muted,
        fontSize: 9,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.6,
      ),
    );
  }

  Widget _buildValueBox({
    required String text,
    bool highlighted = false,
    bool centered = false,
    bool emphasized = false,
    IconData? icon,
  }) {
    final foreground = highlighted ? Colors.white : _text;

    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: highlighted ? _lime : Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: highlighted ? _lime : _surfaceLight),
      ),
      child: Stack(
        children: [
          if (!highlighted)
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SizedBox(height: 1.4, child: ColoredBox(color: _lime)),
            ),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 13),
              child: Row(
                mainAxisAlignment: centered
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: _lime, size: 15),
                    const SizedBox(width: 12),
                  ],
                  Flexible(
                    child: Text(
                      text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: centered ? TextAlign.center : TextAlign.start,
                      style: TextStyle(
                        color: foreground,
                        fontSize: emphasized ? 12 : 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: highlighted ? 0.8 : 0,
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

  Widget _buildBottomNav(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    const items = [
      (Icons.water_drop, 'SESSAO'),
      (Icons.history_rounded, 'HISTORICO'),
      (Icons.insert_chart_outlined, 'STATUS'),
      (Icons.person, 'PERFIL'),
    ];

    return Container(
      height: 72 + bottomInset,
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.08))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (var i = 0; i < items.length; i++)
            InkWell(
              onTap: () {
                if (i == 0) {
                  Navigator.of(
                    context,
                  ).pushReplacementNamed(AppRotas.dashboardAtleta);
                } else if (i == 1) {
                  Navigator.of(
                    context,
                  ).pushReplacementNamed(AppRotas.historicoAtleta);
                } else if (i == 2) {
                  Navigator.of(
                    context,
                  ).pushReplacementNamed(AppRotas.taxaMedia);
                }
              },
              child: SizedBox(
                width: 74,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(items[i].$1, color: i == 3 ? _lime : _muted, size: 23),
                    const SizedBox(height: 5),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        items[i].$2,
                        style: TextStyle(
                          color: i == 3 ? _lime : _muted,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.9,
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
