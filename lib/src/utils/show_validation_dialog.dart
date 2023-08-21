part of alert_dialogs;

Future<bool?> showValidationDialog({
  required BuildContext context,
  required String selectedLocale,
  required void Function() onPressed,
}) async {

  String validateData = "", confirm = "", cancel = "";

  switch (selectedLocale) {
    case 'en_US':
      validateData = 'Validate data?';
      confirm = 'Validate';
      cancel = 'Cancel';
      break;
    case 'es_ES':
      validateData = '¿Validar datos?';
      confirm = 'Validar';
      cancel = 'Cancelar';
      break;
    case 'fr_FR':
      validateData = 'Valider les données?';
      confirm = 'Valider';
      cancel = 'Annuler';
      break;
  }

  if (kIsWeb || !Platform.isIOS) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(validateData),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancel,),
          ),
          TextButton(
            onPressed: () {
              onPressed();
              Navigator.of(context).pop(true);
            },
            child: Text(confirm,),
          ),
        ],
      ),
    );
  }
  return showCupertinoDialog(
    context: context,
    builder: (context) => CupertinoAlertDialog(
      title: Text(validateData),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancel,),
        ),
        TextButton(
          onPressed: () {
            onPressed();
            Navigator.of(context).pop(true);
          },
          child: Text(confirm,),
        ),
      ],
    ),
  );
}
