import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quantum_computing_simulator/features/quantum_playground/presentation/pages/quantum_playground_page.dart';
import 'package:quantum_computing_simulator/features/learn/presentation/pages/learn_page.dart';
import 'package:quantum_computing_simulator/features/experiment/presentation/pages/experiment_page.dart';
import 'package:quantum_computing_simulator/features/settings/presentation/pages/settings_page.dart';
import 'package:quantum_computing_simulator/features/achievements/presentation/pages/achievements_page.dart';
import 'package:quantum_computing_simulator/shared/providers/achievement_provider.dart';
import 'package:quantum_computing_simulator/features/circuits/presentation/pages/saved_circuits_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalPoints = ref.watch(achievementProvider.notifier).totalPoints;
    final achievements = ref.watch(achievementProvider);
    final unlockedAchievements = achievements.where((a) => a.isUnlocked).length;
    final totalAchievements = achievements.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quantum Computing Simulator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.emoji_events),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AchievementsPage(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsPage(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SavedCircuitsPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome to Quantum Computing',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Explore the fascinating world of quantum computing through interactive simulations and learning modules.',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                  _buildAchievementBadge(context, totalPoints,
                      unlockedAchievements, totalAchievements),
                ],
              ),
              const SizedBox(height: 32),
              _buildFeatureCard(
                context,
                'Quantum Playground',
                'Visualize and manipulate qubits with quantum gates',
                Icons.science,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const QuantumPlaygroundPage(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildFeatureCard(
                context,
                'Learn Quantum Computing',
                'Understand the fundamentals of quantum computing',
                Icons.school,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LearnPage(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildFeatureCard(
                context,
                'Experiment Mode',
                'Create and simulate your own quantum circuits',
                Icons.science_outlined,
                () {
                  try {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ExperimentPage(),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error opening Experiment Mode: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAchievementBadge(
    BuildContext context,
    int totalPoints,
    int unlockedAchievements,
    int totalAchievements,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star, color: Colors.amber),
              const SizedBox(width: 4),
              Text(
                totalPoints.toString(),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '$unlockedAchievements/$totalAchievements',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Achievements',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(
                icon,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios),
            ],
          ),
        ),
      ),
    );
  }
}
