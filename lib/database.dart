import 'package:cloud_firestore/cloud_firestore.dart';


class DatabaseMethods {
  Future<void> addEmployeeDetails(Map<String, dynamic> employeeInfoMap, String id) async {
    try {
      print("Đang lưu dữ liệu nhân viên với ID: $id");
      await FirebaseFirestore.instance.collection("Employee").doc(id).set(employeeInfoMap);
      print("Đã lưu thành công dữ liệu nhân viên với ID: $id");
      return;
    } catch (e) {
      print("Lỗi khi lưu dữ liệu nhân viên: $e");
      throw e;
    }
  }
}