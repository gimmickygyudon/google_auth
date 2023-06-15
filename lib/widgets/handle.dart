import 'package:flutter/material.dart';

class HandleNoInternet extends StatelessWidget {
  const HandleNoInternet({super.key, required this.message, this.color});

  final String message;
  final Color? color;

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
        ))
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
