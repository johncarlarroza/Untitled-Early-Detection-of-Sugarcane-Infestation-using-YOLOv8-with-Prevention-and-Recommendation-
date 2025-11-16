import 'package:flutter/material.dart';

class EnlargedImageScreen extends StatelessWidget {
  final String imageUrl;

  const EnlargedImageScreen({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Center(
          child: Hero(
            tag: imageUrl,
            child: Image.asset(imageUrl),
          ),
        ),
      ),
    );
  }
}
