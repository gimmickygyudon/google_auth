import 'package:flutter/material.dart';

import '../functions/push.dart';
import '../functions/validate.dart';
import '../styles/theme.dart';
import '../widgets/checkbox.dart';
import '../widgets/profile.dart';
import '../widgets/button.dart';

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

  bool _keyboardVisible = false;
  final GlobalKey<LoginButtonState> loginButtonKey = GlobalKey();
  final GlobalKey<LoginButtonState> loginButtonKeyFloat = GlobalKey();

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

  String logintype() => RegExp(r'^[0-9]+$').hasMatch(_usernameController.text) ? 'Nomor' : 'Email';
  Future<void> login(BuildContext context) async {
    Validate.checkUser(
      context: context, 
      logintype: widget.logintype == null ? logintype() : widget.logintype!,
      login: true,
      user: _usernameController.text,
      password: _passwordController.text,
      source: { 'user_name': widget.source?['user_name'], 'user_email': widget.source?['user_email'] }
    );
  }

  @override
  Widget build(BuildContext context) {
    _keyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;
    return Theme(
      data: Theme.of(context).copyWith(appBarTheme: Themes.appBarTheme(context)),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          toolbarHeight: 0
        ),
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height - kToolbarHeight,
                  child: Form(
                    child: Column(
                      children: [
                         if(MediaQuery.of(context).size.height > 750) Flexible(
                          flex: 3, 
                          child: Column(
                            children: [
                              const SizedBox(height: 24),
                              Image(
                                image: const AssetImage('assets/Logo Indostar.png'),
                                height: (MediaQuery.of(context).size.height > 750) ? null : 30,
                              ),
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
                        if (widget.source == null) Expanded(flex: 3, child: Image.asset('assets/start_page.png', fit: BoxFit.cover)),
                        SizedBox(
                          height: widget.source != null 
                          ? MediaQuery.of(context).size.height > 750 ? 40 : 20 
                          : 20
                        ),
                        if (widget.source != null) ...[
                          Expanded(
                            flex: (MediaQuery.of(context).size.height > 750) ? 3 : 4, child: UserProfile(source: widget.source)
                          ),
                        ],
                        Flexible(
                          flex: widget.source != null ? 8 : 4,
                          child: Theme(
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
                                      loginButtonKey.currentState?.refresh(isValidated);
                                      loginButtonKeyFloat.currentState?.refresh(isValidated);
                                    }),
                                    readOnly: widget.source == null ? false : true,
                                    textInputAction: isValidated
                                      ? TextInputAction.done
                                      : TextInputAction.next,
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.4),
                                    decoration: Styles.inputDecorationForm(
                                      context: context,
                                      placeholder: 'Email / No. HP',
                                      isPhone: logintype() == 'Nomor' ? true : false,
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
                                      loginButtonKey.currentState?.refresh(isValidated);
                                      loginButtonKeyFloat.currentState?.refresh(isValidated);
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
                                  SizedBox(height: _keyboardVisible ? 0 : 24),
                                  LoginButton(
                                    key: loginButtonKey,
                                    source: widget.source,
                                    isVisible: _keyboardVisible ? false : true,
                                    isValidated: isValidated, 
                                    loggingIn: loggingIn, 
                                    login: login
                                  ), 
                                  if (widget.source != null && MediaQuery.of(context).size.height > 750) ...[
                                    const SizedBox(height: 12),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical : 12),
                                      child: Row(
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
                                    ),
                                    const SizedBox(height: 24),
                                    LoginsButton(
                                      logintype: widget.logintype, 
                                      source: widget.source, 
                                      usernameController: _usernameController
                                    )
                                  ]
                                ],
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Themes.bottomFloatingBar(
              context: context,
              isVisible: _keyboardVisible,
              child: LoginButton(
                key: loginButtonKeyFloat,
                source: widget.source,
                isVisible: _keyboardVisible,
                isValidated: isValidated, 
                loggingIn: loggingIn, 
                login: login
              ),
            )
          ],
        ),
      ),
    );
  }
}

class LoginButton extends StatefulWidget {
  const LoginButton({
    super.key, 
    this.source, 
    required this.isValidated, 
    required this.loggingIn, 
    required this.login, 
    required this.isVisible
  });

  final Map? source;
  final bool isValidated;
  final bool isVisible;
  final bool loggingIn;
  final Function login;

  @override
  State<LoginButton> createState() => LoginButtonState();
}

class LoginButtonState extends State<LoginButton> {
  late bool isValidated;
  late bool isLoading;

  @override
  void initState() {
    isValidated = widget.isValidated;
    isLoading = false;
    super.initState();
  }

  void refresh(validated) => setState(() {
    isValidated = validated;
  });
  
  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: widget.isVisible,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: () => widget.source == null ? pushStart(context) : pushLogin(context),
            child: Text(widget.source == null ? 'Kembali' : 'Ubah Akun')
          ),
          ElevatedButton(
            onPressed: isValidated == true && widget.loggingIn == false
              ? () {
                setState(() => isLoading = true);
                widget.login(context).whenComplete(() => setState(() {
                  isLoading = false;
                }));
              }
              : null,
            style: Styles.buttonForm(context: context),
            child: Text(isLoading ? 'Tunggu Sebentar...' : 'Masuk')
          ),
        ],
      ),
    );
  }
}
