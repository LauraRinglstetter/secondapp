import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:secondapp/constants/routes.dart';
import 'package:secondapp/views/notes/notes_view_local.dart';
import 'package:secondapp/services/remote/couchdb_api.dart';
import 'package:secondapp/services/local/local_user.dart';
import 'package:secondapp/services/auth/local_session.dart';

class LoginViewLocal extends StatefulWidget {
  const LoginViewLocal({super.key});

  @override
  State<LoginViewLocal> createState() => _LoginViewLocalState();
}

class _LoginViewLocalState extends State<LoginViewLocal> {
  late final CouchDbApi _couch;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _error;

  @override
  void initState() {
    super.initState();
    _couch = CouchDbApi.forEnvironment();
  }

  Future<void> _login() async {
    final box = Hive.box<LocalUser>('users');
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final LocalUser? user = box.values.cast<LocalUser?>().firstWhere(
      (u) => u!.email == email && u.password == password,
      orElse: () => null,
    );

    if (user != null) {
      LocalSession.setUser(user);
      await Hive.box('settings').put('last_user_id', user.id);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const NotesViewLocal()),
      );
      return;
    }

    final remoteUser = await _couch.findUserByEmail(email);

    if (remoteUser != null && remoteUser['password'] == password) {
      // Nutzer in Hive speichern
      final imported = LocalUser(
        id: remoteUser['_id'],
        email: remoteUser['email'],
        password: remoteUser['password'],
      );
      await box.put(imported.id, imported);

      LocalSession.setUser(imported);
      await Hive.box('settings').put('last_user_id', imported.id);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const NotesViewLocal()),
      );
    } else {
      setState(() {
        _error = 'Falsche E-Mail oder Passwort';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Anmelden')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'E-Mail'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Passwort'),
              obscureText: true,
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _login,
              child: const Text('Einloggen'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushReplacementNamed(registerLocalRoute);
              },
              child: const Text('Registrieren'),
            ),
          ],
        ),
      ),
    );
  }
}