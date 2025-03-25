import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirebaseTestPage extends StatefulWidget {
  const FirebaseTestPage({Key? key}) : super(key: key);

  @override
  State<FirebaseTestPage> createState() => _FirebaseTestPageState();
}

class _FirebaseTestPageState extends State<FirebaseTestPage> {
  bool _isFirebaseInitialized = false;
  bool _isCheckingFirestore = false;
  String _firestoreStatus = 'Chưa kiểm tra';
  String _errorMessage = '';
  Map<String, String> _installationStatus = {};
  bool _isCheckingSetup = false;

  @override
  void initState() {
    super.initState();
    _checkFirebaseStatus();
  }

  Future<void> _checkFirebaseStatus() async {
    try {
      _isFirebaseInitialized = Firebase.apps.isNotEmpty;
      setState(() {});
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi kiểm tra Firebase: ${e.toString()}';
      });
    }
  }

  Future<void> _testFirestore() async {
    setState(() {
      _isCheckingFirestore = true;
      _firestoreStatus = 'Đang kiểm tra...';
    });

    try {
      // Thử truy cập Firestore để kiểm tra kết nối
      final testCollection = FirebaseFirestore.instance.collection('test');
      final docId = 'test_${DateTime.now().millisecondsSinceEpoch}';
      
      // Thử ghi dữ liệu
      await testCollection.doc(docId).set({
        'timestamp': FieldValue.serverTimestamp(),
        'message': 'Test connection',
      });
      
      // Thử đọc dữ liệu
      final docSnapshot = await testCollection.doc(docId).get();
      
      // Xóa dữ liệu test
      await testCollection.doc(docId).delete();
      
      setState(() {
        _firestoreStatus = 'Kết nối thành công! ${docSnapshot.exists ? '(Đọc/ghi OK)' : ''}';
        _isCheckingFirestore = false;
      });
    } catch (e) {
      setState(() {
        _firestoreStatus = 'Kết nối thất bại';
        _errorMessage = 'Lỗi Firestore: ${e.toString()}';
        _isCheckingFirestore = false;
      });
    }
  }

  // Kiểm tra cài đặt Firebase
  Future<void> _checkFirebaseSetup() async {
    setState(() {
      _isCheckingSetup = true;
      _installationStatus = {};
      _errorMessage = '';
    });

    try {
      // Kiểm tra Firebase Core
      _installationStatus['Firebase Core'] = Firebase.apps.isNotEmpty 
          ? 'Đã cài đặt' 
          : 'Chưa khởi tạo';

      // Thông tin về nền tảng
      _installationStatus['Nền tảng'] = defaultTargetPlatform.toString();
      
      // Kiểm tra file cấu hình
      try {
        final app = Firebase.app();
        _installationStatus['Firebase App'] = app.name;
        _installationStatus['Firebase Options'] = app.options != null
            ? 'Đã cấu hình' 
            : 'Thiếu cấu hình';
      } catch (e) {
        _installationStatus['Firebase App'] = 'Lỗi: $e';
      }

      // Kiểm tra quyền internet
      _installationStatus['Internet Permission'] = 'Không xác định (cần kiểm tra manifest/info.plist)';

      // Kiểm tra Firestore
      try {
        FirebaseFirestore.instance.collection('test');
        _installationStatus['Firestore'] = 'Có thể truy cập';
      } catch (e) {
        _installationStatus['Firestore'] = 'Lỗi: $e';
      }

    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi kiểm tra cài đặt: $e';
      });
    } finally {
      setState(() {
        _isCheckingSetup = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kiểm tra Firebase'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Trạng thái Firebase',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            _isFirebaseInitialized
                                ? Icons.check_circle
                                : Icons.error,
                            color: _isFirebaseInitialized
                                ? Colors.green
                                : Colors.red,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isFirebaseInitialized
                                ? 'Đã khởi tạo'
                                : 'Chưa khởi tạo',
                            style: TextStyle(
                              color: _isFirebaseInitialized
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Trạng thái Firestore',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            _firestoreStatus == 'Kết nối thành công!'
                                ? Icons.check_circle
                                : _firestoreStatus == 'Chưa kiểm tra'
                                    ? Icons.info
                                    : Icons.error,
                            color: _firestoreStatus == 'Kết nối thành công!'
                                ? Colors.green
                                : _firestoreStatus == 'Chưa kiểm tra'
                                    ? Colors.blue
                                    : Colors.red,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _firestoreStatus,
                            style: TextStyle(
                              color: _firestoreStatus == 'Kết nối thành công!'
                                  ? Colors.green
                                  : _firestoreStatus == 'Chưa kiểm tra'
                                      ? Colors.blue
                                      : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_isCheckingFirestore)
                            const Padding(
                              padding: EdgeInsets.only(left: 8.0),
                              child: SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Card(
                    color: Colors.red.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.error, color: Colors.red),
                              SizedBox(width: 8),
                              Text(
                                'Chi tiết lỗi:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(_errorMessage),
                        ],
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isFirebaseInitialized ? _testFirestore : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(_isFirebaseInitialized
                    ? 'Kiểm tra kết nối Firestore'
                    : 'Firebase chưa khởi tạo'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _checkFirebaseStatus,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('Kiểm tra lại trạng thái Firebase'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _checkFirebaseSetup,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isCheckingSetup)
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    Text('Kiểm tra cài đặt chi tiết'),
                  ],
                ),
              ),
              if (_installationStatus.isNotEmpty) ...[
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Thông tin cài đặt Firebase',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        ..._installationStatus.entries.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${entry.key}: ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Expanded(
                                  child: Text(
                                    entry.value,
                                    style: TextStyle(
                                      color: entry.value.contains('Lỗi') ? Colors.red : null,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 32),
              const Text(
                'Hướng dẫn cài đặt Firebase:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                '1. Tạo dự án Firebase trên console.firebase.google.com',
              ),
              const SizedBox(height: 4),
              const Text(
                '2. Đăng ký ứng dụng iOS/Android',
              ),
              const SizedBox(height: 4),
              const Text(
                '3. Tải file cấu hình (GoogleService-Info.plist hoặc google-services.json)',
              ),
              const SizedBox(height: 4),
              const Text(
                '4. Thêm file vào dự án (iOS/android folder)',
              ),
              const SizedBox(height: 4),
              const Text(
                '5. Cấu hình Info.plist và Podfile (iOS)',
              ),
              const SizedBox(height: 4),
              const Text(
                '6. Khởi động lại ứng dụng hoàn toàn (không chỉ hot restart)',
              ),
            ],
          ),
        ),
      ),
    );
  }
} 