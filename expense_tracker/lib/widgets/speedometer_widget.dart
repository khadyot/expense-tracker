import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/app_theme.dart';

class SpeedometerWidget extends StatelessWidget {
  final double dailyLimit;
  final double currentSpent;
  final double predictedSpend; // Including ghost bills

  const SpeedometerWidget({
    super.key,
    required this.dailyLimit,
    required this.currentSpent,
    this.predictedSpend = 0,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (currentSpent / dailyLimit).clamp(0.0, 1.0);
    final predictedPercentage =
        ((currentSpent + predictedSpend) / dailyLimit).clamp(0.0, 1.0);
    final safeToSpend = math.max(0, dailyLimit - currentSpent);

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Speedometer
          SizedBox(
            height: 200,
            width: 200,
            child: CustomPaint(
              painter: SpeedometerPainter(
                percentage: percentage,
                predictedPercentage: predictedPercentage,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '₹${safeToSpend.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      'Safe to Spend',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(
                label: 'Spent',
                value: '₹${currentSpent.toStringAsFixed(0)}',
                color: Colors.white,
              ),
              _StatItem(
                label: 'Limit',
                value: '₹${dailyLimit.toStringAsFixed(0)}',
                color: Colors.white,
              ),
              if (predictedSpend > 0)
                _StatItem(
                  label: 'Predicted',
                  value: '₹${predictedSpend.toStringAsFixed(0)}',
                  color: const Color(0xFFFFCC80),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}

class SpeedometerPainter extends CustomPainter {
  final double percentage;
  final double predictedPercentage;

  SpeedometerPainter({
    required this.percentage,
    required this.predictedPercentage,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) /
        2; // Removed -10 to utilize full space
    final strokeWidth = 16.0; // Reduced thickness slightly to create more space

    // Background arc
    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi * 0.75, // Start angle
      math.pi * 1.5, // Sweep angle
      false,
      bgPaint,
    );

    // Predicted spend arc (ghost layer)
    if (predictedPercentage > percentage) {
      final predictedPaint = Paint()
        ..color = const Color(0xFFFFCC80).withOpacity(0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      final predictedAngle = math.pi * 1.5 * predictedPercentage;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        math.pi * 0.75,
        predictedAngle,
        false,
        predictedPaint,
      );
    }

    // Current spend arc
    final progressPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Colors.white, Color(0xFFE0E0E0)],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = math.pi * 1.5 * percentage;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi * 0.75,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(SpeedometerPainter oldDelegate) {
    return oldDelegate.percentage != percentage ||
        oldDelegate.predictedPercentage != predictedPercentage;
  }
}
