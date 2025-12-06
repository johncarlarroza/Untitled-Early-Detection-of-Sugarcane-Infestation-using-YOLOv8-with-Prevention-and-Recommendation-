import 'package:early_application_1/camera/cameraonline.dart';
import 'package:early_application_1/lists/disease_details.dart';
import 'package:early_application_1/lists/pest_details.dart';
import 'package:early_application_1/lists/pest_mitigation.dart';
import 'package:early_application_1/lists/variants_details.dart';
import 'package:early_application_1/models/infos.dart';
import 'package:early_application_1/profilepage/profile.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; // Tracks the currently selected index
  bool _showOverlay = false; // Control overlay visibility

  // Define the pages to navigate to
  final List<Widget> _pages = [
    HomeContent(), // Home content is now a separate widget
    CameraPage(), // Camera page content
    ProfilePage(), // Person page content
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update the selected index
    });
  }

  void _toggleOverlay() {
    setState(() {
      _showOverlay = !_showOverlay; // Toggle overlay visibility
    });
  }

  Future<bool> _onWillPop() async {
    // Return false to prevent going back to the previous screen
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          flexibleSpace: Center(
            child: Container(
              padding: const EdgeInsets.only(top: 30), // Add top padding here
              child: Image.asset(
                'assets/u.png', // Replace with your image asset path
                height: 350,
                fit: BoxFit.contain, // Fit the image in the available space
              ),
            ),
          ),
        ),
        body: Stack(
          children: [
            _pages[_selectedIndex], // Display the selected page
            // Overlay
            if (_showOverlay)
              GestureDetector(
                onTap: _toggleOverlay, // Close overlay when tapped outside
                child: Container(
                  color: Colors.black54, // Semi-transparent background
                  alignment: Alignment.center,
                  child: Stack(
                    children: [
                      Center(
                        child: Container(
                          // Image or content for classification results
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
                              // Add your classification results here
                              Text('Coconut Pests: 5'),
                              Text('Coconut Diseases: 2'),
                              // Add more results as needed
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 20,
                        top: 20,
                        child: IconButton(
                          icon: Icon(Icons.close, color: Colors.red, size: 30),
                          onPressed:
                              _toggleOverlay, // Close overlay on button press
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex, // Set the current index
          onTap: _onItemTapped, // Pass the tap handler
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.camera), label: 'Camera'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}

// HomeContent widget to hold the list of pests, diseases, and variants
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
      name: 'Sugarcane Pests Control Measures',
      description: 'Different ways of pest mitigation controls.',
      imageUrl: 'assets/smitig.png',
    ),
  ];

  // List of pest images (10 images)
  final List<String> pestImages = [
    'assets/image1.gif', // 1
    'assets/image2.gif', // 2
    'assets/image3.gif', // 3
    'assets/image4.gif', // 4
    'assets/image5.gif',
    'assets/image6.gif',
    'assets/image7.gif',
    'assets/image8.gif',
    'assets/image9.gif',
    // 5
    // Add more images as needed
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
        MaterialPageRoute(builder: (context) => Cocomitig()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Horizontal list of pest images
        Container(
          height: 100, // Set height for the image carousel
          margin: const EdgeInsets.symmetric(vertical: 10),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: pestImages.length,
            itemBuilder: (context, index) {
              return Container(
                width: 75, // Width of each image container
                margin: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(pestImages[index], fit: BoxFit.cover),
                ),
              );
            },
          ),
        ),
        // List of pests with details
        Expanded(
          child: ListView.builder(
            itemCount: pests.length,
            itemBuilder: (context, index) {
              final pest = pests[index];
              return Card(
                margin: const EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Container(
                        width: 90,
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Image.asset(pest.imageUrl, fit: BoxFit.cover),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pest.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              pest.description,
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 1),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 20,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () {
                                  _navigateToPestList(context, pest.name);
                                },
                                child: const Text('More'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
