import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quantum_computing_simulator/shared/models/circuit_save.dart';
import 'package:quantum_computing_simulator/shared/providers/circuit_save_provider.dart';

class SaveCircuitDialog extends ConsumerStatefulWidget {
  final List<CircuitStep> steps;

  const SaveCircuitDialog({
    super.key,
    required this.steps,
  });

  @override
  ConsumerState<SaveCircuitDialog> createState() => _SaveCircuitDialogState();
}

class _SaveCircuitDialogState extends ConsumerState<SaveCircuitDialog> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'General';

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveCircuit() {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a name for the circuit'),
        ),
      );
      return;
    }

    final circuit = CircuitSave(
      name: _nameController.text,
      description: _descriptionController.text,
      steps: widget.steps,
      createdAt: DateTime.now(),
      lastModified: DateTime.now(),
      metadata: {
        'category': _selectedCategory,
      },
    );

    ref.read(circuitSaveProvider.notifier).saveCircuit(circuit);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Save Circuit'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Circuit Name',
                hintText: 'Enter a name for your circuit',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Enter a description for your circuit',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
              ),
              items: const [
                DropdownMenuItem(
                  value: 'General',
                  child: Text('General'),
                ),
                DropdownMenuItem(
                  value: 'Algorithms',
                  child: Text('Algorithms'),
                ),
                DropdownMenuItem(
                  value: 'Tutorials',
                  child: Text('Tutorials'),
                ),
                DropdownMenuItem(
                  value: 'Experiments',
                  child: Text('Experiments'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedCategory = value;
                  });
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveCircuit,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
