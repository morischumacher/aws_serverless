import 'package:aic_ui/src/service/jwt_token.dart';
import 'package:aic_ui/src/service/secure_storage.dart';
import 'package:flutter/material.dart';

class AuthInfoCard extends StatefulWidget {
  const AuthInfoCard({super.key});

  @override
  State<AuthInfoCard> createState() => _AuthInfoCardState();
}

class _AuthInfoCardState extends State<AuthInfoCard> {
  final _secureStorage = SecureStorage();

  Future<JwtToken> _getToken() async {
    return await _secureStorage.getAccessToken() as JwtToken;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.1),
          borderRadius: const BorderRadius.all(Radius.circular(20)),
        ),
        child: Padding(
            padding: const EdgeInsets.all(20),
            child: FutureBuilder<JwtToken>(
              future: _getToken(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Expiry Date:'),
                          Text(snapshot.data!.getExpiryDate()!.toString()),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('User ID:'),
                          Text(snapshot.data!.getUserId()),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Email:'),
                          Text(snapshot.data!.getEmail()),
                        ],
                      ),
                    ],
                  );
                } else if (snapshot.hasError) {
                  return Text('${snapshot.error}');
                }
                return const CircularProgressIndicator();
              },
            )),
      ),
    );
  }
}

Widget _getAuthInfo(BuildContext context, AsyncSnapshot<JwtToken> snapshot) {
  return Container();
}
