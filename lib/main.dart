import 'package:flutter/material.dart';
// import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Parse().initialize(
    'w0jXv8yaGLOoUmppKURGrCXgOaVoN3caIM0QIIZ1',                                 // from Back4App
    'https://parseapi.back4app.com',         // from Back4App
    clientKey: 'sIW4IPhtRbr45h3N6sJQlSn7YVKIj6bdvzSfMejD',                  // from Back4App
    autoSendSessionId: true,
  );
 runApp(const MovieApp());
}

class MovieApp extends StatelessWidget {
  const MovieApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie Watchlist',
     theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
      ),
      home: const AuthGate(),
    );
  }
}