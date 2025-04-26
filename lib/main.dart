import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:quantum_computing_simulator/core/theme/app_theme.dart';
import 'package:quantum_computing_simulator/features/home/presentation/pages/home_page.dart';
import 'package:quantum_computing_simulator/shared/services/circuit_storage_service.dart';
import 'package:quantum_computing_simulator/shared/providers/quantum_circuit_provider.dart';
import 'package:quantum_computing_simulator/shared/providers/settings_provider.dart';
import 'package:quantum_computing_simulator/shared/providers/achievement_provider.dart';
import 'package:quantum_computing_simulator/shared/providers/circuit_storage_provider.dart'
    as circuit_provider;

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    try {
      final prefs = await SharedPreferences.getInstance();
      final circuitStorageService = CircuitStorageService();

      // Initialize database
      await circuitStorageService.database;

      final settingsNotifier = SettingsNotifier(prefs);
      final achievementNotifier = AchievementNotifier(prefs);

      runApp(
        ProviderScope(
          overrides: [
            circuit_provider.circuitStorageServiceProvider
                .overrideWithValue(circuitStorageService),
            settingsProvider.overrideWith((ref) => settingsNotifier),
            achievementProvider.overrideWith((ref) => achievementNotifier),
          ],
          child: const QuantumComputingSimulator(),
        ),
      );
    } catch (e, stackTrace) {
      print('Error initializing app: $e');
      print('Stack trace: $stackTrace');

      // Show error UI
      runApp(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error initializing app',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        e.toString(),
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          // Restart app
                          main();
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
  }, (error, stackTrace) {
    print('Uncaught error: $error');
    print('Stack trace: $stackTrace');
  });
}

class QuantumComputingSimulator extends ConsumerWidget {
  const QuantumComputingSimulator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp(
      title: 'Quantum Computing Simulator',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settings.themeMode,
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
      builder: (context, child) {
        ErrorWidget.builder = (FlutterErrorDetails details) {
          return Material(
            child: Container(
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'An error occurred',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    details.exception.toString(),
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Restart app
                      main();
                    },
                    child: const Text('Restart App'),
                  ),
                ],
              ),
            ),
          );
        };
        return child!;
      },
    );
  }
}
