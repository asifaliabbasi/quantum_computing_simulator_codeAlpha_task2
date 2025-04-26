import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quantum_computing_simulator/shared/models/tutorial.dart';
import 'package:quantum_computing_simulator/shared/providers/tutorial_provider.dart';

class TutorialPage extends ConsumerStatefulWidget {
  final String tutorialId;

  const TutorialPage({
    super.key,
    required this.tutorialId,
  });

  @override
  ConsumerState<TutorialPage> createState() => _TutorialPageState();
}

class _TutorialPageState extends ConsumerState<TutorialPage> {
  late Tutorial _tutorial;
  late int _currentStep;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTutorial();
  }

  void _loadTutorial() {
    final tutorials = ref.read(tutorialsProvider);
    _tutorial = tutorials.firstWhere((t) => t.id == widget.tutorialId);
    final progress = ref.read(tutorialProvider)[widget.tutorialId];
    _currentStep = progress?.currentStep ?? 0;
    setState(() {
      _isLoading = false;
    });
  }

  void _nextStep() {
    if (_currentStep < _tutorial.steps.length - 1) {
      setState(() {
        _currentStep++;
      });
      ref.read(tutorialProvider.notifier).updateProgress(
            widget.tutorialId,
            _currentStep,
          );
    } else {
      ref.read(tutorialProvider.notifier).completeTutorial(widget.tutorialId);
      Navigator.pop(context);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      ref.read(tutorialProvider.notifier).updateProgress(
            widget.tutorialId,
            _currentStep,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final step = _tutorial.steps[_currentStep];
    final progress = ref.watch(tutorialProvider)[widget.tutorialId];
    final isCompleted = progress?.isCompleted ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text(_tutorial.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark),
            onPressed: () {
              // TODO: Implement bookmarking
            },
          ),
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentStep + 1) / _tutorial.steps.length,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    step.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  if (step.imagePath != null) ...[
                    const SizedBox(height: 16),
                    Image.asset(
                      step.imagePath!,
                      fit: BoxFit.contain,
                    ),
                  ],
                  if (step.codeExamples != null) ...[
                    const SizedBox(height: 16),
                    ...step.codeExamples!.map((code) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color:
                                  Theme.of(context).colorScheme.surfaceVariant,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              code,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontFamily: 'monospace',
                                  ),
                            ),
                          ),
                        )),
                  ],
                  if (step.isInteractive) ...[
                    const SizedBox(height: 16),
                    _buildInteractiveSection(step),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_currentStep > 0)
                TextButton.icon(
                  onPressed: _previousStep,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Previous'),
                )
              else
                const SizedBox.shrink(),
              if (_currentStep < _tutorial.steps.length - 1)
                ElevatedButton.icon(
                  onPressed: _nextStep,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Next'),
                )
              else
                ElevatedButton.icon(
                  onPressed: () {
                    ref
                        .read(tutorialProvider.notifier)
                        .completeTutorial(widget.tutorialId);
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Complete'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInteractiveSection(TutorialStep step) {
    // TODO: Implement interactive elements based on step type
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Interactive Exercise',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Complete this exercise to proceed to the next step.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _nextStep,
            child: const Text('Complete Exercise'),
          ),
        ],
      ),
    );
  }
}
