import 'package:flutter/material.dart';

/// A widget that builds different layouts based on screen size
class ResponsiveBuilder extends StatelessWidget {
  /// Widget to display on mobile screens (< 600)
  final Widget? mobile;

  /// Widget to display on tablet screens (>= 600 && < 1200)
  final Widget? tablet;

  /// Widget to display on desktop screens (>= 1200)
  final Widget? desktop;

  const ResponsiveBuilder({
    super.key,
    this.mobile,
    this.tablet,
    this.desktop,
  });

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1200;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1200;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    // Desktop layout
    if (size.width >= 1200) {
      return desktop ?? tablet ?? mobile ?? const SizedBox.shrink();
    }

    // Tablet layout
    if (size.width >= 600) {
      return tablet ?? mobile ?? const SizedBox.shrink();
    }

    // Mobile layout
    return mobile ?? const SizedBox.shrink();
  }
}
