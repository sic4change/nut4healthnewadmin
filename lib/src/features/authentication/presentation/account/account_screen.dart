
import 'package:adminnut4health/src/utils/async_value_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../common_widgets/avatar.dart';
import '../../../../routing/app_router.dart';
import '../../../../sample/model/model.dart';
import '../../../../utils/alert_dialogs.dart';
import '../../data/firebase_auth_repository.dart';
import '../../data/firestore_repository.dart';
import 'account_screen_controller.dart';

/// Translate names
late String _logout, _goBack, _areSure, _cancel, _changePassword;

void initText() {
  late SampleModel model = SampleModel.instance;
  final selectedLocale = model.locale.toString();
  switch (selectedLocale) {
    case 'en_US':
      _logout = 'Logout';
      _goBack = 'Go Back';
      _areSure = 'Are you sure?';
      _cancel = 'Cancel';
      _changePassword = "Change password";
      break;
    case 'es_ES':
      _logout = 'Salir';
      _goBack = 'Volver';
      _areSure = '¿Estás seguro?';
      _cancel = 'Cancelar';
      _changePassword = "Cambiar contraseña";
      break;
    case 'fr_FR':
      _logout = 'Sortir';
      _goBack = 'Revenir';
      _areSure = 'Êtes-vous sûr?';
      _cancel = 'Annuler';
      _changePassword = "Changer de mot de passe";
      break;
  }
}

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    initText();
    ref.listen<AsyncValue>(
      accountScreenControllerProvider,
      (_, state) => state.showAlertDialogOnError(context),
    );
    final state = ref.watch(accountScreenControllerProvider);
    final user = ref.watch(authRepositoryProvider).currentUser;
    final userDatabase = ref.watch(userDatabaseStreamProvider(user!.uid));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(0, 116, 227, 1),
        title: state.isLoading
            ? const CircularProgressIndicator()
            : Text(""),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(130.0),
          child: Column(
            children: [
              if (user != null && userDatabase != null) ...[
                Avatar(
                  photoUrl: userDatabase.value?.photo,
                  radius: 50,
                  borderColor: Colors.black54,
                  borderWidth: 2.0,
                ),
                const SizedBox(height: 8),
                if (user.displayName != null)
                  Text(
                    user.displayName!,
                    style: const TextStyle(color: Colors.white),
                  ),
                const SizedBox(height: 8),
              ],
            ],
          ),
        ),
      ),
      body: SizedBox(
          height: 250,
          child: Column(
            children: <Widget>[
              Align(
                  alignment: FractionalOffset.bottomCenter,
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    height: 40,
                    width: 200,
                    child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                             Colors.blue),
                        ),
                        onPressed: () => {
                          context.goNamed(AppRoute.main.name)
                        },
                        child: Text(_goBack,
                            style: const TextStyle(
                                fontFamily: 'HeeboMedium',
                                color: Colors.white))),
                  )),
              Align(
                  alignment: FractionalOffset.bottomCenter,
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    height: 40,
                    width: 200,
                    child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.blue),
                        ),
                        onPressed: () {
                          _forgotPassword(context, ref, userDatabase.value!.email);
                        },
                        child: Text(_changePassword,
                            style: const TextStyle(
                                fontFamily: 'HeeboMedium',
                                color: Colors.white))),
                  )),
              Align(
                  alignment: FractionalOffset.bottomCenter,
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    height: 40,
                    width: 200,
                    child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.blue),
                        ),
                        onPressed: state.isLoading
                            ? null
                            : () async {
                          final logout = await showAlertDialog(
                            context: context,
                            title: _areSure,
                            cancelActionText: _cancel,
                            defaultActionText: _logout,
                          );
                          if (logout == true) {
                            ref
                                .read(accountScreenControllerProvider.notifier)
                                .signOut();
                          }
                        },
                        child: Text(_logout,
                            style: const TextStyle(
                                fontFamily: 'HeeboMedium',
                                color: Colors.white))),
                  )),
            ],
          )),
    );
  }

  Future<void> _forgotPassword(BuildContext context, WidgetRef ref, String email) async {
    final controller = ref.read(accountScreenControllerProvider.notifier);
    await controller.forgotPassword(email: email);
  }
}
