import 'dart:convert';
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
      print('✅ Datenbank "$dbName" wurde erstellt');
    } else if (response.statusCode == 412) {
      print('ℹ️ Datenbank "$dbName" existiert bereits');
    } else {
      throw Exception('❌ Fehler beim Erstellen der Datenbank: ${response.body}');
    }
  }

  //Eine Notiz an CouchDB senden, true oder false für Upload erfolgreich oder nicht
  Future<bool> uploadNote(String dbName, LocalNote note) async {
    final uri = _buildUri('/$dbName/${note.id}');
    final body = jsonEncode({
      '_id': note.id,
      'userId': note.userId,
      'content': note.content
          .map((p) => {
                'author': p.author,
                'text': p.text,
                'timestamp': p.timestamp.toIso8601String(),
              })
          .toList(),
      'sharedWith': note.sharedWith,
      'lastModified': note.lastModified.toIso8601String(),
    });

    final response = await http.put(uri, headers: _headers, body: body);
    return response.statusCode == 201 || response.statusCode == 202;
  }

    Future<List<Map<String, dynamic>>> fetchNotes(String dbName, String userId) async {
      final uri = _buildUri('/$dbName/_find');
      final body = jsonEncode({
        'selector': {
          'userId': userId,
        }
      });

      final response = await http.post(uri, headers: _headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final docs = data['docs'] as List<dynamic>;
        return docs.cast<Map<String, dynamic>>();
      } else {
        print('Fehler beim Abrufen: ${response.statusCode}');
        return [];
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
        print('Fehler beim Abfragen von Nutzern: ${response.body}');
        return null;
      }
    }


}
