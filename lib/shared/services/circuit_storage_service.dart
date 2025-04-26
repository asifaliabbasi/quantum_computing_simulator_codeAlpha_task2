import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import 'package:quantum_computing_simulator/shared/models/circuit_template.dart';
import 'package:quantum_computing_simulator/shared/models/quantum_gate.dart';
import 'package:quantum_computing_simulator/shared/models/complex.dart';

class CircuitStorageService {
  static Database? _database;
  static const String _tableName = 'circuits';
  static const int _databaseVersion = 2;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      String path = join(await getDatabasesPath(), 'quantum_circuits.db');
      return await openDatabase(
        path,
        version: _databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        onConfigure: _onConfigure,
      );
    } catch (e) {
      print('Error initializing database: $e');
      rethrow;
    }
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        gates TEXT NOT NULL,
        targetQubits TEXT NOT NULL,
        parameters TEXT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Drop and recreate the table for version 2
      await db.execute('DROP TABLE IF EXISTS $_tableName');
      await _onCreate(db, newVersion);
    }
  }

  Future<int> saveCircuit(CircuitTemplate circuit) async {
    try {
      final db = await database;
      final gatesJson = circuit.gates
          .map((gate) => {
                'name': gate.name,
                'symbol': gate.symbol,
                'matrix': gate.matrix
                    .map((row) => row
                        .map((complex) => {
                              'real': complex.real,
                              'imaginary': complex.imaginary,
                            })
                        .toList())
                    .toList(),
                'description': gate.description,
                'type': gate.type.toString().split('.').last,
              })
          .toList();

      return await db.insert(_tableName, {
        'name': circuit.name,
        'description': circuit.description,
        'gates': jsonEncode(gatesJson),
        'targetQubits': jsonEncode(circuit.targetQubits),
        'parameters': jsonEncode(circuit.parameters),
      });
    } catch (e) {
      print('Error saving circuit: $e');
      rethrow;
    }
  }

  Future<List<CircuitTemplate>> loadCircuits() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(_tableName);

      return List.generate(maps.length, (i) {
        final map = maps[i];
        try {
          final gatesJson = jsonDecode(map['gates'] as String) as List;
          final targetQubitsJson =
              jsonDecode(map['targetQubits'] as String) as List;
          final parametersJson =
              jsonDecode(map['parameters'] as String) as Map<String, dynamic>;

          final gates = gatesJson.map((gateJson) {
            final matrix = (gateJson['matrix'] as List)
                .map((row) => (row as List)
                    .map((complex) => Complex(
                          (complex['real'] as num).toDouble(),
                          (complex['imaginary'] as num).toDouble(),
                        ))
                    .toList())
                .toList();

            return QuantumGate(
              name: gateJson['name'] as String,
              symbol: gateJson['symbol'] as String,
              matrix: matrix,
              description: gateJson['description'] as String,
              type: QuantumGateType.values.firstWhere(
                (e) => e.toString() == 'QuantumGateType.${gateJson['type']}',
                orElse: () => QuantumGateType.hadamard,
              ),
            );
          }).toList();

          return CircuitTemplate(
            name: map['name'] as String,
            description: map['description'] as String,
            gates: gates,
            targetQubits: targetQubitsJson.map((e) => e as int).toList(),
            parameters: parametersJson,
          );
        } catch (e) {
          print('Error parsing circuit ${map['name']}: $e');
          print('Raw gates data: ${map['gates']}');
          print('Raw targetQubits data: ${map['targetQubits']}');
          print('Raw parameters data: ${map['parameters']}');
          rethrow;
        }
      });
    } catch (e) {
      print('Error loading circuits: $e');
      rethrow;
    }
  }

  Future<void> deleteCircuit(int id) async {
    try {
      final db = await database;
      await db.delete(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('Error deleting circuit: $e');
      rethrow;
    }
  }

  Future<void> updateCircuit(int id, CircuitTemplate circuit) async {
    try {
      final db = await database;
      final gatesJson = circuit.gates
          .map((gate) => {
                'name': gate.name,
                'symbol': gate.symbol,
                'matrix': gate.matrix
                    .map((row) => row
                        .map((complex) => {
                              'real': complex.real,
                              'imaginary': complex.imaginary,
                            })
                        .toList())
                    .toList(),
                'description': gate.description,
                'type': gate.type.toString().split('.').last,
              })
          .toList();

      await db.update(
        _tableName,
        {
          'name': circuit.name,
          'description': circuit.description,
          'gates': jsonEncode(gatesJson),
          'targetQubits': jsonEncode(circuit.targetQubits),
          'parameters': jsonEncode(circuit.parameters),
        },
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('Error updating circuit: $e');
      rethrow;
    }
  }

  Future<void> clearDatabase() async {
    try {
      final db = await database;
      await db.delete(_tableName);
    } catch (e) {
      print('Error clearing database: $e');
      rethrow;
    }
  }
}
