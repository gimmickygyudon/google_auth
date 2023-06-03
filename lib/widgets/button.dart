import 'package:flutter/material.dart';

import '../functions/authentication.dart';
import '../functions/validate.dart';
import 'snackbar.dart';

class LoginsButton extends StatefulWidget {
  const LoginsButton({
    super.key, 
    required this.logintype, 
    required this.loggingIn, 
    required this.source, 
    required this.usernameController
  });
  
  final String? logintype;
  final bool loggingIn;
  final Map? source;
  final TextEditingController usernameController;

  @override
  State<LoginsButton> createState() => _LoginsButtonState();
}

class _LoginsButtonState extends State<LoginsButton> {
  late bool loggingIn;

  @override
  void initState() {
    loggingIn = widget.loggingIn;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.logintype != 'Google'
    ? GoogleSignInButton(
        isLoading: widget.loggingIn,
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
              debugPrint(source.toString());
              Validate.checkUser(
                context: context,
                user: value.email!,
                logintype: 'Google',
                source: source
              );
            }
          });
        }
      )
    : EmailSignInButton(
      onPressed: () {
        Validate.checkUser(
          context: context, 
          logintype: 'Email', 
          user: widget.usernameController.text,
          source: widget.source,
          skipDialog: true
        );
      },
    );
  }
}

class GoogleSignInButton extends StatefulWidget {
  const GoogleSignInButton({super.key, required this.onPressed, required this.isLoading});

  final Function onPressed;
  final bool isLoading;

  @override
  State<GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> {

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Authentication.initializeFirebase(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Error initializing Firebase | Check your internet connectivity');
        } else if (snapshot.connectionState == ConnectionState.done) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: OutlinedButton(
              style: ButtonStyle(
                side: MaterialStatePropertyAll(BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.5))),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
              ),
              onPressed: () async {
                widget.onPressed();
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: widget.isLoading
                  ? <Widget>[
                    SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary, strokeWidth: 2)
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text('Signing in...', style: Theme.of(context).textTheme.labelSmall),
                    )
                  ] 
                  : <Widget>[
                    Image.network('https://upload.wikimedia.org/wikipedia/commons/thumb/5/53/Google_%22G%22_Logo.svg/2008px-Google_%22G%22_Logo.svg.png',
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text('Masuk dengan Google', style: Theme.of(context).textTheme.labelSmall),
                    )
                  ],
                ),
              ),
            ),
          );
        }
        return CircularProgressIndicator(color: Theme.of(context).colorScheme.primary);
      }
    );
  }
}

class EmailSignInButton extends StatelessWidget {
  const EmailSignInButton({super.key, required this.onPressed});

  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () => onPressed(),
      style: ButtonStyle(
        side: MaterialStatePropertyAll(BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.5))),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.email_outlined),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text('Masuk dengan Email', style: Theme.of(context).textTheme.labelSmall),
            )
          ]
        ),
      ),
    );
  }
}
