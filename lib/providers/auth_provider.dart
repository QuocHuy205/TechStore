import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';

/// Provider quản lý trạng thái Authentication
/// Dùng với Provider package (ChangeNotifier)
///
/// Tên: AuthStateProvider (tránh xung đột với firebase_auth.AuthProvider)
class AuthStateProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  // === Getters ===
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _user != null;

  AuthStateProvider() {
    // Lắng nghe thay đổi trạng thái đăng nhập từ Firebase
    _authService.authStateChanges.listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  /// Đăng nhập bằng email và mật khẩu
  ///
  /// Trả về [true] nếu thành công, [false] nếu thất bại.
  /// Lỗi được lưu vào [_errorMessage].
  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _authService.signIn(email, password);
      _setLoading(false);
      return true;
    } catch (errorMsg) {
      _errorMessage = errorMsg.toString();
      _setLoading(false);
      return false;
    }
  }

  /// Đăng xuất khỏi hệ thống
  Future<void> signOut() async {
    _setLoading(true);
    await _authService.signOut();
    _setLoading(false);
  }

  /// Xóa thông báo lỗi (dùng khi người dùng bắt đầu nhập lại)
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // === Private helpers ===
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
