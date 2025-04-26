import 'dart:convert';
import 'package:quantum_computing_simulator/shared/models/quantum_gate.dart';

class CircuitSave {
  final String name;
  final String description;
  final List<CircuitStep> steps;
  final DateTime createdAt;
  final DateTime lastModified;
  final Map<String, dynamic>? metadata;

  const CircuitSave({
    required this.name,
    required this.description,
    required this.steps,
    required this.createdAt,
    required this.lastModified,
    this.metadata,
  });

  CircuitSave copyWith({
    String? name,
    String? description,
    List<CircuitStep>? steps,
    DateTime? createdAt,
    DateTime? lastModified,
    Map<String, dynamic>? metadata,
  }) {
    return CircuitSave(
      name: name ?? this.name,
      description: description ?? this.description,
      steps: steps ?? this.steps,
      createdAt: createdAt ?? this.createdAt,
      lastModified: lastModified ?? this.lastModified,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'steps': steps.map((step) => step.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'lastModified': lastModified.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory CircuitSave.fromJson(Map<String, dynamic> json) {
    return CircuitSave(
      name: json['name'] as String,
      description: json['description'] as String,
      steps: (json['steps'] as List)
          .map((step) => CircuitStep.fromJson(step as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastModified: DateTime.parse(json['lastModified'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
}

class CircuitStep {
  final QuantumGate gate;
  final int targetQubit;
  final int? controlQubit;
  final Map<String, dynamic>? parameters;

  const CircuitStep({
    required this.gate,
    required this.targetQubit,
    this.controlQubit,
    this.parameters,
  });

  Map<String, dynamic> toJson() {
    return {
      'gate': gate.type.index,
      'targetQubit': targetQubit,
      'controlQubit': controlQubit,
      'parameters': parameters,
    };
  }

  factory CircuitStep.fromJson(Map<String, dynamic> json) {
    return CircuitStep(
      gate: QuantumGate.getGateByType(
        QuantumGateType.values[json['gate'] as int],
      )!,
      targetQubit: json['targetQubit'] as int,
      controlQubit: json['controlQubit'] as int?,
      parameters: json['parameters'] as Map<String, dynamic>?,
    );
  }
}
