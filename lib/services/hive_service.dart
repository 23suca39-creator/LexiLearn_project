import 'package:hive_flutter/hive_flutter.dart';
import '../models/user.dart';

class HiveService {
  static const String usersBoxName = 'usersBox';
  static const String rememberMeBoxName = 'rememberMeBox';

  static Future<void> initHive() async {
    await Hive.initFlutter();
    Hive.registerAdapter(UserAdapter());
    await Hive.openBox<User>(usersBoxName);
    await Hive.openBox(rememberMeBoxName);
  }

  static Box<User> getUsersBox() => Hive.box<User>(usersBoxName);
  static Box getRememberMeBox() => Hive.box(rememberMeBoxName);
}
