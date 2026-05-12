import 'package:flutter/material.dart';
import 'package:hidratrack/Componentes/ResponsiveContent.dart';
import 'package:hidratrack/Componentes/atleta_bottom_nav_bar.dart';

class TelaDashboardAtleta extends StatelessWidget {
  const TelaDashboardAtleta({
    super.key,
    required this.data,
    this.onStartSession,
  });

  final AtletaDashboardData data;
  final VoidCallback? onStartSession;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 900;
    final isVeryNarrow = width < 300;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0A0F),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(
          right: isDesktop ? 28 : 0,
          bottom: isDesktop ? 12 : 0,
        ),
        child: _buildActionButton(),
      ),
      bottomNavigationBar: AtletaBottomNavBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
            Navigator.of(context).pushReplacementNamed('/dashboard-atleta');
          }
        },
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: ResponsiveContent(
            maxWidth: isDesktop ? 980 : 1180,
            mobilePadding: const EdgeInsets.fromLTRB(18, 16, 18, 112),
            desktopPadding: const EdgeInsets.fromLTRB(32, 28, 32, 124),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopBar(isDesktop),
                SizedBox(height: isDesktop ? 36 : 28),
                _buildHeader(isDesktop),
                SizedBox(height: isDesktop ? 28 : 22),
                if (data.hasAlert) ...[
                  _buildAlertCard(isDesktop),
                  const SizedBox(height: 20),
                ],
                _buildStatsRow(isVeryNarrow),
                SizedBox(height: isDesktop ? 160 : 130),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(bool isDesktop) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Center(
          child: Text(
            'HIDRATRACK',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFFFF2F64),
              fontSize: isDesktop ? 18 : 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 6,
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: CircleAvatar(
            radius: isDesktop ? 22 : 14,
            backgroundColor: const Color(0xFF173242),
            child: Icon(
              Icons.person,
              color: const Color(0xFFFFD6DA),
              size: isDesktop ? 22 : 15,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          data.greetingTitle,
          style: TextStyle(
            color: const Color(0xFFFFD6DA),
            fontSize: isDesktop ? 38 : 28,
            fontWeight: FontWeight.bold,
            fontFamily: 'Bebas Neue',
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          data.subtitle,
          style: const TextStyle(color: Color(0xFFD7B8BC), fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildAlertCard(bool isDesktop) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isDesktop ? 24 : 20),
      decoration: BoxDecoration(
        color: const Color(0xFF151517),
        borderRadius: BorderRadius.circular(isDesktop ? 20 : 18),
        gradient: const LinearGradient(
          colors: [Color(0xFF151517), Color(0xFF122B34)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF10202B),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.water_drop_outlined,
              color: Color(0xFF00B7FF),
              size: 24,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.alertTitle,
                  style: TextStyle(
                    color: const Color(0xFFFFD6DA),
                    fontSize: isDesktop ? 20 : 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Bebas Neue',
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  data.alertMessage,
                  style: const TextStyle(
                    color: Color(0xFFF2E9F1),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: LinearProgressIndicator(
                    minHeight: 7,
                    value: data.progress,
                    color: const Color(0xFF19C6FF),
                    backgroundColor: const Color(0xFF263137),
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    data.progressPercentage,
                    style: const TextStyle(
                      color: Color(0xFFFFD6DA),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(bool isVeryNarrow) {
    final cards = [
      _buildStatCard(
        icon: Icons.keyboard_outlined,
        label: data.averageRateLabel,
        value: data.averageRateValue,
        accent: const Color(0xFF00B7FF),
      ),
      _buildStatCard(
        icon: Icons.trending_up,
        label: data.variationLabel,
        value: data.variationValue,
        accent: data.variationColor,
      ),
    ];

    if (isVeryNarrow) {
      return Column(
        children: [cards.first, const SizedBox(height: 12), cards.last],
      );
    }

    return Row(
      children: [
        Expanded(child: cards.first),
        const SizedBox(width: 14),
        Expanded(child: cards.last),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color accent,
  }) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 120),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF151517),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF1D1D21),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: accent, size: 14),
          ),
          const SizedBox(height: 28),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFFD7B8BC),
              fontSize: 12,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: accent,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    return ElevatedButton.icon(
      onPressed: onStartSession ?? () {},
      icon: const Icon(Icons.directions_run, color: Colors.white, size: 28),
      label: const Text(
        'NOVA SESSÃO',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFF2F64),
        foregroundColor: Colors.white,
        elevation: 12,
        shadowColor: const Color(0xFFFF2F64).withValues(alpha: 0.5),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
    );
  }
}

class AtletaDashboardData {
  const AtletaDashboardData({
    required this.greetingTitle,
    required this.subtitle,
    required this.alertTitle,
    required this.alertSubtitle,
    required this.alertMessage,
    this.hasAlert = false,
    required this.progress,
    required this.progressLabel,
    required this.progressPercentage,
    required this.averageRateLabel,
    required this.averageRateValue,
    required this.variationLabel,
    required this.variationValue,
    required this.variationColor,
  });

  final String greetingTitle;
  final String subtitle;
  final String alertTitle;
  final String alertSubtitle;
  final String alertMessage;
  final bool hasAlert;
  final double progress;
  final String progressLabel;
  final String progressPercentage;
  final String averageRateLabel;
  final String averageRateValue;
  final String variationLabel;
  final String variationValue;
  final Color variationColor;

  factory AtletaDashboardData.fromHydrationMetrics({
    required String athleteName,
    required double sweatRate,
    required double recommendedIntakeLiters,
    required Duration recommendedWindow,
    required double completedPercent,
    required double averageRate,
    required double variationPercent,
    bool hasHydrationAlert = true,
  }) {
    final variationPositive = variationPercent >= 0;
    final variationString = variationPositive
        ? '+${variationPercent.toStringAsFixed(1)}%'
        : '${variationPercent.toStringAsFixed(1)}%';

    return AtletaDashboardData(
      greetingTitle: 'BOM TREINO, ${athleteName.toUpperCase()}',
      subtitle: 'Seu foco hoje: Hidratação e Recuperação.',
      alertTitle: 'ALERTA DE HIDRATAÇÃO',
      alertSubtitle: 'Sua taxa de suor na última sessão foi alta.',
      alertMessage:
          'Sua taxa de suor na última sessão foi alta. Recomenda-se ingestão de ${recommendedIntakeLiters.toStringAsFixed(1)}L nas próximas ${recommendedWindow.inHours} horas.',
      hasAlert: hasHydrationAlert,
      progress: completedPercent.clamp(0, 1),
      progressLabel: 'COMPLETADO',
      progressPercentage:
          '${(completedPercent * 100).toStringAsFixed(0)}% COMPLETADO',
      averageRateLabel: 'TAXA MÉDIA',
      averageRateValue: '${averageRate.toStringAsFixed(1)} L/h',
      variationLabel: 'VARIAÇÃO %',
      variationValue: variationString,
      variationColor: variationPositive
          ? const Color(0xFFFF2F64)
          : const Color(0xFF00B7FF),
    );
  }
}
