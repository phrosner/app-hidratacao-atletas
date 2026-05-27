import 'package:flutter/material.dart';
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

  bool _mostrarSenha = false;

  static const _nomeCompleto = 'Vitor Thompson de Oliveira';
  static const _nomeExibicao = 'Vitor Thompson';
  static const _codigoPrincipal = 'HT-000000';
  static const _codigos = ['HT-000001', 'HT-000002', 'HT-000003'];
  static const _idade = '24';
  static const _altura = '185';
  static const _email = 'vitorthompson@atleta.com';
  static const _senha = 'hidratrack24';

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
                      const SizedBox(height: 28),
                      _buildSectionTitle('Informacoes Pessoais'),
                      const SizedBox(height: 10),
                      _buildPersonalInfo(),
                      const SizedBox(height: 22),
                      _buildSectionTitle('Credenciais de Acesso'),
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
    return const Row(
      children: [
        Icon(Icons.water_drop_outlined, color: _lime, size: 18),
        SizedBox(width: 6),
        Text(
          'H2OTRACK',
          style: TextStyle(
            color: _lime,
            fontSize: 15,
            fontWeight: FontWeight.w900,
            height: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
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
        const Text(
          _nomeExibicao,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _text,
            fontSize: 23,
            fontWeight: FontWeight.w900,
            height: 1,
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
        _buildLabel('NOME COMPLETO'),
        const SizedBox(height: 7),
        _buildValueBox(text: _nomeCompleto),
        const SizedBox(height: 14),
        _buildLabel('CODIGO DE IDENTIFICACAO'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildValueBox(
                text: _codigoPrincipal,
                highlighted: true,
                centered: true,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildValueBox(
                text: _codigos[0],
                highlighted: true,
                centered: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildValueBox(
                text: _codigos[1],
                highlighted: true,
                centered: true,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildValueBox(
                text: _codigos[2],
                highlighted: true,
                centered: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('IDADE'),
                  const SizedBox(height: 7),
                  _buildValueBox(
                    text: _idade,
                    icon: Icons.person_outline,
                    emphasized: true,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('ALTURA (CM)'),
                  const SizedBox(height: 7),
                  _buildValueBox(
                    text: _altura,
                    icon: Icons.straighten,
                    emphasized: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCredentialsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 20, 16, 20),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCredentialItem(
            icon: Icons.mail_outline,
            label: 'EMAIL DE LOGIN',
            value: _email,
          ),
          const SizedBox(height: 20),
          _buildCredentialItem(
            icon: Icons.lock_outline,
            label: 'SENHA',
            value: _mostrarSenha ? _senha : '********',
            trailing: IconButton(
              tooltip: _mostrarSenha ? 'Ocultar senha' : 'Mostrar senha',
              onPressed: () {
                setState(() => _mostrarSenha = !_mostrarSenha);
              },
              icon: Icon(
                _mostrarSenha ? Icons.visibility_off : Icons.visibility,
                color: _muted,
                size: 20,
              ),
            ),
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
        ?trailing,
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
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
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
