import 'package:flutter/material.dart';
import 'package:google_auth/functions/video.dart';
import 'package:google_auth/widgets/handle.dart';

import '../../functions/push.dart';

class GalleryRoute extends StatefulWidget {
  const GalleryRoute({super.key, required this.isLoading});

  final bool isLoading;

  @override
  State<GalleryRoute> createState() => _GalleryRouteState();
}

class _GalleryRouteState extends State<GalleryRoute> {
  late Future ytVideos;

  @override
  void initState() {
    ytVideos = Video.getYTVideos();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xF1111111),
        child: Stack(
          fit: StackFit.expand,
          children: [
            AnimatedOpacity(
              duration: const Duration(milliseconds: 2000),
              curve: Curves.easeInOut,
              opacity: widget.isLoading ? 0 : 1,
              child: AnimatedScale(
                duration: const Duration(milliseconds: 3000),
                curve: Curves.fastOutSlowIn,
                scale: widget.isLoading ? 1.1 : 1,
                child: ColorFiltered(
                  colorFilter: const ColorFilter.mode(Colors.black38, BlendMode.srcATop),
                  child: Image.asset('assets/background.png', fit: BoxFit.cover)
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 72, 28, 24),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: 'Telusuri Produk Berkualitas Indostar', style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          height: 0,
                          fontSize: 30,
                          fontWeight: FontWeight.w300,
                          color: Colors.white
                        )),
                      ]
                    )
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 0, 28, 12),
                  child: Row(
                    children: [
                      const Icon(Icons.play_circle, color: Colors.red),
                      const SizedBox(width: 8),
                      Text('Video Terbaru', style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        letterSpacing: 0
                      )),
                      const SizedBox(width: 16),
                    ],
                  ),
                ),
                FutureBuilder(
                  future: ytVideos,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: HandleLoading(strokeWidth: 4, color: Colors.white54));
                    } else if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                      return SizedBox(
                        height: 140,
                        child: ListView.builder(
                        itemCount: snapshot.data.length,
                        padding: const EdgeInsets.fromLTRB(30, 0, 0, 24),
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: InkWell(
                                onHover: (value) {},
                                onTap: () => launchURL(url: 'https://www.youtube.com/watch?v=${snapshot.data[index]['id']}'),
                                child: Ink(
                                  width: 180,
                                  child: Image.network('https://img.youtube.com/vi/${snapshot.data[index]['id']}/0.jpg', fit: BoxFit.cover),
                                ),
                              ),
                            ),
                          );
                        }),
                      );
                    } else {
                      return Center(
                        heightFactor: 1.2,
                        child: HandleNoInternet(
                          message: 'Tidak Tersambung ke Internet.',
                          color: Colors.blue.shade200,
                          textColor: Colors.blue.shade50,
                        )
                      );
                    }
                  }
                )
              ],
            ),
          ],
        ),
      )
    );
  }
}