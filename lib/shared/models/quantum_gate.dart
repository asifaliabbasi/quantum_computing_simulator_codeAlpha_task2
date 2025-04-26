import 'package:flutter/material.dart';
import 'package:quantum_computing_simulator/shared/models/complex.dart';

enum QuantumGateType {
  hadamard,
  pauliX,
  pauliY,
  pauliZ,
  cnot,
  tGate,
  sGate,
}

class QuantumGate {
  final String name;
  final String symbol;
  final List<List<Complex>> matrix;
  final String description;
  final QuantumGateType type;

  const QuantumGate({
    required this.name,
    required this.symbol,
    required this.matrix,
    required this.description,
    required this.type,
  });

  // Standard quantum gates
  static final hadamard = QuantumGate(
    name: 'Hadamard',
    symbol: 'H',
    matrix: [
      [Complex(0.7071, 0), Complex(0.7071, 0)],
      [Complex(0.7071, 0), Complex(-0.7071, 0)],
    ],
    description: 'Creates superposition',
    type: QuantumGateType.hadamard,
  );

  static final pauliX = QuantumGate(
    name: 'Pauli-X',
    symbol: 'X',
    matrix: [
      [Complex(0, 0), Complex(1, 0)],
      [Complex(1, 0), Complex(0, 0)],
    ],
    description: 'Bit flip',
    type: QuantumGateType.pauliX,
  );

  static final pauliY = QuantumGate(
    name: 'Pauli-Y',
    symbol: 'Y',
    matrix: [
      [Complex(0, 0), Complex(0, -1)],
      [Complex(0, 1), Complex(0, 0)],
    ],
    description: 'Bit and phase flip',
    type: QuantumGateType.pauliY,
  );

  static final pauliZ = QuantumGate(
    name: 'Pauli-Z',
    symbol: 'Z',
    matrix: [
      [Complex(1, 0), Complex(0, 0)],
      [Complex(0, 0), Complex(-1, 0)],
    ],
    description: 'Phase flip',
    type: QuantumGateType.pauliZ,
  );

  static final tGate = QuantumGate(
    name: 'T',
    symbol: 'T',
    matrix: [
      [Complex(1, 0), Complex(0, 0)],
      [Complex(0, 0), Complex(0.7071, 0.7071)],
    ],
    description: 'π/4 phase',
    type: QuantumGateType.tGate,
  );

  static final sGate = QuantumGate(
    name: 'S',
    symbol: 'S',
    matrix: [
      [Complex(1, 0), Complex(0, 0)],
      [Complex(0, 0), Complex(0, 1)],
    ],
    description: 'π/2 phase',
    type: QuantumGateType.sGate,
  );

  static final cnot = QuantumGate(
    name: 'CNOT',
    symbol: 'CNOT',
    matrix: [
      [Complex(1, 0), Complex(0, 0), Complex(0, 0), Complex(0, 0)],
      [Complex(0, 0), Complex(1, 0), Complex(0, 0), Complex(0, 0)],
      [Complex(0, 0), Complex(0, 0), Complex(0, 0), Complex(1, 0)],
      [Complex(0, 0), Complex(0, 0), Complex(1, 0), Complex(0, 0)],
    ],
    description: 'Controlled NOT',
    type: QuantumGateType.cnot,
  );

  // Apply gate to a qubit state
  Complex applyToState(Complex state) {
    if (matrix.length == 2) {
      // Single qubit gate
      final real = matrix[0][0].real * state.real -
          matrix[0][0].imaginary * state.imaginary +
          matrix[0][1].real * state.real -
          matrix[0][1].imaginary * state.imaginary;
      final imaginary = matrix[0][0].real * state.imaginary +
          matrix[0][0].imaginary * state.real +
          matrix[0][1].real * state.imaginary +
          matrix[0][1].imaginary * state.real;
      return Complex(real, imaginary);
    } else {
      // Multi-qubit gate (e.g., CNOT)
      // For CNOT, we need to handle the control and target qubits
      if (type == QuantumGateType.cnot) {
        // CNOT gate implementation
        // This is a simplified version - in a real implementation,
        // you would need to handle the full state vector
        return state; // Placeholder - actual implementation needed
      }
      return state; // Default case
    }
  }

  // Get all available gates
  static List<QuantumGate> get allGates => [
        hadamard,
        pauliX,
        pauliY,
        pauliZ,
        tGate,
        sGate,
        cnot,
      ];

  // Get gate by type
  static QuantumGate? getGateByType(QuantumGateType type) {
    try {
      return allGates.firstWhere((gate) => gate.type == type);
    } catch (e) {
      return null;
    }
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'symbol': symbol,
        'matrix': matrix
            .map((row) => row
                .map((complex) => {
                      'real': complex.real,
                      'imaginary': complex.imaginary,
                    })
                .toList())
            .toList(),
        'description': description,
        'type': type.toString().split('.').last,
      };

  factory QuantumGate.fromJson(Map<String, dynamic> json) {
    return QuantumGate(
      name: json['name'] as String,
      symbol: json['symbol'] as String,
      matrix: (json['matrix'] as List)
          .map((row) => (row as List)
              .map((complex) => Complex(
                    (complex as Map<String, dynamic>)['real'] as double,
                    (complex as Map<String, dynamic>)['imaginary'] as double,
                  ))
              .toList())
          .toList(),
      description: json['description'] as String,
      type: QuantumGateType.values.firstWhere(
        (e) => e.toString() == 'QuantumGateType.${json['type']}',
        orElse: () => QuantumGateType.hadamard,
      ),
    );
  }
}
