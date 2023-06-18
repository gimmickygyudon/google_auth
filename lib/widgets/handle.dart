import 'package:flutter/material.dart';
import 'package:google_auth/functions/push.dart';
import 'package:google_auth/styles/theme.dart';

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
        CircleAvatar(
          maxRadius: 60,
          backgroundColor: color?.withOpacity(0.15) ?? Theme.of(context).colorScheme.inversePrimary.withOpacity(0.25),
          child: Icon(Icons.cell_tower, size: 80, color: color ?? Theme.of(context).colorScheme.primary)
        ),
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

class HandleEmptyCart extends StatelessWidget {
  const HandleEmptyCart({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          children: [
            Image.asset('assets/delivery01.png'),
            const SizedBox(height: 32),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.info_outline, size: 18, color: Theme.of(context).colorScheme.secondary),
                const SizedBox(width: 8),
                Text('Sepertinya Anda Belum Memesan.', style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0
                )),
              ],
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () => pushDashboard(context, currentPage: 2),
              style: Styles.buttonLight(context: context),
              icon: Image.asset('assets/logo IBM p C.png', height: 16),
              label: const Text('Pesan Sekarang')
            )
          ],
        ),
      ),
    );
  }
}

class HandleEmptyOrder extends StatelessWidget {
  const HandleEmptyOrder({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          const SizedBox(height: 92),
          const Icon(Icons.shopping_bag_outlined, size: 72),
          const SizedBox(height: 24),
          Text('Kami Menawarkan Barang Berkualitas Tinggi Berstandart',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.secondary,
              letterSpacing: 0
            )
          ),
          const SizedBox(height: 48),
          ElevatedButton.icon(
            onPressed: () => pushDashboard(context, currentPage: 2),
            style: Styles.buttonLight(context: context),
            label: const Text('Pesan Sekarang'),
            icon: Image.asset('assets/logo IBM p C.png', height: 18)
          ),
          const SizedBox(height: 92),
        ],
      ),
    );
  }
}