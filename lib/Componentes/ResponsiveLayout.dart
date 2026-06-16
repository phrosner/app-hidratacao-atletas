import 'package:flutter/material.dart';

/// Breakpoint desktop: mobile permanece igual abaixo deste valor.
abstract final class ResponsiveLayout {
  static const double desktopBreakpoint = 900;
  static const double mobileMaxWidth = 520;
  static const double desktopMaxWidth = 1180;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= desktopBreakpoint;

  static double contentMaxWidth(BuildContext context) =>
      isDesktop(context) ? desktopMaxWidth : mobileMaxWidth;

  static EdgeInsets pagePadding(BuildContext context) {
    if (isDesktop(context)) {
      return const EdgeInsets.symmetric(horizontal: 40, vertical: 28);
    }
    return const EdgeInsets.symmetric(horizontal: 16, vertical: 16);
  }

  static EdgeInsets scrollPadding(
    BuildContext context, {
    double mobileLeft = 16,
    double mobileTop = 12,
    double mobileRight = 16,
    double mobileBottom = 86,
  }) {
    if (isDesktop(context)) {
      return EdgeInsets.fromLTRB(40, 28, 40, mobileBottom);
    }
    return EdgeInsets.fromLTRB(
      mobileLeft,
      mobileTop,
      mobileRight,
      mobileBottom,
    );
  }

  /// Empilha no mobile; lado a lado no desktop (ex.: login, dashboards).
  static Widget rowOrColumn({
    required BuildContext context,
    required List<Widget> children,
    double desktopSpacing = 32,
    double mobileSpacing = 0,
    CrossAxisAlignment desktopCrossAxis = CrossAxisAlignment.start,
    MainAxisAlignment desktopMainAxis = MainAxisAlignment.start,
  }) {
    if (!isDesktop(context)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _intersperse(children, SizedBox(height: mobileSpacing)),
      );
    }
    return Row(
      crossAxisAlignment: desktopCrossAxis,
      mainAxisAlignment: desktopMainAxis,
      children: [
        for (var i = 0; i < children.length; i++)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: i > 0 ? desktopSpacing / 2 : 0,
                right: i < children.length - 1 ? desktopSpacing / 2 : 0,
              ),
              child: children[i],
            ),
          ),
      ],
    );
  }

  /// Grade 2 colunas no desktop; lista vertical no mobile.
  static Widget cardGrid({
    required BuildContext context,
    required List<Widget> children,
    double spacing = 16,
  }) {
    if (!isDesktop(context) || children.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _intersperse(children, SizedBox(height: spacing)),
      );
    }

    final rows = <Widget>[];
    for (var i = 0; i < children.length; i += 2) {
      final left = children[i];
      final right = i + 1 < children.length ? children[i + 1] : null;
      rows.add(
        Padding(
          padding: EdgeInsets.only(bottom: i + 2 < children.length ? spacing : 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: left),
              SizedBox(width: spacing),
              Expanded(child: right ?? const SizedBox.shrink()),
            ],
          ),
        ),
      );
    }
    return Column(children: rows);
  }

  static List<Widget> _intersperse(List<Widget> items, Widget spacer) {
    if (items.isEmpty) return items;
    final out = <Widget>[items.first];
    for (var i = 1; i < items.length; i++) {
      out.add(spacer);
      out.add(items[i]);
    }
    return out;
  }
}

/// Envolve o conteúdo centralizado: mobile 520px, desktop até 1180px.
class ResponsivePage extends StatelessWidget {
  const ResponsivePage({
    super.key,
    required this.child,
    this.alignment = Alignment.topCenter,
    this.padding,
  });

  final Widget child;
  final Alignment alignment;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: ResponsiveLayout.contentMaxWidth(context),
        ),
        child: Padding(
          padding: padding ?? EdgeInsets.zero,
          child: child,
        ),
      ),
    );
  }
}
