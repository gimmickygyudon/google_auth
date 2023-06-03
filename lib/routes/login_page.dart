import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_auth/functions/push.dart';
import 'package:google_auth/functions/validate.dart';
import 'package:google_auth/strings/user.dart';
import 'package:google_auth/styles/theme.dart';
import 'package:google_auth/widgets/checkbox.dart';
import 'package:google_auth/widgets/profile.dart';

import '../functions/authentication.dart';
import '../widgets/button.dart';
import '../widgets/snackbar.dart';

class LoginRoute extends StatefulWidget {
  const LoginRoute({super.key, this.source, this.logintype});

  final Map? source;
  final String? logintype;

  @override
  State<LoginRoute> createState() => _LoginRouteState();
}

class _LoginRouteState extends State<LoginRoute> {
  late bool loggingIn, visibility, isValidated;
  late TextEditingController _usernameController, _passwordController;

  @override
  void initState() {
    loggingIn = false;
    visibility = false;
    isValidated = false;

    String? username = widget.source?['phone_number'];
    username ??= widget.source?['user_email'];

    _usernameController = TextEditingController(text: username);
    _passwordController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  void login(BuildContext context) {
    String logintype() => RegExp(r'^[0-9]+$').hasMatch(_usernameController.text) ? 'Nomor' : 'Email';
    Validate.checkUser(
      context: context, 
      logintype: widget.logintype == null ? logintype() : widget.logintype!,
      login: true,
      user: _usernameController.text,
      password: _passwordController.text
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
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
        child: Form(
          child: Column(
            children: [
              Column(
                children: [
                  const Image(image: AssetImage('assets/Logo Indostar.png')),
                  const SizedBox(height: 12),
                  Text('Mulailah mengelola bisnis anda dengan aman dan cepat.',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).colorScheme.secondary
                    ),
                    textAlign: TextAlign.center
                  ),
                ],
              ),
              SizedBox(height: widget.source != null ? 40 : 60),
              if (widget.source != null) ...[
                UserProfile(source: widget.source),
                const SizedBox(height: 30),
              ],
              Theme(
                data: Theme.of(context).copyWith(inputDecorationTheme: Themes.inputDecorationThemeForm(context: context)),
                child: StatefulBuilder(builder: (context, setState) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _usernameController,
                        onChanged: (value) => setState(() {
                          isValidated = Validate.validate(
                            _usernameController.text.trim().isNotEmpty &&
                            _passwordController.text.trim().isNotEmpty
                          );
                        }),
                        readOnly: widget.source == null ? false : true,
                        textInputAction: isValidated
                          ? TextInputAction.done
                          : TextInputAction.next,
                        decoration: Styles.inputDecorationForm(
                          context: context,
                          placeholder: 'Email / No. HP',
                          icon: const Icon(Icons.person),
                          condition: _usernameController.text.trim().isNotEmpty
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _passwordController,
                        onChanged: (value) => setState(() {
                          isValidated = Validate.validate(
                            _usernameController.text.trim().isNotEmpty &&
                            _passwordController.text.trim().isNotEmpty
                          );
                        }),
                        onSubmitted: (value) => login(context),
                        autofocus: widget.source == null ? false : true,
                        obscureText: visibility ? false : true,
                        autocorrect: false,
                        enableSuggestions: false,
                        decoration: Styles.inputDecorationForm(
                          context: context,
                          placeholder: 'Kata Sandi',
                          icon: const Icon(Icons.key),
                          condition: _usernameController.text.trim().isNotEmpty,
                          visibility: visibility
                        ),
                        keyboardType: TextInputType.visiblePassword,
                      ),
                      const SizedBox(height: 4),
                      CheckboxPassword(
                        onChanged: (value) => setState(() => visibility = value!),
                        visibility: visibility
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () => pushStart(context),
                            child: const Text('Kembali')
                          ),
                          ElevatedButton(
                            onPressed: isValidated == true && loggingIn == false
                              ? () => login(context)
                              : null,
                            style: Styles.buttonForm(context: context),
                            child: const Text('Masuk')
                          ),
                        ],
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
                      fontWeight: FontWeight.w400
                    )
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
                    if (value == null) setState(() => loggingIn = false);
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
