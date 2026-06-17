import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double? size;
  final Animation<double>? fadeAnimation;
  final Animation<double>? scaleAnimation;
  final String assetPath;

  const AppLogo({
    super.key,
    this.size,
    this.fadeAnimation,
    this.scaleAnimation,
    this.assetPath = 'assets/images/logo/logo.png',
  });

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final logoHeight = size ?? deviceSize.height * 0.25;

    Widget logo = Image.asset(
      assetPath,
      height: logoHeight,
      filterQuality: FilterQuality.high,
    );

    if (scaleAnimation != null) {
      logo = ScaleTransition(scale: scaleAnimation!, child: logo);
    }

    if (fadeAnimation != null) {
      logo = FadeTransition(opacity: fadeAnimation!, child: logo);
    }

    return logo;
  }
}