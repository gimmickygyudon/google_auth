import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/services.dart';
import 'package:google_auth/functions/sqlite.dart';
import 'package:google_auth/functions/validate.dart';
import 'package:google_auth/widgets/dialog.dart';

import '../functions/google_signin.dart';
import '../functions/push.dart';
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
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
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
        title: const Text('Daftar Akun'),
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
                  inputDecorationTheme: InputDecorationTheme(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)),
                    filled: true,
                    fillColor: Theme.of(context).hoverColor,
                    labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0, color: Theme.of(context).colorScheme.secondary),
                    floatingLabelStyle: TextStyle(fontWeight: FontWeight.w500, letterSpacing: 0, color: Theme.of(context).colorScheme.primary)
                  )
                ),
                child: Form(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      TextField(
                        controller: _usernameController,
                        onChanged: (value) {
                          validate();
                        },
                        autofocus: true,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: 'Nama Lengkap',
                          enabledBorder: _usernameController.text.trim().isNotEmpty ? OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).colorScheme.primary.withOpacity(0.5), width: 1)) : null,
                          focusedBorder: _usernameController.text.trim().isNotEmpty ? OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)) : null,
                          border: _usernameController.text.trim().isNotEmpty ? OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)) : null
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
                        decoration: InputDecoration(
                          labelText: 'Email',
                          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).colorScheme.error, width: 2)),
                          focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).colorScheme.error, width: 2)),
                          enabledBorder: _emailController.text.trim().isNotEmpty ? OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).colorScheme.primary.withOpacity(0.5), width: 1)) : null,
                          focusedBorder: _emailController.text.trim().isNotEmpty ? OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)) : null,
                          border: _emailController.text.trim().isNotEmpty ? OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)) : null
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
                        decoration: InputDecoration(
                          labelText: 'No. Handphone',
                          enabledBorder: _phonenumberController.text.trim().isNotEmpty ? OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).colorScheme.primary.withOpacity(0.5), width: 1)) : null,
                          focusedBorder: _phonenumberController.text.trim().isNotEmpty ? OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)) : null,
                          border: _phonenumberController.text.trim().isNotEmpty ? OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)) : null
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
                        decoration: InputDecoration(
                          labelText: 'Kata Sandi',
                          suffixIcon: Icon(visibility ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                          enabledBorder: _passwordController.text.trim().isNotEmpty ? OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).colorScheme.primary.withOpacity(0.5), width: 1)) : null,
                          focusedBorder: _passwordController.text.trim().isNotEmpty ? OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)) : null,
                          border: _passwordController.text.trim().isNotEmpty ? OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)) : null
                        )
                      ),
                      const SizedBox(height: 4),
                      FocusScope(
                        canRequestFocus: false,
                        child: Theme(
                          data: Theme.of(context).copyWith(splashFactory: NoSplash.splashFactory),
                          child: CheckboxListTile(
                            onChanged: (value) => setState(() => visibility = value!),
                            value: visibility, 
                            contentPadding: EdgeInsets.zero,
                            visualDensity: const VisualDensity(vertical: -4, horizontal: -4),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            title: Text('Tampilkan Sandi', style: Theme.of(context).textTheme.bodySmall?.copyWith(letterSpacing: 0)),
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                        ),
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
                        textInputAction: isValidated ? TextInputAction.done : TextInputAction.none,
                        decoration: InputDecoration(
                          labelText: 'Masukan Ulang Kata Sandi',
                          suffixIcon: const Icon(Icons.visibility_outlined),
                          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).colorScheme.error, width: 2)),
                          focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).colorScheme.error, width: 2)),
                          enabledBorder: _repasswordController.text.trim().isNotEmpty ? OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).colorScheme.primary.withOpacity(0.5), width: 1)) : null,
                          focusedBorder: _repasswordController.text.trim().isNotEmpty ? OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)) : null,
                          border: _repasswordController.text.trim().isNotEmpty ? OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)) : null
                        )
                      ),
                      const SizedBox(height: 42),
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
              style: ButtonStyle(
                elevation: MaterialStateProperty.resolveWith((states) {
                  if (states.contains(MaterialState.disabled)) return null;
                  return states.contains(MaterialState.pressed) ? 1 : 8;
                }),
                shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                backgroundColor: MaterialStateProperty.resolveWith((states) {
                  return states.contains(MaterialState.disabled) ? null : Theme.of(context).colorScheme.primary;
                }),
                foregroundColor: MaterialStateProperty.resolveWith((states) {
                  return states.contains(MaterialState.disabled) ? null : Theme.of(context).colorScheme.surface;
                }),
                overlayColor: MaterialStateProperty.resolveWith((states) {
                  return states.contains(MaterialState.disabled) ? null : Theme.of(context).colorScheme.inversePrimary;
                }),
              ),
              child: const Text('Daftar')
            ),
          ),
        ],
      )
    );
  }
}