import 'package:hive/hive.dart';
import 'local_paragraph.dart';

part 'local_note.g.dart'; 

@HiveType(typeId: 0)
class LocalNote extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  List<LocalParagraph> content;

  @HiveField(3)
  List<String> sharedWith;

  @HiveField(4)
  DateTime lastModified;

  @HiveField(5)
  bool synced;

  LocalNote({
    required this.id,
    required this.userId,
    required this.content,
    required this.sharedWith,
    required this.lastModified,
    this.synced = false,
  });
  
  LocalNote copyWith({
    List<LocalParagraph>? content,
    List<String>? sharedWith,
    DateTime? lastModified,
    bool? synced,
  }) {
    return LocalNote(
      id: id,
      userId: userId,
      content: content ?? this.content,
      sharedWith: sharedWith ?? this.sharedWith,
      lastModified: lastModified ?? this.lastModified,
      synced: synced ?? this.synced,
    );
  }
}
