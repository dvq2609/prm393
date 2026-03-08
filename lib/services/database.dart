import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods{
  Future<void> addUserDetail(Map<String, dynamic> userInfoMap, String id) async {
    await FirebaseFirestore.instance
    .collection("users")
    .doc(id)
    .set(userInfoMap);
  }

  UpdateUserwallet(String id, String amout) async {
    await FirebaseFirestore.instance
    .collection("users")
    .doc(id)
    .update({"wallet": amout});
  }

  Future addFoodItem(Map<String, dynamic> userInfoMap, String name) async {
    return await FirebaseFirestore.instance
    .collection(name)
    .add(userInfoMap);
  }

  Future<Stream<QuerySnapshot>> getFoodItem(String name) async {
    return await FirebaseFirestore.instance
    .collection(name)
    .snapshots();
  }
}