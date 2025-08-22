import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:secondapp/constants/routes.dart';
import 'package:secondapp/enums/menu_action.dart';
import 'package:secondapp/services/auth/local_session.dart';
import 'package:secondapp/services/local/local_note.dart';
import 'package:secondapp/services/note_storage/hive_note_storage.dart';
import 'package:secondapp/services/remote/couchdb_api.dart';
import 'package:secondapp/utilities/dialogs/logout_dialog.dart';
import 'package:secondapp/views/login_view_local.dart';
import 'package:secondapp/views/notes/notes_list_view.dart';
import 'package:secondapp/services/sync/note_sync_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:secondapp/widgets/connectivity_banner.dart';

class NotesViewLocal extends StatefulWidget {
  const NotesViewLocal({super.key});

  @override
  State<NotesViewLocal> createState() => _NotesViewLocalState();
}

class _NotesViewLocalState extends State<NotesViewLocal> {
  late final HiveNoteStorage _notesService;
  late final NoteSyncService _syncService;
  late final CouchDbApi couch;

  late final Stream<ConnectivityResult> _connectivityStream;
  late final StreamSubscription<ConnectivityResult> _connectivitySubscription;
  bool _isOnline = false;

  Future<bool> _checkInternetAccess() async {
    try {
      if (kIsWeb) {
        return await couch.ping().timeout(const Duration(seconds: 3));
      } else {
        final result = await InternetAddress.lookup('example.com')
            .timeout(const Duration(seconds: 3));
        return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      }
    } catch (_) {
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    _notesService = HiveNoteStorage();
    
    couch = CouchDbApi.forEnvironment();

    _syncService = NoteSyncService(_notesService, couch);

    // Direkt beim Start Internet testen
    _checkInternetAccess().then((hasInternet) {
      setState(() {
        _isOnline = hasInternet;
      });
    });

    //  Automatische Erkennung von Online-Verfügbarkeit
    _connectivityStream = Connectivity().onConnectivityChanged;
    _connectivitySubscription = _connectivityStream.listen((status) async {
    bool nowOnline = false;

    if (status != ConnectivityResult.none) {
      nowOnline = await _checkInternetAccess();
    }

    setState(() {
      _isOnline = nowOnline;
    });

    if (nowOnline) {
      await _syncService.fetchNotesFromCouchDb();
      await _syncService.syncNotes();
      if (mounted) setState(() {});
    }
  });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final isReachable = await couch.ping();
      if (isReachable) {
        await _syncService.fetchNotesFromCouchDb();
        await _syncService.syncNotes();
        setState(() {});
      }
    });
  }
  
  @override
  void dispose() {
    _connectivitySubscription.cancel(); 
    super.dispose();
  }
  Future<bool> _hasInternet() async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  @override
  Widget build(BuildContext context) {
    final user = LocalSession.currentUser;
    if (user == null) {
      return const Center(child: Text('Kein Nutzer eingeloggt'));
    }
    final userId = user.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Deine Notizen'),
        actions: [
          IconButton(
            onPressed: () async {
              await Navigator.of(context).pushNamed(createUpdateNoteHiveView);
              await _syncService.syncNotes(); 
              setState(() {});
            },
            icon: const Icon(Icons.add),
          ),
          IconButton(
            onPressed: () async {
              final online = await _hasInternet();
              if (!online) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Keine Internetverbindung')),
                );
                return;
              }
              await _syncService.fetchNotesFromCouchDb();
              await _syncService.syncNotes();
              setState(() {});
            },
            icon: const Icon(Icons.sync),
          ),
          IconButton(
            onPressed: () async {
              final userId = LocalSession.currentUser!.id;
              final allNotes = await _notesService.getAllNotes(ownerUserId: userId);

              for (final note in allNotes) {
                await couch.uploadNote('notes', note);
              }

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Notizen synchronisiert')),
                );
              }
            },
            icon: const Icon(Icons.cloud_upload),
          ),

          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final shouldLogout = await showLogOutDialog(context);
                  if (shouldLogout) {
                    LocalSession.logout();
                    await Hive.box('settings').delete('last_user_id');
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginViewLocal()),
                      (_) => false,
                    );
                  }
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Text('Abmelden'),
                ),
              ];
            },
          ),
        ],
      ),
      body: Column(
        children: [
          ConnectivityBanner(
            isOnline: _isOnline,
            internetCheck: () => couch.ping(),          
            checkTimeout: const Duration(seconds: 3),   
          ),
          Expanded(
            child: FutureBuilder(
              future: _notesService.getAllNotes(ownerUserId: userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasData) {
                    final allNotes = snapshot.data as Iterable<LocalNote>;
                    return NotesListView(
                      notes: allNotes,
                      currentUserId: userId,
                      onDeleteNote: (note) async {
                        await _notesService.deleteNote(documentId: note.id);
                        await couch.deleteNote('notes', note.id); 
                        setState(() {});
                      },
                      onTap: (note) {
                        Navigator.of(context).pushNamed(
                          createUpdateNoteHiveView,
                          arguments: note,
                        );
                      },
                    );
                  } else {
                    return const Center(child: Text('Keine Notizen gefunden.'));
                  }
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
