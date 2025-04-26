import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quantum_computing_simulator/shared/models/circuit_save.dart';
import 'package:quantum_computing_simulator/shared/services/database_helper.dart';

class CircuitTrackingService {
  final DatabaseHelper _db;
  final _circuitController = StreamController<List<CircuitSave>>.broadcast();
  List<CircuitSave> _currentCircuits = [];

  CircuitTrackingService(this._db) {
    _loadInitialCircuits();
  }

  Stream<List<CircuitSave>> get circuitStream => _circuitController.stream;

  Future<void> _loadInitialCircuits() async {
    _currentCircuits = await _db.getCircuits();
    _circuitController.add(_currentCircuits);
  }

  Future<void> saveCircuit(CircuitSave circuit) async {
    await _db.insertCircuit(circuit);
    _currentCircuits = await _db.getCircuits();
    _circuitController.add(_currentCircuits);
  }

  Future<void> updateCircuit(CircuitSave circuit) async {
    await _db.updateCircuit(circuit);
    _currentCircuits = await _db.getCircuits();
    _circuitController.add(_currentCircuits);
  }

  Future<void> deleteCircuit(String name) async {
    await _db.deleteCircuit(name);
    _currentCircuits = await _db.getCircuits();
    _circuitController.add(_currentCircuits);
  }

  CircuitSave? getCircuit(String name) {
    try {
      return _currentCircuits.firstWhere((c) => c.name == name);
    } catch (e) {
      return null;
    }
  }

  List<CircuitSave> getCircuitsByCategory(String category) {
    return _currentCircuits
        .where((c) => c.metadata?['category'] == category)
        .toList();
  }

  List<String> getCategories() {
    final categories = _currentCircuits
        .map((c) => c.metadata?['category'] as String? ?? 'General')
        .toSet()
        .toList();
    categories.sort();
    return categories;
  }

  Future<void> saveCircuitStep(String circuitName, CircuitStep step) async {
    final circuit = getCircuit(circuitName);
    if (circuit != null) {
      final updatedCircuit = circuit.copyWith(
        steps: [...circuit.steps, step],
        lastModified: DateTime.now(),
      );
      await updateCircuit(updatedCircuit);
    }
  }

  Future<void> deleteCircuitStep(String circuitName, int stepIndex) async {
    final circuit = getCircuit(circuitName);
    if (circuit != null) {
      final updatedSteps = List<CircuitStep>.from(circuit.steps);
      updatedSteps.removeAt(stepIndex);
      final updatedCircuit = circuit.copyWith(
        steps: updatedSteps,
        lastModified: DateTime.now(),
      );
      await updateCircuit(updatedCircuit);
    }
  }

  Future<void> reorderCircuitSteps(
      String circuitName, int oldIndex, int newIndex) async {
    final circuit = getCircuit(circuitName);
    if (circuit != null) {
      final updatedSteps = List<CircuitStep>.from(circuit.steps);
      final step = updatedSteps.removeAt(oldIndex);
      updatedSteps.insert(newIndex, step);
      final updatedCircuit = circuit.copyWith(
        steps: updatedSteps,
        lastModified: DateTime.now(),
      );
      await updateCircuit(updatedCircuit);
    }
  }

  List<CircuitSave> getCurrentCircuits() => _currentCircuits;

  void dispose() {
    _circuitController.close();
  }
}

final circuitTrackingServiceProvider = Provider<CircuitTrackingService>((ref) {
  return CircuitTrackingService(DatabaseHelper());
});
