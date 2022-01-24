import 'package:shared_preferences/shared_preferences.dart';

class CacheHelper {
  static SharedPreferences? sharedPreferences;
  static init() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  static Future<dynamic> putString(
      {required String key, required String? value}) async {
    return await sharedPreferences!.setString(key, value!);
  }

  static String? getString({required String key}) {
    return sharedPreferences!.getString(key);
  }
  static void removeString(uId) async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    sharedPreferences!.remove(uId);
  }


  // CacheHelper();

}
