import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quantum_computing_simulator/shared/models/circuit_template.dart';
import 'package:quantum_computing_simulator/shared/services/circuit_storage_service.dart';

final circuitStorageServiceProvider = Provider<CircuitStorageService>((ref) {
  return CircuitStorageService();
});

final savedCircuitsProvider =
    FutureProvider<List<CircuitTemplate>>((ref) async {
  final storageService = ref.watch(circuitStorageServiceProvider);
  return await storageService.loadCircuits();
});

final circuitStorageProvider = StateNotifierProvider<CircuitStorageNotifier,
    AsyncValue<List<CircuitTemplate>>>((ref) {
  return CircuitStorageNotifier(ref.watch(circuitStorageServiceProvider));
});

class CircuitStorageNotifier
    extends StateNotifier<AsyncValue<List<CircuitTemplate>>> {
  final CircuitStorageService _storageService;

  CircuitStorageNotifier(this._storageService)
      : super(const AsyncValue.loading()) {
    loadCircuits();
  }

  Future<void> loadCircuits() async {
    try {
      final circuits = await _storageService.loadCircuits();
      state = AsyncValue.data(circuits);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> saveCircuit(CircuitTemplate circuit) async {
    try {
      await _storageService.saveCircuit(circuit);
      await loadCircuits();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteCircuit(int id) async {
    try {
      await _storageService.deleteCircuit(id);
      await loadCircuits();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateCircuit(int id, CircuitTemplate circuit) async {
    try {
      await _storageService.updateCircuit(id, circuit);
      await loadCircuits();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}
