import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quantum_computing_simulator/features/quantum_playground/presentation/widgets/gate_controls.dart';
import 'package:quantum_computing_simulator/shared/models/complex.dart';
import 'package:quantum_computing_simulator/shared/models/quantum_circuit.dart';
import 'package:quantum_computing_simulator/shared/models/quantum_gate.dart';
import 'package:quantum_computing_simulator/shared/models/circuit_template.dart';
import 'package:quantum_computing_simulator/shared/models/achievement.dart';
import 'package:quantum_computing_simulator/shared/providers/quantum_circuit_provider.dart';
import 'package:quantum_computing_simulator/shared/providers/circuit_storage_provider.dart';
import 'package:quantum_computing_simulator/shared/providers/achievement_provider.dart';

class ExperimentPage extends ConsumerStatefulWidget {
  const ExperimentPage({super.key});

  @override
  ConsumerState<ExperimentPage> createState() => _ExperimentPageState();
}

class _ExperimentPageState extends ConsumerState<ExperimentPage> {
  final TextEditingController _circuitNameController = TextEditingController();
  final TextEditingController _circuitDescriptionController =
      TextEditingController();
  bool _isSaving = false;
  Set<String> _usedGates = {};

  @override
  void initState() {
    super.initState();
    // Initialize circuit state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(quantumCircuitProvider.notifier).reset();
    });
  }

  @override
  void dispose() {
    _circuitNameController.dispose();
    _circuitDescriptionController.dispose();
    super.dispose();
  }

  void _showSaveDialog() {
    _circuitNameController.clear();
    _circuitDescriptionController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Circuit'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _circuitNameController,
              decoration: const InputDecoration(
                labelText: 'Circuit Name',
                hintText: 'Enter a name for your circuit',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _circuitDescriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Enter a description for your circuit',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_circuitNameController.text.isNotEmpty) {
                final circuit = ref.read(quantumCircuitProvider);
                final template = CircuitTemplate(
                  name: _circuitNameController.text,
                  description: _circuitDescriptionController.text,
                  gates: circuit.steps.map((step) => step.gate).toList(),
                  targetQubits:
                      circuit.steps.map((step) => step.targetQubit).toList(),
                );

                ref.read(circuitStorageProvider.notifier).saveCircuit(template);
                ref
                    .read(achievementProvider.notifier)
                    .checkSaveLoadAchievements(true);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Circuit saved successfully'),
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showLoadDialog() {
    final circuitsAsync = ref.watch(circuitStorageProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Load Circuit'),
        content: SizedBox(
          width: double.maxFinite,
          child: circuitsAsync.when(
            data: (circuits) {
              if (circuits.isEmpty) {
                return const Center(
                  child: Text('No saved circuits available'),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                itemCount: circuits.length,
                itemBuilder: (context, index) {
                  final circuit = circuits[index];
                  return ListTile(
                    title: Text(circuit.name),
                    subtitle: Text(circuit.description),
                    trailing: Text('${circuit.gates.length} gates'),
                    onTap: () {
                      _loadCircuit(circuit);
                      Navigator.pop(context);
                    },
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => Center(
              child: Text('Error: $error'),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _loadCircuit(CircuitTemplate template) {
    final circuit = ref.read(quantumCircuitProvider.notifier);
    circuit.reset();

    for (var i = 0; i < template.gates.length; i++) {
      circuit.addStep(template.gates[i], template.targetQubits[i]);
      _usedGates.add(template.gates[i].type.toString());
    }

    ref.read(achievementProvider.notifier).checkSaveLoadAchievements(false);
    ref.read(achievementProvider.notifier).checkCircuitAchievements(
          template.gates.length,
          _usedGates,
        );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Loaded circuit: ${template.name}'),
      ),
    );
  }

  void _onGateApplied(QuantumGate gate, int targetQubit) {
    ref.read(quantumCircuitProvider.notifier).addStep(gate, targetQubit);
    _usedGates.add(gate.type.toString());

    final circuit = ref.read(quantumCircuitProvider);
    ref.read(achievementProvider.notifier).checkCircuitAchievements(
          circuit.steps.length,
          _usedGates,
        );
  }

  @override
  Widget build(BuildContext context) {
    final circuit = ref.watch(quantumCircuitProvider);
    final achievements = ref.watch(achievementProvider);
    final totalPoints = ref.read(achievementProvider.notifier).totalPoints;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Experiment Mode'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _showSaveDialog,
          ),
          IconButton(
            icon: const Icon(Icons.folder_open),
            onPressed: _showLoadDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(quantumCircuitProvider.notifier).reset();
              _usedGates.clear();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildCircuitDisplay(circuit),
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        Container(
                          height: 200,
                          constraints: const BoxConstraints(maxHeight: 200),
                          child: _buildAchievementDisplay(
                              achievements, totalPoints),
                        ),
                        const Divider(height: 1),
                        Expanded(
                          child: GateControls(
                            onGateApplied: _onGateApplied,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Container(
              constraints: const BoxConstraints(maxHeight: 100),
              child: _buildStateDisplay(circuit),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Implement measurement
        },
        icon: const Icon(Icons.science),
        label: const Text('Measure'),
      ),
    );
  }

  Widget _buildAchievementDisplay(
      List<Achievement> achievements, int totalPoints) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.emoji_events, color: Colors.amber),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Achievements',
                  style: Theme.of(context).textTheme.titleLarge,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$totalPoints pts',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.amber,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: achievements.length,
              itemBuilder: (context, index) {
                final achievement = achievements[index];
                return ListTile(
                  dense: true,
                  leading: Icon(
                    achievement.icon,
                    color: achievement.isUnlocked ? Colors.amber : Colors.grey,
                  ),
                  title: Text(
                    achievement.title,
                    style: Theme.of(context).textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    achievement.description,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    '+${achievement.points}',
                    style: TextStyle(
                      color:
                          achievement.isUnlocked ? Colors.amber : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircuitDisplay(QuantumCircuit circuit) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Circuit Steps',
                  style: Theme.of(context).textTheme.titleLarge,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${circuit.steps.length} steps',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: circuit.steps.length,
            itemBuilder: (context, index) {
              final step = circuit.steps[index];
              return Card(
                child: ListTile(
                  leading: Icon(_getGateIcon(step.gate)),
                  title: Text(
                    '${_getGateName(step.gate)} on Qubit ${step.targetQubit + 1}',
                    style: Theme.of(context).textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: step.controlQubit != null
                      ? Text(
                          'Controlled by Qubit ${step.controlQubit! + 1}',
                          style: Theme.of(context).textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        )
                      : null,
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      ref
                          .read(quantumCircuitProvider.notifier)
                          .removeStep(index);
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStateDisplay(QuantumCircuit circuit) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current State',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            _formatStateVector(circuit.currentState),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontFamily: 'monospace',
                ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _formatStateVector(List<Complex> states) {
    if (states.isEmpty) return '|0⟩';

    final buffer = StringBuffer();
    buffer.write('|ψ⟩ = ');

    for (var i = 0; i < states.length; i++) {
      final state = states[i];
      if (i > 0) buffer.write(' ⊗ ');
      buffer.write('(${state.toString()})');
    }

    return buffer.toString();
  }

  IconData _getGateIcon(QuantumGate gate) {
    switch (gate.type) {
      case QuantumGateType.hadamard:
        return Icons.waves;
      case QuantumGateType.pauliX:
        return Icons.flip;
      case QuantumGateType.pauliY:
        return Icons.rotate_right;
      case QuantumGateType.pauliZ:
        return Icons.rotate_left;
      case QuantumGateType.cnot:
        return Icons.link;
      case QuantumGateType.tGate:
        return Icons.timer;
      case QuantumGateType.sGate:
        return Icons.speed;
    }
  }

  String _getGateName(QuantumGate gate) {
    switch (gate.type) {
      case QuantumGateType.hadamard:
        return 'Hadamard';
      case QuantumGateType.pauliX:
        return 'Pauli-X';
      case QuantumGateType.pauliY:
        return 'Pauli-Y';
      case QuantumGateType.pauliZ:
        return 'Pauli-Z';
      case QuantumGateType.cnot:
        return 'CNOT';
      case QuantumGateType.tGate:
        return 'T';
      case QuantumGateType.sGate:
        return 'S';
    }
  }
}
