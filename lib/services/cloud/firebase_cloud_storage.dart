import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:secondapp/services/cloud/cloud_note.dart';
import 'package:secondapp/services/cloud/cloud_storage_constants.dart';
import 'package:secondapp/services/cloud/cloud_storage_exceptions.dart';

//Singleton-Klasse
class FirebaseCloudStorage {

  //Firestore-Collection called 'notes':
  final notes = FirebaseFirestore.instance.collection('notes');

  Future<void> deleteNote({
    required String documentId,
  }) async {
    try {
      notes.doc(documentId).delete();
    } catch (e) {
        throw CouldNotDeleteNoteException();
    }
  }


  //gibt Live-Stream aller Notizen zurück die Nutzer erstellt hat oder die mit ihm geteilt wurden
  Stream<Iterable<CloudNote>> allNotes({
    required String userId,
    required String userEmail,
  }) {
    return notes.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => CloudNote.fromSnapshot(doc))
          .where((note) =>
              note.ownerUserId == userId || note.sharedWith.contains(userEmail));
    });
  }

  //holt alle Notizen eines bestimmten Nutzers auf der Firestore-Datenbank, 
  //gefiltert nach ownerUserId und gibt sie als Liste von CloudNote-Ojekten zurück
  Future<Iterable<CloudNote>> getNotes({required String ownerUserId}) async {
    try {
      return await notes
      .where(
        ownerUserIdFieldName,
        isEqualTo: ownerUserId
      )
      .get()
      .then(
        (value) => value.docs.map((doc) => CloudNote.fromSnapshot(doc))
      );
    } catch(e) {
      throw CouldNotGetAllNotesException();
    }
  }

  Future<CloudNote> createNewNote({required String ownerUserId}) async {
    final document = await notes.add({
      ownerUserIdFieldName: ownerUserId,
      sharedWithFieldName: [], 
      contentFieldName: [],
    });
    final fetchedNote = await document.get();
    print('✅ Firestore-Dokument erstellt: ${document.id}');
    return CloudNote(
      documentId: fetchedNote.id, 
      ownerUserId: ownerUserId,  
      sharedWith: [], 
      content: [],
    );
  }

  Future<void> addParagraphToNote({
    required String noteId,
    required NoteParagraph paragraph,
  }) async {
    final docRef = notes.doc(noteId);
    await docRef.update({
      contentFieldName: FieldValue.arrayUnion([paragraph.toMap()])
    });
  }

  //Notizen können geteilt werden
  Future<void> shareNote({
    required String noteId,
    required String emailToShareWith,
  }) async {
    final doc = notes.doc(noteId);
    final snapshot = await doc.get();

    final data = snapshot.data();
    final currentList = List<String>.from(data?[sharedWithFieldName] ?? []);
    if (!currentList.contains(emailToShareWith)) {
      currentList.add(emailToShareWith);
      await doc.update({sharedWithFieldName: currentList});
    }
  }
  //Prüfen, ob der Nutzer mit der E-Mail existiert
  Future<bool> userExists(String email) async {
    final query = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    return query.docs.isNotEmpty;
  }



  //erstellt eine einzige Instanz dieser Klasse, die global verwendet werden kann
  static final FirebaseCloudStorage _shared = 
  FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;
}