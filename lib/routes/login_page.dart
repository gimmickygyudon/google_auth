import 'package:flutter/material.dart';

import '../functions/push.dart';
import '../functions/validate.dart';
import '../styles/theme.dart';
import '../widgets/checkbox.dart';
import '../widgets/profile.dart';
import '../widgets/button.dart';
import '../widgets/snackbar.dart';

class LoginRoute extends StatefulWidget {
  const LoginRoute({super.key, this.source, this.logintype});

  final Map? source;
  final String? logintype;

  @override
  State<LoginRoute> createState() => _LoginRouteState();
}

class _LoginRouteState extends State<LoginRoute> {
  late bool loggingIn, visibility, isValidated, isLoading;
  late TextEditingController _usernameController, _passwordController;

  final GlobalKey<LoginButtonState> loginButtonKey = GlobalKey();
  final GlobalKey<LoginButtonState> loginButtonKeyFloat = GlobalKey();

  @override
  void initState() {
    loggingIn = false;
    visibility = false;
    isValidated = false;
    isLoading = false;

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
    ).onError((error, stackTrace) {
      showSnackBar(context, snackBarError(context: context, content: error.toString()));
      setLoading(false);

      return Future.error(error.toString());
    }).then((value) => setLoading(false));
  }

  void setLoading(bool value) => setState(() => isLoading = value);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(appBarTheme: Themes.appBarTheme(context)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Halaman Masuk'),
          centerTitle: true,
          actions: [
            Image.asset('assets/logo IBM p C.png', height: 24),
            const SizedBox(width: 12),
          ],
        ),
        body: Center(
          heightFactor: 1.25,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Column(
              children: [
                if (widget.source == null) ... [
                  Image.asset('assets/start_page.png'),
                  const SizedBox(height: 20),
                  Text('Silahkan Masukan Nomor Handphone atau Alamat Email Anda.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                      letterSpacing: 0
                    )
                  ),
                  const SizedBox(height: 40),
                ],
                Theme(
                  data: Theme.of(context).copyWith(inputDecorationTheme: Themes.inputDecorationThemeForm(context: context)),
                  child: StatefulBuilder(builder: (context, setState) {
                    return Column(
                      children: [
                        if (widget.source != null) Padding(
                          padding: const EdgeInsets.only(bottom: 46),
                          child: UserProfile(source: widget.source),
                        ),
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
                          onSubmitted: isValidated ? (value) => login(context) : null,
                          obscureText: visibility ? false : true,
                          autocorrect: false,
                          enableSuggestions: false,
                          decoration: Styles.inputDecorationForm(
                            context: context,
                            placeholder: 'Kata Sandi',
                            icon: const Icon(Icons.key),
                            condition: _passwordController.text.trim().isNotEmpty,
                            visibility: visibility
                          ),
                          keyboardType: TextInputType.visiblePassword,
                        ),
                        const SizedBox(height: 4),
                        CheckboxPassword(
                          onChanged: (value) => setState(() => visibility = value!),
                          visibility: visibility
                        ),
                        const SizedBox(height: 24),
                        LoginButton(
                          key: loginButtonKey,
                          source: widget.source,
                          setLoading: setLoading,
                          isLoading: isLoading,
                          isVisible: true,
                          isValidated: isValidated,
                          loggingIn: loggingIn,
                          login: login
                        ),
                        if (widget.source != null && MediaQuery.of(context).size.height > 700) ...[
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
              ],
            ),
          ),
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
    required this.isVisible,
    required this.isLoading,
    required this.setLoading
  });

  final Map? source;
  final bool isValidated, isVisible, loggingIn, isLoading;
  final Function login, setLoading;

  @override
  State<LoginButton> createState() => LoginButtonState();
}

class LoginButtonState extends State<LoginButton> {
  late bool isValidated;

  @override
  void initState() {
    isValidated = widget.isValidated;
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
            onPressed: isValidated == true && widget.loggingIn == false && widget.isLoading == false
              ? () {
                widget.setLoading(true);
                widget.login(context);
              }
              : null,
            style: Styles.buttonForm(context: context, isLoading: widget.isLoading),
            child: Row(
              children: [
                if(widget.isLoading) SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary, strokeWidth: 2)
                ),
                if(widget.isLoading) const SizedBox(width: 12),
                Text(widget.isLoading ? 'Sebentar...' : 'Masuk'),
              ],
            )
          ),
        ],
      ),
    );
  }
}
