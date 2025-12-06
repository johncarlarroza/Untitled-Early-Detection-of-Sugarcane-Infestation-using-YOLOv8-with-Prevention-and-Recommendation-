import 'package:early_application_1/offline/camera/off_camera.dart';
import 'package:early_application_1/offline/lists/pest_mitigation.dart';
import 'package:early_application_1/offline/models/infos.dart';
import 'package:early_application_1/offline/profilepage/profile.dart';
import 'package:flutter/material.dart';

import 'lists/pest_details.dart';
import 'lists/disease_details.dart';
import 'lists/variants_details.dart';

class OffHomePage extends StatefulWidget {
  const OffHomePage({super.key});

  @override
  _OffHomePageState createState() => _OffHomePageState();
}

class _OffHomePageState extends State<OffHomePage> {
  int _selectedIndex = 0;
  bool _showOverlay = false;

  final List<Widget> _pages = [
    HomeContent(),
    const OffCamera(),
    const OffProfilePage(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: Center(
          child: Container(
            padding: const EdgeInsets.only(top: 30),
            child: Image.asset(
              'assets/u.png',
              height: 100,
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
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
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
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.camera), label: 'Camera'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
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
