//import 'package:secondapp/views/verifiy_email_view.dart';
//import 'package:secondapp/views/register_view.dart';
//import 'package:secondapp/views/login_view.dart';
//import 'package:secondapp/services/auth/auth_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:secondapp/constants/routes.dart';
import 'package:secondapp/services/auth/local_session.dart';
import 'package:secondapp/services/local/local_user.dart';
import 'package:secondapp/views/login_view_local.dart';
import 'package:secondapp/views/notes/create_update_note_view.dart';
import 'package:secondapp/views/notes/create_update_note_view_hive.dart';
import 'package:secondapp/views/notes/notes_view.dart';
import 'package:secondapp/views/notes/notes_view_local.dart';
import 'package:secondapp/views/register_view_local.dart';
import 'package:flutter/material.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDir.path);
  Hive.registerAdapter(LocalUserAdapter());
  await Hive.openBox<LocalUser>('users');
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
       
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomePage(),
      routes: {
        //loginRoute: (context) => const LoginView(),
        //registerRoute: (context) => const RegisterView(),
        //notesRoute: (context) => const NotesView(),
        //verifyEmailRoute: (context) => const VerifyEmailView(),
        registerLocalRoute: (context) => const RegisterViewLocal(),
        loginLocalRoute: (context) => const LoginViewLocal(),
        createOrUpdateNoteRoute: (context) => const CreateUpdateNoteView(),
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







