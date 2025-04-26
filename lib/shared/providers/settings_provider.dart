import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings {
  final ThemeMode themeMode;
  final bool showTutorial;
  final bool showGateDescriptions;
  final bool showStateVector;
  final bool showProbabilities;

  const Settings({
    this.themeMode = ThemeMode.system,
    this.showTutorial = true,
    this.showGateDescriptions = true,
    this.showStateVector = true,
    this.showProbabilities = true,
  });

  Settings copyWith({
    ThemeMode? themeMode,
    bool? showTutorial,
    bool? showGateDescriptions,
    bool? showStateVector,
    bool? showProbabilities,
  }) {
    return Settings(
      themeMode: themeMode ?? this.themeMode,
      showTutorial: showTutorial ?? this.showTutorial,
      showGateDescriptions: showGateDescriptions ?? this.showGateDescriptions,
      showStateVector: showStateVector ?? this.showStateVector,
      showProbabilities: showProbabilities ?? this.showProbabilities,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'themeMode': themeMode.index,
      'showTutorial': showTutorial,
      'showGateDescriptions': showGateDescriptions,
      'showStateVector': showStateVector,
      'showProbabilities': showProbabilities,
    };
  }

  factory Settings.fromJson(Map<String, dynamic> json) {
    return Settings(
      themeMode: ThemeMode.values[json['themeMode'] as int],
      showTutorial: json['showTutorial'] as bool,
      showGateDescriptions: json['showGateDescriptions'] as bool,
      showStateVector: json['showStateVector'] as bool,
      showProbabilities: json['showProbabilities'] as bool,
    );
  }
}

class SettingsNotifier extends StateNotifier<Settings> {
  final SharedPreferences _prefs;
  static const String _settingsKey = 'settings';

  SettingsNotifier(this._prefs) : super(_loadSettings(_prefs));

  static Settings _loadSettings(SharedPreferences prefs) {
    final settingsJson = prefs.getString(_settingsKey);
    if (settingsJson == null) {
      return const Settings();
    }
    try {
      final Map<String, dynamic> settingsMap = jsonDecode(settingsJson);
      return Settings.fromJson(settingsMap);
    } catch (e) {
      return const Settings();
    }
  }

  Future<void> _saveSettings() async {
    final settingsJson = jsonEncode(state.toJson());
    await _prefs.setString(_settingsKey, settingsJson);
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    state = state.copyWith(themeMode: themeMode);
    await _saveSettings();
  }

  Future<void> setShowTutorial(bool show) async {
    state = state.copyWith(showTutorial: show);
    await _saveSettings();
  }

  Future<void> setShowGateDescriptions(bool show) async {
    state = state.copyWith(showGateDescriptions: show);
    await _saveSettings();
  }

  Future<void> setShowStateVector(bool show) async {
    state = state.copyWith(showStateVector: show);
    await _saveSettings();
  }

  Future<void> setShowProbabilities(bool show) async {
    state = state.copyWith(showProbabilities: show);
    await _saveSettings();
  }

  Future<void> resetToDefaults() async {
    state = const Settings();
    await _saveSettings();
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, Settings>((ref) {
  throw UnimplementedError(
      'SettingsNotifier must be initialized with SharedPreferences');
});
