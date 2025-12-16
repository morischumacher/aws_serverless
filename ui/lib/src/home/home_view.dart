import 'package:aic_ui/src/home/custom_bottom_navigation_bar.dart';
import 'package:aic_ui/src/settings/settings_view.dart';
import 'package:flutter/material.dart';

import 'package:aic_ui/src/components/custom_elevated_button.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  static const String routeName = '/home';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
            maxWidth: 300,
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'Choose a topic!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                  ),
                ),
                const SizedBox(height: 30),
                CustomElevatedButton(
                    child: const Text('Addition'),
                    onPressed: () {
                      Navigator.pushNamed(context, '/addition');
                    }),
                const SizedBox(height: 20),
                CustomElevatedButton(
                    child: const Text('Multiplication'),
                    onPressed: () {
                      Navigator.pushNamed(context, '/multiplication');
                    }),
                const SizedBox(height: 20),
                CustomElevatedButton(
                    child: const Text('Derivatives'),
                    onPressed: () {
                      Navigator.pushNamed(context, '/derivative');
                    }),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }
}
