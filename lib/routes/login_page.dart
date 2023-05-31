import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_auth/functions/validate.dart';

import '../functions/google_signin.dart';
import '../widgets/button.dart';
import '../widgets/snackbar.dart';

class LoginRoute extends StatefulWidget {
  const LoginRoute({super.key, this.source, this.from});

  final Map? source;
  final String? from;

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

    _usernameController = TextEditingController(
      text: widget.source?[widget.from == 'Email' ? 'user_email' : 'phone_number']
    );
    _passwordController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
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
        child: Column(
          children: [
            Column(
              children: [
                const Image(image: AssetImage('assets/Logo Indostar.png')),
                const SizedBox(height: 12),
                Text('Mulailah mengelola bisnis anda dengan aman dan cepat.', 
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w400, color: Theme.of(context).colorScheme.secondary), textAlign: TextAlign.center
                ),
              ],
            ),
            SizedBox(height: widget.source != null ? 40 : 60),
            if (widget.source != null) ...[
              Icon(Icons.account_circle, size: 48, color: Theme.of(context).colorScheme.secondary),
              const SizedBox(height: 4),
              Text(widget.source?['user_name'], style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 30),
            ],
            Theme(
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
              child: StatefulBuilder(
                builder: (context, setState) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _usernameController,
                        onChanged: (value) => setState(() {
                          isValidated = InputForm.validate(
                            _usernameController.text.trim().isNotEmpty && _passwordController.text.trim().isNotEmpty
                          );
                        }),
                        readOnly: widget.source == null ? false : true,
                        autofocus: widget.source == null ? true : false,
                        textInputAction: isValidated ? TextInputAction.done : TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: 'Email / No. HP',
                          enabledBorder: _usernameController.text.trim().isNotEmpty ? OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).colorScheme.primary.withOpacity(0.5), width: 1)) : null,
                          focusedBorder: _usernameController.text.trim().isNotEmpty ? OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)) : null
                        )
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _passwordController,
                        onChanged: (value) => setState(() {
                          isValidated = InputForm.validate(
                            _usernameController.text.trim().isNotEmpty && _passwordController.text.trim().isNotEmpty
                          );
                        }),
                        autofocus: widget.source == null ? false : true,
                        obscureText: visibility ? false : true,
                        autocorrect: false,
                        enableSuggestions: false,
                        decoration: InputDecoration(
                          labelText: 'Kata Sandi',
                          suffixIcon: Icon(visibility ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                          enabledBorder: _passwordController.text.trim().isNotEmpty ? OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).colorScheme.primary.withOpacity(0.5), width: 1)) : null,
                          focusedBorder: _passwordController.text.trim().isNotEmpty ? OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)) : null
                        ),
                      ),
                      const SizedBox(height: 4),
                      Theme(
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
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: isValidated == true && loggingIn == false ? () {} : null,
                        style: ButtonStyle(
                          elevation: MaterialStateProperty.resolveWith((states) {
                            if (states.contains(MaterialState.disabled)) return null;
                            return states.contains(MaterialState.pressed) ? 1 : 8;
                          }),
                          visualDensity: const VisualDensity(horizontal: 2, vertical: 2),
                          shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
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
                        child: const Text('Masuk')
                      )
                    ],
                  );
                }
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                const Expanded(child: Divider(endIndent: 8)),
                Text('Lanjutkan dengan', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.outline, fontWeight: FontWeight.w400)),
                const Expanded(child: Divider(indent: 8)),
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
    );
  }
}
