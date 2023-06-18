import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_auth/widgets/button.dart';

import '../functions/validate.dart';
import '../styles/theme.dart';
import '../widgets/snackbar.dart';

class StartPageRoute extends StatefulWidget {
  const StartPageRoute({super.key});

  @override
  State<StartPageRoute> createState() => _StartPageRouteState();
}

class _StartPageRouteState extends State<StartPageRoute> {
  late bool loggingIn, isValidated;
  late TextEditingController _phonenumberController;

  final GlobalKey<LoginButtonState> loginButtonKeyFloat = GlobalKey();
  final GlobalKey<LoginButtonState> loginButtonKey = GlobalKey();

  late bool isLoading;

  @override
  void initState() {
    loggingIn = false;
    isValidated = false;
    isLoading = false;
    _phonenumberController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _phonenumberController.dispose();
    super.dispose();
  }

  void setLoading(bool value) => setState(() => isLoading = value);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle.dark,
      child: Theme(
        data: Theme.of(context).copyWith(
          appBarTheme: Themes.appBarTheme(context)
        ),
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            centerTitle: true,
            title: Image.asset('assets/Logo Indostar.png', height: 24),
            toolbarHeight: kToolbarHeight + 20,
            actions: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert))
            ],
          ),
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: Image(image: AssetImage('assets/welcome.png')),
                  ),
                  Text(
                    'Silahkan masuk dengan menggunakkan Nomor Handphone Anda.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                      letterSpacing: 0.2
                    )
                  ),
                  const SizedBox(height: 40),
                  Theme(
                    data: Theme.of(context).copyWith(inputDecorationTheme: Themes.inputDecorationThemeForm(context: context)),
                    child: StatefulBuilder(builder: (context, setState) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextField(
                            controller: _phonenumberController,
                            onChanged: (value) {
                              setState(() {
                                isValidated = Validate.validate(_phonenumberController.text.trim().isNotEmpty);
                              });
                              loginButtonKey.currentState?.refresh(isValidated);
                              loginButtonKeyFloat.currentState?.refresh(isValidated);
                            },
                            onSubmitted: isValidated || _phonenumberController.text.trim().isNotEmpty ? (value) {
                              FocusScope.of(context).unfocus();

                              setLoading(true);
                              Validate.checkUser(
                                context: context,
                                user: value,
                                logintype: 'Nomor'
                              ).onError((error, stackTrace) {
                                showSnackBar(context, snackBarError(context: context, content: error.toString()));
                                setLoading(false);

                                return Future.error(error.toString());
                              }).then((value) => setLoading(false));
                            }
                            : null,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.4),
                            inputFormatters: [ FilteringTextInputFormatter.digitsOnly ],
                            decoration: Styles.inputDecorationForm(
                              context: context,
                              placeholder: 'Nomor HP',
                              floatingLabelBehavior: FloatingLabelBehavior.always,
                              icon: const Icon(Icons.phone),
                              isPhone: true,
                              condition: _phonenumberController.text.trim().isNotEmpty
                            ),
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 12),
                          LoginButton(
                            key: loginButtonKey,
                            isLoading: isLoading,
                            setLoading: setLoading,
                            isVisible: true,
                            phonenumberController: _phonenumberController,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Row(
                              children: [
                                const Expanded(child: Divider(endIndent: 8)),
                                Text('Lanjutkan dengan',
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: Theme.of(context).colorScheme.outline,
                                    fontWeight: FontWeight.w400
                                  )
                                ),
                                const Expanded(child: Divider(indent: 8)),
                              ]
                            ),
                          ),
                          LoginsButton(
                            logintype: 'Nomor',
                            source: {'phone_number': _phonenumberController.text},
                            usernameController: _phonenumberController,
                          ),
                        ],
                      );
                    }),
                  ),
                ]
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LoginButton extends StatefulWidget {
  const LoginButton({
    super.key, required this.phonenumberController, required this.isVisible, required this.setLoading, required this.isLoading
  });

  final TextEditingController phonenumberController;
  final bool isVisible, isLoading;
  final Function setLoading;

  @override
  State<LoginButton> createState() => LoginButtonState();
}

class LoginButtonState extends State<LoginButton> {
  late bool isValidated;

  @override
  void initState() {
    isValidated = false;
    super.initState();
  }

  void refresh(validate) {
    setState(() {
      isValidated = validate;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: widget.isVisible,
      child: ElevatedButton(
        onPressed: isValidated && widget.isLoading == false ? () {
          widget.setLoading(true);

          Validate.checkUser(
            context: context,
            user: widget.phonenumberController.text,
            logintype: 'Nomor'
          ).onError((error, stackTrace) {
            showSnackBar(context, snackBarError(context: context, content: error.toString()));
            widget.setLoading(false);

            return Future.error(error.toString());
          }).then((value) => widget.setLoading(false));
        }
        : null,
        style: Styles.buttonForm(context: context, isLoading: widget.isLoading),
        child: widget.isLoading == true
          ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary, strokeWidth: 2)
                ),
                const SizedBox(width: 12),
                const Text('Mencoba Masuk...')
              ],
            )
          : const Text('Masuk')
      ),
    );
  }
}
