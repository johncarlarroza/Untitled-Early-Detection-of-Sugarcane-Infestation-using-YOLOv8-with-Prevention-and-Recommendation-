import 'package:flutter/material.dart';

class BasePage extends StatefulWidget {
  final Widget body; // The main content of the page
  final int currentIndex; // The index of the currently selected tab
  final Function(int)? onTap; // Callback for when a tab is tapped

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/u.png', height: 50), // Logo or Title
        centerTitle: true,
        backgroundColor: Color.fromARGB(
          255,
          183,
          224,
          19,
        ), // AppBar background color
      ),
      body: widget.body, // Main content from the parent widget
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.camera), label: 'Camera'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Person'),
        ],
        currentIndex: widget.currentIndex, // Highlight the current tab
        selectedItemColor: Color.fromARGB(
          255,
          183,
          224,
          19,
        ), // Color for the selected tab
        onTap: (index) {
          if (widget.onTap != null) {
            widget.onTap!(index); // Call the provided onTap function
          }
        },
      ),
    );
  }
}
