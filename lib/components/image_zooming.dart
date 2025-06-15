import 'package:flutter/material.dart';

Widget zoomableImage(String imageUrl) {
  return SizedBox(
    height: 200,
    child: InteractiveViewer(
      panEnabled: true,
      minScale: 1,
      maxScale: 5,
      child: Image.network(
        imageUrl,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Text('Failed to load image'),
      ),
    ),
  );
}
