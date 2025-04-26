import 'package:flutter/material.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final int points;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.points,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    IconData? icon,
    int? points,
    bool? isUnlocked,
    DateTime? unlockedAt,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      points: points ?? this.points,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'iconCodePoint': icon.codePoint,
        'iconFontFamily': icon.fontFamily,
        'iconFontPackage': icon.fontPackage,
        'points': points,
        'isUnlocked': isUnlocked,
        'unlockedAt': unlockedAt?.toIso8601String(),
      };

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      icon: IconData(
        json['iconCodePoint'] as int,
        fontFamily: json['iconFontFamily'] as String?,
        fontPackage: json['iconFontPackage'] as String?,
      ),
      points: json['points'] as int,
      isUnlocked: json['isUnlocked'] as bool,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'] as String)
          : null,
    );
  }
}

class Achievements {
  static final List<Achievement> allAchievements = [
    Achievement(
      id: 'first_circuit',
      title: 'First Circuit',
      description: 'Create your first quantum circuit',
      icon: Icons.electric_bolt,
      points: 10,
    ),
    Achievement(
      id: 'gate_master',
      title: 'Gate Master',
      description: 'Use all types of quantum gates',
      icon: Icons.science,
      points: 20,
    ),
    Achievement(
      id: 'circuit_saver',
      title: 'Circuit Saver',
      description: 'Save your first circuit',
      icon: Icons.save,
      points: 15,
    ),
    Achievement(
      id: 'circuit_loader',
      title: 'Circuit Loader',
      description: 'Load a saved circuit',
      icon: Icons.folder_open,
      points: 15,
    ),
    Achievement(
      id: 'complex_circuit',
      title: 'Complex Circuit',
      description: 'Create a circuit with 5 or more gates',
      icon: Icons.science_outlined,
      points: 25,
    ),
    Achievement(
      id: 'superposition_master',
      title: 'Superposition Master',
      description: 'Create a circuit with 5 qubits in superposition',
      icon: Icons.waves,
      points: 50,
    ),
    Achievement(
      id: 'entanglement_expert',
      title: 'Entanglement Expert',
      description: 'Create an entangled state between two qubits',
      icon: Icons.link,
      points: 30,
    ),
    Achievement(
      id: 'algorithm_implementer',
      title: 'Algorithm Implementer',
      description: 'Implement a quantum algorithm',
      icon: Icons.speed,
      points: 100,
    ),
    Achievement(
      id: 'circuit_collector',
      title: 'Circuit Collector',
      description: 'Save 10 different quantum circuits',
      icon: Icons.collections,
      points: 25,
    ),
  ];

  static Achievement? getAchievementById(String id) {
    try {
      return allAchievements.firstWhere((achievement) => achievement.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<Achievement> getUnlockedAchievements(
      List<Achievement> achievements) {
    return achievements.where((achievement) => achievement.isUnlocked).toList();
  }

  static List<Achievement> getLockedAchievements(
      List<Achievement> achievements) {
    return achievements
        .where((achievement) => !achievement.isUnlocked)
        .toList();
  }

  static int getTotalPoints(List<Achievement> achievements) {
    return achievements
        .where((achievement) => achievement.isUnlocked)
        .fold(0, (sum, achievement) => sum + achievement.points);
  }
}
