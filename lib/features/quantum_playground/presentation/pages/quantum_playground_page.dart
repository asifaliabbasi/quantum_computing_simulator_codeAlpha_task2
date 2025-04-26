import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quantum_computing_simulator/features/quantum_playground/presentation/widgets/qubit_visualization.dart';
import 'package:quantum_computing_simulator/features/quantum_playground/presentation/widgets/gate_controls.dart';
import 'package:quantum_computing_simulator/features/quantum_playground/presentation/widgets/state_vector_display.dart';
import 'package:quantum_computing_simulator/features/quantum_playground/presentation/widgets/load_circuit_dialog.dart';
import 'package:quantum_computing_simulator/shared/models/complex.dart';
import 'package:quantum_computing_simulator/shared/models/quantum_gate.dart';
import 'package:quantum_computing_simulator/shared/models/circuit_save.dart';
import 'package:quantum_computing_simulator/shared/providers/settings_provider.dart';
import 'package:quantum_computing_simulator/shared/providers/circuit_save_provider.dart';

class QuantumPlaygroundPage extends ConsumerStatefulWidget {
  const QuantumPlaygroundPage({super.key});

  @override
  ConsumerState<QuantumPlaygroundPage> createState() =>
      _QuantumPlaygroundPageState();
}

class _QuantumPlaygroundPageState extends ConsumerState<QuantumPlaygroundPage> {
  int _numberOfQubits = 1;
  List<Complex> _qubitStates = [Complex(1, 0)]; // Initial state |0⟩
  List<Map<String, dynamic>> _circuitHistory = [];
  bool _isMeasuring = false;
  Map<int, int> _measurementResults = {};
  String _currentCircuitName = 'Untitled Circuit';

  void _updateQubitState(int index, Complex newState) {
    setState(() {
      _qubitStates[index] = newState;
    });
  }

  void _addQubit() {
    if (_numberOfQubits < 5) {
      setState(() {
        _numberOfQubits++;
        _qubitStates.add(Complex(1, 0));
      });
    }
  }

  void _removeQubit() {
    if (_numberOfQubits > 1) {
      setState(() {
        _numberOfQubits--;
        _qubitStates.removeLast();
      });
    }
  }

  void _applyGate(QuantumGate gate, int targetQubit) {
    setState(() {
      _circuitHistory.add({
        'gate': gate,
        'targetQubit': targetQubit,
        'timestamp': DateTime.now(),
      });
      // TODO: Implement actual gate application logic
    });
  }

  void _measureQubits() {
    setState(() {
      _isMeasuring = true;
      // Simulate measurement
      for (int i = 0; i < _qubitStates.length; i++) {
        final probability = _qubitStates[i].real * _qubitStates[i].real;
        _measurementResults[i] = probability > 0.5 ? 1 : 0;
      }
    });
  }

  void _resetCircuit() {
    setState(() {
      _qubitStates = List.generate(_numberOfQubits, (_) => Complex(1, 0));
      _circuitHistory.clear();
      _measurementResults.clear();
      _isMeasuring = false;
      _currentCircuitName = 'Untitled Circuit';
    });
  }

  void _showLoadDialog() {
    showDialog(
      context: context,
      builder: (context) => LoadCircuitDialog(
        onCircuitSelected: (circuit) {
          setState(() {
            _currentCircuitName = circuit.name;
            _circuitHistory = circuit.steps.map((step) {
              return {
                'gate': step.gate,
                'targetQubit': step.targetQubit,
                'timestamp': DateTime.now(),
              };
            }).toList();
            // TODO: Apply loaded circuit steps
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentCircuitName),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addQubit,
            tooltip: 'Add Qubit',
          ),
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: _removeQubit,
            tooltip: 'Remove Qubit',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetCircuit,
            tooltip: 'Reset Circuit',
          ),
          IconButton(
            icon: const Icon(Icons.folder_open),
            onPressed: _showLoadDialog,
            tooltip: 'Load Circuit',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: QubitVisualization(
                      qubitStates: _qubitStates,
                      onStateChanged: _updateQubitState,
                      measurementResults: _measurementResults,
                      isMeasuring: _isMeasuring,
                    ),
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(
                    flex: 2,
                    child: GateControls(
                      onGateApplied: _applyGate,
                    ),
                  ),
                ],
              ),
            ),
            if (settings.showStateVector) ...[
              const Divider(height: 1),
              Container(
                constraints: const BoxConstraints(maxHeight: 100),
                child: StateVectorDisplay(
                  qubitStates: _qubitStates,
                ),
              ),
            ],
            if (settings.showProbabilities) ...[
              const Divider(height: 1),
              Container(
                constraints: const BoxConstraints(maxHeight: 100),
                child: _buildProbabilityDisplay(),
              ),
            ],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _measureQubits,
        icon: const Icon(Icons.science),
        label: const Text('Measure'),
      ),
    );
  }

  Widget _buildProbabilityDisplay() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: _qubitStates.length,
      itemBuilder: (context, index) {
        final state = _qubitStates[index];
        final probability = state.real * state.real;
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text(
                'Qubit ${index + 1}',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Text(
                '|0⟩: ${(probability * 100).toStringAsFixed(1)}%\n|1⟩: ${((1 - probability) * 100).toStringAsFixed(1)}%',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
}
