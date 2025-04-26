import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:quantum_computing_simulator/shared/models/circuit_save.dart';
import 'package:quantum_computing_simulator/shared/models/tutorial.dart';
import 'package:quantum_computing_simulator/shared/models/quantum_gate.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'quantum_simulator.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    // Circuits table
    await db.execute('''
      CREATE TABLE circuits(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        created_at TEXT NOT NULL,
        last_modified TEXT NOT NULL,
        category TEXT,
        metadata TEXT
      )
    ''');

    // Circuit steps table
    await db.execute('''
      CREATE TABLE circuit_steps(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        circuit_id INTEGER NOT NULL,
        gate_type INTEGER NOT NULL,
        target_qubit INTEGER NOT NULL,
        control_qubit INTEGER,
        parameters TEXT,
        FOREIGN KEY (circuit_id) REFERENCES circuits (id) ON DELETE CASCADE
      )
    ''');

    // Tutorials table
    await db.execute('''
      CREATE TABLE tutorials(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        category TEXT NOT NULL,
        difficulty INTEGER NOT NULL,
        icon_data INTEGER NOT NULL
      )
    ''');

    // Tutorial steps table
    await db.execute('''
      CREATE TABLE tutorial_steps(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tutorial_id TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        image_path TEXT,
        code_examples TEXT,
        is_interactive INTEGER NOT NULL,
        next_step_id TEXT,
        previous_step_id TEXT,
        FOREIGN KEY (tutorial_id) REFERENCES tutorials (id) ON DELETE CASCADE
      )
    ''');

    // Tutorial progress table
    await db.execute('''
      CREATE TABLE tutorial_progress(
        tutorial_id TEXT PRIMARY KEY,
        current_step INTEGER NOT NULL,
        is_completed INTEGER NOT NULL,
        last_accessed TEXT NOT NULL,
        user_data TEXT,
        FOREIGN KEY (tutorial_id) REFERENCES tutorials (id) ON DELETE CASCADE
      )
    ''');
  }

  // Circuit operations
  Future<int> insertCircuit(CircuitSave circuit) async {
    final db = await database;
    final circuitId = await db.insert('circuits', {
      'name': circuit.name,
      'description': circuit.description,
      'created_at': circuit.createdAt.toIso8601String(),
      'last_modified': circuit.lastModified.toIso8601String(),
      'category': circuit.metadata?['category'],
      'metadata':
          circuit.metadata != null ? jsonEncode(circuit.metadata) : null,
    });

    for (final step in circuit.steps) {
      await db.insert('circuit_steps', {
        'circuit_id': circuitId,
        'gate_type': step.gate.type.index,
        'target_qubit': step.targetQubit,
        'control_qubit': step.controlQubit,
        'parameters':
            step.parameters != null ? jsonEncode(step.parameters) : null,
      });
    }

    return circuitId;
  }

  Future<List<CircuitSave>> getCircuits() async {
    final db = await database;
    final List<Map<String, dynamic>> circuitMaps = await db.query('circuits');
    final List<CircuitSave> circuits = [];

    for (final circuitMap in circuitMaps) {
      final List<Map<String, dynamic>> stepMaps = await db.query(
        'circuit_steps',
        where: 'circuit_id = ?',
        whereArgs: [circuitMap['id']],
      );

      final steps = stepMaps.map((stepMap) {
        return CircuitStep(
          gate: QuantumGate.getGateByType(
            QuantumGateType.values[stepMap['gate_type'] as int],
          )!,
          targetQubit: stepMap['target_qubit'] as int,
          controlQubit: stepMap['control_qubit'] as int?,
          parameters: stepMap['parameters'] != null
              ? jsonDecode(stepMap['parameters'] as String)
              : null,
        );
      }).toList();

      circuits.add(CircuitSave(
        name: circuitMap['name'] as String,
        description: circuitMap['description'] as String,
        steps: steps,
        createdAt: DateTime.parse(circuitMap['created_at'] as String),
        lastModified: DateTime.parse(circuitMap['last_modified'] as String),
        metadata: circuitMap['metadata'] != null
            ? jsonDecode(circuitMap['metadata'] as String)
            : null,
      ));
    }

    return circuits;
  }

  Future<void> updateCircuit(CircuitSave circuit) async {
    final db = await database;
    await db.update(
      'circuits',
      {
        'name': circuit.name,
        'description': circuit.description,
        'last_modified': circuit.lastModified.toIso8601String(),
        'category': circuit.metadata?['category'],
        'metadata':
            circuit.metadata != null ? jsonEncode(circuit.metadata) : null,
      },
      where: 'name = ?',
      whereArgs: [circuit.name],
    );

    // Delete existing steps
    await db.delete(
      'circuit_steps',
      where: 'circuit_id = ?',
      whereArgs: [circuit.name],
    );

    // Insert new steps
    for (final step in circuit.steps) {
      await db.insert('circuit_steps', {
        'circuit_id': circuit.name,
        'gate_type': step.gate.type.index,
        'target_qubit': step.targetQubit,
        'control_qubit': step.controlQubit,
        'parameters':
            step.parameters != null ? jsonEncode(step.parameters) : null,
      });
    }
  }

  Future<void> deleteCircuit(String name) async {
    final db = await database;
    await db.delete(
      'circuits',
      where: 'name = ?',
      whereArgs: [name],
    );
  }

  // Tutorial operations
  Future<void> insertTutorial(Tutorial tutorial) async {
    final db = await database;
    await db.insert('tutorials', {
      'id': tutorial.id,
      'title': tutorial.title,
      'description': tutorial.description,
      'category': tutorial.category,
      'difficulty': tutorial.difficulty,
      'icon_data': tutorial.icon.codePoint,
    });

    for (final step in tutorial.steps) {
      await db.insert('tutorial_steps', {
        'tutorial_id': tutorial.id,
        'title': step.title,
        'description': step.description,
        'image_path': step.imagePath,
        'code_examples':
            step.codeExamples != null ? jsonEncode(step.codeExamples) : null,
        'is_interactive': step.isInteractive ? 1 : 0,
        'next_step_id': step.nextStepId,
        'previous_step_id': step.previousStepId,
      });
    }
  }

  Future<List<Tutorial>> getTutorials() async {
    final db = await database;
    final List<Map<String, dynamic>> tutorialMaps = await db.query('tutorials');
    final List<Tutorial> tutorials = [];

    for (final tutorialMap in tutorialMaps) {
      final List<Map<String, dynamic>> stepMaps = await db.query(
        'tutorial_steps',
        where: 'tutorial_id = ?',
        whereArgs: [tutorialMap['id']],
      );

      final steps = stepMaps.map((stepMap) {
        return TutorialStep(
          title: stepMap['title'] as String,
          description: stepMap['description'] as String,
          imagePath: stepMap['image_path'] as String?,
          codeExamples: stepMap['code_examples'] != null
              ? List<String>.from(
                  jsonDecode(stepMap['code_examples'] as String))
              : null,
          isInteractive: stepMap['is_interactive'] == 1,
          nextStepId: stepMap['next_step_id'] as String?,
          previousStepId: stepMap['previous_step_id'] as String?,
        );
      }).toList();

      tutorials.add(Tutorial(
        id: tutorialMap['id'] as String,
        title: tutorialMap['title'] as String,
        description: tutorialMap['description'] as String,
        icon: IconData(
          tutorialMap['icon_data'] as int,
          fontFamily: 'MaterialIcons',
        ),
        steps: steps,
        category: tutorialMap['category'] as String,
        difficulty: tutorialMap['difficulty'] as int,
      ));
    }

    return tutorials;
  }

  Future<void> updateTutorialProgress(TutorialProgress progress) async {
    final db = await database;
    await db.insert(
      'tutorial_progress',
      {
        'tutorial_id': progress.tutorialId,
        'current_step': progress.currentStep,
        'is_completed': progress.isCompleted ? 1 : 0,
        'last_accessed': progress.lastAccessed.toIso8601String(),
        'user_data':
            progress.userData != null ? jsonEncode(progress.userData) : null,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<TutorialProgress?> getTutorialProgress(String tutorialId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tutorial_progress',
      where: 'tutorial_id = ?',
      whereArgs: [tutorialId],
    );

    if (maps.isEmpty) return null;

    final map = maps.first;
    return TutorialProgress(
      tutorialId: map['tutorial_id'] as String,
      currentStep: map['current_step'] as int,
      isCompleted: map['is_completed'] == 1,
      lastAccessed: DateTime.parse(map['last_accessed'] as String),
      userData: map['user_data'] != null
          ? jsonDecode(map['user_data'] as String)
          : null,
    );
  }
}
