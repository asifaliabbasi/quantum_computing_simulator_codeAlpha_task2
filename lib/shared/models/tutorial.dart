import 'package:flutter/material.dart';

class TutorialStep {
  final String title;
  final String description;
  final String? imagePath;
  final List<String>? codeExamples;
  final bool isInteractive;
  final String? nextStepId;
  final String? previousStepId;

  const TutorialStep({
    required this.title,
    required this.description,
    this.imagePath,
    this.codeExamples,
    this.isInteractive = false,
    this.nextStepId,
    this.previousStepId,
  });
}

class Tutorial {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final List<TutorialStep> steps;
  final String category;
  final int difficulty; // 1-5

  const Tutorial({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.steps,
    required this.category,
    this.difficulty = 1,
  });
}

class TutorialProgress {
  final String tutorialId;
  final int currentStep;
  final bool isCompleted;
  final DateTime lastAccessed;
  final Map<String, dynamic>? userData;

  const TutorialProgress({
    required this.tutorialId,
    required this.currentStep,
    this.isCompleted = false,
    required this.lastAccessed,
    this.userData,
  });

  TutorialProgress copyWith({
    String? tutorialId,
    int? currentStep,
    bool? isCompleted,
    DateTime? lastAccessed,
    Map<String, dynamic>? userData,
  }) {
    return TutorialProgress(
      tutorialId: tutorialId ?? this.tutorialId,
      currentStep: currentStep ?? this.currentStep,
      isCompleted: isCompleted ?? this.isCompleted,
      lastAccessed: lastAccessed ?? this.lastAccessed,
      userData: userData ?? this.userData,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tutorialId': tutorialId,
      'currentStep': currentStep,
      'isCompleted': isCompleted,
      'lastAccessed': lastAccessed.toIso8601String(),
      'userData': userData,
    };
  }

  factory TutorialProgress.fromJson(Map<String, dynamic> json) {
    return TutorialProgress(
      tutorialId: json['tutorialId'] as String,
      currentStep: json['currentStep'] as int,
      isCompleted: json['isCompleted'] as bool,
      lastAccessed: DateTime.parse(json['lastAccessed'] as String),
      userData: json['userData'] as Map<String, dynamic>?,
    );
  }
}
