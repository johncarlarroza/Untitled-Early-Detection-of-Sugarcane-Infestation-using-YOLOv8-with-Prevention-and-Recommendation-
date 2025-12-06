import 'package:flutter/material.dart';

class AppInfoPage extends StatelessWidget {
  const AppInfoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('App Info')),
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/backg.png', // Background image
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Two logos at the top center
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Image(image: AssetImage('assets/cict.png'), height: 60),
                    SizedBox(width: 20),
                    Image(image: AssetImage('assets/pca.png'), height: 60),
                  ],
                ),
                const SizedBox(height: 20),
                // Main logo for pestincoco
                Image.asset('assets/u.png', height: 120),
                const SizedBox(height: 20),
                // Description of pestincoco
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Pestecane provides high-quality pest control services, utilizing '
                    'environmentally friendly solutions to ensure your spaces remain '
                    'safe and pest-free. With years of experience and a commitment to '
                    'customer satisfaction/',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
