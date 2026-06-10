import 'package:flutter/material.dart';
import '../../../core/model/user_model.dart';

class ProfileProvider extends ChangeNotifier {
  UserModel _user = const UserModel(
    id: 'mock_001',
    firstName: 'علی',
    lastName: 'رضایی',
    phone: '09121234567',
    points: 1250,
  );

  UserModel get user => _user;

  void updateUser({String? firstName, String? lastName}) {
    _user = _user.copyWith(
      firstName: firstName,
      lastName: lastName,
    );
    notifyListeners();
  }

  void addPoints(int amount) {
    _user = _user.copyWith(points: _user.points + amount);
    notifyListeners();
  }

  // TODO: وصل کردن به Supabase Auth
  void signOut() {
    notifyListeners();
  }
}