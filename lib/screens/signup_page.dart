// lib/screens/signup_page.dart

import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'login_page.dart';  // <-- import the login page

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});
  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  String _user = '', _email = '', _pass = '';
  bool _loading = false, _error = false;

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() {
      _loading = true;
      _error = false;
    });

    final user = ParseUser(_user, _pass, _email);
    final res = await user.signUp();

    setState(() => _loading = false);
    if (res.success) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } else {
      setState(() => _error = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
          margin: const EdgeInsets.symmetric(horizontal: 24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Create Account', style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 16),
                  Form(
                    key: _formKey,
                    child: Column(children: [
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          border: OutlineInputBorder(),
                        ),
                        onSaved: (v) => _user = v!.trim(),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                        onSaved: (v) => _email = v!.trim(),
                        validator: (v) =>
                            v != null && v.contains('@') ? null : 'Invalid email',
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                        onSaved: (v) => _pass = v!,
                        validator: (v) =>
                            v != null && v.length >= 4 ? null : 'Min 4 chars',
                      ),
                      const SizedBox(height: 24),
                      if (_loading)
                        const CircularProgressIndicator()
                      else
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _signup,
                            child: const Text('Sign Up'),
                          ),
                        ),
                      if (_error)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            'Signup failed. Try again.',
                            style: TextStyle(color: theme.colorScheme.error),
                          ),
                        ),
                    ]),
                  ),

                  // ← New button to navigate back to Login
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      );
                    },
                    child: const Text('Already have an account? Log In'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
