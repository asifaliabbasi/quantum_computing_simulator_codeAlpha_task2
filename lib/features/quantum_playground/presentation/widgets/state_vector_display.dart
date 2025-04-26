import 'package:flutter/material.dart';
import 'package:quantum_computing_simulator/shared/models/complex.dart';

class StateVectorDisplay extends StatelessWidget {
  final List<Complex> qubitStates;

  const StateVectorDisplay({
    super.key,
    required this.qubitStates,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quantum State',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              _formatStateVector(),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontFamily: 'monospace',
                  ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatStateVector() {
    if (qubitStates.isEmpty) return '|0⟩';

    final buffer = StringBuffer();
    buffer.write('|ψ⟩ = ');

    for (var i = 0; i < qubitStates.length; i++) {
      final state = qubitStates[i];
      if (i > 0) buffer.write(' ⊗ ');
      buffer.write('(${state.toString()})');
    }

    return buffer.toString();
  }
}
