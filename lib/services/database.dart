import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

class DatabaseMethods {
  Future<void> addUserDetail(
    Map<String, dynamic> userInfoMap,
    String id,
  ) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .set(userInfoMap);
  }

  UpdateUserwallet(String id, String amout) async {
    await FirebaseFirestore.instance.collection("users").doc(id).update({
      "wallet": amout,
    });
  }

  Future addFoodItem(Map<String, dynamic> userInfoMap, String name) async {
    return await FirebaseFirestore.instance.collection(name).add(userInfoMap);
  }

  Future<Stream<QuerySnapshot>> getFoodItem(String name) async {
    return FirebaseFirestore.instance.collection(name).snapshots();
  }

  Future<Stream<List<DocumentSnapshot>>> getAllFoodItems() async {
    return Rx.combineLatest4(
      FirebaseFirestore.instance.collection("Ice-cream").snapshots(),
      FirebaseFirestore.instance.collection("Pizza").snapshots(),
      FirebaseFirestore.instance.collection("Salad").snapshots(),
      FirebaseFirestore.instance.collection("Burger").snapshots(),
      (
        QuerySnapshot iceCream,
        QuerySnapshot pizza,
        QuerySnapshot salad,
        QuerySnapshot burger,
      ) {
        return [...iceCream.docs, ...pizza.docs, ...salad.docs, ...burger.docs];
      },
    );
  }

  Future<void> AddFoodtoCart(
    Map<String, dynamic> userInfoMap,
    String id,
  ) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .collection("Cart")
        .add(userInfoMap);
  }

  Future<Stream<QuerySnapshot>> getFoodCart(String id) async {
    return FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .collection("Cart")
        .snapshots();
  }

  Future<void> updateFoodItem(String category, String id, Map<String, dynamic> updatedInfo) async {
    await FirebaseFirestore.instance
        .collection(category)
        .doc(id)
        .update(updatedInfo);
  }

  Future<void> deleteFoodItem(String category, String id) async {
    await FirebaseFirestore.instance
        .collection(category)
        .doc(id)
        .delete();
  }
}
