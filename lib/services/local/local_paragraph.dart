import 'package:hive/hive.dart';

part 'local_paragraph.g.dart';

@HiveType(typeId: 1)
class LocalParagraph extends HiveObject {
  @HiveField(0)
  final String author;

  @HiveField(1)
  final String text;

  @HiveField(2)
  final DateTime timestamp;

  LocalParagraph({
    required this.author,
    required this.text,
    required this.timestamp,
  });
}
