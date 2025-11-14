// setting_view_model.dart
import 'package:flutter/foundation.dart';
import 'package:opicproject/core/manager/autn_manager.dart';
import 'package:opicproject/core/models/alarm_setting_model.dart';
import 'package:opicproject/core/models/user_model.dart';

import 'setting_repository.dart';

class SettingViewModel extends ChangeNotifier {
  final SettingRepository _repository = SettingRepository();

  UserInfo? _loginUser;
  UserInfo? get loginUser => _loginUser;

  AlarmSetting? _alarmSetting;
  AlarmSetting? get alarmSetting => _alarmSetting;

  int? _loginUserId;
  int? get loginUserId => _loginUserId;

  bool _isExist = false;
  bool get isExist => _isExist;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  late bool _isLoading = false;
  bool get isLoading => _isLoading;

  SettingViewModel() {
    AuthManager.shared.addListener(_onAuthChanged);
  }

  void _onAuthChanged() {
    _checkCurrentAuth();
  }

  void _checkCurrentAuth() {
    final userId = AuthManager.shared.userInfo?.id;

    if (userId != null && !_isInitialized) {
      _loginUserId = userId;
      _isInitialized = true;
      notifyListeners();
      initialize(userId);
    } else if (userId == null && _isInitialized) {
      _loginUserId = null;
      _isInitialized = false;
      notifyListeners();
    } else if (userId != null && _isInitialized) {
      print("초기화 완료");
    }
  }

  Future<void> initialize(int loginUserId) async {
    _loginUserId = loginUserId;
  }

  Future<void> fetchUserInfo(int userId) async {
    _loginUser = await _repository.fetchAUser(userId);
    notifyListeners();
  }

  Future<bool> checkIfExist(String nickname, int currentUserId) async {
    if (_loginUser?.nickname == nickname) {
      _isExist = false;
      notifyListeners();
      return false;
    }

    _isExist = await _repository.checkIfExist(
      nickname,
      excludeUserId: currentUserId,
    );
    notifyListeners();
    return _isExist;
  }

  Future<bool> editNickname(int loginUserId, String nickname) async {
    _isLoading = true;
    notifyListeners();

    final updatedUser = await _repository.editNickname(loginUserId, nickname);

    if (updatedUser != null) {
      _loginUser = updatedUser;
      AuthManager.shared.updateUserInfo(updatedUser);
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchAlarmSetting(int loginId) async {
    _alarmSetting = await _repository.fetchAlarmSetting(loginId);
    notifyListeners();
  }

  Future<void> updateAlarmSetting({
    required int userId,
    required AlarmSetting newSetting,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.updateAlarmSetting(userId, newSetting);
      _alarmSetting = newSetting;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    AuthManager.shared.removeListener(_onAuthChanged);
    super.dispose();
  }
}
