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
  const RegisterRoute(
      {super.key, this.phonenumber, required this.logintype, this.source});

  final Map? source;
  final String? phonenumber;
  final String logintype;

  @override
  State<RegisterRoute> createState() => _RegisterRouteState();
}

class _RegisterRouteState extends State<RegisterRoute> {
  late TextEditingController _usernameController,
      _emailController,
      _phonenumberController,
      _passwordController,
      _repasswordController;
  late bool isValidated, visibility;

  bool loggingIn = false;
  bool _keyboardVisible = false;

  @override
  void initState() {
    isValidated = false;
    visibility = false;
    _usernameController =
        TextEditingController(text: widget.source?['user_name']);
    _emailController =
        TextEditingController(text: widget.source?['user_email']);
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
              _repasswordController.text == _passwordController.text);
    });
  }

  void registerUser() {
    UserRegister user = UserRegister(
        id_ousr: null,
        login_type: widget.logintype,
        user_email: _emailController.text,
        user_name: _usernameController.text,
        phone_number: _phonenumberController.text,
        user_password: _repasswordController.text);
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
  }

  @override
  Widget build(BuildContext context) {
    _keyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;
    return Scaffold(
        appBar: AppBar(
          title: Text('Daftar Akun',
              style: Theme.of(context).textTheme.titleMedium),
          shadowColor: Theme.of(context).colorScheme.shadow,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12))),
          surfaceTintColor: Colors.transparent,
          actions: const [
            Image(image: AssetImage('assets/logo IBM p C.png'), height: 25),
            SizedBox(width: 12)
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Theme(
                  data: Theme.of(context).copyWith(
                      inputDecorationTheme:
                          Themes.inputDecorationThemeForm(context: context)),
                  child: Form(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      children: [
                        StatefulBuilder(builder: (context, setState) {
                          return Column(
                            children: [
                              const SizedBox(height: 20),
                              if (widget.logintype != 'Google') ...[
                                TextField(
                                  controller: _usernameController,
                                  onChanged: (value) {
                                    validate();
                                  },
                                  autofocus: widget.logintype != 'Google'
                                      ? true
                                      : false,
                                  textInputAction: TextInputAction.next,
                                  decoration: Styles.inputDecorationForm(
                                      context: context,
                                      placeholder: 'Nama Lengkap',
                                      condition: _usernameController.text
                                          .trim()
                                          .isNotEmpty),
                                  keyboardType: TextInputType.name,
                                ),
                                const SizedBox(height: 20),
                                TextFormField(
                                  controller: _emailController,
                                  onChanged: (value) {
                                    validate();
                                  },
                                  validator: (value) => EmailValidator.validate(
                                          value!.trim())
                                      ? null
                                      : "● Pastikan anda memasukkan alamat email",
                                  textInputAction: TextInputAction.next,
                                  decoration: Styles.inputDecorationForm(
                                      context: context,
                                      placeholder: 'Alamat Email',
                                      icon: const Icon(Icons.mail_outline),
                                      condition: _emailController.text
                                          .trim()
                                          .isNotEmpty),
                                  keyboardType: TextInputType.emailAddress,
                                ),
                              ] else ...[
                                Stack(
                                  alignment: Alignment.bottomRight,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(2),
                                      child: CircleAvatar(
                                          backgroundImage: NetworkImage(
                                              widget.source?['photo_url']),
                                          radius: 32),
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(25.7)),
                                      child: const CircleAvatar(
                                        backgroundImage: NetworkImage(
                                            'https://upload.wikimedia.org/wikipedia/commons/thumb/5/53/Google_%22G%22_Logo.svg/2008px-Google_%22G%22_Logo.svg.png'),
                                        radius: 10,
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(widget.source?['user_name'],
                                    style:
                                        Theme.of(context).textTheme.bodyLarge),
                                Text(widget.source?['user_email'],
                                    style:
                                        Theme.of(context).textTheme.bodySmall),
                                const SizedBox(height: 30),
                              ],
                              const SizedBox(height: 20),
                              TextField(
                                controller: _phonenumberController,
                                onChanged: (value) {
                                  validate();
                                },
                                autofocus:
                                    widget.logintype == 'Google' ? true : false,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                textInputAction: TextInputAction.next,
                                decoration: Styles.inputDecorationForm(
                                    context: context,
                                    placeholder: 'No. Handphone',
                                    icon: const Icon(Icons.phone),
                                    condition: _phonenumberController.text
                                        .trim()
                                        .isNotEmpty),
                                keyboardType: TextInputType.phone,
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
                                  icon: const Icon(Icons.key),
                                  condition:
                                      _passwordController.text.isNotEmpty,
                                ),
                                keyboardType: TextInputType.visiblePassword,
                              ),
                              const SizedBox(height: 4),
                              FocusScope(
                                  canRequestFocus: false,
                                  child: CheckboxPassword(
                                      onChanged: (value) =>
                                          setState(() => visibility = value!),
                                      visibility: visibility)),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: _repasswordController,
                                onChanged: (value) {
                                  validate();
                                },
                                validator: (value) => value ==
                                        _passwordController.text
                                    ? null
                                    : '● Pastikan kata sandi yang anda masukan sama',
                                obscureText: true,
                                autocorrect: false,
                                enableSuggestions: false,
                                textInputAction: isValidated
                                    ? TextInputAction.send
                                    : TextInputAction.done,
                                decoration: Styles.inputDecorationForm(
                                    context: context,
                                    condition:
                                        _repasswordController.text.isNotEmpty,
                                    placeholder: 'Masukan Ulang Kata Sandi',
                                    visibility: visibility,
                                    visibilityDisabled: true),
                                keyboardType: TextInputType.visiblePassword,
                              ),
                              const SizedBox(height: 24),
                              ButtonRegister(
                                  isVisible: _keyboardVisible ? false : true,
                                  enable: isValidated,
                                  onPressed: () => registerUser()),
                              const SizedBox(height: 30)
                            ],
                          );
                        }),
                        Row(children: [
                          const Expanded(child: Divider(endIndent: 12)),
                          Text('Daftar dengan cara lain',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                      color:
                                          Theme.of(context).colorScheme.outline,
                                      fontWeight: FontWeight.w400)),
                          const Expanded(child: Divider(indent: 12)),
                        ]),
                        const SizedBox(height: 42),
                        widget.logintype != 'Google'
                            ? GoogleSignInButton(
                                isLoading: loggingIn,
                                onPressed: () async {
                                  hideSnackBar(context);
                                  setState(() => loggingIn = true);
                                  await Authentication.signInWithGoogle(
                                          context: context)
                                      .then((value) {
                                    if (value == null)
                                      setState(() => loggingIn = false);
                                  });
                                })
                            : EmailSignInButton()
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              child: ButtonRegister(
                  isVisible: _keyboardVisible,
                  enable: isValidated,
                  onPressed: () => registerUser()),
            )
          ],
        ));
  }
}

class ButtonRegister extends StatelessWidget {
  const ButtonRegister(
      {super.key,
      required this.isVisible,
      required this.enable,
      required this.onPressed});

  final bool isVisible;
  final bool enable;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: isVisible,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton(
              onPressed: enable ? () => onPressed() : null,
              style: Styles.buttonForm(context: context).copyWith(
                  visualDensity:
                      const VisualDensity(vertical: 1, horizontal: 2)),
              child: const Text('Daftar')),
        ],
      ),
    );
  }
}
