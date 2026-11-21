import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Widget Logo officiel pour UniManager
/// Affiche l'emblème universitaire vectoriel avec sa typographie soignée
class UniManagerLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool isDarkBackground;
  final String? subtitle;

  const UniManagerLogo({
    super.key,
    this.size = 64,
    this.showText = true,
    this.isDarkBackground = false,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDarkBackground ? Colors.white : const Color(0xFF0F172A);
    final subtextColor = isDarkBackground ? Colors.white70 : const Color(0xFF64748B);

    final emblem = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E3A8A), // Bleu Royal
            Color(0xFF0284C7), // Cyan Vif
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0284C7).withOpacity(0.35),
            blurRadius: size * 0.25,
            offset: Offset(0, size * 0.1),
          ),
        ],
      ),
      child: Center(
        child: CustomPaint(
          size: Size(size * 0.65, size * 0.65),
          painter: _GraduationCapPainter(),
        ),
      ),
    );

    if (!showText) return emblem;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        emblem,
        SizedBox(width: size * 0.22),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: size * 0.42,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  fontFamily: 'sans-serif',
                ),
                children: [
                  TextSpan(
                    text: 'Uni',
                    style: TextStyle(color: textColor),
                  ),
                  const TextSpan(
                    text: 'Manager',
                    style: TextStyle(
                      color: AppTheme.secondaryCyan,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: size * 0.18,
                  fontWeight: FontWeight.w600,
                  color: subtextColor,
                  letterSpacing: 1.2,
                ),
              ),
            ] else ...[
              Container(
                margin: const EdgeInsets.only(top: 2),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryCyan.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'GESTION UNIVERSITAIRE',
                  style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryBlue,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

/// Peintre personnalisé pour l'icône vectorielle de chapeau de diplômé et livre
class _GraduationCapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final strokePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.08
      ..strokeCap = StrokeCap.round;

    final goldPaint = Paint()
      ..color = const Color(0xFFFBBF24) // Doré pour le pompon
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    // 1. Chapeau de diplômé (losange supérieur)
    final capPath = Path();
    capPath.moveTo(w * 0.5, h * 0.12);
    capPath.lineTo(w * 0.95, h * 0.35);
    capPath.lineTo(w * 0.5, h * 0.56);
    capPath.lineTo(w * 0.05, h * 0.35);
    capPath.close();
    canvas.drawPath(capPath, paint);

    // 2. Base inférieure du chapeau
    final baseCapPath = Path();
    baseCapPath.moveTo(w * 0.24, h * 0.46);
    baseCapPath.quadraticBezierTo(w * 0.24, h * 0.68, w * 0.5, h * 0.72);
    baseCapPath.quadraticBezierTo(w * 0.76, h * 0.68, w * 0.76, h * 0.46);
    baseCapPath.lineTo(w * 0.5, h * 0.56);
    baseCapPath.close();
    canvas.drawPath(baseCapPath, paint);

    // 3. Cordon et pompon doré
    final tasselPath = Path();
    tasselPath.moveTo(w * 0.5, h * 0.35);
    tasselPath.lineTo(w * 0.88, h * 0.42);
    tasselPath.lineTo(w * 0.88, h * 0.68);
    final tasselLinePaint = Paint()
      ..color = const Color(0xFFFBBF24)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.055
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(tasselPath, tasselLinePaint);
    canvas.drawCircle(Offset(w * 0.88, h * 0.72), w * 0.06, goldPaint);

    // 4. Livre ouvert stylisé en dessous
    final bookPath = Path();
    // Page gauche
    bookPath.moveTo(w * 0.5, h * 0.88);
    bookPath.quadraticBezierTo(w * 0.3, h * 0.78, w * 0.12, h * 0.82);
    // Page droite
    bookPath.moveTo(w * 0.5, h * 0.88);
    bookPath.quadraticBezierTo(w * 0.7, h * 0.78, w * 0.88, h * 0.82);
    canvas.drawPath(bookPath, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
