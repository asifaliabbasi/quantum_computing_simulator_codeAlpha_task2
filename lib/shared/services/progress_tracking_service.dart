import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quantum_computing_simulator/shared/models/tutorial.dart';
import 'package:quantum_computing_simulator/shared/services/database_helper.dart';

class ProgressTrackingService {
  final DatabaseHelper _db;
  final _progressController =
      StreamController<Map<String, TutorialProgress>>.broadcast();
  Map<String, TutorialProgress> _currentProgress = {};

  ProgressTrackingService(this._db) {
    _loadInitialProgress();
  }

  Stream<Map<String, TutorialProgress>> get progressStream =>
      _progressController.stream;

  Future<void> _loadInitialProgress() async {
    final tutorials = await _db.getTutorials();
    for (final tutorial in tutorials) {
      final progress = await _db.getTutorialProgress(tutorial.id);
      if (progress != null) {
        _currentProgress[tutorial.id] = progress;
      }
    }
    _progressController.add(_currentProgress);
  }

  Future<void> updateProgress(String tutorialId, int step) async {
    final progress = TutorialProgress(
      tutorialId: tutorialId,
      currentStep: step,
      lastAccessed: DateTime.now(),
    );
    await _db.updateTutorialProgress(progress);
    _currentProgress[tutorialId] = progress;
    _progressController.add(_currentProgress);
  }

  Future<void> completeTutorial(String tutorialId) async {
    final progress = _currentProgress[tutorialId]?.copyWith(
      isCompleted: true,
      lastAccessed: DateTime.now(),
    );
    if (progress != null) {
      await _db.updateTutorialProgress(progress);
      _currentProgress[tutorialId] = progress;
      _progressController.add(_currentProgress);
    }
  }

  Future<void> resetProgress(String tutorialId) async {
    final progress = TutorialProgress(
      tutorialId: tutorialId,
      currentStep: 0,
      lastAccessed: DateTime.now(),
    );
    await _db.updateTutorialProgress(progress);
    _currentProgress[tutorialId] = progress;
    _progressController.add(_currentProgress);
  }

  double getTutorialProgress(String tutorialId) {
    final progress = _currentProgress[tutorialId];
    if (progress == null) return 0.0;
    return progress.currentStep / 10; // Assuming 10 steps per tutorial
  }

  bool isTutorialCompleted(String tutorialId) {
    return _currentProgress[tutorialId]?.isCompleted ?? false;
  }

  Map<String, TutorialProgress> getCurrentProgress() => _currentProgress;

  void dispose() {
    _progressController.close();
  }
}

final progressTrackingServiceProvider =
    Provider<ProgressTrackingService>((ref) {
  return ProgressTrackingService(DatabaseHelper());
});
