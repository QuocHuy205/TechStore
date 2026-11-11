/// Các chuỗi văn bản dùng trong ứng dụng TechStore
/// Tập trung tại đây để dễ bảo trì và tránh hardcode rải rác
class AppStrings {
  AppStrings._(); // Không cho khởi tạo

  // === Tên ứng dụng ===
  static const String appName = 'TechStore';
  static const String appFullName = 'TechStore - Quản lý phụ kiện điện thoại';

  // === Màn hình đăng nhập ===
  static const String loginTitle = 'Đăng nhập Admin';
  static const String loginSubtitle = 'Hệ thống quản lý TechStore';
  static const String emailLabel = 'Email';
  static const String emailHint = 'Nhập email admin';
  static const String passwordLabel = 'Mật khẩu';
  static const String passwordHint = 'Nhập mật khẩu';
  static const String loginButton = 'Đăng nhập';
  static const String loggingIn = 'Đang đăng nhập...';

  // === Màn hình danh sách sản phẩm ===
  static const String productListTitle = 'Quản lý sản phẩm';
  static const String addProduct = 'Thêm sản phẩm';
  static const String editProduct = 'Sửa sản phẩm';
  static const String deleteProduct = 'Xóa sản phẩm';
  static const String noProducts = 'Chưa có sản phẩm nào';
  static const String searchHint = 'Tìm kiếm sản phẩm...';
  static const String logout = 'Đăng xuất';

  // === Form sản phẩm ===
  static const String productName = 'Tên sản phẩm';
  static const String productNameHint = 'VD: Tai nghe Bluetooth JBL';
  static const String productPrice = 'Giá (VNĐ)';
  static const String productPriceHint = 'VD: 350000';
  static const String productQuantity = 'Số lượng';
  static const String productQuantityHint = 'VD: 15';
  static const String productImage = 'Hình ảnh';
  static const String selectImage = 'Chọn ảnh từ thư viện';
  static const String captureImage = 'Chụp ảnh';
  static const String uploadingImage = 'Đang tải ảnh lên...';
  static const String saveProduct = 'Lưu sản phẩm';
  static const String saving = 'Đang lưu...';
  static const String cancel = 'Hủy';

  // === Thông báo ===
  static const String deleteConfirmTitle = 'Xác nhận xóa';
  static const String deleteConfirmMessage =
      'Bạn có chắc muốn xóa sản phẩm này?\nHành động này không thể hoàn tác.';
  static const String deleteConfirm = 'Xóa';
  static const String logoutConfirmTitle = 'Xác nhận đăng xuất';
  static const String logoutConfirmMessage = 'Bạn có muốn đăng xuất khỏi hệ thống?';

  // === Thông báo thành công ===
  static const String addSuccess = 'Thêm sản phẩm thành công!';
  static const String updateSuccess = 'Cập nhật sản phẩm thành công!';
  static const String deleteSuccess = 'Đã xóa sản phẩm.';

  // === Thông báo lỗi ===
  static const String errorRequired = 'Trường này không được để trống';
  static const String errorInvalidPrice = 'Giá phải là số dương hợp lệ';
  static const String errorInvalidQuantity = 'Số lượng phải là số nguyên không âm';
  static const String errorImageRequired = 'Vui lòng chọn hoặc nhập URL hình ảnh';
  static const String errorUploadFailed = 'Tải ảnh thất bại. Vui lòng thử lại.';
  static const String errorNetworkFailed = 'Không thể kết nối. Kiểm tra mạng.';
  static const String errorWrongCredentials = 'Email hoặc mật khẩu không đúng';
  static const String errorUserNotFound = 'Tài khoản không tồn tại';
  static const String errorTooManyRequests = 'Quá nhiều lần thử. Hãy thử lại sau.';
  static const String errorUnknown = 'Đã có lỗi xảy ra. Vui lòng thử lại.';
}
