part of alert_dialogs;

Future<bool?> showValidationDialog({
  required BuildContext context,
  required void Function() onPressed,
}) async {
  if (kIsWeb || !Platform.isIOS) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("¿Validar datos?"),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text("Cancelar",),
          ),
          TextButton(
            onPressed: () {
              onPressed();
              Navigator.of(context).pop(true);
            },
            child: Text("Validar",),
          ),
        ],
      ),
    );
  }
  return showCupertinoDialog(
    context: context,
    builder: (context) => CupertinoAlertDialog(
      title: Text("¿Validar datos?"),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text("Cancelar",),
        ),
        TextButton(
          onPressed: () {
            onPressed();
            Navigator.of(context).pop(true);
          },
          child: Text("Validar",),
        ),
      ],
    ),
  );
}
