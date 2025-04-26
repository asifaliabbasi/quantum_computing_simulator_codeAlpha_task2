import 'package:quantum_computing_simulator/shared/models/quantum_gate.dart';
import 'package:quantum_computing_simulator/shared/models/complex.dart';

class CircuitStep {
  final QuantumGate gate;
  final int targetQubit;
  final int? controlQubit;

  const CircuitStep({
    required this.gate,
    required this.targetQubit,
    this.controlQubit,
  });

  Map<String, dynamic> toJson() => {
        'gate': gate.name,
        'targetQubit': targetQubit,
        'controlQubit': controlQubit,
      };

  factory CircuitStep.fromJson(Map<String, dynamic> json) {
    final gate = QuantumGate.allGates.firstWhere(
      (g) => g.name == json['gate'],
      orElse: () => QuantumGate.pauliX,
    );
    return CircuitStep(
      gate: gate,
      targetQubit: json['targetQubit'],
      controlQubit: json['controlQubit'],
    );
  }
}

class QuantumCircuit {
  final List<CircuitStep> steps;
  final int numberOfQubits;
  List<Complex> _currentState;

  QuantumCircuit({
    required this.steps,
    required this.numberOfQubits,
  }) : _currentState = List.generate(
          numberOfQubits,
          (index) => Complex(1, 0),
        );

  List<Complex> get currentState => _currentState;

  void applyStep(CircuitStep step) {
    if (step.controlQubit != null) {
      // Apply controlled gate
      if (_currentState[step.controlQubit!].real == 1) {
        _currentState[step.targetQubit] =
            step.gate.applyToState(_currentState[step.targetQubit]);
      }
    } else {
      // Apply single-qubit gate
      _currentState[step.targetQubit] =
          step.gate.applyToState(_currentState[step.targetQubit]);
    }
  }

  void reset() {
    _currentState = List.generate(
      numberOfQubits,
      (index) => Complex(1, 0),
    );
  }

  Map<String, dynamic> toJson() => {
        'steps': steps.map((step) => step.toJson()).toList(),
        'numberOfQubits': numberOfQubits,
      };

  factory QuantumCircuit.fromJson(Map<String, dynamic> json) {
    final steps = (json['steps'] as List)
        .map((step) => CircuitStep.fromJson(step))
        .toList();
    return QuantumCircuit(
      steps: steps,
      numberOfQubits: json['numberOfQubits'],
    );
  }
}
