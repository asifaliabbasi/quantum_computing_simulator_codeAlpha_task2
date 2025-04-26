import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LearnPage extends StatelessWidget {
  const LearnPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learn Quantum Computing'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection(
                context,
                'Getting Started',
                [
                  _buildLearningCard(
                    context,
                    'Introduction to Quantum Computing',
                    'Learn the basics of quantum computing and qubits',
                    Icons.science,
                    'https://www.youtube.com/watch?v=JRIPV0dPAd4',
                  ),
                  _buildLearningCard(
                    context,
                    'Quantum Gates and Circuits',
                    'Understand how quantum gates work and how to build circuits',
                    Icons.electric_bolt,
                    'https://www.youtube.com/watch?v=F_Riqjdh2oM',
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSection(
                context,
                'Recommended YouTube Channels',
                [
                  _buildChannelCard(
                    context,
                    'Quantum Computing Now',
                    'Comprehensive tutorials and explanations',
                    'https://www.youtube.com/@QuantumComputingNow',
                    'https://www.youtube.com/@QuantumComputingNow',
                  ),
                  _buildChannelCard(
                    context,
                    'Quantum Computing for Everyone',
                    'Beginner-friendly quantum computing content',
                    'https://www.youtube.com/@QuantumComputingForEveryone',
                    'https://www.youtube.com/@QuantumComputingForEveryone',
                  ),
                  _buildChannelCard(
                    context,
                    'Quantum Computing Explained',
                    'In-depth technical explanations',
                    'https://www.youtube.com/@QuantumComputingExplained',
                    'https://www.youtube.com/@QuantumComputingExplained',
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSection(
                context,
                'Advanced Topics',
                [
                  _buildLearningCard(
                    context,
                    'Quantum Algorithms',
                    'Learn about quantum algorithms and their applications',
                    Icons.speed,
                    'https://www.youtube.com/watch?v=2hXG8v8p0KM',
                  ),
                  _buildLearningCard(
                    context,
                    'Quantum Error Correction',
                    'Understand how to handle errors in quantum systems',
                    Icons.bug_report,
                    'https://www.youtube.com/watch?v=6YuUtUwFuTM',
                  ),
                  _buildLearningCard(
                    context,
                    'Quantum Cryptography',
                    'Explore the security aspects of quantum computing',
                    Icons.security,
                    'https://www.youtube.com/watch?v=UVzRbU6y7Ks',
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSection(
                context,
                'Practice Exercises',
                [
                  _buildExerciseCard(
                    context,
                    'Basic Quantum Gates',
                    'Practice using different quantum gates',
                    Icons.play_circle,
                    () {
                      // TODO: Implement practice exercise
                    },
                  ),
                  _buildExerciseCard(
                    context,
                    'Circuit Building',
                    'Create and simulate quantum circuits',
                    Icons.build,
                    () {
                      // TODO: Implement practice exercise
                    },
                  ),
                  _buildExerciseCard(
                    context,
                    'Quantum Algorithms',
                    'Implement and test quantum algorithms',
                    Icons.code,
                    () {
                      // TODO: Implement practice exercise
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
      BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildLearningCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    String url,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _launchUrl(url),
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
              const Icon(Icons.play_circle_outline),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChannelCard(
    BuildContext context,
    String title,
    String description,
    String url,
    String channelUrl,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _launchUrl(channelUrl),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Icon(
                Icons.youtube_searched_for,
                size: 48,
                color: Colors.red,
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
              const Icon(Icons.open_in_new),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
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

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }
}
