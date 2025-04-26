import 'package:flutter/material.dart';

class Lesson {
  final String id;
  final String title;
  final String description;
  final String content;
  final List<String> images;
  final List<Quiz> quizzes;
  final bool isPremium;
  final IconData icon;

  const Lesson({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.images,
    required this.quizzes,
    this.isPremium = false,
    required this.icon,
  });
}

class Quiz {
  final String id;
  final String question;
  final List<String> options;
  final int correctOption;
  final String explanation;

  const Quiz({
    required this.id,
    required this.question,
    required this.options,
    required this.correctOption,
    required this.explanation,
  });
}

class EducationalContent {
  static final List<Lesson> lessons = [
    Lesson(
      id: 'qubits',
      title: 'Qubits and Superposition',
      description:
          'Learn about the fundamental building blocks of quantum computing.',
      content: '''
Qubits are the quantum equivalent of classical bits. While classical bits can only be 0 or 1, qubits can exist in a superposition of states, allowing for parallel computation.

Key concepts:
- Superposition: A qubit can be in multiple states simultaneously
- Measurement: When measured, a qubit collapses to either 0 or 1
- Probability amplitudes: Complex numbers that determine the probability of measurement outcomes
''',
      images: ['assets/images/qubit_superposition.png'],
      quizzes: [
        Quiz(
          id: 'qubit_quiz_1',
          question:
              'What is the main difference between a classical bit and a qubit?',
          options: [
            'Qubits can be in multiple states simultaneously',
            'Qubits are faster than classical bits',
            'Qubits use more energy',
            'Qubits are larger in size',
          ],
          correctOption: 0,
          explanation:
              'Qubits can exist in a superposition of states, while classical bits can only be 0 or 1.',
        ),
      ],
      icon: Icons.bubble_chart,
    ),
    Lesson(
      id: 'gates',
      title: 'Quantum Gates',
      description: 'Explore the building blocks of quantum circuits.',
      content: '''
Quantum gates are the basic operations that can be performed on qubits. They are represented by unitary matrices and can be combined to create complex quantum circuits.

Common gates:
- Hadamard (H): Creates superposition
- Pauli gates (X, Y, Z): Basic rotations
- CNOT: Two-qubit controlled operation
- T and S gates: Phase operations
''',
      images: ['assets/images/quantum_gates.png'],
      quizzes: [
        Quiz(
          id: 'gate_quiz_1',
          question: 'What does the Hadamard gate do?',
          options: [
            'Creates superposition',
            'Performs a bit flip',
            'Adds two qubits',
            'Measures a qubit',
          ],
          correctOption: 0,
          explanation:
              'The Hadamard gate creates an equal superposition of |0⟩ and |1⟩ states.',
        ),
      ],
      icon: Icons.grid_on,
    ),
    Lesson(
      id: 'entanglement',
      title: 'Quantum Entanglement',
      description:
          'Understand the phenomenon that Einstein called "spooky action at a distance".',
      content: '''
Quantum entanglement is a phenomenon where two or more particles become correlated in such a way that the quantum state of each particle cannot be described independently.

Key points:
- Entangled particles share a single quantum state
- Measurement of one particle affects the other
- Used in quantum teleportation and cryptography
''',
      images: ['assets/images/entanglement.png'],
      quizzes: [
        Quiz(
          id: 'entanglement_quiz_1',
          question:
              'What happens when you measure one of two entangled qubits?',
          options: [
            'The other qubit instantly takes a correlated value',
            'Nothing happens to the other qubit',
            'Both qubits become random',
            'The entanglement is destroyed',
          ],
          correctOption: 0,
          explanation:
              'Measuring one entangled qubit causes the other to instantly take a correlated value, regardless of distance.',
        ),
      ],
      icon: Icons.link,
    ),
    Lesson(
      id: 'algorithms',
      title: 'Quantum Algorithms',
      description:
          'Learn about powerful quantum algorithms that solve problems faster than classical computers.',
      content: '''
Quantum algorithms leverage quantum properties to solve certain problems exponentially faster than classical algorithms.

Important algorithms:
- Shor's algorithm: Factoring large numbers
- Grover's algorithm: Searching unsorted databases
- Deutsch-Jozsa algorithm: Determining if a function is constant or balanced
''',
      images: ['assets/images/quantum_algorithms.png'],
      quizzes: [
        Quiz(
          id: 'algorithm_quiz_1',
          question: 'What is the main advantage of Grover\'s algorithm?',
          options: [
            'Quadratic speedup in searching unsorted databases',
            'Exponential speedup in factoring',
            'Linear speedup in sorting',
            'Constant time complexity',
          ],
          correctOption: 0,
          explanation:
              'Grover\'s algorithm provides a quadratic speedup in searching unsorted databases compared to classical algorithms.',
        ),
      ],
      isPremium: true,
      icon: Icons.speed,
    ),
  ];
}
