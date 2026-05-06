import 'package:flutter/material.dart';

class ResponsiveContent extends StatelessWidget {
  const ResponsiveContent({
    super.key,
    required this.child,
    this.maxWidth = 1180,
    this.mobilePadding = const EdgeInsets.all(16),
    this.desktopPadding = const EdgeInsets.symmetric(
      horizontal: 32,
      vertical: 28,
    ),
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsets mobilePadding;
  final EdgeInsets desktopPadding;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 900;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: isDesktop ? desktopPadding : mobilePadding,
          child: child,
        ),
      ),
    );
  }
}
