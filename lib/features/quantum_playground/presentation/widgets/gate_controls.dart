import 'package:flutter/material.dart';
import 'package:quantum_computing_simulator/shared/models/quantum_gate.dart';

class GateControls extends StatelessWidget {
  final Function(QuantumGate, int) onGateApplied;

  const GateControls({
    super.key,
    required this.onGateApplied,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Text(
                'Quantum Gates',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              padding: const EdgeInsets.all(8.0),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildGateButton(context, QuantumGate.hadamard, 'H'),
                _buildGateButton(context, QuantumGate.pauliX, 'X'),
                _buildGateButton(context, QuantumGate.pauliY, 'Y'),
                _buildGateButton(context, QuantumGate.pauliZ, 'Z'),
                _buildGateButton(context, QuantumGate.cnot, 'CNOT'),
                _buildGateButton(context, QuantumGate.tGate, 'T'),
                _buildGateButton(context, QuantumGate.sGate, 'S'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGateButton(
      BuildContext context, QuantumGate gate, String label) {
    return ElevatedButton(
      onPressed: () {
        // TODO: Show qubit selection dialog
        onGateApplied(gate, 0);
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              _getGateDescription(gate.type),
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  String _getGateDescription(QuantumGateType type) {
    switch (type) {
      case QuantumGateType.hadamard:
        return 'Creates superposition';
      case QuantumGateType.pauliX:
        return 'Bit flip';
      case QuantumGateType.pauliY:
        return 'Bit and phase flip';
      case QuantumGateType.pauliZ:
        return 'Phase flip';
      case QuantumGateType.cnot:
        return 'Controlled NOT';
      case QuantumGateType.tGate:
        return 'π/4 phase';
      case QuantumGateType.sGate:
        return 'π/2 phase';
    }
  }
}
