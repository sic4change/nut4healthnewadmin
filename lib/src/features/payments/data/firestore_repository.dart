import 'dart:async';

import 'package:adminnut4health/src/features/contracts/domain/contract.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../authentication/data/firebase_auth_repository.dart';
import '../../../common_data/firestore_data_source.dart';

import 'package:rxdart/rxdart.dart';

import '../../users/domain/user.dart';
import '../domain/PaymentWithScreenerAndContract.dart';
import '../domain/payment.dart';

String documentIdFromCurrentDate() {
  final iso = DateTime.now().toIso8601String();
  return iso.replaceAll(':', '-').replaceAll('.', '-');
}

class FirestorePath {
  static String payment(String uid) => 'payments/$uid';
  static String paymnts() => 'payments';
  static String contract(String uid) => 'contracts/$uid';
  static String contracts() => 'contracts';
  static String user(String uid) => 'users/$uid';
  static String users() => 'users';

}

class FirestoreRepository {
  const FirestoreRepository(this._dataSource);
  final FirestoreDataSource _dataSource;

  Future<void> setPayment({required Payment payment}) =>
      _dataSource.setData(
        path: FirestorePath.paymnts(),
        data: payment.toMap(),
      );

  Future<void> deletePayment({required Payment payment}) async {
    await _dataSource.deleteData(path: FirestorePath.payment(payment.paymentId));
  }

  Future<void> updatePayment({required Payment payment}) async {
    await _dataSource.updateData(path: FirestorePath.payment(payment.paymentId), data: payment.toMap());
  }

  Future<void> addPayment({required Payment payment}) async {
    await _dataSource.addData(path: FirestorePath.paymnts(), data: payment.toMap());
  }

  Stream<Payment> watchPayment({required PaymentID paymentId}) =>
      _dataSource.watchDocument(
        path: FirestorePath.payment(paymentId),
        builder: (data, documentId) => Payment.fromMap(data, documentId),
      );

  Stream<List<Payment>> watchPayments() {
    Stream<List<Payment>> payments = _dataSource.watchCollection(
      path: FirestorePath.paymnts(),
      builder: (data, documentId) => Payment.fromMap(data, documentId),
    );
    return payments;
  }

  Stream<List<User>> watchUsers() {
    Stream<List<User>> users =  _dataSource.watchCollection(
      path: FirestorePath.users(),
      builder: (data, documentId) => User.fromMap(data, documentId),
    );
    return users;
  }

  Stream<List<Contract>> watchContracts() {
    Stream<List<Contract>> contracts =  _dataSource.watchCollection(
      path: FirestorePath.contracts(),
      builder: (data, documentId) => Contract.fromMap(data, documentId),
    );
    return contracts;
  }

  Stream<List<PaymentWithScreener>> watchPaymentsWithScreenerAndContract() {
    const emptyUser = User(userId: '', name: '', email: '', role: '');
    /*const emptyContract = Contract(contractId: '', code: '', point: '', screenerId: '',
    medicalId: '', armCircunference: 0.0, armCircumferenceMedical: 0.0, weight: 0.0, height: 0.0,
    childName: '', childSurname: '', sex: '', childDNI: '', childTutor: '', childPhoneContract: '',
    childAddress: '', smsSent: false, duration: '0', percentage: 0);*/

    return CombineLatestStream.combine2(
        watchPayments(), watchUsers(),
          (List<Payment> payments, List<User> users) {
            return payments.map((payment) {
              final Map<String, User> userMap = Map.fromEntries(
                users.map((user) => MapEntry(user.userId, user)),
              );
              final screener = userMap[payment.screenerId] ?? emptyUser;
              return PaymentWithScreener(payment, screener);
            }).toList();
          });
  }

  Future<User> fetchUser({required UserID userId}) =>
      _dataSource.fetchDocument(
        path: FirestorePath.user(userId),
        builder: (data, documentId) => User.fromMap(data, documentId),
      );

  Future<List<User>> fetchUsers() =>
      _dataSource.fetchCollection(
        path: FirestorePath.users(),
        builder: (data, documentId) => User.fromMap(data, documentId),
      );
}

final databaseProvider = Provider<FirestoreRepository>((ref) {
  return FirestoreRepository(ref.watch(firestoreDataSourceProvider));
});

final paymentsStreamProvider = StreamProvider.autoDispose<List<PaymentWithScreener>>((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) {
    throw AssertionError('User can\'t be null');
  }
  final database = ref.watch(databaseProvider);
  return database.watchPaymentsWithScreenerAndContract();
});





