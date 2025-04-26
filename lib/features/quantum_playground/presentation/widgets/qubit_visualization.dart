import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:quantum_computing_simulator/shared/models/complex.dart';

class QubitVisualization extends StatelessWidget {
  final List<Complex> qubitStates;
  final Function(int, Complex) onStateChanged;
  final Map<int, int> measurementResults;
  final bool isMeasuring;

  const QubitVisualization({
    super.key,
    required this.qubitStates,
    required this.onStateChanged,
    this.measurementResults = const {},
    this.isMeasuring = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: qubitStates.length,
            itemBuilder: (context, index) {
              return _buildQubitLine(context, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQubitLine(BuildContext context, int index) {
    final state = qubitStates[index];
    final measurementResult = measurementResults[index];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Text(
              'Qubit ${index + 1}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'State: ${state.toString()}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (isMeasuring && measurementResult != null)
                    Text(
                      'Measurement: |$measurementResult⟩',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QubitPainter extends CustomPainter {
  final List<Complex> qubitStates;
  final Function(int, Complex) onStateChanged;

  QubitPainter({
    required this.qubitStates,
    required this.onStateChanged,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.4;

    // Draw Bloch sphere
    final spherePaint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw main circle
    canvas.drawCircle(center, radius, spherePaint);

    // Draw axes
    final axisPaint = Paint()
      ..color = Colors.grey.withOpacity(0.5)
      ..strokeWidth = 1;

    // X-axis
    canvas.drawLine(
      Offset(center.dx - radius, center.dy),
      Offset(center.dx + radius, center.dy),
      axisPaint,
    );

    // Y-axis
    canvas.drawLine(
      Offset(center.dx, center.dy - radius),
      Offset(center.dx, center.dy + radius),
      axisPaint,
    );

    // Draw qubit states
    for (var i = 0; i < qubitStates.length; i++) {
      final state = qubitStates[i];
      final theta = 2 * math.atan2(state.imaginary, state.real);
      final phi = math.atan2(state.imaginary, state.real);

      final x = radius * math.sin(theta) * math.cos(phi);
      final y = radius * math.sin(theta) * math.sin(phi);

      final pointPaint = Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(center.dx + x, center.dy + y),
        8,
        pointPaint,
      );

      // Draw qubit label
      final textPainter = TextPainter(
        text: TextSpan(
          text: 'Q${i + 1}',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 12,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(center.dx + x + 10, center.dy + y - 10),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
