import 'package:flutter/material.dart';
import 'package:google_auth/functions/push.dart';
import 'package:google_auth/styles/theme.dart';

class HandleNoInternet extends StatelessWidget {
  const HandleNoInternet({
    super.key, required this.message, this.color, this.onPressed, this.buttonText, this.textColor
  });

  final String message;
  final Color? color, textColor;
  final Function? onPressed;
  final String? buttonText;

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
          color: textColor ?? Theme.of(context).colorScheme.secondary,
          letterSpacing: 0
        )),
        const SizedBox(height: 48),
        if(onPressed != null) OutlinedButton(
         onPressed: () {
           onPressed!();
         },
         style: ButtonStyle(side: MaterialStatePropertyAll(BorderSide(color: Theme.of(context).colorScheme.primary))),
         child: Text(buttonText ?? 'Muat Ulang')
        )
      ],
    );
  }
}

class HandleLoading extends StatelessWidget {
  const HandleLoading({super.key, this.strokeWidth, this.color, this.height, this.width, this.widget});

  final double? strokeWidth, height, width;
  final Color? color;
  final Widget? widget;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 48),
        SizedBox(
          height: height ?? 54,
          width: width ?? 54,
          child: CircularProgressIndicator(
            strokeWidth: strokeWidth ?? 2,
            color: color ?? Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 24),
        widget ?? const SizedBox()
      ],
    );
  }
}

class HandleLoadingBar extends StatelessWidget {
  const HandleLoadingBar({super.key, this.minHeight, this.color, this.backgroundColor});

  final double? minHeight;
  final Color? color, backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LinearProgressIndicator(color: color, minHeight: minHeight, backgroundColor: backgroundColor),
      ],
    );
  }
}

class HandleEmptyCart extends StatelessWidget {
  const HandleEmptyCart({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 44),
      child: Center(
        child: Column(
          children: [
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
              onPressed: () => pushOrdersPage(context: context, page: 1),
              style: Styles.buttonFlat(context: context),
              icon: const Icon(Icons.history),
              label: const Text('Riwayat Pesanan')
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
          Text('Kami Menawarkan Barang Berkualitas Tinggi Berstandar',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.secondary,
              letterSpacing: 0
            )
          ),
          const SizedBox(height: 48),
          ElevatedButton.icon(
            onPressed: () => pushDashboard(context, currentPage: 2),
            style: Styles.buttonFlat(context: context),
            label: const Text('Pesan Sekarang'),
            icon: CircleAvatar(
              radius: 13,
              backgroundColor: Colors.white,
              child: Image.asset('assets/logo IBM p C.png', height: 18)
            )
          ),
          const SizedBox(height: 92),
        ],
      ),
    );
  }
}

class HandleEmptyAddress extends StatelessWidget {
  const HandleEmptyAddress({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          const SizedBox(height: 92),
          const Icon(Icons.home_work_outlined, size: 72),
          const SizedBox(height: 24),
          Text('Sepertinya Anda Belum Menambah Lokasi Pengiriman',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.secondary,
              letterSpacing: 0
            )
          ),
          const SizedBox(height: 48),
          ElevatedButton.icon(
            onPressed: () => pushAddressAdd(context: context, hero: 'Add'),
            style: Styles.buttonLight(context: context),
            label: const Text('Tambah Sekarang'),
            icon: const Icon(Icons.add_location_alt)
          ),
          const SizedBox(height: 92),
        ],
      ),
    );
  }
}

class HandleLocationDisabled extends StatelessWidget {
  const HandleLocationDisabled({super.key, required this.buttonPressed});

  final Function buttonPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          const SizedBox(height: 60),
          const Icon(Icons.wrong_location_outlined, size: 72),
          const SizedBox(height: 24),
          Text('Tidak dapat menghubungi layanan GPS di device anda.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.secondary,
              letterSpacing: 0
            )
          ),
          const SizedBox(height: 48),
          ElevatedButton.icon(
            onPressed: () => buttonPressed(),
            style: Styles.buttonLight(context: context),
            label: const Text('Hidukan Layanan Lokasi'),
            icon: const Icon(Icons.toggle_off_outlined, size: 32)
          ),
          const SizedBox(height: 92),
        ],
      ),
    );
  }
}

class HandleLocationPermission extends StatelessWidget {
  const HandleLocationPermission({super.key, required this.buttonPressed});

  final Function buttonPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          const SizedBox(height: 60),
          const Icon(Icons.wrong_location_outlined, size: 72),
          const SizedBox(height: 24),
          Text('Tidak dapat menghubungi layanan GPS di device anda.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.secondary,
              letterSpacing: 0
            )
          ),
          const SizedBox(height: 48),
          ElevatedButton.icon(
            onPressed: () => buttonPressed(),
            style: Styles.buttonLight(context: context),
            label: const Text('Ubah Akses Layanan Lokasi'),
            icon: const Icon(Icons.toggle_off_outlined, size: 32)
          ),
          const SizedBox(height: 92),
        ],
      ),
    );
  }
}

class HandleNoData extends StatelessWidget {
  const HandleNoData({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Icon(Icons.bar_chart_outlined, size: 40, color: Theme.of(context).colorScheme.secondary),
          ),
          Text('Tidak ada data yang ditemukan', style: Theme.of(context).textTheme.titleSmall)
        ],
      )
    );
  }
}

class DisableWidget extends StatelessWidget {
  const DisableWidget({super.key, required this.disable, required this.child});

  final bool disable;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: disable,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        foregroundDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: disable ? Border.all(
            color: Theme.of(context).colorScheme.outlineVariant
          ) : null,
          color: Theme.of(context).colorScheme.background.withOpacity(disable ? 0.9 : 0)
        ),
        child: ColorFiltered(
          colorFilter: ColorFilter.mode(disable ? Theme.of(context).colorScheme.background : Colors.transparent, BlendMode.saturation),
          child: child
        )
      )
    );
  }
}