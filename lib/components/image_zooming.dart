import 'package:flutter/material.dart';

Widget zoomableImage(String imageUrl) {
  return InteractiveViewer(
    panEnabled: true,
    minScale: 1,
    maxScale: 5,
    child: Image.network(
      imageUrl,
      width: double.infinity,          
      fit: BoxFit.fitWidth,             
      errorBuilder: (_, __, ___) => const Text('Failed to load image'),
    ),
  );
}
