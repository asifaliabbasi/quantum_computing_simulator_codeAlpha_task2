import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quantum_computing_simulator/shared/models/circuit_save.dart';
import 'package:quantum_computing_simulator/shared/services/database_helper.dart';
import 'package:quantum_computing_simulator/shared/services/circuit_tracking_service.dart';

class CircuitSaveNotifier extends StateNotifier<List<CircuitSave>> {
  final DatabaseHelper _db;
  final CircuitTrackingService _circuitService;

  CircuitSaveNotifier(this._db, this._circuitService) : super([]) {
    _initializeCircuits();
  }

  Future<void> _initializeCircuits() async {
    _circuitService.circuitStream.listen((circuits) {
      state = circuits;
    });
  }

  Future<void> saveCircuit(CircuitSave circuit) async {
    await _circuitService.saveCircuit(circuit);
  }

  Future<void> updateCircuit(CircuitSave circuit) async {
    await _circuitService.updateCircuit(circuit);
  }

  Future<void> deleteCircuit(String name) async {
    await _circuitService.deleteCircuit(name);
  }

  CircuitSave? getCircuit(String name) {
    return _circuitService.getCircuit(name);
  }

  List<CircuitSave> getCircuitsByCategory(String category) {
    return _circuitService.getCircuitsByCategory(category);
  }

  List<String> getCategories() {
    return _circuitService.getCategories();
  }

  Future<void> saveCircuitStep(String circuitName, CircuitStep step) async {
    await _circuitService.saveCircuitStep(circuitName, step);
  }

  Future<void> deleteCircuitStep(String circuitName, int stepIndex) async {
    await _circuitService.deleteCircuitStep(circuitName, stepIndex);
  }

  Future<void> reorderCircuitSteps(
      String circuitName, int oldIndex, int newIndex) async {
    await _circuitService.reorderCircuitSteps(circuitName, oldIndex, newIndex);
  }
}

final circuitSaveProvider =
    StateNotifierProvider<CircuitSaveNotifier, List<CircuitSave>>((ref) {
  final db = DatabaseHelper();
  final circuitService = ref.watch(circuitTrackingServiceProvider);
  return CircuitSaveNotifier(db, circuitService);
});
