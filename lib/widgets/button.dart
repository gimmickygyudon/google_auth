import 'package:flutter/material.dart';

class GoogleSignInButton extends StatefulWidget {
  const GoogleSignInButton({super.key, required this.onPressed});

  final Function onPressed;

  @override
  State<GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> {
  bool _isSigningIn = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: _isSigningIn
      ? CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.background))
      : OutlinedButton(
          style: ButtonStyle(
            side: MaterialStatePropertyAll(BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.5))),
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
            ),
          ),
          onPressed: () async {
            setState(() {
              _isSigningIn = true;
            });
          
            widget.onPressed();

            setState(() {
              _isSigningIn = false;
            });
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.network('https://upload.wikimedia.org/wikipedia/commons/thumb/5/53/Google_%22G%22_Logo.svg/2008px-Google_%22G%22_Logo.svg.png',
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    'Masuk dengan Google',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.inverseSurface,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
    );
  }
}
