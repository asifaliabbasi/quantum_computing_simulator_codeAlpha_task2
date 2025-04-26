import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quantum_computing_simulator/shared/models/circuit_template.dart';
import 'package:quantum_computing_simulator/shared/models/quantum_gate.dart';
import 'package:quantum_computing_simulator/shared/providers/circuit_storage_provider.dart';

class CreateCircuitPage extends ConsumerStatefulWidget {
  const CreateCircuitPage({super.key});

  @override
  ConsumerState<CreateCircuitPage> createState() => _CreateCircuitPageState();
}

class _CreateCircuitPageState extends ConsumerState<CreateCircuitPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _nameFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  List<QuantumGate> _selectedGates = [];
  List<int> _targetQubits = [];

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onNameChanged);
    _descriptionController.addListener(_onDescriptionChanged);
  }

  @override
  void dispose() {
    _nameController.removeListener(_onNameChanged);
    _descriptionController.removeListener(_onDescriptionChanged);
    _nameController.dispose();
    _descriptionController.dispose();
    _nameFocusNode.dispose();
    _descriptionFocusNode.dispose();
    super.dispose();
  }

  void _onNameChanged() {
    if (_nameController.text.isNotEmpty) {
      _nameController.selection = TextSelection.fromPosition(
        TextPosition(offset: _nameController.text.length),
      );
    }
  }

  void _onDescriptionChanged() {
    if (_descriptionController.text.isNotEmpty) {
      _descriptionController.selection = TextSelection.fromPosition(
        TextPosition(offset: _descriptionController.text.length),
      );
    }
  }

  void _addGate(QuantumGate gate) {
    setState(() {
      _selectedGates.add(gate);
      _targetQubits.add(0); // Default target qubit
    });
  }

  void _removeGate(int index) {
    setState(() {
      _selectedGates.removeAt(index);
      _targetQubits.removeAt(index);
    });
  }

  void _updateTargetQubit(int index, int value) {
    setState(() {
      _targetQubits[index] = value;
    });
  }

  void _saveCircuit() {
    if (_formKey.currentState!.validate()) {
      final circuit = CircuitTemplate(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        gates: _selectedGates,
        targetQubits: _targetQubits,
      );

      ref.read(circuitStorageProvider.notifier).saveCircuit(circuit);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Circuit'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveCircuit,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              focusNode: _nameFocusNode,
              decoration: const InputDecoration(
                labelText: 'Circuit Name',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) {
                _nameFocusNode.unfocus();
                FocusScope.of(context).requestFocus(_descriptionFocusNode);
              },
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              focusNode: _descriptionFocusNode,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) {
                _descriptionFocusNode.unfocus();
              },
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Available Gates',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: QuantumGate.allGates.map((gate) {
                return ElevatedButton(
                  onPressed: () => _addGate(gate),
                  child: Text(gate.symbol),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text(
              'Selected Gates',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _selectedGates.length,
              itemBuilder: (context, index) {
                final gate = _selectedGates[index];
                return Card(
                  child: ListTile(
                    title: Text(gate.name),
                    subtitle: Text('Target Qubit: ${_targetQubits[index]}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownButton<int>(
                          value: _targetQubits[index],
                          items: List.generate(8, (i) => i).map((i) {
                            return DropdownMenuItem(
                              value: i,
                              child: Text('Qubit $i'),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              _updateTargetQubit(index, value);
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _removeGate(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
