import 'package:early_application_1/camera/cameraonline.dart';
import 'package:early_application_1/lists/disease_details.dart';
import 'package:early_application_1/lists/pest_details.dart';
import 'package:early_application_1/lists/pest_mitigation.dart';
import 'package:early_application_1/lists/variants_details.dart';
import 'package:early_application_1/models/infos.dart';
import 'package:early_application_1/offline/lists/pest_mitigation.dart';
import 'package:early_application_1/pages/chatbot_page.dart';
import 'package:early_application_1/profilepage/profile.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  bool _showOverlay = false;

  final List<Widget> _pages = [
    HomeContent(),
    CameraPage(),
    ProfilePage(),
    const ChatbotPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _toggleOverlay() {
    setState(() {
      _showOverlay = !_showOverlay;
    });
  }

  Future<bool> _onWillPop() async {
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xFF0B3D2E), // DARK JUNGLE GREEN
          flexibleSpace: Center(
            child: Container(
              padding: const EdgeInsets.only(top: 30),
              child: Image.asset(
                'assets/u.png',
                height: 140,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        body: Stack(
          children: [
            _pages[_selectedIndex],
            if (_showOverlay)
              GestureDetector(
                onTap: _toggleOverlay,
                child: Container(
                  color: Colors.black54,
                  alignment: Alignment.center,
                  child: Stack(
                    children: [
                      Center(
                        child: Container(
                          width: 300,
                          height: 300,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9), // soft jungle green
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: const Color(0xFF6D4C41), // deep brown
                              width: 2,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                'Classification Result',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF6D4C41),
                                ),
                              ),
                              SizedBox(height: 20),
                              Text(
                                'Coconut Pests: 5',
                                style: TextStyle(color: Colors.black87),
                              ),
                              Text(
                                'Coconut Diseases: 2',
                                style: TextStyle(color: Colors.black87),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 20,
                        top: 20,
                        child: IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Colors.red,
                            size: 30,
                          ),
                          onPressed: _toggleOverlay,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: const Color(0xFF0B3D2E), // dark jungle green
          selectedItemColor: const Color(0xFF81C784), // fresh jungle green
          unselectedItemColor: const Color(0xFFD7CCC8), // light brown/cream
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.camera), label: 'Camera'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
            BottomNavigationBarItem(
                icon: Icon(Icons.smart_toy), label: 'Chatbot'),
          ],
        ),
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  final List<Infos> pests = [
    Infos(
      name: 'Cocoa Pests',
      description: 'Learn about various pests that affect Cocoa trees.',
      imageUrl: 'assets/s.png',
    ),
    Infos(
      name: 'Cocoa Diseases',
      description: 'Information about diseases that can harm Cocoa plants.',
      imageUrl: 'assets/sugarcane.png',
    ),
    Infos(
      name: 'Cocoa Varieties',
      description: 'Different variants of Cocoa trees.',
      imageUrl: 'assets/svariety.png',
    ),
    Infos(
      name: 'Cocoa Pest Control Measures',
      description: 'Different ways of pest mitigation controls.',
      imageUrl: 'assets/smitig.png',
    ),
  ];

  // 10 horizontal images
  final List<String> bannerImages = [
    'assets/b1.gif',
    'assets/b2.gif',
    'assets/b3.gif',
    'assets/b4.gif',
    'assets/b5.gif',
    'assets/b6.gif',
    'assets/b7.gif',
    'assets/b8.gif',
    'assets/b9.gif',
    'assets/b10.gif',
  ];

  void _navigateToPestList(BuildContext context, String name) {
    if (name == 'Cocoa Pests') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PestListPage()),
      );
    } else if (name == 'Cocoa Diseases') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DiseaseListPage()),
      );
    } else if (name == 'Cocoa Varieties') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => VariantListPage()),
      );
    } else if (name == 'Cocoa Pest Control Measures') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => OffCocomitig()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ---- HORIZONTAL IMAGE LIST ----
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: bannerImages.length,
            padding: const EdgeInsets.all(10),
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.only(right: 10),
                width: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: const Color(0xFF6D4C41),
                    width: 1,
                  ),
                  color: const Color(0xFFE8F5E9),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.asset(
                    bannerImages[index],
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),

        // ---- LIST OF PEST CARDS ----
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: pests.length,
            itemBuilder: (context, index) {
              final pest = pests[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 3,
                color: const Color(0xFFE8F5E9), // soft jungle green
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: const BorderSide(
                    color: Color(0xFF6D4C41), // brown outline
                    width: 1,
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(15),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      pest.imageUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(
                    pest.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0B3D2E), // dark jungle green text
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text(
                      pest.description,
                      style:
                          const TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                  ),
                  trailing: ElevatedButton(
                    onPressed: () {
                      _navigateToPestList(context, pest.name);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFF6D4C41), // deep brown button
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 15,
                      ),
                    ),
                    child: const Text('More'),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
