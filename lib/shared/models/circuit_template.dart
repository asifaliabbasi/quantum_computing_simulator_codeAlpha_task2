import 'package:quantum_computing_simulator/shared/models/quantum_gate.dart';
import 'package:quantum_computing_simulator/shared/models/complex.dart';

class CircuitTemplate {
  final String name;
  final String description;
  final List<QuantumGate> gates;
  final List<int> targetQubits;
  final Map<String, dynamic> parameters;

  CircuitTemplate({
    required this.name,
    required this.description,
    required this.gates,
    required this.targetQubits,
    this.parameters = const {},
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'gates': gates.map((gate) => gate.toJson()).toList(),
        'targetQubits': targetQubits,
        'parameters': parameters,
      };

  factory CircuitTemplate.fromJson(Map<String, dynamic> json) {
    return CircuitTemplate(
      name: json['name'] as String,
      description: json['description'] as String,
      gates: (json['gates'] as List)
          .map((gate) => QuantumGate.fromJson(gate as Map<String, dynamic>))
          .toList(),
      targetQubits:
          (json['targetQubits'] as List).map((e) => e as int).toList(),
      parameters: json['parameters'] as Map<String, dynamic>,
    );
  }

  // Apply the circuit template to a quantum state
  List<Complex> applyToState(List<Complex> state) {
    List<Complex> result = List.from(state);
    for (int i = 0; i < gates.length; i++) {
      final gate = gates[i];
      final targetQubit = targetQubits[i];
      result[targetQubit] = gate.applyToState(result[targetQubit]);
    }
    return result;
  }

  // Get all available circuit templates
  static List<CircuitTemplate> get allTemplates => [
        CircuitTemplate(
          name: 'Bell State',
          description: 'Creates a Bell state (maximally entangled state)',
          gates: [QuantumGate.hadamard, QuantumGate.cnot],
          targetQubits: [0, 1],
        ),
        CircuitTemplate(
          name: 'Quantum Teleportation',
          description: 'Implements quantum teleportation protocol',
          gates: [
            QuantumGate.hadamard,
            QuantumGate.cnot,
            QuantumGate.hadamard,
            QuantumGate.pauliX,
            QuantumGate.pauliZ,
          ],
          targetQubits: [0, 1, 2],
        ),
        CircuitTemplate(
          name: 'Quantum Fourier Transform',
          description: 'Implements the quantum Fourier transform',
          gates: [
            QuantumGate.hadamard,
            QuantumGate.tGate,
            QuantumGate.sGate,
          ],
          targetQubits: [0, 1, 2],
        ),
      ];
}
