import 'package:hive/hive.dart';

part 'local_user.g.dart';

@HiveType(typeId: 2)
class LocalUser extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String email;

  @HiveField(2)
  final String password; // In Produktion: Hash verwenden!

  LocalUser({
    required this.id,
    required this.email,
    required this.password,
  });
}
