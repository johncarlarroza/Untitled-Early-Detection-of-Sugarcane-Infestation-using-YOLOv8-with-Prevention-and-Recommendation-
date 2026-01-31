import 'package:flutter/material.dart';

class BasePage extends StatefulWidget {
  final Widget body;
  final int currentIndex;
  final Function(int)? onTap;

  const BasePage({
    required this.body,
    required this.currentIndex,
    this.onTap,
    super.key,
  });

  @override
  _BasePageState createState() => _BasePageState();
}

class _BasePageState extends State<BasePage> {
  Color? _overrideSelectedColor; // <-- KEY PART

  final Color primaryGreen =
      const Color.fromARGB(255, 183, 224, 19); // main green

  final Color lightBrown = const Color(0xFFE6D7C3); // light brown

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/u.png', height: 50),
        centerTitle: true,
        backgroundColor: primaryGreen,
      ),
      body: widget.body,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.camera), label: 'Camera'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Person'),
        ],

        currentIndex: widget.currentIndex,

        selectedItemColor:
            _overrideSelectedColor ?? primaryGreen, // 👈 dynamic color

        unselectedItemColor: Colors.grey,

        onTap: (index) {
          if (index == widget.currentIndex) {
            // User tapped the SAME tab → make it light brown
            setState(() {
              _overrideSelectedColor = Colors.brown;
            });

            // Reset back to green after 300ms (nice effect)
            Future.delayed(const Duration(milliseconds: 300), () {
              if (mounted) {
                setState(() {
                  _overrideSelectedColor = null;
                });
              }
            });
          }

          if (widget.onTap != null) {
            widget.onTap!(index);
          }
        },
      ),
    );
  }
}
