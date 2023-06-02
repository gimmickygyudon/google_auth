import 'package:flutter/material.dart';

class Themes {
  static InputDecorationTheme inputDecorationThemeForm(
      {required BuildContext context}) {
    return InputDecorationTheme(
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary, width: 2)),
        filled: true,
        fillColor: Theme.of(context).hoverColor,
        labelStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            letterSpacing: 0,
            color: Theme.of(context).colorScheme.secondary),
        floatingLabelStyle: TextStyle(
            fontWeight: FontWeight.w500,
            letterSpacing: 0,
            color: Theme.of(context).colorScheme.primary));
  }
}

class Styles {
  static ButtonStyle buttonForm({required BuildContext context}) {
    return ButtonStyle(
      visualDensity: VisualDensity.standard,
      elevation: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.disabled)) return null;
        return states.contains(MaterialState.pressed) ? 1 : 8;
      }),
      shape: MaterialStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
      backgroundColor: MaterialStateProperty.resolveWith((states) {
        return states.contains(MaterialState.disabled)
            ? null
            : Theme.of(context).colorScheme.primary;
      }),
      foregroundColor: MaterialStateProperty.resolveWith((states) {
        return states.contains(MaterialState.disabled)
            ? null
            : Theme.of(context).colorScheme.surface;
      }),
      overlayColor: MaterialStateProperty.resolveWith((states) {
        return states.contains(MaterialState.disabled)
            ? null
            : Theme.of(context).colorScheme.inversePrimary;
      }),
    );
  }

  static InputDecoration inputDecorationForm(
      {required BuildContext context,
      required String placeholder,
      required bool condition,
      Icon? icon,
      bool? visibility,
      bool? visibilityDisabled}) {
    bool? visibility_ = visibility;
    if (visibilityDisabled == true) visibility_ = false;
    return InputDecoration(
        labelText: placeholder,
        prefixIcon: icon,
        suffixIcon: visibility_ != null
            ? visibility_
                ? const Icon(Icons.visibility_outlined)
                : const Icon(Icons.visibility_off_outlined)
            : null,
        errorMaxLines: 3,
        errorStyle: Theme.of(context)
            .textTheme
            .bodySmall
            ?.copyWith(color: Colors.red, fontSize: 11),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error, width: 2)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error, width: 2)),
        enabledBorder: condition
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.5),
                    width: 1))
            : null,
        focusedBorder: condition
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary, width: 2))
            : null,
        border: condition
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary, width: 2))
            : null);
  }
}
