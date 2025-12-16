import 'package:aic_ui/src/api/profile_api.dart';
import 'package:aic_ui/src/components/custom_elevated_button.dart';
import 'package:aic_ui/src/exercise/exercise.dart';
import 'package:aic_ui/src/exercise/exercise_type.dart';
import 'package:aic_ui/src/helpers/capitalize.dart';
import 'package:aic_ui/src/home/custom_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';

class ResultsView extends StatelessWidget {
  const ResultsView({super.key});

  static const routeName = '/results';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Results'),
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
            final profileData = snapshot.data!;
            print(profileData);
            return SingleChildScrollView(
              child: Center(
                child: Column(
                  children: [
                    ResultOverviewCard(
                      exerciseType: ExerciseType.addition,
                      exerciseResults: profileData.addition,
                    ),
                    const SizedBox(height: 20),
                    ResultOverviewCard(
                      exerciseType: ExerciseType.multiplication,
                      exerciseResults: profileData.multiplication,
                    ),
                    const SizedBox(height: 20),
                    ResultOverviewCard(
                      exerciseType: ExerciseType.derivative,
                      exerciseResults: profileData.derivative,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          }
        },
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }
}

class ResultOverviewCard extends StatelessWidget {
  const ResultOverviewCard({
    super.key,
    required this.exerciseType,
    required this.exerciseResults,
  });

  final ExerciseType exerciseType;
  final ExerciseResults exerciseResults;

  @override
  Widget build(BuildContext context) {
    //final Exercises exercises = Provider.of<Exercises>(context);

    return ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 400,
        ),
        child: Container(
            padding: const EdgeInsets.all(20.0),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.1),
              borderRadius: const BorderRadius.all(Radius.circular(20)),
            ),
            child: Center(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(capitalize(exerciseType.name.split('.').last),
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 20),
                Table(
                  children: [
                    const TableRow(children: [
                      Text('Total'),
                      Text('Success'),
                      Text('Grade'),
                    ]),
                    if (exerciseType == ExerciseType.addition)
                      TableRow(
                        children: [
                          Text('${exerciseResults.additionExercises.length}'),
                          Text('${(exerciseResults.ratio * 100).round()}%'),
                          Text('${exerciseResults.grade}'),
                        ],
                      ),
                    if (exerciseType == ExerciseType.multiplication)
                      TableRow(
                        children: [
                          Text(
                              '${exerciseResults.multiplicationExercises.length}'),
                          Text('${(exerciseResults.ratio * 100).round()}%'),
                          Text('${exerciseResults.grade}'),
                        ],
                      ),
                    if (exerciseType == ExerciseType.derivative)
                      TableRow(
                        children: [
                          Text('${exerciseResults.derivativeExercises.length}'),
                          Text('${(exerciseResults.ratio * 100).round()}%'),
                          Text('${exerciseResults.grade}'),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                CustomElevatedButton(
                    child: const SizedBox(
                        width: double.infinity,
                        child: Center(child: Text('Details'))),
                    onPressed: () {
                      Navigator.pushNamed(context,
                          '/results/details/${exerciseType.toString().split('.').last}',
                          arguments: exerciseType);
                    }),
              ],
            ))));
  }
}
