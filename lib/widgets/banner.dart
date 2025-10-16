import 'package:flutter/material.dart';

/// Banner dengan custom background image
class AppBanner extends StatelessWidget {
  final String? backgroundImage;
  final double height;
  final BoxFit fit;

  const AppBanner({
    super.key,
    this.backgroundImage,
    this.height = 250,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
        image: backgroundImage != null
            ? DecorationImage(
                image: AssetImage(backgroundImage!),
                fit: fit,
              )
            : null,
      ),
      child: backgroundImage == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.image, size: 80, color: Colors.white24),
                  SizedBox(height: 10),
                  Text(
                    'Tambahkan gambar banner',
                    style: TextStyle(color: Colors.white38, fontSize: 16),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}