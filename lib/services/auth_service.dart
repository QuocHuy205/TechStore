import 'package:firebase_auth/firebase_auth.dart';
import '../core/constants/app_strings.dart';

/// Service xử lý xác thực và phân quyền (Authentication & Authorization)
///
/// Các chức năng:
/// - signIn: Đăng nhập bằng Email/Password
/// - signOut: Đăng xuất khỏi hệ thống
/// - Kiểm tra trạng thái đăng nhập: [isLoggedIn], [authStateChanges], [currentUser]
/// - Kiểm tra quyền Admin: [isAdmin], [checkAdminRole]
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Stream theo dõi sự thay đổi trạng thái đăng nhập theo thời gian thực
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Lấy thông tin user hiện tại đang đăng nhập (null nếu chưa đăng nhập)
  User? get currentUser => _auth.currentUser;

  /// Kiểm tra xem người dùng hiện tại đã đăng nhập hay chưa
  bool get isLoggedIn => _auth.currentUser != null;

  /// Kiểm tra xem người dùng hiện tại có quyền Admin hay không
  ///
  /// Quy tắc: Người dùng đã đăng nhập với email admin hợp lệ
  bool get isAdmin {
    final user = _auth.currentUser;
    if (user == null || user.email == null) return false;
    final email = user.email!.toLowerCase().trim();
    return email == 'admin@techstore.com' || email.contains('admin');
  }

  /// Phương thức bất đồng bộ kiểm tra quyền Admin
  Future<bool> checkAdminRole() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    // Làm mới token để cập nhật trạng thái mới nhất
    await user.reload();
    return isAdmin;
  }

  /// Đăng nhập tài khoản Admin bằng Email và Mật khẩu
  ///
  /// Trả về [UserCredential] nếu đăng nhập thành công.
  /// Ném ra ngoại lệ [String] tiếng Việt rõ ràng nếu thất bại.
  Future<UserCredential> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthError(e.code);
    } catch (e) {
      throw AppStrings.errorUnknown;
    }
  }

  /// Đăng xuất khỏi hệ thống Firebase Authentication
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Chuyển đổi mã lỗi từ Firebase Auth sang thông báo tiếng Việt
  String _mapFirebaseAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return AppStrings.errorUserNotFound;
      case 'wrong-password':
      case 'invalid-credential':
        return AppStrings.errorWrongCredentials;
      case 'invalid-email':
        return 'Địa chỉ email không đúng định dạng.';
      case 'user-disabled':
        return 'Tài khoản Admin này đã bị vô hiệu hóa.';
      case 'too-many-requests':
        return AppStrings.errorTooManyRequests;
      case 'network-request-failed':
        return AppStrings.errorNetworkFailed;
      default:
        return '${AppStrings.errorUnknown} (Mã lỗi: $code)';
    }
  }
}
