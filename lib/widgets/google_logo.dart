import 'package:flutter/material.dart';

/// Colored Google logo widget matching Google's brand guidelines
/// Displays the iconic Google "G" logo with official brand colors
class GoogleLogo extends StatelessWidget {
  const GoogleLogo({
    super.key,
    this.size = 24,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: SweepGradient(
          center: Alignment.center,
          colors: [
            const Color(0xFF4285F4), // Blue
            const Color(0xFFEA4335), // Red
            const Color(0xFFFBBC05), // Yellow
            const Color(0xFF34A853), // Green
            const Color(0xFF4285F4), // Blue (wrap around)
          ],
          stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
        ),
      ),
      child: Center(
        child: Container(
          width: size * 0.65,
          height: size * 0.65,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              'G',
              style: TextStyle(
                fontSize: size * 0.5,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF4285F4), // Google blue
                height: 1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
