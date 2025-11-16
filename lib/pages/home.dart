import 'package:early_application_1/BasePage.dart';
import 'package:early_application_1/camera/camera.dart';
import 'package:early_application_1/lists/disease_details.dart';
import 'package:early_application_1/lists/pest_details.dart';
import 'package:early_application_1/lists/variants_details.dart';
import 'package:early_application_1/models/infos.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; // Tracks the currently selected index

  // Define the pages to navigate to
  final List<Widget> _pages = [
    HomeContent(), // Home content is now a separate widget
    const CameraPage(), // Camera page content
    Center(child: Text('Person Page')), // Person page content
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update the selected index
    });
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      body: _pages[_selectedIndex], // Display the selected page
      currentIndex: _selectedIndex, // Set the current index
      onTap: _onItemTapped, // Pass the tap handler
    );
  }
}

// HomeContent widget to hold the list of pests, diseases, and variants
class HomeContent extends StatelessWidget {
  final List<Infos> pests = [
    Infos(
      name: 'Sugarcane Pests',
      description: 'Learn about various pests that affect coconut trees.',
      imageUrl: 'assets/u.png',
    ),
    Infos(
      name: 'Sugarcane Diseases',
      description: 'Information about diseases that can harm coconut trees.',
      imageUrl: 'assets/u.png',
    ),
    Infos(
      name: 'Sugarcane Varieties',
      description: 'Different variants of coconut trees.',
      imageUrl: 'assets/u.png',
    ),
  ];

  void _navigateToPestList(BuildContext context, String name) {
    if (name == 'Coconut Pests') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PestListPage()),
      );
    } else if (name == 'Coconut Diseases') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DiseaseListPage()),
      );
    } else if (name == 'Coconut Variants') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => VariantListPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: pests.length,
      itemBuilder: (context, index) {
        final pest = pests[index];
        return Card(
          margin: const EdgeInsets.all(10),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                // Image section
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Image.asset(pest.imageUrl, fit: BoxFit.cover),
                ),
                const SizedBox(width: 10),
                // Description and Button section
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
                      const SizedBox(height: 5),
                      Text(
                        pest.description,
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: ElevatedButton(
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
    );
  }
}
