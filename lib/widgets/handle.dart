import 'package:flutter/material.dart';

class HandleNoInternet extends StatelessWidget {
  const HandleNoInternet({super.key, required this.message, this.color, this.onPressed});

  final String message;
  final Color? color;
  final Function? onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 48),
        Icon(Icons.wifi_off, size: 80, color: color ?? Theme.of(context).colorScheme.primary),
        const SizedBox(height: 24),
        Text(message, style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.secondary,
          letterSpacing: 0
        )),
        const SizedBox(height: 48),
      //OutlinedButton(
      //  onPressed: () {
      //    if (onPressed != null) onPressed!();
      //  },
      //  style: ButtonStyle(side: MaterialStatePropertyAll(BorderSide(color: Theme.of(context).colorScheme.primary))),
      //  child: const Text('Muat Ulang')
      //)
      ],
    );
  }
}

class HandleLoading extends StatelessWidget {
  const HandleLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 48),
        SizedBox(
          height: 54,
          width: 54,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }
}
