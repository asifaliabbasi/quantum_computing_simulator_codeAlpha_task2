import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quantum_computing_simulator/shared/models/quantum_circuit.dart';
import 'package:quantum_computing_simulator/shared/models/quantum_gate.dart';
import 'package:quantum_computing_simulator/shared/services/circuit_storage_service.dart';

final circuitStorageServiceProvider = Provider<CircuitStorageService>((ref) {
  throw UnimplementedError('Initialize with SharedPreferences instance');
});

final quantumCircuitProvider =
    StateNotifierProvider<QuantumCircuitNotifier, QuantumCircuit>((ref) {
  return QuantumCircuitNotifier();
});

class QuantumCircuitNotifier extends StateNotifier<QuantumCircuit> {
  QuantumCircuitNotifier()
      : super(QuantumCircuit(steps: [], numberOfQubits: 1));

  void addStep(QuantumGate gate, int targetQubit, {int? controlQubit}) {
    final newStep = CircuitStep(
      gate: gate,
      targetQubit: targetQubit,
      controlQubit: controlQubit,
    );

    final newSteps = [...state.steps, newStep];
    state = QuantumCircuit(
      steps: newSteps,
      numberOfQubits: state.numberOfQubits,
    );

    state.applyStep(newStep);
  }

  void removeStep(int index) {
    final newSteps = [...state.steps];
    newSteps.removeAt(index);

    state = QuantumCircuit(
      steps: newSteps,
      numberOfQubits: state.numberOfQubits,
    );

    // Reapply all steps to get the correct state
    state.reset();
    for (final step in newSteps) {
      state.applyStep(step);
    }
  }

  void setNumberOfQubits(int count) {
    state = QuantumCircuit(
      steps: state.steps,
      numberOfQubits: count,
    );
  }

  void reset() {
    state = QuantumCircuit(
      steps: [],
      numberOfQubits: state.numberOfQubits,
    );
  }

  Future<void> saveCircuit(String name) async {
    // TODO: Implement saving using CircuitStorageService
  }

  Future<void> loadCircuit(String name) async {
    // TODO: Implement loading using CircuitStorageService
  }
}
