import 'package:flutter/material.dart';

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
}
