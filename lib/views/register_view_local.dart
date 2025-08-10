import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:secondapp/services/remote/couchdb_api.dart';
import 'package:secondapp/views/notes/notes_view_local.dart';
import 'package:uuid/uuid.dart';

import 'package:secondapp/constants/routes.dart';
import 'package:secondapp/services/local/local_user.dart';
import 'package:secondapp/services/auth/local_session.dart';

class RegisterViewLocal extends StatefulWidget {
  const RegisterViewLocal({super.key});

  @override
  State<RegisterViewLocal> createState() => _RegisterViewLocalState();
}

class _RegisterViewLocalState extends State<RegisterViewLocal> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _error;

  Future<LocalUser?> _register() async {
    final box = Hive.box<LocalUser>('users');
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (box.values.any((u) => u.email == email)) {
      setState(() {
        _error = 'E-Mail existiert bereits';
      });
      return null;
    }

    final user = LocalUser(
      id: const Uuid().v4(),
      email: email,
      password: password,
    );

    await box.put(user.id, user);
    return user;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrieren')),
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
              onPressed: () async {
                final user = await _register();
                if (user != null) {
                  LocalSession.setUser(user);
                  final couch = CouchDbApi.forEnvironment();

                  await couch.uploadUser(user);
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const NotesViewLocal()),
                  );
                }
              },
              child: const Text('Registrieren'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushReplacementNamed(loginLocalRoute);
              },
              child: const Text('Schon registriert? Login hier'),
            ),
          ],
        ),
      ),
    );
  }
}
