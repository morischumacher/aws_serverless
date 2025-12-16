import 'package:aic_ui/src/exercise/exercise.dart';
import 'package:aic_ui/src/exercise/exercise_type.dart';
import 'package:flutter/material.dart';
import 'package:aic_ui/src/api/profile_api.dart';

import '../settings/settings_view.dart';

class ResultsDetailsView extends StatelessWidget {
  final ExerciseType exerciseType;

  const ResultsDetailsView({super.key, required this.exerciseType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Results for ${exerciseType.toString().split('.').last}'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.restorablePushNamed(context, SettingsView.routeName);
            },
          ),
        ],
      ),
      body: FutureBuilder<Exercises>(
        future: ProfileApi().get_profile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(
              child: Text('No data available'),
            );
          } else {
            final exercisesList = snapshot.data!;
            return _buildResultList(exercisesList);
          }
        },
      ),
    );
  }

  Padding _buildResultList(Exercises allExercises) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: ListView.builder(
        itemCount: allExercises.getExercises(exerciseType).length,
        itemBuilder: (context, index) {
          BaseExercise currentExercise =
              allExercises.getExercises(exerciseType)[index];
          IconData iconData;
          if (!currentExercise.isAnswered()) {
            iconData = Icons.help_outline;
          } else if (currentExercise.getAnswer() ==
              currentExercise.getSolution()) {
            iconData = Icons.check_circle_outline;
          } else {
            iconData = Icons.highlight_off;
          }
          return ListTile(
            leading: Icon(iconData,
                color: currentExercise.isAnswered()
                    ? (currentExercise.getAnswer() ==
                            currentExercise.getSolution()
                        ? Colors.green
                        : Colors.red)
                    : Colors.grey),
            title: Text(currentExercise.getQuestion()),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (currentExercise.isAnswered())
                  Text('Solution: ${currentExercise.getSolution()}')
                else
                  const Text('Solution: -'),
                if (currentExercise.isAnswered())
                  Text('Your answer: ${currentExercise.getAnswer()}'),
              ],
            ),
          );
        },
      ),
    );
  }
}
