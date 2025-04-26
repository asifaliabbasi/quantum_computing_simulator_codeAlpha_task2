import 'package:flutter/material.dart';
import 'package:quantum_computing_simulator/shared/models/quantum_gate.dart';
import 'package:quantum_computing_simulator/shared/models/circuit_save.dart';

class CircuitVisualization extends StatelessWidget {
  final List<CircuitStep> steps;
  final int numberOfQubits;
  final Function(CircuitStep)? onStepSelected;
  final Function(CircuitStep)? onStepDeleted;
  final bool isInteractive;

  const CircuitVisualization({
    super.key,
    required this.steps,
    required this.numberOfQubits,
    this.onStepSelected,
    this.onStepDeleted,
    this.isInteractive = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: steps.length,
            itemBuilder: (context, index) {
              final step = steps[index];
              return _buildStepRow(context, step, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStepRow(BuildContext context, CircuitStep step, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: InkWell(
        onTap: isInteractive ? () => onStepSelected?.call(step) : null,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              _buildGateIcon(context, step.gate),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.gate.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      'Target: Qubit ${step.targetQubit + 1}${step.controlQubit != null ? ', Control: Qubit ${step.controlQubit! + 1}' : ''}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (isInteractive)
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => onStepDeleted?.call(step),
                  tooltip: 'Delete Step',
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGateIcon(BuildContext context, QuantumGate gate) {
    IconData iconData;
    switch (gate.type) {
      case QuantumGateType.hadamard:
        iconData = Icons.waves;
        break;
      case QuantumGateType.pauliX:
        iconData = Icons.flip;
        break;
      case QuantumGateType.pauliY:
        iconData = Icons.rotate_right;
        break;
      case QuantumGateType.pauliZ:
        iconData = Icons.rotate_left;
        break;
      case QuantumGateType.cnot:
        iconData = Icons.link;
        break;
      case QuantumGateType.tGate:
        iconData = Icons.timer;
        break;
      case QuantumGateType.sGate:
        iconData = Icons.speed;
        break;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        iconData,
        color: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
    );
  }
}
