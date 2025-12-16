import 'package:aic_ui/src/service/secure_storage.dart';
import 'package:aic_ui/src/user_profile/auth_info.dart';
import 'package:flutter/material.dart';

import '../auth/login_view.dart';
import 'profile_card.dart';

class UserProfileView extends StatelessWidget {
  UserProfileView({super.key});

  static const String routeName = '/user-profile';

  final secureStorage = SecureStorage();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              leading: BackButton(
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              actions: <Widget>[
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () async {
                    await secureStorage.deleteAll();
                    if (!context.mounted) return;
                    Navigator.restorablePushNamed(context, LoginView.routeName);
                  },
                ),
              ],
              title: const Text('User Profile'),
            ),
            body: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 500,
                ),
                child: const Center(
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      Text('Profile',
                          style: TextStyle(
                            fontSize: 30,
                          )),
                      SizedBox(height: 20),
                      ProfileCard(),
                      SizedBox(height: 20),
                      AuthInfoCard(),
                    ],
                  ),
                ),
              ),
            )));
  }
}
