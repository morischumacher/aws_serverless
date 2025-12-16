import 'exercise_type.dart';

import 'dart:math' as math;

class RandomExercise {
  final ExerciseType exerciseType;
  final random = math.Random();

  RandomExercise({required this.exerciseType});

  String getQuestion() {
    int term1 = random.nextInt(10);
    int term2 = random.nextInt(10);

    switch (exerciseType) {
      case ExerciseType.addition:
        return '$term1 + $term2 = ?';
      case ExerciseType.multiplication:
        return '$term1 * $term2 = ?';
      case ExerciseType.derivative:
        return generateRandomPolynomial();
      default:
        return '';
    }
  }

  String generateRandomPolynomial() {
    int degree = random.nextInt(3) + 1; // Random degree between 1 and 3
    String polynomial = '';

    for (int i = degree; i >= 0; i--) {
      int coefficient = random.nextInt(10);
      polynomial += '$coefficient*x^$i';
      if (i > 0) {
        polynomial += ' + ';
      }
    }

    return 'd/dx ${polynomial.trim()} = ?';
  }
}
