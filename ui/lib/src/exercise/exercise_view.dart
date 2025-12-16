import 'dart:math';

import 'package:aic_ui/src/api/exercise_api.dart';
import 'package:aic_ui/src/exercise/exercise.dart';
import 'package:flutter/material.dart';
import '../home/custom_bottom_navigation_bar.dart';
import '../settings/settings_view.dart';
import '../components/custom_elevated_button.dart';
import './exercise_type.dart';

class ExerciseView extends StatefulWidget {
  final ExerciseType exerciseType;

  const ExerciseView({super.key, required this.exerciseType});

  @override
  State<ExerciseView> createState() => _ExerciseViewState();
}

class _ExerciseViewState extends State<ExerciseView> {
  late final TextEditingController answerController;
  late final FocusNode answerFocusNode;

  final exerciseApi = ExerciseApi();

  bool _isLoading = false;

  BaseExercise? _currentExercise;

  @override
  void initState() {
    super.initState();
    answerController = TextEditingController();
    answerFocusNode = FocusNode();
    _fetchExercise();

    // Request focus on the TextField after the widget has been built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(answerFocusNode);
    });
  }

  Future<void> _fetchExercise() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    BaseExercise? newExercise;
    do {
      newExercise = await exerciseApi
          .get_exercise()
          .then((exercise) => exercise?.getExercise(widget.exerciseType));
    } while (newExercise?.getQuestion() == _currentExercise?.getQuestion());

    setState(() {
      _isLoading = false;
      _currentExercise = newExercise;
    });
  }

  @override
  void dispose() {
    // Clean up the controller and focus node when the widget is disposed
    answerController.dispose();
    answerFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
            "Exercising ${widget.exerciseType.toString().split('.').last}"),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.restorablePushNamed(context, SettingsView.routeName);
            },
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 400,
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: _isLoading || _currentExercise == null
                ? const CircularProgressIndicator()
                : _buildExerciseView(_currentExercise!),
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }

  Column _buildExerciseView(BaseExercise exercise) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        _buildExerciseQuestionText(exercise),
        const SizedBox(height: 20),
        _buildExerciseInputField(),
        const SizedBox(height: 60),
        _buildExerciseSolutionSubmitButton(exercise),
      ],
    );
  }

  CustomElevatedButton _buildExerciseSolutionSubmitButton(
      BaseExercise baseExercise) {
    return CustomElevatedButton(
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Next',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            SizedBox(width: 10),
            Icon(Icons.arrow_forward),
          ],
        ),
        onPressed: () async {
          // todo: check if text field is not empty
          // todo: check if text is a number
          if (answerController.text.isEmpty) {
            // todo: show snackbar
            const SnackBar(
              content: Text("Please enter the answer."),
            );
            return;
          }

          if (widget.exerciseType != ExerciseType.derivative) {
            if (int.tryParse(answerController.text) == null) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("Please enter a number."),
              ));
              return;
            }
          } else {
            RegExp r = RegExp(r'^[0-9x*+^\s]*$');

            if (!r.hasMatch(answerController.text)) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("Please enter a valid answer."),
              ));
              return;
            }
          }

          baseExercise.setAnswer(answerController.text);

          // send the answer to the server
          await exerciseApi.post_solution(baseExercise);

          // fetch a new exercise
          await _fetchExercise();

          //exercises.submitAnswer(widget.exerciseType, answerController.text);
          answerController.clear();
          answerFocusNode.requestFocus();
        });
  }

  TextField _buildExerciseInputField() {
    return TextField(
      textAlign: TextAlign.center,
      controller: answerController,
      focusNode: answerFocusNode,
      style: const TextStyle(
        fontSize: 20,
      ),
      decoration: const InputDecoration(
        hintText: 'Enter your answer',
      ),
      onSubmitted: (String value) {
        if (value.isNotEmpty) {
          //exercises.submitAnswer(widget.exerciseType, value);
          answerController.clear();
          answerFocusNode.requestFocus();
        }
      },
    );
  }

  Text _buildExerciseQuestionText(BaseExercise exercise) {
    return Text(
      exercise.getQuestion(),
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 40,
      ),
    );
  }
}
