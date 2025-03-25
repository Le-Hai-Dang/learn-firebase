import 'package:flutter/material.dart';
import 'package:learn/database.dart';
import 'package:random_string/random_string.dart';

class EmployeePage extends StatefulWidget {
  const EmployeePage({super.key});

  @override
  State<EmployeePage> createState() => _EmployeePageState();
}

class _EmployeePageState extends State<EmployeePage> {
  TextEditingController namecontroller = new TextEditingController();
  TextEditingController titlecontroller = new TextEditingController();
  TextEditingController emailcontroller = new TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';
  
  // Hiển thị thông báo dưới dạng SnackBar
  void _showMessage(String message, bool isError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  // Kiểm tra các trường nhập liệu
  bool _validateInputs() {
    if (namecontroller.text.isEmpty) {
      _showMessage('Vui lòng nhập họ và tên', true);
      return false;
    }
    if (titlecontroller.text.isEmpty) {
      _showMessage('Vui lòng nhập chức vụ', true);
      return false;
    }
    if (emailcontroller.text.isEmpty) {
      _showMessage('Vui lòng nhập email', true);
      return false;
    }
    return true;
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông tin nhân viên'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Thông tin cá nhân',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: namecontroller,
                decoration: InputDecoration(
                  labelText: 'Họ và tên',
                  hintText: 'Nhập họ và tên',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titlecontroller,
                decoration: InputDecoration(
                  labelText: 'Chức vụ',
                  hintText: 'Nhập chức vụ',
                  prefixIcon: Icon(Icons.work),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailcontroller,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'Nhập địa chỉ email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              const SizedBox(height: 30),
              Center(
                child: _isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () async {
                          // Kiểm tra dữ liệu đầu vào
                          if (!_validateInputs()) return;
                          
                          setState(() {
                            _isLoading = true;
                            _errorMessage = '';
                          });
                          
                          try {
                            String id = randomAlpha(10);
                            Map<String, dynamic> employeeInforMap = {
                              "name": namecontroller.text,
                              "title": titlecontroller.text,
                              "email": emailcontroller.text,
                              "id": id,
                            };
                            
                            print("Sending data to Firebase: $employeeInforMap");
                            
                            await DatabaseMethods().addEmployeeDetails(employeeInforMap, id);
                            
                            // Hiển thị thông báo thành công
                            _showMessage('Lưu thông tin thành công!', false);
                            
                            // Xóa dữ liệu đã nhập
                            namecontroller.clear();
                            titlecontroller.clear();
                            emailcontroller.clear();
                          } catch (e) {
                            print("Error saving to Firebase: $e");
                            setState(() {
                              _errorMessage = 'Lỗi: ${e.toString()}';
                            });
                            _showMessage('Lỗi khi lưu thông tin: ${e.toString()}', true);
                          } finally {
                            setState(() {
                              _isLoading = false;
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Lưu thông tin'),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
