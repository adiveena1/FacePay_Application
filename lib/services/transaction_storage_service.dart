import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../models/payment_transaction.dart';
import '../models/merchant.dart';
import '../models/verification_result.dart';
import 'firebase_service.dart';

class TransactionStorageService {
  static SharedPreferences? _prefs;

  static Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Load current wallet balance
  static Future<double> getBalance() async {
    final prefs = await _getPrefs();
    return prefs.getDouble(AppConstants.prefKeyBalance) ?? AppConstants.defaultInitialBalance;
  }

  /// Update wallet balance
  static Future<void> updateBalance(double newBalance) async {
    final prefs = await _getPrefs();
    await prefs.setDouble(AppConstants.prefKeyBalance, newBalance);
    // Sync balance to Cloud Firestore
    await FirebaseService.syncBalance('user_aditya', newBalance);
  }

  /// Deduct balance upon successful payment
  static Future<bool> deductBalance(double amount) async {
    final current = await getBalance();
    if (current >= amount) {
      await updateBalance(current - amount);
      return true;
    }
    return false;
  }

  /// Load all transactions (returns reverse chronological order)
  static Future<List<PaymentTransaction>> getTransactions() async {
    final prefs = await _getPrefs();
    final rawJson = prefs.getString(AppConstants.prefKeyTransactions);
    if (rawJson == null || rawJson.isEmpty) {
      // Return sample demo data if completely fresh
      return _getSeedTransactions();
    }
    try {
      final List<dynamic> list = jsonDecode(rawJson);
      final transactions = list.map((e) => PaymentTransaction.fromJson(e as Map<String, dynamic>)).toList();
      // Ensure sorted newest first
      transactions.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return transactions;
    } catch (e) {
      return [];
    }
  }

  /// Save a new transaction
  static Future<void> saveTransaction(PaymentTransaction transaction) async {
    final prefs = await _getPrefs();
    final list = await getTransactions();
    // Prepend new transaction
    list.insert(0, transaction);
    final rawJson = jsonEncode(list.map((e) => e.toJson()).toList());
    await prefs.setString(AppConstants.prefKeyTransactions, rawJson);

    // Sync transaction to Cloud Firestore in real time
    await FirebaseService.syncTransaction(transaction);
  }

  /// Clear all transaction history
  static Future<void> clearHistory() async {
    final prefs = await _getPrefs();
    await prefs.remove(AppConstants.prefKeyTransactions);
  }

  /// Reset all local demo data
  static Future<void> resetDemoData() async {
    final prefs = await _getPrefs();
    await prefs.remove(AppConstants.prefKeyTransactions);
    await prefs.remove(AppConstants.prefKeyBalance);
    await prefs.remove(AppConstants.prefKeyRewards);
  }

  static List<PaymentTransaction> _getSeedTransactions() {
    final now = DateTime.now();
    return [
      PaymentTransaction(
        id: 'FP-DEMO-001',
        merchant: const Merchant(
          id: 'M-101',
          name: 'Campus Cafeteria',
          upiId: 'cafeteria@campusupi',
          category: 'Dining',
        ),
        amount: 150.00,
        timestamp: now.subtract(const Duration(hours: 3)),
        status: PaymentStatus.success,
        verificationRequired: false,
        verificationResult: VerificationResult(
          status: VerificationStatus.notRequired,
          message: 'Standard checkout without face verification (<= ₹500)',
          timestamp: now.subtract(const Duration(hours: 3)),
        ),
      ),
      PaymentTransaction(
        id: 'FP-DEMO-002',
        merchant: const Merchant(
          id: 'M-102',
          name: 'Tech World Electronics',
          upiId: 'techworld@icici',
          category: 'Electronics',
        ),
        amount: 1250.00,
        timestamp: now.subtract(const Duration(days: 1)),
        status: PaymentStatus.success,
        verificationRequired: true,
        verificationResult: VerificationResult(
          status: VerificationStatus.passed,
          message: 'Face liveness verified (Blink + Turn Left)',
          blinkPassed: true,
          headTurnPassed: true,
          timestamp: now.subtract(const Duration(days: 1)),
        ),
      ),
    ];
  }
}
