import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

/// Service quản lý trạng thái kết nối mạng
class ConnectivityService extends GetxService {
  final Connectivity _connectivity = Connectivity();
  
  /// Trạng thái kết nối hiện tại
  final isConnected = true.obs;
  
  /// Loại kết nối hiện tại
  final connectionType = Rx<ConnectivityResult>(ConnectivityResult.none);
  
  /// Stream subscription
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  Future<ConnectivityService> init() async {
    // Kiểm tra trạng thái ban đầu
    await _checkConnectivity();
    
    // Lắng nghe thay đổi kết nối
    _subscription = _connectivity.onConnectivityChanged.listen(_onConnectivityChanged);
    
    return this;
  }

  Future<void> _checkConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    _updateConnectionStatus(results);
  }

  void _onConnectivityChanged(List<ConnectivityResult> results) {
    _updateConnectionStatus(results);
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    // Lấy kết nối tốt nhất
    final bestConnection = _getBestConnection(results);
    connectionType.value = bestConnection;
    
    final wasConnected = isConnected.value;
    isConnected.value = bestConnection != ConnectivityResult.none;
    
    // Thông báo khi trạng thái thay đổi
    if (wasConnected != isConnected.value) {
      if (isConnected.value) {
        _onConnectionRestored();
      } else {
        _onConnectionLost();
      }
    }
  }

  ConnectivityResult _getBestConnection(List<ConnectivityResult> results) {
    // Ưu tiên: wifi > mobile > ethernet > vpn > other > none
    if (results.contains(ConnectivityResult.wifi)) return ConnectivityResult.wifi;
    if (results.contains(ConnectivityResult.mobile)) return ConnectivityResult.mobile;
    if (results.contains(ConnectivityResult.ethernet)) return ConnectivityResult.ethernet;
    if (results.contains(ConnectivityResult.vpn)) return ConnectivityResult.vpn;
    if (results.contains(ConnectivityResult.other)) return ConnectivityResult.other;
    return ConnectivityResult.none;
  }

  void _onConnectionRestored() {
    Get.log('📶 Đã kết nối mạng');
  }

  void _onConnectionLost() {
    Get.log('📵 Mất kết nối mạng');
  }

  /// Kiểm tra có mạng không (sync)
  bool get hasConnection => isConnected.value;

  /// Kiểm tra có mạng không (async - chính xác hơn)
  Future<bool> checkConnection() async {
    await _checkConnectivity();
    return isConnected.value;
  }

  /// Lấy tên loại kết nối
  String get connectionTypeName {
    switch (connectionType.value) {
      case ConnectivityResult.wifi:
        return 'WiFi';
      case ConnectivityResult.mobile:
        return 'Di động';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      case ConnectivityResult.vpn:
        return 'VPN';
      case ConnectivityResult.other:
        return 'Khác';
      default:
        return 'Không có mạng';
    }
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
