import 'package:flutter/material.dart';

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
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)
      ),
      filled: true,
      fillColor: Theme.of(context).hoverColor,
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

  static ButtonStyle buttonForm({required BuildContext context}) {
    return ButtonStyle(
      visualDensity: VisualDensity.standard,
      elevation: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.disabled)) return null;
        return states.contains(MaterialState.pressed) ? 1 : 8;
      }),
      shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
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
    {
      required BuildContext context,
      required String placeholder,
      required bool condition,
      Icon? icon,
      bool? visibility,
      bool? visibilityDisabled,
      bool? isPhone,
      String? prefixText,
      Widget? suffixIcon,
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
        alignLabelWithHint: true,
        floatingLabelBehavior: floatingLabelBehavior,
        suffixText: prefixText,
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
        fillColor: condition ? Theme.of(context).colorScheme.inversePrimary.withOpacity(0.15) : Theme.of(context).hoverColor,
        errorStyle: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.red, fontSize: 11),
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
