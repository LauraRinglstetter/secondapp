import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:secondapp/constants/routes.dart';
import 'package:secondapp/views/notes/notes_view_local.dart';
import 'package:uuid/uuid.dart';

import 'package:secondapp/services/local/local_user.dart';
import 'package:secondapp/services/auth/local_session.dart';
import 'package:secondapp/views/notes/notes_view.dart';

class LoginViewLocal extends StatefulWidget {
  const LoginViewLocal({super.key});

  @override
  State<LoginViewLocal> createState() => _LoginViewLocalState();
}

class _LoginViewLocalState extends State<LoginViewLocal> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _error;

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
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const NotesViewLocal()),
      );
    } else {
      setState(() {
        _error = 'Falsche E-Mail oder Passwort';
      });
    }
  }
  Future<void> _deleteUserByEmail(String email) async {
    final box = await Hive.openBox<LocalUser>('users');

    final userKey = box.keys.firstWhere(
      (key) => box.get(key)?.email == email,
      orElse: () => null,
    );

    if (userKey != null) {
      await box.delete(userKey);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nutzer "$email" gelöscht')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kein Nutzer mit E-Mail "$email" gefunden')),
      );
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
