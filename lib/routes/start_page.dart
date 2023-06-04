import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_auth/widgets/button.dart';

import '../functions/push.dart';
import '../functions/validate.dart';
import '../styles/theme.dart';

class StartPageRoute extends StatefulWidget {
  const StartPageRoute({super.key});

  @override
  State<StartPageRoute> createState() => _StartPageRouteState();
}

class _StartPageRouteState extends State<StartPageRoute> {
  late bool loggingIn, isValidated;
  late TextEditingController _phonenumberController;

  final GlobalKey<LoginButtonState> loginButtonKeyFloat = GlobalKey();
  final GlobalKey<LoginButtonState> loginButtonKey = GlobalKey();
  bool _keyboardVisible = false;

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
    _keyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;
    return AnnotatedRegion(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
          scrolledUnderElevation: 8,
          shadowColor: Theme.of(context).colorScheme.shadow,
          surfaceTintColor: Theme.of(context).colorScheme.inversePrimary,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12)
            )
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height - kToolbarHeight,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        flex: 3, 
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: kToolbarHeight),
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
                      ),
                      Expanded(flex: 4, child: Image.asset('assets/bricklayer_3 @vector4stock.png', fit: BoxFit.cover)),
                      Flexible(
                        flex: 6,
                        child: Theme(
                          data: Theme.of(context).copyWith(inputDecorationTheme: Themes.inputDecorationThemeForm(context: context)),
                          child: StatefulBuilder(builder: (context, setState) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const SizedBox(height: 20),
                                Text(
                                  'Silakan masuk dengan menggunakkan nomor handphone Anda.',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: Theme.of(context).colorScheme.secondary,
                                    letterSpacing: 0.2
                                  )
                                ),
                                const SizedBox(height: 20),
                                TextField(
                                  controller: _phonenumberController,
                                  onChanged: (value) {
                                    isValidated = Validate.validate(_phonenumberController.text.trim().isNotEmpty);
                                    loginButtonKey.currentState?.refresh(isValidated);
                                    loginButtonKeyFloat.currentState?.refresh(isValidated);
                                  },
                                  onSubmitted: isValidated ? (value) {
                                    FocusScope.of(context).unfocus();
                                    Validate.checkUser(
                                      context: context,
                                      user: value,
                                      logintype: 'Nomor'
                                    );
                                  }
                                  : null,
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.4),
                                  inputFormatters: [ FilteringTextInputFormatter.digitsOnly ],
                                  decoration: Styles.inputDecorationForm(
                                    context: context,
                                    placeholder: 'Masukan Nomor HP',
                                    icon: const Icon(Icons.phone),
                                    isPhone: true,
                                    condition: _phonenumberController.text.trim().isNotEmpty
                                  ),
                                  keyboardType: TextInputType.phone,
                                ),
                                const SizedBox(height: 12),
                                LoginButton(
                                  key: loginButtonKey,
                                  isVisible: _keyboardVisible ? false : true,
                                  phonenumberController: _phonenumberController, 
                                ),
                                const SizedBox(height: 4),
                                LoginsButton(
                                  logintype: 'Nomor', 
                                  source: {'phone_number': _phonenumberController.text}, 
                                  usernameController: _phonenumberController,
                                  borderRadius: 8,
                                ),
                                Column(
                                  children: [
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
                                    ),
                                  ]
                                )
                              ],
                            );
                          }),
                        ),
                      ),
                    ]
                  ),
                ),
              ),
            ),
            Themes.bottomFloatingBar(
              context: context,
              isVisible: _keyboardVisible,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: LoginButton(
                  key: loginButtonKeyFloat,
                  isVisible: _keyboardVisible,
                  phonenumberController: _phonenumberController, 
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class LoginButton extends StatefulWidget {
  const LoginButton({super.key, required this.phonenumberController, required this.isVisible});

  final TextEditingController phonenumberController;
  final bool isVisible;

  @override
  State<LoginButton> createState() => LoginButtonState();
}

class LoginButtonState extends State<LoginButton> {
  bool isValidated = false;

  void refresh(validate) {
    setState(() {
      isValidated = validate;     
    });
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: widget.isVisible,
      child: ElevatedButton(
        onPressed: isValidated ? () {
          FocusScope.of(context).unfocus();
          Validate.checkUser(
            context: context,
            user: widget.phonenumberController.text,
            logintype: 'Nomor'
          );
        }
        : null,
        style: Styles.buttonForm(context: context),
        child: const Text('Masuk')
      ),
    );
  }
}
