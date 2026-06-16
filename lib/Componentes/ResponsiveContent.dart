import 'package:flutter/material.dart';
import 'package:hidratrack/Componentes/ResponsiveLayout.dart';

class ResponsiveContent extends StatelessWidget {
  const ResponsiveContent({
    super.key,
    required this.child,
    this.maxWidth,
    this.mobilePadding = const EdgeInsets.all(16),
    this.desktopPadding = const EdgeInsets.symmetric(
      horizontal: 40,
      vertical: 28,
    ),
  });

  final Widget child;
  final double? maxWidth;
  final EdgeInsets mobilePadding;
  final EdgeInsets desktopPadding;

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final width = maxWidth ?? ResponsiveLayout.contentMaxWidth(context);

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: width),
        child: Padding(
          padding: isDesktop ? desktopPadding : mobilePadding,
          child: child,
        ),
      ),
    );
  }
}
