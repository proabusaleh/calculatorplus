import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  static SharedPreferences? _instance;

  static Future<SharedPreferences> getInstance() async {
    _instance ??= await SharedPreferences.getInstance();
    return _instance!;
  }
}
