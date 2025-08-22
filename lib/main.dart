import 'package:hive_flutter/hive_flutter.dart';
import 'package:secondapp/constants/routes.dart';
import 'package:secondapp/services/auth/local_session.dart';
import 'package:secondapp/services/local/local_note.dart';
import 'package:secondapp/services/local/local_paragraph.dart';
import 'package:secondapp/services/local/local_user.dart';
import 'package:secondapp/views/login_view_local.dart';
import 'package:secondapp/views/notes/create_update_note_view_hive.dart';
import 'package:secondapp/views/notes/notes_view_local.dart';
import 'package:secondapp/views/register_view_local.dart';
import 'package:flutter/material.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  // Adapter nur registrieren, wenn nicht schon vorhanden
  if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(LocalUserAdapter());
  if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(LocalNoteAdapter());
  if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(LocalParagraphAdapter());


  await Hive.openBox<LocalUser>('users');
  await Hive.openBox('settings');
  final usersBox = Hive.box<LocalUser>('users');

  // Prüft, ob letzter Nutzer gespeichert wurde
  final lastUserId = Hive.box('settings').get('last_user_id');
  if (lastUserId != null) {
    final lastUser = usersBox.get(lastUserId);
    if (lastUser != null) {
      LocalSession.setUser(lastUser);
    }
  }


  runApp(
    MaterialApp(
      title: 'Local-First-Edge-Prototyp',
      theme: ThemeData(
       
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomePage(),
      routes: {
        registerLocalRoute: (context) => const RegisterViewLocal(),
        loginLocalRoute: (context) => const LoginViewLocal(),
        createUpdateNoteHiveView: (context) => const CreateUpdateNoteHiveView(),
        notesLocalRoute: (context) => const NotesViewLocal(),
      }
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = LocalSession.currentUser;

    if (user != null) {
      return const NotesViewLocal();
    } else {
      return const LoginViewLocal();
    }
  }
}