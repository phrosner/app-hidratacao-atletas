import 'package:flutter/material.dart';

class AtletaBottomNavBar extends StatelessWidget {
  const AtletaBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const Color _background = Color(0xFF17151A);
  static const Color _activeColor = Color(0xFFFF2F64);
  static const Color _inactiveColor = Color(0xFF6F7480);

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Container(
      height: 66 + bottomInset,
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: _background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 18,
            offset: Offset(0, -8),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildItem(index: 0, icon: Icons.home_outlined, label: 'INÍCIO'),
          _buildItem(
            index: 1,
            icon: Icons.fitness_center_outlined,
            label: 'SESSÕES',
          ),
          _buildItem(
            index: 2,
            icon: Icons.history_outlined,
            label: 'HISTÓRICO',
          ),
          _buildItem(index: 3, icon: Icons.person_outline, label: 'PERFIL'),
        ],
      ),
    );
  }

  Widget _buildItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isActive = currentIndex == index;
    final color = isActive ? _activeColor : _inactiveColor;

    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 19),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
