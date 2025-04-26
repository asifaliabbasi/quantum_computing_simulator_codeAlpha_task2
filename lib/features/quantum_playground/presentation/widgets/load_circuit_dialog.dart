import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quantum_computing_simulator/shared/models/circuit_save.dart';
import 'package:quantum_computing_simulator/shared/providers/circuit_save_provider.dart';

class LoadCircuitDialog extends ConsumerWidget {
  final Function(CircuitSave) onCircuitSelected;

  const LoadCircuitDialog({
    super.key,
    required this.onCircuitSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final circuits = ref.watch(circuitSaveProvider);
    final categories = ref.read(circuitSaveProvider.notifier).getCategories();

    return AlertDialog(
      title: const Text('Load Circuit'),
      content: SizedBox(
        width: double.maxFinite,
        child: DefaultTabController(
          length: categories.length,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TabBar(
                isScrollable: true,
                tabs:
                    categories.map((category) => Tab(text: category)).toList(),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: TabBarView(
                  children: categories.map((category) {
                    final categoryCircuits = ref
                        .read(circuitSaveProvider.notifier)
                        .getCircuitsByCategory(category);
                    return _buildCircuitList(context, categoryCircuits);
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  Widget _buildCircuitList(BuildContext context, List<CircuitSave> circuits) {
    if (circuits.isEmpty) {
      return const Center(
        child: Text('No circuits found in this category'),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: circuits.length,
      itemBuilder: (context, index) {
        final circuit = circuits[index];
        return ListTile(
          title: Text(circuit.name),
          subtitle: Text(
            circuit.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Text(
            '${circuit.steps.length} steps',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          onTap: () {
            onCircuitSelected(circuit);
            Navigator.pop(context);
          },
        );
      },
    );
  }
}
