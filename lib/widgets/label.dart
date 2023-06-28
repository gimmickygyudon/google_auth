import 'package:flutter/material.dart';

class LabelSearch extends StatelessWidget {
  const LabelSearch({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 12),
      padding: const EdgeInsets.only(left: 12, right: 16),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(12),
          bottomRight: Radius.circular(12)
        ),
        // color: Theme.of(context).colorScheme.surfaceVariant
      ),
      child: IntrinsicHeight(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            VerticalDivider(indent: 8, endIndent: 8, color: Theme.of(context).colorScheme.outlineVariant),
            const SizedBox(width: 4),
            Icon(Icons.search, color: Theme.of(context).colorScheme.inverseSurface, size: 22),
            const SizedBox(width: 4),
            Text('Pencarian', style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.inverseSurface
            ))
          ],
        ),
      )
    );
  }
}

class LabelNoSend extends StatelessWidget {
  const LabelNoSend({super.key});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      triggerMode: TooltipTriggerMode.tap,
      message: 'Pesanan Belum Terkirim. Periksa Koneksi Internet Anda',
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).colorScheme.tertiary
          )
        ),
        child: Row(
          children: [
            Text('Belum Terkirim', style: Theme.of(context).textTheme.bodySmall?.copyWith(
              letterSpacing: 0,
              color: Theme.of(context).colorScheme.tertiary
            )),
            const SizedBox(width: 6),
            Icon(Icons.circle_outlined, size: 16, color: Theme.of(context).colorScheme.tertiary),
          ],
        ),
      ),
    );
  }
}

class LabelSend extends StatelessWidget {
  const LabelSend({super.key});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      triggerMode: TooltipTriggerMode.tap,
      message: 'Pesanan Notifikasi Berhasil Terkirim',
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.done_all, size: 16, color: Theme.of(context).colorScheme.primary),
      ),
    );
  }
}