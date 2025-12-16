import 'dart:convert';
import 'package:aic_ui/src/exercise/exercise_type.dart';

class Exercises {
  final ExerciseResults<Addition> addition;
  final ExerciseResults<Multiplication> multiplication;
  final ExerciseResults<Derivative> derivative;

  Exercises(
      {required this.addition,
      required this.multiplication,
      required this.derivative});

  factory Exercises.fromJson(Map<String, dynamic> json) {
    return Exercises(
        addition: ExerciseResults.fromJson(json['addition']),
        multiplication: ExerciseResults.fromJson(json['multiplication']),
        derivative: ExerciseResults.fromJson(json['derivative']));
  }

  List<BaseExercise> getExercises(ExerciseType exerciseType) {
    if (exerciseType == ExerciseType.addition) {
      return addition.getAdditionExercises();
    } else if (exerciseType == ExerciseType.multiplication) {
      return multiplication.getMultiplicationExercises();
    } else {
      return derivative.getDerivativeExercises();
    }
  }
}

class ExerciseResults<T> {
  final double ratio;
  final int grade;
  final List<Addition> additionExercises;
  final List<Multiplication> multiplicationExercises;
  final List<Derivative> derivativeExercises;

  ExerciseResults(
      {required this.ratio,
      required this.grade,
      required this.additionExercises,
      required this.multiplicationExercises,
      required this.derivativeExercises});

  factory ExerciseResults.fromJson(Map<String, dynamic> json) {
    final ratio = double.parse(json["ratio"].toString());
    final grade = int.parse(json["grade"].toString());

    if (T == Addition) {
      List<Addition> additionExercises = (json['exercises'] as List)
          .map((exerciseJson) => Addition.fromJson(exerciseJson))
          .toList();
      return ExerciseResults(
          ratio: ratio,
          grade: grade,
          additionExercises: additionExercises,
          multiplicationExercises: List.empty(),
          derivativeExercises: List.empty());
    } else if (T == Multiplication) {
      List<Multiplication> multiplicationExercises = (json['exercises'] as List)
          .map((exerciseJson) => Multiplication.fromJson(exerciseJson))
          .toList();
      return ExerciseResults(
          ratio: ratio,
          grade: grade,
          additionExercises: List.empty(),
          multiplicationExercises: multiplicationExercises,
          derivativeExercises: List.empty());
    } else {
      List<Derivative> derivativeExercises = (json['exercises'] as List)
          .map((exerciseJson) => Derivative.fromJson(exerciseJson))
          .toList();
      return ExerciseResults(
          ratio: ratio,
          grade: grade,
          additionExercises: List.empty(),
          multiplicationExercises: List.empty(),
          derivativeExercises: derivativeExercises);
    }
  }

  List<Addition> getAdditionExercises() {
    return additionExercises;
  }

  List<Multiplication> getMultiplicationExercises() {
    return multiplicationExercises;
  }

  List<Derivative> getDerivativeExercises() {
    return derivativeExercises;
  }
}

class Exercise {
  final Addition addition;
  final Multiplication multiplication;
  final Derivative derivative;

  Exercise(
      {required this.addition,
      required this.multiplication,
      required this.derivative});

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      addition: Addition.fromJson(json['addition']),
      multiplication: Multiplication.fromJson(json['multiplication']),
      derivative: Derivative.fromJson(json['derivative']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'addition': addition.toJson(),
      'multiplication': multiplication.toJson(),
      'derivative': derivative.toJson(),
    };
  }

  BaseExercise getExercise(ExerciseType exerciseType) {
    switch (exerciseType) {
      case ExerciseType.addition:
        return addition;
      case ExerciseType.multiplication:
        return multiplication;
      case ExerciseType.derivative:
        return derivative;
    }
  }
}

abstract class BaseExercise {
  Map<String, dynamic> toJson();
  String getQuestion();
  bool isAnswered();
  void setAnswer(String answer);
  String getAnswer();
  String getSolution();
}

class Addition extends BaseExercise {
  final List<int> exercise;
  final Map<String, dynamic> params;
  bool isSolved;

  Addition(
      {required this.exercise, required this.params, this.isSolved = false});

  factory Addition.fromJson(Map<String, dynamic> json) {
    return Addition(
      exercise: List<int>.from(jsonDecode(json['exercise'])),
      params: jsonDecode(json['params'].replaceAll("'", "\"")),
      isSolved: json['is_solved'] == 1 ? true : false,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'exercise': exercise.toString(),
      'type': 'addition',
      'params': jsonEncode(params).replaceAll("\"", "'"),
      'is_solved': isSolved ? 1 : 0,
    };
  }

  @override
  String getQuestion() {
    return '${exercise.join(' + ')} = ?';
  }

  @override
  void setAnswer(String answer) {
    try {
      params['solution'] = int.parse(answer);
    } catch (e) {
      params['solution'] = -1;
    }
  }

  @override
  bool isAnswered() {
    return params['solution'] != null && params['solution'] != '';
  }

  @override
  String getAnswer() {
    return params['solution'].toString();
  }

  @override
  String getSolution() {
    return params['correct_solution'].toString();
  }
}

class Multiplication extends BaseExercise {
  final List<int> exercise;
  final Map<String, dynamic> params;
  bool isSolved;

  Multiplication(
      {required this.exercise, required this.params, this.isSolved = false});

  factory Multiplication.fromJson(Map<String, dynamic> json) {
    return Multiplication(
      exercise: List<int>.from(jsonDecode(json['exercise'])),
      params: jsonDecode(json['params'].replaceAll("'", "\"")),
      isSolved: json['is_solved'] == 1 ? true : false,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'exercise': exercise.toString(),
      'params': jsonEncode(params).replaceAll("\"", "'"),
      'type': 'multiplication',
      'is_solved': isSolved ? 1 : 0,
    };
  }

  @override
  String getQuestion() {
    return '${exercise.join(' * ')} = ?';
  }

  @override
  void setAnswer(String answer) {
    try {
      params['solution'] = int.parse(answer);
    } catch (e) {
      params['solution'] = -1;
    }
  }

  @override
  bool isAnswered() {
    return params['solution'] != null && params['solution'] != '';
  }

  @override
  String getAnswer() {
    return params['solution'].toString();
  }

  @override
  String getSolution() {
    return params['correct_solution'].toString();
  }
}

class Derivative extends BaseExercise {
  final Map<String, List<int>> exercise;
  final Map<String, dynamic> params;
  bool isSolved;
  final String exerciseString;

  Derivative(
      {required this.exercise,
      required this.params,
      required this.exerciseString,
      this.isSolved = false});

  factory Derivative.fromJson(Map<String, dynamic> json) {
    return Derivative(
      exercise: getExerciseFromJsonString(json['exercise']),
      params: jsonDecode(json['params'].replaceAll("'", "\"")),
      isSolved: json['is_solved'] == 1 ? true : false,
      exerciseString: json['exercise'],
    );
  }

  static Map<String, List<int>> getExerciseFromJsonString(String jsonString) {
    jsonString = jsonString.replaceAll("'", "\"");
    Map<String, dynamic> map = jsonDecode(jsonString);
    return map.map((key, value) => MapEntry(key, List<int>.from(value)));
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'exercise': exerciseString,
      'params': jsonEncode(params).replaceAll("\"", "'"),
      'type': 'derivative',
      'is_solved': isSolved ? 1 : 0,
    };
  }

  @override
  String getQuestion() {
    List<int> coefficients = exercise['values']!;
    List<int> exponents = exercise['degrees']!;

    String question = 'd/dx ';

    for (int i = 0; i < coefficients.length; i++) {
      if (i != 0 && i != coefficients.length) {
        question += ' + ';
      }

      question += '${coefficients[i]}x^${exponents[i]}';
    }

    return '$question = ?';
  }

  @override
  void setAnswer(String answer) {
    List<int> values = [];
    List<int> degrees = [];

    Map<String, List<int>> solution = {
      'values': [],
      'degrees': [],
    };

    try {
      answer = answer.replaceAll(' ', '');
      var terms = answer.split('+');

      for (var term in terms) {
        var parts = term.split('^');
        int? coefficient =
            int.tryParse(parts[0].replaceAll('x', '').replaceAll('*', ''));

        var exponent = 0;

        if (parts.length > 1) {
          exponent = int.parse(parts[1]);
        }

        values.add(coefficient ?? 1);
        degrees.add(exponent);
      }

      solution['values'] = values;
      solution['degrees'] = degrees;
    } finally {
      params['solution'] = solution;
    }
  }

  @override
  bool isAnswered() {
    return params['solution'] != null && params['solution'] != '';
  }

  @override
  String getAnswer() {
    return params['solution'].toString();
  }

  @override
  String getSolution() {
    return params['correct_solution'].toString();
  }
}
