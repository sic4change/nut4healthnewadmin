
import 'package:adminnut4health/src/localization/string_hardcoded.dart';

/// Form type for email & password authentication
enum EmailPasswordSignInFormType { signIn, register }

extension EmailPasswordSignInFormTypeX on EmailPasswordSignInFormType {
  String get passwordLabelText {
    if (this == EmailPasswordSignInFormType.register) {
      return 'Contraseña'.hardcoded;
    } else {
      return 'Contraseña'.hardcoded;
    }
  }

  // Getters
  String get primaryButtonText {
    if (this == EmailPasswordSignInFormType.register) {
      return 'Crear cuenta'.hardcoded;
    } else {
      return 'Acceder'.hardcoded;
    }
  }

  String get secondaryButtonText {
    if (this == EmailPasswordSignInFormType.register) {
      return '¿Ya tienes cuenta? Acceder'.hardcoded;
    } else {
      return '¿No tienes cuenta? Registrar'.hardcoded;
    }
  }

  EmailPasswordSignInFormType get secondaryActionFormType {
    if (this == EmailPasswordSignInFormType.register) {
      return EmailPasswordSignInFormType.signIn;
    } else {
      return EmailPasswordSignInFormType.register;
    }
  }

  String get errorAlertTitle {
    if (this == EmailPasswordSignInFormType.register) {
      return 'Error al crear cuenta'.hardcoded;
    } else {
      return 'Error a acceder'.hardcoded;
    }
  }

  String get title {
    if (this == EmailPasswordSignInFormType.register) {
      return 'Registrar'.hardcoded;
    } else {
      return 'Acceder'.hardcoded;
    }
  }
}
