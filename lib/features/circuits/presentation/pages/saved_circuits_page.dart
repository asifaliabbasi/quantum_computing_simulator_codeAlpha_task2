import 'package:flutter/material.dart';
import 'package:quantum_computing_simulator/features/circuits/presentation/widgets/saved_circuits_list.dart';
import 'package:quantum_computing_simulator/features/circuits/presentation/pages/create_circuit_page.dart';

class SavedCircuitsPage extends StatelessWidget {
  const SavedCircuitsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Circuits'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const CreateCircuitPage()),
              );
            },
          ),
        ],
      ),
      body: const SavedCircuitsList(),
    );
  }
}
