import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quantum_computing_simulator/shared/models/achievement.dart';

class AchievementNotifier extends StateNotifier<List<Achievement>> {
  final SharedPreferences _prefs;
  static const String _achievementsKey = 'achievements';

  AchievementNotifier(this._prefs) : super([]) {
    _loadAchievements();
  }

  void _loadAchievements() {
    final achievementsJson = _prefs.getStringList(_achievementsKey);
    if (achievementsJson != null) {
      state = achievementsJson
          .map((json) => Achievement.fromJson(jsonDecode(json)))
          .toList();
    } else {
      // Initialize with default achievements
      state = Achievements.allAchievements;
      _saveAchievements();
    }
  }

  void _saveAchievements() {
    final achievementsJson =
        state.map((achievement) => jsonEncode(achievement.toJson())).toList();
    _prefs.setStringList(_achievementsKey, achievementsJson);
  }

  int get totalPoints => Achievements.getTotalPoints(state);

  void unlockAchievement(String id) {
    final index = state.indexWhere((achievement) => achievement.id == id);
    if (index != -1 && !state[index].isUnlocked) {
      state = [
        ...state.sublist(0, index),
        state[index].copyWith(
          isUnlocked: true,
          unlockedAt: DateTime.now(),
        ),
        ...state.sublist(index + 1),
      ];
      _saveAchievements();
    }
  }

  void checkCircuitAchievements(int gateCount, Set<String> usedGates) {
    // Check first circuit achievement
    if (gateCount > 0) {
      unlockAchievement('first_circuit');
    }

    // Check gate master achievement
    if (usedGates.length >= 5) {
      unlockAchievement('gate_master');
    }

    // Check complex circuit achievement
    if (gateCount >= 5) {
      unlockAchievement('complex_circuit');
    }

    // Check superposition master achievement
    if (gateCount >= 5 && usedGates.contains('QuantumGateType.hadamard')) {
      unlockAchievement('superposition_master');
    }

    // Check entanglement expert achievement
    if (usedGates.contains('QuantumGateType.cnot')) {
      unlockAchievement('entanglement_expert');
    }
  }

  void checkSaveLoadAchievements(bool isSave) {
    if (isSave) {
      unlockAchievement('circuit_saver');
    } else {
      unlockAchievement('circuit_loader');
    }
  }

  void checkCircuitCollectionAchievement(int savedCircuitsCount) {
    if (savedCircuitsCount >= 10) {
      unlockAchievement('circuit_collector');
    }
  }

  List<Achievement> getUnlockedAchievements() {
    return Achievements.getUnlockedAchievements(state);
  }

  List<Achievement> getLockedAchievements() {
    return Achievements.getLockedAchievements(state);
  }
}

final achievementProvider =
    StateNotifierProvider<AchievementNotifier, List<Achievement>>((ref) {
  throw UnimplementedError();
});
