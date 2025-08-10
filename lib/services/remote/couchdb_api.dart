import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:secondapp/services/local/local_note.dart';
import 'package:secondapp/services/local/local_user.dart';

//Klasse kapselt alle Funktionen, um mit CouchD zu kommunizieren
class CouchDbApi {
  final String host;
  final String username;
  final String password;

  const CouchDbApi({
    required this.host,
    required this.username,
    required this.password,
  });

  /// Neue Factory: wählt CouchDB-Host abhängig vom Port der Web-App
  factory CouchDbApi.forEnvironment({
    String username = 'admin',
    String password = 'admin',
  }) {
    String hostUrl;

    if (kIsWeb) {
      final port = Uri.base.port;
      if (port == 8080) {
        hostUrl = 'http://localhost:5985';
      } else if (port == 8081) {
        hostUrl = 'http://localhost:5984';
      } else {
        hostUrl = 'http://localhost:5984'; // Fallback
      }
    } else {
      hostUrl = 'http://10.0.2.2:5984'; // Mobile/Emulator
    }

    return CouchDbApi(
      host: hostUrl,
      username: username,
      password: password,
    );
  }

  //Hilfsmethode, um URL zu bauen
  Uri _buildUri(String path) => Uri.parse('$host$path');

  //HTTP-Header
  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization':
            'Basic ${base64Encode(utf8.encode('$username:$password'))}',
      };

  Future<bool> ping() async {
    final uri = _buildUri('/');
    final response = await http.get(uri, headers: _headers);
    return response.statusCode == 200;
  }
  Future<void> createDbIfNotExists(String dbName) async {
    final uri = _buildUri('/$dbName');
    final response = await http.put(uri, headers: _headers);
    if (response.statusCode == 201) {
      print(' Datenbank "$dbName" wurde erstellt');
    } else if (response.statusCode == 412) {
      print('ℹDatenbank "$dbName" existiert bereits');
    } else {
      throw Exception('Fehler beim Erstellen der Datenbank: ${response.body}');
    }
  }

  //Eine Notiz an CouchDB senden, true oder false für Upload erfolgreich oder nicht
  Future<bool> uploadNote(String dbName, LocalNote note) async {
    final uri = _buildUri('/$dbName/${note.id}');

    // Prüfen, ob das Dokument existiert, um _rev zu bekommen
    final existingResponse = await http.get(uri, headers: _headers);

    String? rev;
    if (existingResponse.statusCode == 200) {
      final existingDoc = jsonDecode(existingResponse.body);
      rev = existingDoc['_rev'];
    }

    final body = {
      '_id': note.id,
      'userId': note.userId,
      'content': note.content.map((p) => {
        'author': p.author,
        'text': p.text,
        'timestamp': p.timestamp.toIso8601String(),
      }).toList(),
      'sharedWith': note.sharedWith,
      'lastModified': note.lastModified.toIso8601String(),
      if (rev != null) '_rev': rev, // Nur senden, wenn vorhanden
    };

    final response = await http.put(uri, headers: _headers, body: jsonEncode(body));

    return response.statusCode == 201 || response.statusCode == 202;
  }


    Future<List<Map<String, dynamic>>> fetchNotes(String dbName, String userId) async {
      final uri = _buildUri('/$dbName/_find');
      final body = jsonEncode({
        'selector': {
          r'$or': [
            {'userId': userId},
            {'sharedWith': {'\$elemMatch': {'\$eq': userId}}}
          ]
        }
      });

      final response = await http.post(uri, headers: _headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final docs = data['docs'] as List<dynamic>;
        return docs.cast<Map<String, dynamic>>();
      } else {
        return [];
      }
    }
    //Für Notizen-Sharing
    Future<Map<String, dynamic>?> findUserByEmail(String email) async {
      final uri = _buildUri('/users/_find');
      final body = jsonEncode({
        'selector': {
          'email': email,
        },
        'limit': 1,
      });

      final response = await http.post(uri, headers: _headers, body: body);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final docs = decoded['docs'] as List;
        if (docs.isNotEmpty) {
          return docs.first;
        }
        return null;
      } else {
        return null;
      }
    }
    Future<void> uploadUser(LocalUser user) async {
      final uri = _buildUri('/users/${user.id}');
      final body = jsonEncode({
        '_id': user.id,
        'email': user.email,
        'password': user.password,
      });

      final response = await http.put(uri, headers: _headers, body: body);

      if (response.statusCode == 201 || response.statusCode == 202) {
        print('Nutzer erfolgreich in CouchDB gespeichert');
      } else {
        print('Fehler beim Speichern des Nutzers: ${response.body}');
      }
    }

    Future<void> deleteNote(String dbName, String noteId) async {
      final uri = _buildUri('/$dbName/$noteId');
      final getResponse = await http.get(uri, headers: _headers);

      if (getResponse.statusCode == 200) {
        final rev = jsonDecode(getResponse.body)['_rev'];
        final deleteUri = _buildUri('/$dbName/$noteId?rev=$rev');
        final deleteResponse = await http.delete(deleteUri, headers: _headers);

        if (deleteResponse.statusCode == 200 || deleteResponse.statusCode == 202) {
          print('Notiz $noteId erfolgreich aus CouchDB gelöscht.');
        } else {
          print('Fehler beim Löschen der Notiz: ${deleteResponse.body}');
        }
      } else {
        print('Notiz nicht gefunden: ${getResponse.body}');
      }
    }



}
