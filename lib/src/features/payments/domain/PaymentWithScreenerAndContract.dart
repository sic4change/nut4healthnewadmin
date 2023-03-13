import 'package:adminnut4health/src/features/payments/domain/payment.dart';
import 'package:adminnut4health/src/features/users/domain/user.dart';


class PaymentWithScreener {
  final Payment payment;
  final User screener;

  PaymentWithScreener(this.payment, this.screener);
}