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
          flexibleSpace: Stack(
            children: [
              Center(
                child: Container(
                  padding: const EdgeInsets.only(top: 30),
                  child: Image.asset(
                    'assets/u.png',
                    height: 350,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
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
                          width: 90,
                          height: 300,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Classification Result',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 20),
                              Text('Coconut Pests: 5'),
                              Text('Coconut Diseases: 2'),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 20,
                        top: 20,
                        child: IconButton(
                          icon: Icon(Icons.close, color: Colors.red, size: 30),
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
          backgroundColor: const Color(0xFF1B5E20), // Dark green background
          selectedItemColor: const Color.fromARGB(
              255, 119, 255, 0), // Golden/yellow when selected
          unselectedItemColor: const Color.fromARGB(
              179, 44, 166, 10), // Light gray when unselected
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
      name: 'Sugarcane Pests',
      description: 'Learn about various pests that affect sugarcane trees.',
      imageUrl: 'assets/s.png',
    ),
    Infos(
      name: 'Sugarcane Diseases',
      description: 'Information about diseases that can harm sugarcane plants.',
      imageUrl: 'assets/sugarcane.png',
    ),
    Infos(
      name: 'Sugarcane Varieties',
      description: 'Different variants of coconut trees.',
      imageUrl: 'assets/svariety.png',
    ),
    Infos(
      name: 'Sugarcane Pest Control Measures',
      description: 'Different ways of pest mitigation controls.',
      imageUrl: 'assets/smitig.png',
    ),
  ];

  void _navigateToPestList(BuildContext context, String name) {
    if (name == 'Sugarcane Pests') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PestListPage()),
      );
    } else if (name == 'Sugarcane Diseases') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DiseaseListPage()),
      );
    } else if (name == 'Sugarcane Varieties') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => VariantListPage()),
      );
    } else if (name == 'Sugarcane Pest Control Measures') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => OffCocomitig()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: pests.length,
      itemBuilder: (context, index) {
        final pest = pests[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
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
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                pest.description,
                style: const TextStyle(fontSize: 14),
              ),
            ),
            trailing: ElevatedButton(
              onPressed: () {
                _navigateToPestList(context, pest.name);
              },
              style: ElevatedButton.styleFrom(
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
    );
  }
}
