// setting_repository.dart
import 'package:opicproject/core/manager/dio_manager.dart';
import 'package:opicproject/core/manager/supabase_manager.dart';
import 'package:opicproject/core/models/alarm_setting_model.dart';
import 'package:opicproject/core/models/user_model.dart';

class SettingRepository {
  Future<UserInfo?> fetchAUser(int userId) async {
    return await SupabaseManager.shared.fetchAUser(userId);
  }

  Future<bool> checkIfExist(String userNickname, {int? excludeUserId}) async {
    return await SupabaseManager.shared.checkIfExist(
      userNickname,
      excludeUserId: excludeUserId,
    );
  }

  Future<UserInfo?> editNickname(int loginUserId, String newNickname) async {
    return await SupabaseManager.shared.editNickname(loginUserId, newNickname);
  }

  Future<AlarmSetting?> fetchAlarmSetting(int loginId) async {
    return await DioManager.shared.fetchAlarmSetting(loginId: loginId);
  }

  Future<void> updateAlarmSetting(int userId, AlarmSetting setting) async {
    await SupabaseManager.shared.updateAlarmSetting(userId, setting);
  }
}
