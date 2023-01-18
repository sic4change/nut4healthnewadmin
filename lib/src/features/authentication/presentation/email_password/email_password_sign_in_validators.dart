
import 'package:adminnut4health/src/features/authentication/presentation/email_password/string_validators.dart';
import 'package:adminnut4health/src/localization/string_hardcoded.dart';

import 'email_password_sign_in_form_type.dart';

/// Mixin class to be used for client-side email & password validation
mixin EmailAndPasswordValidators {
  final StringValidator emailSubmitValidator = EmailSubmitRegexValidator();
  final StringValidator passwordRegisterSubmitValidator =
      MinLengthStringValidator(6);
  final StringValidator passwordSignInSubmitValidator =
      NonEmptyStringValidator();

  bool canSubmitEmail(String email) {
    return emailSubmitValidator.isValid(email);
  }

  bool canSubmitPassword(
      String password, EmailPasswordSignInFormType formType) {
    if (formType == EmailPasswordSignInFormType.register) {
      return passwordRegisterSubmitValidator.isValid(password);
    }
    return passwordSignInSubmitValidator.isValid(password);
  }

  String? emailErrorText(String email) {
    final bool showErrorText = !canSubmitEmail(email);
    final String errorText = email.isEmpty
        ? 'El correo electrónico no puede estar vacío'.hardcoded
        : 'Correo electrónico no válido'.hardcoded;
    return showErrorText ? errorText : null;
  }

  String? passwordErrorText(
      String password, EmailPasswordSignInFormType formType) {
    final bool showErrorText = !canSubmitPassword(password, formType);
    final String errorText = password.isEmpty
        ? 'La contraseña no puede estar vacía'.hardcoded
        : 'Contraseña demasiado corta'.hardcoded;
    return showErrorText ? errorText : null;
  }
}
