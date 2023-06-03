import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../functions/authentication.dart';
import '../functions/push.dart';
import '../functions/validate.dart';
import '../styles/theme.dart';
import '../widgets/button.dart';
import '../widgets/snackbar.dart';

class StartPageRoute extends StatefulWidget {
  const StartPageRoute({super.key});

  @override
  State<StartPageRoute> createState() => _StartPageRouteState();
}

class _StartPageRouteState extends State<StartPageRoute> {
  late bool loggingIn, isValidated;
  late TextEditingController _phonenumberController;

  @override
  void initState() {
    loggingIn = false;
    isValidated = false;
    _phonenumberController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _phonenumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
          scrolledUnderElevation: 0,
          shadowColor: Theme.of(context).colorScheme.shadow,
          surfaceTintColor: Colors.transparent,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12)
            )
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 48),
          child: Column(
            children: [
              const SizedBox(height: kToolbarHeight),
              const Image(image: AssetImage('assets/Logo Indostar.png')),
              const SizedBox(height: 12),
              Column(
                children: [
                  Text('Mulailah mengelola bisnis anda dengan aman dan cepat.',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).colorScheme.secondary
                    ),
                    textAlign: TextAlign.center
                  ),
                ],
              ),
              const SizedBox(height: 140),
              Theme(
                data: Theme.of(context).copyWith(inputDecorationTheme: Themes.inputDecorationThemeForm(context: context)),
                child: StatefulBuilder(builder: (context, setState) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Silakan masuk dengan menggunakkan nomor handphone Anda.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.secondary)
                        ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _phonenumberController,
                        onChanged: (value) {
                          setState(() {
                            isValidated = Validate.validate(_phonenumberController.text.trim().isNotEmpty);
                          });
                        },
                        onSubmitted: isValidated ? (value) {
                          Validate.checkUser(
                            context: context,
                            user: value,
                            logintype: 'Nomor'
                          );
                        }
                        : null,
                        inputFormatters: [ FilteringTextInputFormatter.digitsOnly ],
                        decoration: Styles.inputDecorationForm(
                          context: context,
                          placeholder: 'Nomor HP',
                          icon: const Icon(Icons.phone),
                          isPhone: true,
                          condition: _phonenumberController.text.trim().isNotEmpty
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: isValidated ? () {
                          Validate.checkUser(
                            context: context,
                            user: _phonenumberController.text,
                            logintype: 'Nomor'
                          );
                        }
                        : null,
                        style: Styles.buttonForm(context: context),
                        child: const Text('Masuk')
                      ),
                      const SizedBox(height: 16),
                      Text('Sudah mempunyai akun Customer Indostar?',
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center
                      ),
                      TextButton(
                        onPressed: () {
                          pushLogin(context);
                        },
                        child: Text('Klik Disini',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Theme.of(context).colorScheme.primary),
                          textAlign: TextAlign.center
                        )
                      )
                    ],
                  );
                }),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  const Expanded(child: Divider(endIndent: 8)),
                  Text('Lanjutkan dengan',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                    fontWeight: FontWeight.w400)
                  ),
                  const Expanded(child: Divider(indent: 8)),
                ]
              ),
              const SizedBox(height: 42),
              GoogleSignInButton(
                isLoading: loggingIn,
                onPressed: () async {
                  hideSnackBar(context);
                  setState(() => loggingIn = true);
                  await Authentication.signInWithGoogle().then((value) {
                    if (value == null) {
                      setState(() => loggingIn = false);
                    } else {
                      setState(() => loggingIn = false);
                      Map<String, dynamic> source = {
                        'user_email': value.email,
                        'user_name': value.displayName,
                        'photo_url': value.photoURL,
                      };
                      Validate.checkUser(
                        context: context,
                        user: value.email!,
                        logintype: 'Google',
                        source: source,
                      );
                    }
                  });
                }
              )
            ],
          ),
        ),
      ),
    );
  }
}
