import 'package:aic_ui/src/api/auth_api.dart';
import 'package:flutter/services.dart';
import '../components/custom_elevated_button.dart';
import '../components/custom_text_button.dart';
import 'package:flutter/material.dart';
import '../components/logo.dart';
import '../home/home_view.dart';
import '../settings/settings_view.dart';
import 'register_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  static const routeName = '/login';

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  // text editing controllers
  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  final _focusNode = FocusNode();

  final _authApi = AuthApi();

  var _isLoading = false;
  var _loginSuccessful = false;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 500,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Logo(),
                      const SizedBox(height: 60.0),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Please login to continue',
                              style: TextStyle(
                                fontSize: 20,
                                color: Theme.of(context).hintColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      TextField(
                        controller: emailController,
                        decoration: const InputDecoration(hintText: 'Email'),
                      ),
                      const SizedBox(height: 20.0),
                      RawKeyboardListener(
                        focusNode: _focusNode,
                        onKey: (event) {
                          if (event.isKeyPressed(LogicalKeyboardKey.enter)) {
                            _loginAction(context);
                          }
                        },
                        child: TextField(
                          controller: passwordController,
                          obscureText: true,
                          decoration:
                              const InputDecoration(hintText: 'Password'),
                        ),
                      ),
                      const SizedBox(height: 80.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomElevatedButton(
                            child: _isLoading
                                ? const CircularProgressIndicator()
                                : const Text('Login'),
                            onPressed: () => _loginAction(context),
                          ),
                          const SizedBox(width: 20.0),
                          CustomTextButton(
                            child: const Text('Sign Up'),
                            onPressed: () {
                              Navigator.pushNamed(
                                  context, RegisterView.routeName);
                            },
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 10.0,
            right: 10.0,
            child: IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.restorablePushNamed(context, SettingsView.routeName);
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loginAction(BuildContext context) async {
    // check if any of the fields are empty
    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields.")),
      );
      return;
    }

    // perform the login
    await _login();

    if (!context.mounted) return;
    // react to login result
    if (_loginSuccessful) {
      Navigator.pushNamed(context, HomeView.routeName);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Wrong credentials.")),
      );
    }
  }

  Future<void> _login() async {
    setState(() => _isLoading = true);

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    bool result = false;

    try {
      result = await _authApi.login(email, password);
    } on Exception catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() {
        _isLoading = false;
        _loginSuccessful = result;
      });
    }
  }
}
