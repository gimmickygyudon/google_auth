import 'package:flutter/material.dart';
import 'package:google_auth/functions/push.dart';

import '../functions/authentication.dart';
import '../functions/validate.dart';
import 'snackbar.dart';

class LoginsButton extends StatefulWidget {
  const LoginsButton({
    super.key,
    required this.logintype,
    required this.source,
    required this.usernameController,
    this.borderRadius
  });

  final String? logintype;
  final Map? source;
  final TextEditingController usernameController;
  final double? borderRadius;

  @override
  State<LoginsButton> createState() => _LoginsButtonState();
}

class _LoginsButtonState extends State<LoginsButton> {
  late bool loggingIn;

  @override
  void initState() {
    loggingIn = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.logintype != 'Google'
    ? GoogleSignInButton(
        borderRadius: widget.borderRadius,
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
      borderRadius: widget.borderRadius,
      onPressed: () {
        pushLogin(context, logintype: 'Email');
      },
    );
  }
}

class GoogleSignInButton extends StatefulWidget {
  const GoogleSignInButton({super.key, required this.onPressed, required this.isLoading, this.borderRadius});

  final Function onPressed;
  final bool isLoading;
  final double? borderRadius;

  @override
  State<GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> {

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: ButtonStyle(
        visualDensity: const VisualDensity(horizontal: 1, vertical: 1),
        side: MaterialStatePropertyAll(BorderSide(color: Theme.of(context).colorScheme.outlineVariant)),
        shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(widget.borderRadius ?? 40))),
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
              child: Text('Tunggu Sebentar...', style: Theme.of(context).textTheme.labelSmall),
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
    );
  }
}

class EmailSignInButton extends StatelessWidget {
  const EmailSignInButton({super.key, required this.onPressed, this.borderRadius});

  final Function onPressed;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () => onPressed(),
      style: ButtonStyle(
        side: MaterialStatePropertyAll(BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.5))),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 40),
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

class ButtonListTile extends StatelessWidget {
  const ButtonListTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.onTap, this.bgRadius, this.borderRadius, this.color, this.bgColor, this.dense, this.visualDensity
  });

  final Function() onTap;
  final Widget icon;
  final Widget? title, subtitle, trailing;
  final double? bgRadius;
  final BorderRadius? borderRadius;
  final Color? color, bgColor;
  final bool? dense;
  final VisualDensity? visualDensity;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: color ?? Theme.of(context).colorScheme.inversePrimary.withOpacity(0.25).withBlue(150),
      shape: RoundedRectangleBorder(borderRadius: borderRadius ?? BorderRadius.circular(50)),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        dense: dense ?? false,
        visualDensity: visualDensity,
        onTap: () => onTap(),
        leading: CircleAvatar(
          radius: bgRadius ?? 24,
          backgroundColor: bgColor ?? Theme.of(context).colorScheme.inversePrimary.withOpacity(0.75).withBlue(150),
          child: icon,
        ),
        title: title,
        titleTextStyle: Theme.of(context).textTheme.labelLarge,
        subtitle: subtitle,
        subtitleTextStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
          letterSpacing: 0
        ),
        trailing: trailing ?? Icon(Icons.arrow_forward, color: Theme.of(context).colorScheme.secondary),
      ),
    );
  }
}