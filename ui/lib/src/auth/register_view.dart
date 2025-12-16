import 'package:aic_ui/src/api/auth_api.dart';

import '../auth/login_view.dart';
import '../components/custom_elevated_button.dart';
import 'package:flutter/material.dart';
import '../components/logo.dart';
import '../components/custom_text_button.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  static const routeName = '/register';

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  // Create controllers for text fields
  final emailController = TextEditingController();
  final passwordController1 = TextEditingController();
  final passwordController2 = TextEditingController();
  final userNameController = TextEditingController();

  final _authApi = AuthApi();

  bool _isLoading = false;
  bool _signupSuccessful = false;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    emailController.dispose();
    passwordController1.dispose();
    passwordController2.dispose();
    userNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
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
                          'Sign Up',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Please fill in the form below to register',
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
                  const SizedBox(height: 20),
                  TextField(
                    controller: userNameController,
                    decoration: const InputDecoration(hintText: 'Username'),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: passwordController1,
                    obscureText: true,
                    decoration: const InputDecoration(hintText: 'Password'),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: passwordController2,
                    obscureText: true,
                    decoration: const InputDecoration(hintText: 'Password'),
                  ),
                  const SizedBox(height: 20),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomElevatedButton(
                        child: const Text('Cancel'),
                        onPressed: () {
                          Navigator.restorablePushNamed(
                            context,
                            LoginView.routeName,
                          );
                        },
                      ),
                      const SizedBox(width: 20.0),
                      CustomTextButton(
                        child: _isLoading
                            ? const CircularProgressIndicator()
                            : const Text('Register'),
                        onPressed: () => _signupAction(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _signupAction(BuildContext context) async {
    // check if passwords match
    if (passwordController1.text != passwordController2.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
        ),
      );
      return;
    }

    // check if any field is empty
    if (emailController.text.isEmpty ||
        passwordController1.text.isEmpty ||
        passwordController2.text.isEmpty ||
        userNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
        ),
      );
      return;
    }

    // perform the signup
    await _signup();

    if (!context.mounted) return;

    // react to signup result
    if (_signupSuccessful) {
      Navigator.pushNamed(context, LoginView.routeName);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sign up failed'),
        ),
      );
    }
  }

  Future<void> _signup() async {
    setState(() => _isLoading = true);

    final email = emailController.text;
    final name = userNameController.text;
    final password = passwordController1.text;

    bool result = false;

    try {
      result = await _authApi.register(email, name, password);
    } catch (e) {
      if (!context.mounted) return;
    } finally {
      setState(() {
        _isLoading = false;
        _signupSuccessful = result;
      });
    }
  }
}
