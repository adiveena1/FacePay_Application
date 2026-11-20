import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import '../models/payment_transaction.dart';

/// Service managing cloud synchronization with Firebase Cloud Firestore.
/// Designed with offline-first resilience: if Firebase is not yet configured
/// or offline, operations fail gracefully without interrupting payments.
class FirebaseService {
  static bool _isInitialized = false;
  static bool get isInitialized => _isInitialized;

  /// Safely initialize Firebase with platform credentials
  static Future<bool> initialize() async {
    try {
      if (Firebase.apps.isNotEmpty) {
        _isInitialized = true;
        return true;
      }
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _isInitialized = true;
      return true;
    } catch (e) {
      // Graceful fallback if offline
      _isInitialized = false;
      return false;
    }
  }

  /// Synchronize a payment transaction to Cloud Firestore
  static Future<void> syncTransaction(PaymentTransaction transaction) async {
    if (!_isInitialized) return;
    try {
      final firestore = FirebaseFirestore.instance;
      await firestore.collection('transactions').doc(transaction.id).set({
        ...transaction.toJson(),
        'serverTimestamp': FieldValue.serverTimestamp(),
        'deviceInfo': 'FacePay Android Native Client',
      }, SetOptions(merge: true));
    } catch (e) {
      // Offline fallback: data is already safely stored in local SharedPreferences
    }
  }

  /// Synchronize digital balance to user profile in Cloud Firestore
  static Future<void> syncBalance(String userId, double balance) async {
    if (!_isInitialized) return;
    try {
      final firestore = FirebaseFirestore.instance;
      await firestore.collection('users').doc(userId).set({
        'userId': userId,
        'walletBalance': balance,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      // Offline fallback
    }
  }

  /// Stream live transactions from Cloud Firestore
  static Stream<List<PaymentTransaction>>? transactionStream() {
    if (!_isInitialized) return null;
    try {
      return FirebaseFirestore.instance
          .collection('transactions')
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => PaymentTransaction.fromJson(doc.data()))
              .toList());
    } catch (e) {
      return null;
    }
  }
}
