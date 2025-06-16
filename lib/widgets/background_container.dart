import 'package:flutter/material.dart';

class BackgroundContainer extends StatelessWidget {
  final Widget child;

  const BackgroundContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topCenter,
          radius: 2.0,
          colors: [
            Color(0xFF1F4247),
            Color(0xFF0D1D23),
            Color(0xFF09141A),
          ],
          stops: [0.0, 0.56, 1.0],
        ),
      ),
      child: child,
    );
  }
}
