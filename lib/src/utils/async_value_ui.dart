import 'package:adminnut4health/src/localization/string_hardcoded.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'alert_dialogs.dart';

extension AsyncValueUI on AsyncValue {

  void showAlertDialogOnError(BuildContext context) {
    debugPrint('isLoading: $isLoading, hasError: $hasError');
    if (!isLoading && hasError) {
      showExceptionAlertDialog(
        context: context,
        title: 'Error'.hardcoded,
        exception: 'Credenciales incorrectas'.hardcoded,
      );
    } else if (!isLoading && !hasError) {
      showExceptionAlertDialog(
        context: context,
        title: 'Email enviado'.hardcoded,
        exception: 'Se ha enviado un email al correo. Si no lo encuentras, por favor, '
            'revisa la carpeta de SPAM'.hardcoded,
      );
    }
  }


}
