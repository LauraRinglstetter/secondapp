// import 'package:secondapp/constants/routes.dart';
// import 'package:secondapp/enums/menu_action.dart';
// import 'package:secondapp/services/auth/auth_service.dart';
// import 'package:secondapp/services/auth/local_session.dart';
// import 'package:secondapp/services/cloud/cloud_note.dart';
// //import 'package:secondapp/services/cloud/firebase_cloud_storage.dart';
// import 'package:secondapp/utilities/dialogs/logout_dialog.dart';
// import 'package:secondapp/views/login_view_local.dart';
// import 'package:secondapp/views/notes/notes_list_view.dart';
// import 'package:flutter/material.dart';
// import 'package:secondapp/services/note_storage/hive_note_storage.dart';


// class NotesView extends StatefulWidget {
//   const NotesView({super.key});

//   @override
//   State<NotesView> createState() => _NotesViewState();
// }

// class _NotesViewState extends State<NotesView> {
//   late final HiveNoteStorage _notesService;
//   String get userId => AuthService.firebase().currentUser!.id;

  
//   @override
//   void initState() {
//     _notesService = HiveNoteStorage();
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final user = AuthService.firebase().currentUser!;
//     final userEmail = user.email;
//     final userId = user.id;
//     return Scaffold(
//       appBar: AppBar (
//         title: const Text('Your Notes'),
//         actions: [
//           IconButton(
//             onPressed: () {
//               Navigator.of(context).pushNamed(createOrUpdateNoteRoute);
//             },
//             icon: const Icon(Icons.add)
//           ),
          
//           PopupMenuButton<MenuAction>(
//             onSelected: (value) async {
//               switch(value) {
                
//                 case MenuAction.logout:
//                   final shouldLogout = await showLogOutDialog(context);
//                   if (shouldLogout) {
//                     LocalSession.logout();
//                     Navigator.of(context).pushAndRemoveUntil(
//                       MaterialPageRoute(builder: (context) => const LoginViewLocal()),
//                       (_) => false,
//                     );
//                   }
//               }
//             }, itemBuilder:(context) {
//               return const [
//                 PopupMenuItem<MenuAction>(
//                   value: MenuAction.logout, 
//                   child: Text('Log out'),
//                 )
//               ];
//             },
//           )
//         ],
//       ),
//       body: StreamBuilder (
//         stream: _notesService.allNotes(
//           ownerUserId: userId,
//         ),
//         builder: (context, snapshot) {
//           switch (snapshot.connectionState) {       
//             case ConnectionState.waiting:
//             case ConnectionState.active:
//               if (snapshot.hasData) {
//                 final allNotes = snapshot.data as Iterable<CloudNote>;
//                 return NotesListView(
//                   notes: allNotes, 
//                   currentUserId: userId,
//                   onDeleteNote: (note) async {
//                     await _notesService.deleteNote(documentId: note.documentId);

//                   },
//                   onTap:(note) {
//                     Navigator.of(context).pushNamed(
//                       createOrUpdateNoteRoute,
//                       arguments: note,
//                     );
//                   },
//                 );
//               } else {
//                 return const CircularProgressIndicator();
//               }
//             default:
//               return const CircularProgressIndicator();
//           }
//         },
//       )
//     );
//   }
// }

