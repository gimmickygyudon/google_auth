import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/services.dart';
import 'package:google_auth/functions/sqlite.dart';
import 'package:google_auth/functions/validate.dart';
import 'package:google_auth/widgets/checkbox.dart';
import 'package:google_auth/widgets/dialog.dart';

import '../functions/google_signin.dart';
import '../functions/push.dart';
import '../styles/theme.dart';
import '../widgets/button.dart';
import '../widgets/snackbar.dart';

class RegisterRoute extends StatefulWidget {
  const RegisterRoute({super.key, this.phonenumber, required this.logintype_, this.source});

  final Map? source;
  final String? phonenumber;
  final String logintype_;

  @override
  State<RegisterRoute> createState() => _RegisterRouteState();
}

class _RegisterRouteState extends State<RegisterRoute> {
  late TextEditingController _usernameController, _emailController, 
  _phonenumberController, _passwordController, _repasswordController;
  late bool isValidated, visibility;

  bool loggingIn = false;

  @override
  void initState() {
    isValidated = false;
    visibility = false;
    _usernameController = TextEditingController(text: widget.source?['user_name']);
    _emailController = TextEditingController(text: widget.source?['user_email']);
    _phonenumberController = TextEditingController(text: widget.phonenumber);
    _passwordController = TextEditingController();
    _repasswordController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _phonenumberController.dispose();
    _passwordController.dispose();
    _repasswordController.dispose();
    super.dispose();
  }

  void validate() {
    setState(() {
      isValidated = InputForm.validate(
        _usernameController.text.trim().isNotEmpty && 
        _emailController.text.trim().isNotEmpty &&
        _phonenumberController.text.trim().isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _repasswordController.text.isNotEmpty &&
        EmailValidator.validate(_emailController.text) &&
        _repasswordController.text == _passwordController.text
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Akun', style: Theme.of(context).textTheme.titleMedium),
        shadowColor: Theme.of(context).colorScheme.shadow,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12)
          )
        ),
        surfaceTintColor: Colors.transparent,
        actions: const [ Image(image: AssetImage('assets/logo IBM p C.png'), height: 25), SizedBox(width: 12) ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Theme(
                data: Theme.of(context).copyWith(
                  inputDecorationTheme: Themes.inputDecorationThemeForm(context: context)
                ),
                child: Form(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    children: [
                      StatefulBuilder(
                        builder: (context, setState) {
                          return Column(
                            children: [
                              const SizedBox(height: 20),
                              TextField(
                                controller: _usernameController,
                                onChanged: (value) {
                                  validate();
                                },
                                autofocus: true,
                                textInputAction: TextInputAction.next,
                                decoration: Styles.inputDecorationForm(
                                  context: context, 
                                  placeholder: 'Nama Lengkap', 
                                  condition: _usernameController.text.trim().isNotEmpty
                                )
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: _emailController,
                                onChanged: (value) {
                                  validate();
                                },
                                validator: (value) => EmailValidator.validate(value!.trim()) ? null : "• Pastikan anda memasukkan alamat email @",
                                textInputAction: TextInputAction.next,
                                decoration: Styles.inputDecorationForm(
                                  context: context, 
                                  placeholder: 'Alamat Email',
                                  condition: _emailController.text.trim().isNotEmpty
                                ),
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: 20),
                              TextField(
                                controller: _phonenumberController,
                                onChanged: (value) {
                                  validate();
                                },
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                keyboardType: TextInputType.phone,
                                textInputAction: TextInputAction.next,
                                decoration: Styles.inputDecorationForm(
                                  context: context, 
                                  placeholder: 'No. Handphone', 
                                  condition: _phonenumberController.text.trim().isNotEmpty
                                )
                              ),
                              const SizedBox(height: 20),
                              TextField(
                                controller: _passwordController,
                                onChanged: (value) {
                                  validate();
                                },
                                obscureText: visibility ? false : true,
                                autocorrect: false,
                                enableSuggestions: false,
                                textInputAction: TextInputAction.next,
                                decoration: Styles.inputDecorationForm(
                                  context: context, 
                                  placeholder: 'Kata Sandi',
                                  condition: _passwordController.text.isNotEmpty,
                                  visibility: visibility
                                )
                              ),
                              const SizedBox(height: 4),
                              FocusScope(
                                canRequestFocus: false,
                                child: CheckboxPassword(
                                  onChanged: (value) => setState(() => visibility = value!), 
                                  visibility: visibility
                                )
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: _repasswordController,
                                onChanged: (value) {
                                  validate();
                                },
                                validator: (value) => value == _passwordController.text ? null : '• Pastikan kata sandi yang anda masukan sama',
                                obscureText: true,
                                autocorrect: false,
                                enableSuggestions: false,
                                textInputAction: isValidated ? TextInputAction.send : TextInputAction.done,
                                decoration: Styles.inputDecorationForm(
                                  context: context, 
                                  condition: _repasswordController.text.isNotEmpty, 
                                  placeholder: 'Masukan Ulang Kata Sandi',
                                  visibility: visibility,
                                  visibilityDisabled: true
                                )
                              ),
                              const SizedBox(height: 42),
                            ],
                          );
                        }
                      ), 
                      Row(
                        children: [
                          const Expanded(child: Divider(endIndent: 12)),
                          Text('Daftar dengan cara lain', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.outline, fontWeight: FontWeight.w400)),
                          const Expanded(child: Divider(indent: 12)),
                        ]
                      ),
                      const SizedBox(height: 42),
                      GoogleSignInButton(
                        isLoading: loggingIn,
                        onPressed: () async {
                          hideSnackBar(context);
                          setState(() => loggingIn = true);
                          await Authentication.signInWithGoogle(context: context).then((value) {
                            if (value == null) setState(() => loggingIn = false);
                          });
                        }
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            child: ElevatedButton(
              onPressed: isValidated ? () {
                UserRegister user = UserRegister(
                  id_ousr: null, 
                  login_type: widget.logintype_,
                  user_email: _emailController.text, 
                  user_name: _usernameController.text, 
                  phone_number: _phonenumberController.text, 
                  user_password: _repasswordController.text
                );
                UserRegister.retrieve(_emailController.text).then((value) {
                  if (value.isNotEmpty) { 
                    Map<String, dynamic> source = {
                      'user_email': value.last.user_email,
                      'user_name': value.last.user_name,
                      'phone_number': value.last.phone_number
                    };
                    showRegisteredUser(context, source, pushLogin, 'Email');
                  } else {
                    UserRegister.insert(user).then((user) {
                      pushLogin(context, user, 'Nomor');
                    });
                  }
                });
              } : null,
              style: Styles.buttonForm(context: context),
              child: const Text('Daftar')
            ),
          ),
        ],
      )
    );
  }
}
