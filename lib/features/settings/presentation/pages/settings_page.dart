import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quantum_computing_simulator/shared/providers/settings_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          _buildSection(
            context,
            'Appearance',
            [
              _buildThemeSelector(context, settings, settingsNotifier),
              _buildDivider(),
            ],
          ),
          _buildSection(
            context,
            'Quantum Playground',
            [
              _buildSwitchTile(
                context,
                'Show Gate Descriptions',
                'Display descriptions for quantum gates',
                settings.showGateDescriptions,
                (value) => settingsNotifier.setShowGateDescriptions(value),
              ),
              _buildDivider(),
              _buildSwitchTile(
                context,
                'Show State Vector',
                'Display the current quantum state',
                settings.showStateVector,
                (value) => settingsNotifier.setShowStateVector(value),
              ),
              _buildDivider(),
              _buildSwitchTile(
                context,
                'Show Probabilities',
                'Display measurement probabilities',
                settings.showProbabilities,
                (value) => settingsNotifier.setShowProbabilities(value),
              ),
            ],
          ),
          _buildSection(
            context,
            'Learning',
            [
              _buildSwitchTile(
                context,
                'Show Tutorial',
                'Display tutorial overlays and guides',
                settings.showTutorial,
                (value) => settingsNotifier.setShowTutorial(value),
              ),
            ],
          ),
          _buildSection(
            context,
            'About',
            [
              ListTile(
                title: const Text('Version'),
                subtitle: const Text('1.0.0'),
              ),
              _buildDivider(),
              ListTile(
                title: const Text('Reset Settings'),
                subtitle: const Text('Restore default settings'),
                trailing: const Icon(Icons.restore),
                onTap: () => settingsNotifier.resetToDefaults(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
      BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildThemeSelector(
    BuildContext context,
    Settings settings,
    SettingsNotifier notifier,
  ) {
    return Column(
      children: [
        ListTile(
          title: const Text('Theme'),
          subtitle: Text(_getThemeName(settings.themeMode)),
          trailing: const Icon(Icons.palette),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(
                value: ThemeMode.system,
                label: Text('System'),
                icon: Icon(Icons.brightness_auto),
              ),
              ButtonSegment(
                value: ThemeMode.light,
                label: Text('Light'),
                icon: Icon(Icons.light_mode),
              ),
              ButtonSegment(
                value: ThemeMode.dark,
                label: Text('Dark'),
                icon: Icon(Icons.dark_mode),
              ),
            ],
            selected: {settings.themeMode},
            onSelectionChanged: (Set<ThemeMode> modes) {
              notifier.setThemeMode(modes.first);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(
    BuildContext context,
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1);
  }

  String _getThemeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'System Default';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }
}
