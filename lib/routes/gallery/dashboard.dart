import 'package:flutter/material.dart';
import 'package:google_auth/functions/video.dart';
import 'package:google_auth/widgets/handle.dart';

import '../../functions/push.dart';

class GalleryRoute extends StatefulWidget {
  const GalleryRoute({super.key});

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
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            colorFilter: ColorFilter.mode(Colors.black38, BlendMode.srcATop),
            image: AssetImage('assets/background.png'), fit: BoxFit.cover
          )
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: 'Telusuri Produk Berkualitas Indostar', style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      height: 0,
                      fontWeight: FontWeight.w300,
                      color: Theme.of(context).colorScheme.surface
                    )),
                  ]
                )
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 12),
              child: Row(
                children: [
                  Icon(Icons.play_circle, color: Theme.of(context).colorScheme.inversePrimary),
                  const SizedBox(width: 8),
                  Text('Video Terbaru', style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    letterSpacing: 0
                  )),
                  const SizedBox(width: 16),
                ],
              ),
            ),
            SizedBox(
              height: 140,
              child: FutureBuilder(
                future: ytVideos,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const HandleLoading();
                  } else if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                    return ListView.builder(
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
                    },
                  );
                  } else {
                    return const HandleEmptyOrder();
                  }
                }
              ),
            )
          ],
        ),
      )
    );
  }
}