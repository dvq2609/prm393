import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WalletService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Lấy userId hiện tại
  String? get currentUserId => _auth.currentUser?.uid;

  // Stream để lắng nghe thay đổi số dư realtime
  Stream<int> getBalanceStream() {
    if (currentUserId == null) {
      return Stream.value(0);
    }

    return _firestore
        .collection('wallets')
        .doc(currentUserId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        return 0;
      }
      return (snapshot.data()?['balance'] ?? 0) as int;
    });
  }

  // Lấy số dư hiện tại (one-time)
  Future<int> getCurrentBalance() async {
    if (currentUserId == null) return 0;

    try {
      final doc = await _firestore
          .collection('wallets')
          .doc(currentUserId)
          .get();

      if (!doc.exists) {
        // Tạo ví mới nếu chưa có
        await _createWallet();
        return 0;
      }

      return (doc.data()?['balance'] ?? 0) as int;
    } catch (e) {
      print('Error getting balance: $e');
      return 0;
    }
  }

  // Tạo ví mới cho user
  Future<void> _createWallet() async {
    if (currentUserId == null) return;

    try {
      await _firestore.collection('wallets').doc(currentUserId).set({
        'balance': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error creating wallet: $e');
    }
  }

  // Cộng tiền vào ví sau khi thanh toán thành công
  Future<bool> addBalance({
    required int amount,
    required String orderId,
    required String transactionId,
  }) async {
    print('=== ADD BALANCE ===');
    print('Current userId: $currentUserId');
    print('Amount: $amount');
    print('OrderId: $orderId');

    if (currentUserId == null) {
      print('ERROR: userId is null!');
      return false;
    }

    try {
      final walletRef = _firestore.collection('wallets').doc(currentUserId);
      print('Wallet ref path: ${walletRef.path}');

      // Sử dụng transaction để đảm bảo tính nhất quán
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(walletRef);
        print('Wallet exists: ${snapshot.exists}');

        int currentBalance = 0;
        if (snapshot.exists) {
          currentBalance = (snapshot.data()?['balance'] ?? 0) as int;
          print('Current balance: $currentBalance');
        }

        final newBalance = currentBalance + amount;
        print('New balance: $newBalance');

        if (snapshot.exists) {
          transaction.update(walletRef, {
            'balance': newBalance,
            'lastUpdated': FieldValue.serverTimestamp(),
          });
          print('Updated existing wallet');
        } else {
          transaction.set(walletRef, {
            'balance': newBalance,
            'createdAt': FieldValue.serverTimestamp(),
            'lastUpdated': FieldValue.serverTimestamp(),
          });
          print('Created new wallet');
        }
      });

      print('Transaction completed successfully');

      // Lưu lịch sử giao dịch
      await _saveTransactionHistory(
        amount: amount,
        orderId: orderId,
        transactionId: transactionId,
      );

      print('Transaction history saved');
      return true;
    } catch (e) {
      print('ERROR adding balance: $e');
      print('Error type: ${e.runtimeType}');
      return false;
    }
  }

  // Lưu lịch sử giao dịch
  Future<void> _saveTransactionHistory({
    required int amount,
    required String orderId,
    required String transactionId,
  }) async {
    if (currentUserId == null) return;

    try {
      await _firestore
          .collection('wallets')
          .doc(currentUserId)
          .collection('transactions')
          .add({
        'amount': amount,
        'type': 'deposit', // deposit hoặc withdraw
        'orderId': orderId,
        'transactionId': transactionId,
        'status': 'success',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error saving transaction history: $e');
    }
  }

  // Trừ tiền khi thanh toán đơn hàng
  Future<bool> deductBalance({
    required int amount,
    required String orderId,
  }) async {
    if (currentUserId == null) return false;

    try {
      final walletRef = _firestore.collection('wallets').doc(currentUserId);

      bool success = false;

      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(walletRef);

        if (!snapshot.exists) {
          throw Exception('Wallet not found');
        }

        final currentBalance = (snapshot.data()?['balance'] ?? 0) as int;

        if (currentBalance < amount) {
          throw Exception('Insufficient balance');
        }

        final newBalance = currentBalance - amount;

        transaction.update(walletRef, {
          'balance': newBalance,
          'lastUpdated': FieldValue.serverTimestamp(),
        });

        success = true;
      });

      if (success) {
        // Lưu lịch sử trừ tiền
        await _firestore
            .collection('wallets')
            .doc(currentUserId)
            .collection('transactions')
            .add({
          'amount': -amount,
          'type': 'withdraw',
          'orderId': orderId,
          'status': 'success',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return success;
    } catch (e) {
      print('Error deducting balance: $e');
      return false;
    }
  }
}