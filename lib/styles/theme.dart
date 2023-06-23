import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class ThemeNotifier with ChangeNotifier {

  static var brightness = SchedulerBinding.instance.platformDispatcher.platformBrightness;
  bool darkMode = brightness == Brightness.dark;
  final darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorSchemeSeed: Colors.blue,
    snackBarTheme: const SnackBarThemeData(backgroundColor: Colors.black),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      },
    ),
  );

  final lightTheme = ThemeData(
    useMaterial3: true,
    colorSchemeSeed: Colors.blue,
    snackBarTheme: const SnackBarThemeData(backgroundColor: Colors.white),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      },
    ),
  );


  ThemeMode _themeData = ThemeMode.system;
  ThemeMode getTheme() => _themeData;

  void setThemeMode(bool darkMode, BuildContext context) {
    if (darkMode) {
      _themeData = ThemeMode.dark;
    } else {
      _themeData = ThemeMode.light;
    }
    notifyListeners();
  }
}

class Themes {

  static AppBarTheme appBarTheme(BuildContext context) {
    return AppBarTheme(
      scrolledUnderElevation: 8,
      shadowColor: Theme.of(context).colorScheme.shadow.withOpacity(0.5),
      surfaceTintColor: Theme.of(context).colorScheme.inversePrimary,
      titleTextStyle: Theme.of(context).textTheme.titleMedium,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12)
        )
      ),
    );
  }

  static Widget bottomFloatingBar({required BuildContext context, required Widget child, required bool isVisible, EdgeInsets? padding}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 6),
      margin: padding,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
        color: Theme.of(context).colorScheme.background,
        boxShadow: isVisible == true ? [BoxShadow(spreadRadius: -8, offset: const Offset(0, 0), blurRadius: 8, color: Theme.of(context).shadowColor)] : null
      ),
      child: child,
    );
  }

  static InputDecorationTheme inputDecorationThemeForm({required BuildContext context}) {
    return InputDecorationTheme(
      isDense: true,
      contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary, width: 2)
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)
      ),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: Theme.of(context).colorScheme.secondary
      ),
      floatingLabelStyle: TextStyle(
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        color: Theme.of(context).colorScheme.primary
      )
    );
  }

  static InputDecorationTheme inputDecorationTheme({required BuildContext context}) {
    return InputDecorationTheme(
      isDense: true,
      contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1)
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)
      ),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: Theme.of(context).colorScheme.secondary
      ),
      floatingLabelStyle: TextStyle(
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        color: Theme.of(context).colorScheme.primary
      )
    );
  }
}

class Styles {

  static ButtonStyle buttonForm({required BuildContext context, bool? isLoading}) {
    return ButtonStyle(
      visualDensity: const VisualDensity(horizontal: 2, vertical: 2),
      elevation: MaterialStateProperty.resolveWith((states) {
        if (isLoading == true) {
          return 0;
        } else if (states.contains(MaterialState.disabled)) {
          return null;
        } else if (states.contains(MaterialState.pressed)) {
          return 1;
        } else {
          return 8;
        }
      }),
      shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      backgroundColor: MaterialStateProperty.resolveWith((states) {
        if (isLoading == true) {
          return Theme.of(context).colorScheme.inversePrimary.withOpacity(0.5);
        }
        else if (states.contains(MaterialState.disabled)) {
          return Theme.of(context).colorScheme.secondary.withOpacity(0.1);
        } else {
          return Theme.of(context).colorScheme.primary;
        }
      }),
      foregroundColor: MaterialStateProperty.resolveWith((states) {
        if (isLoading == true) {
          return Theme.of(context).colorScheme.primary;
        } else if (states.contains(MaterialState.disabled)) {
          return null;
        } else {
          return Theme.of(context).colorScheme.surface;
        }
      }),
      overlayColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.disabled)) {
          return null;
        } else {
          return Theme.of(context).colorScheme.inversePrimary;
        }
      }),
    );
  }

  static ButtonStyle buttonFlatSmall({
    required BuildContext context,
    Color? backgroundColor,
    Color? foregroundColor,
    Color? overlayColor,
    BorderRadiusGeometry? borderRadius,
  }) {
    return ButtonStyle(
      elevation: const MaterialStatePropertyAll(0),
      shape: borderRadius != null ? MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: borderRadius)) : null,
      visualDensity: VisualDensity.compact,
      iconSize: const MaterialStatePropertyAll(18),
      textStyle: MaterialStatePropertyAll(Theme.of(context).textTheme.labelMedium?.copyWith(
        letterSpacing: 0
      )),
      foregroundColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.disabled)) {
          return null;
        } else {
          return foregroundColor ?? Theme.of(context).colorScheme.surface;
        }
      }),
      backgroundColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.disabled)) {
          return null;
        } else {
          return backgroundColor ?? Theme.of(context).colorScheme.primary;
        }
      }),
      overlayColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.disabled)) {
          return null;
        } else {
          return overlayColor ?? Theme.of(context).colorScheme.inversePrimary;
        }
      }),
    );
  }

  static ButtonStyle buttonInverseFlatSmall({
    required BuildContext context,
    Color? backgroundColor,
    Color? foregroundColor,
    Color? overlayColor,
    BorderRadiusGeometry? borderRadius,
  }) {
    return ButtonStyle(
      elevation: const MaterialStatePropertyAll(0),
      shape: borderRadius != null ? MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: borderRadius)) : null,
      visualDensity: VisualDensity.compact,
      iconSize: const MaterialStatePropertyAll(18),
      backgroundColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.disabled)) {
          return null;
        } else {
          return foregroundColor ?? Theme.of(context).colorScheme.surface;
        }
      }),
      foregroundColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.disabled)) {
          return null;
        } else {
          return backgroundColor ?? Theme.of(context).colorScheme.primary;
        }
      }),
      overlayColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.disabled)) {
          return null;
        } else {
          return overlayColor ?? Theme.of(context).colorScheme.inversePrimary;
        }
      }),
    );
  }

  static ButtonStyle buttonFlat({
    required BuildContext context,
    Color? backgroundColor,
    Color? foregroundColor,
    Color? overlayColor,
    BorderRadiusGeometry? borderRadius,
  }) {
    return ButtonStyle(
      elevation: const MaterialStatePropertyAll(0),
      shape: borderRadius != null ? MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: borderRadius)) : null,
      backgroundColor: MaterialStateProperty.resolveWith((states) {
         return backgroundColor ?? Theme.of(context).colorScheme.primary;
      }),
      foregroundColor: MaterialStateProperty.resolveWith((states) {
         return foregroundColor ?? Theme.of(context).colorScheme.surface;
      }),
      overlayColor: MaterialStateProperty.resolveWith((states) {
         return overlayColor ?? Theme.of(context).colorScheme.inversePrimary;
      }),
    );
  }

  static ButtonStyle buttonLight({required BuildContext context}) {
    return ButtonStyle(
      elevation: const MaterialStatePropertyAll(0),
      shape: MaterialStatePropertyAll(RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8)
      )),
      backgroundColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.disabled)) return null;
        return Theme.of(context).colorScheme.inversePrimary.withOpacity(0.25);
      }),
      foregroundColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.disabled)) return null;
        return Theme.of(context).colorScheme.primary;
      }),
    );
  }

  static ButtonStyle buttonDanger({required BuildContext context}) {
    return ButtonStyle(
      shape: MaterialStatePropertyAll(RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8)
      )),
      backgroundColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.disabled)) return null;
        return Theme.of(context).colorScheme.error.withOpacity(0.15);
      }),
      foregroundColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.disabled)) return null;
        return Theme.of(context).colorScheme.error.withOpacity(0.9);
      }),
    );
  }

  static InputDecoration inputDecorationForm({
    required BuildContext context,
    required String? placeholder,
    required bool condition,
    String? hintText, prefixText,
    Widget? icon,
    bool? visibility, visibilityDisabled, alignLabelWithHint, isPhone,
    Widget? prefix, suffixIcon,
    TextStyle? labelStyle,
    FloatingLabelBehavior? floatingLabelBehavior
  }) {
    bool? visibility_ = visibility;

    if (visibility != null) {
        visibility_ == true
          ? suffixIcon = const Icon(Icons.visibility_outlined)
          : suffixIcon = const Icon(Icons.visibility_off_outlined);
    }

    if (visibilityDisabled == true) visibility_ = false;
    return InputDecoration(
      labelText: placeholder,
      alignLabelWithHint: alignLabelWithHint,
      floatingLabelBehavior: floatingLabelBehavior,
      suffixText: prefixText,
      prefix: prefix,
      hintText: hintText,
      labelStyle: labelStyle,
      hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: Theme.of(context).colorScheme.inverseSurface.withOpacity(0.2),
        letterSpacing: 0,
      ),
      prefixIcon: isPhone == true ? Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 2),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.asset('assets/Flag_of_Indonesia.svg.png', width: 24)
            ),
          ),
          const SizedBox(width: 12),
          Text('+62', style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(width: 8),
        ],
      ) : icon,
      suffixIcon: suffixIcon,
      errorMaxLines: 3,
      filled: true,
      fillColor: condition ? Theme.of(context).colorScheme.inversePrimary.withOpacity(0.25) : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.45),
      errorStyle: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.error, fontSize: 11),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.error, width: 2)
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).colorScheme.error, width: 2)
      ),
      enabledBorder: condition
      ? OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          width: 1
        )
      )
      : null,
      focusedBorder: condition
      ? OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)
        )
      : null,
      border: condition
      ? OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)
        )
      : null
    );
  }
}
