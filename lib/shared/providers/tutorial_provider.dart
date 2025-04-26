import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quantum_computing_simulator/shared/models/tutorial.dart';
import 'package:quantum_computing_simulator/shared/services/database_helper.dart';
import 'package:quantum_computing_simulator/shared/services/progress_tracking_service.dart';

class TutorialNotifier extends StateNotifier<Map<String, TutorialProgress>> {
  final DatabaseHelper _db;
  final ProgressTrackingService _progressService;

  TutorialNotifier(this._db, this._progressService) : super({}) {
    _initializeProgress();
  }

  Future<void> _initializeProgress() async {
    _progressService.progressStream.listen((progress) {
      state = progress;
    });
  }

  Future<void> updateProgress(String tutorialId, int step) async {
    await _progressService.updateProgress(tutorialId, step);
  }

  Future<void> completeTutorial(String tutorialId) async {
    await _progressService.completeTutorial(tutorialId);
  }

  Future<void> resetProgress(String tutorialId) async {
    await _progressService.resetProgress(tutorialId);
  }

  double getTutorialProgress(String tutorialId) {
    return _progressService.getTutorialProgress(tutorialId);
  }

  bool isTutorialCompleted(String tutorialId) {
    return _progressService.isTutorialCompleted(tutorialId);
  }
}

final tutorialProvider =
    StateNotifierProvider<TutorialNotifier, Map<String, TutorialProgress>>(
        (ref) {
  final db = DatabaseHelper();
  final progressService = ref.watch(progressTrackingServiceProvider);
  return TutorialNotifier(db, progressService);
});

// Sample tutorials
final tutorialsProvider = Provider<List<Tutorial>>((ref) {
  return [
    Tutorial(
      id: 'getting_started',
      title: 'Getting Started with Quantum Computing',
      description:
          'Learn the basics of quantum computing with interactive examples',
      icon: Icons.play_circle,
      category: 'Basics',
      steps: [
        TutorialStep(
          title: 'Introduction to Qubits',
          description: 'Learn about quantum bits and their unique properties',
          isInteractive: true,
        ),
        TutorialStep(
          title: 'Superposition',
          description:
              'Understand how qubits can exist in multiple states simultaneously',
          isInteractive: true,
        ),
        // Add more steps...
      ],
    ),
    Tutorial(
      id: 'quantum_gates',
      title: 'Quantum Gates',
      description:
          'Master the fundamental quantum gates through hands-on practice',
      icon: Icons.grid_on,
      category: 'Gates',
      steps: [
        TutorialStep(
          title: 'Single-Qubit Gates',
          description: 'Learn about gates that operate on a single qubit',
          isInteractive: true,
        ),
        TutorialStep(
          title: 'Multi-Qubit Gates',
          description: 'Explore gates that operate on multiple qubits',
          isInteractive: true,
        ),
        // Add more steps...
      ],
    ),
    // Add more tutorials...
  ];
});
