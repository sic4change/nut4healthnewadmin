import 'package:adminnut4health/src/features/authentication/presentation/email_password/string_validators.dart';
import 'package:adminnut4health/src/localization/string_hardcoded.dart';
import 'package:adminnut4health/src/utils/async_value_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../common_widgets/custom_text_button.dart';
import '../../../../common_widgets/primary_button.dart';
import '../../../../common_widgets/responsive_scrollable_card.dart';
import '../../../../constants/app_sizes.dart';
import '../../../../sample/model/helper.dart';
import '../../../../sample/model/model.dart';
import '../../../../utils/alert_dialogs.dart';
import '../../data/firebase_auth_repository.dart';
import 'email_password_sign_in_controller.dart';
import 'email_password_sign_in_form_type.dart';
import 'email_password_sign_in_validators.dart';


/// Email & password sign in screen.
/// Wraps the [EmailPasswordSignInContents] widget below with a [Scaffold] and
/// [AppBar] with a title.
class EmailPasswordSignInScreen extends StatelessWidget {
  const EmailPasswordSignInScreen({super.key, required this.formType});
  final EmailPasswordSignInFormType formType;

  // * Keys for testing using find.byKey()
  static const emailKey = Key('email');
  static const passwordKey = Key('password');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: getFooter(context),
      body: EmailPasswordSignInContents(
        formType: formType,
      ),
    );
  }
}

/// A widget for email & password authentication, supporting the following:
/// - sign in
/// - register (create an account)
class EmailPasswordSignInContents extends ConsumerStatefulWidget {
  const EmailPasswordSignInContents({
    super.key,
    required this.formType,
  });

  /// The default form type to use.
  final EmailPasswordSignInFormType formType;
  @override
  ConsumerState<EmailPasswordSignInContents> createState() =>
      _EmailPasswordSignInContentsState();
}

class _EmailPasswordSignInContentsState
    extends ConsumerState<EmailPasswordSignInContents>
    with EmailAndPasswordValidators {
  final _formKey = GlobalKey<FormState>();
  final _node = FocusScopeNode();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String get email => _emailController.text;
  String get password => _passwordController.text;

  var _submitted = false;
  // track the formType as a local state variable
  late var _formType = widget.formType;

  @override
  void dispose() {
    // * TextEditingControllers should be always disposed
    _node.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _submitted = true);
    // only submit the form if validation passes
    if (_formKey.currentState!.validate()) {
      final controller =
          ref.read(emailPasswordSignInControllerProvider.notifier);
      await controller.submit(
        email: email,
        password: password,
        formType: _formType,
      );
    }
  }

  void _emailEditingComplete() {
    if (canSubmitEmail(email)) {
      _node.nextFocus();
    }
  }

  void _passwordEditingComplete() {
    if (!canSubmitEmail(email)) {
      _node.previousFocus();
      return;
    }
    _submit();
  }

  Future<void> _forgotPassword() async {
    if (!canSubmitEmail(email)) {
      showExceptionAlertDialog(
        context: context,
        title: 'Error'.hardcoded,
        exception: 'Correo electrónico no válido'.hardcoded,
      );
    } else {
      final controller = ref.read(emailPasswordSignInControllerProvider.notifier);
      await controller.forgotPassword(email: email);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue>(
      emailPasswordSignInControllerProvider,
      (_, state) => state.showAlertDialogOnError(context),
    );
    final state = ref.watch(emailPasswordSignInControllerProvider);
    final user = ref.watch(authRepositoryProvider).currentUser;

    if (user != null && user.metadata != null && user.metadata!.lastSignInTime != null) {
      final claims = user.getIdTokenResult();
      claims.then((value) => {
        if (value.claims != null && value.claims!['servicio-salud'] == true) {
          ref.watch(authRepositoryProvider).signOut()
        } else if (value.claims != null && value.claims!['agente-salud'] == true) {
          ref.watch(authRepositoryProvider).signOut()
        }
      });
    }

    return Center(
      child: ResponsiveScrollableCard(
        child: FocusScope(
          node: _node,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      gapH8,
                      Image.asset("assets/logo.png",
                          width: 150,
                          height: 150,
                      ),
                      gapH8,
                      gapH8,
                      // Email field
                      TextFormField(
                        key: EmailPasswordSignInScreen.emailKey,
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Correo electrónico'.hardcoded,
                          hintText: 'admin@nut4health.org'.hardcoded,
                          enabled: !state.isLoading,
                        ),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (email) =>
                            !_submitted ? null : emailErrorText(email ?? ''),
                        autocorrect: false,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.emailAddress,
                        keyboardAppearance: Brightness.light,
                        onEditingComplete: () => _emailEditingComplete(),
                        inputFormatters: <TextInputFormatter>[
                          ValidatorInputFormatter(
                              editingValidator: EmailEditingRegexValidator()),
                        ],
                      ),
                      gapH8,
                      // Password field
                      TextFormField(
                        key: EmailPasswordSignInScreen.passwordKey,
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: _formType.passwordLabelText,
                          enabled: !state.isLoading,
                        ),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (password) => !_submitted
                            ? null
                            : passwordErrorText(password ?? '', _formType),
                        obscureText: true,
                        autocorrect: false,
                        textInputAction: TextInputAction.done,
                        keyboardAppearance: Brightness.light,
                        onEditingComplete: () => _passwordEditingComplete(),
                      ),
                      gapH8,
                      PrimaryButton(
                        text: _formType.primaryButtonText,
                        isLoading: state.isLoading,
                        onPressed: state.isLoading ? null : () => _submit(),
                      ),
                    ],
                  ),
                ),
                gapH8,
                CustomTextButton(
                  text: _formType.secondaryButtonText,
                  onPressed: state.isLoading ? null : _forgotPassword,
                ),
              ]),
        ),
      ),
    );
  }
}

Widget getFooter(BuildContext context) {
  return Container(
    height: 60,
    decoration: BoxDecoration(
      border: Border(
        top: BorderSide(width: 0.8, color:Colors.grey.withOpacity(0.7)),
      ),
      color: const Color.fromRGBO(234, 234, 234, 1),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
                padding: const EdgeInsets.only(top: 10),
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text('Copyright © 2023 SIC4Change.',
                      style: TextStyle(
                          color: Colors.grey.withOpacity(0.7),
                          fontSize: 12,
                          letterSpacing: 0.23)),
                ))
          ],
        ),
        InkWell(
          onTap: () => launchUrl(Uri.parse('https://www.sic4change.org')),
          child: Image.asset( 'images/sic.png',
              fit: BoxFit.contain,
              height: 25,
              width:  120),
        ),
      ],
    ),
  );
}

