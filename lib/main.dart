import 'package:flutter/material.dart';
import 'package:learn/page/employee.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:learn/page/firebase_test.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print("Đang khởi tạo Firebase...");
  
  try {
    // Khởi tạo Firebase mà không cần tùy chọn - sẽ tự động sử dụng cấu hình mặc định
    await Firebase.initializeApp();
    print("Firebase khởi tạo thành công!");
  } catch (e) {
    print("Lỗi khi khởi tạo Firebase: $e");
    print("Chi tiết lỗi Firebase: ${e.toString()}");
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Home',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Home page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Dự án trắng'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FirebaseTestPage()),
                );
              },
              child: const Text('Kiểm tra kết nối Firebase'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EmployeePage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
