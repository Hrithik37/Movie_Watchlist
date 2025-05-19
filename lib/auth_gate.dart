import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'screens/login_page.dart';
import 'screens/movie_list_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});
  Future<bool> _isLoggedIn() async {
    return (await ParseUser.currentUser()) != null;
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isLoggedIn(),
      builder: (_, snap) {
        if (!snap.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        return snap.data! ? const MovieListPage() : const LoginPage();
      },
    );
  }
}
