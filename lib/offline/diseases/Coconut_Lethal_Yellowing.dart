import 'package:early_application_1/models/infos.dart';
import 'package:flutter/material.dart';

class CoconutLethalYellowingPage extends StatefulWidget {
  final Infos disease;

  CoconutLethalYellowingPage({required this.disease});

  @override
  _CoconutLethalYellowingPageState createState() =>
      _CoconutLethalYellowingPageState();
}

class _CoconutLethalYellowingPageState
    extends State<CoconutLethalYellowingPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    List<String> images = [
      widget.disease.imageUrl,
      'assets/chem.png', // Replace with actual image paths
      // Replace with actual image paths
    ];

    return Scaffold(
      appBar: AppBar(title: Text(widget.disease.name)),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              height: 200,
              child: PageView.builder(
                itemCount: images.length,
                controller: PageController(viewportFraction: 0.8),
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      image: DecorationImage(
                        image: AssetImage(images[index]),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => Dialog(
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.8,
                              height: MediaQuery.of(context).size.height * 0.8,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(images[index]),
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            Text(
              widget.disease.name,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        widget.disease.description,
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Detailed Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Lethal yellowing is a devastating phytoplasma disease that affects coconut palms, primarily in tropical regions. It manifests as a yellowing and wilting of the fronds, leading to rapid decline and eventual death of the tree within months of symptoms appearing. This disease poses a significant threat to coconut cultivation worldwide, impacting both commercial plantations and local economies reliant on coconut products.",
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Symptoms',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        " Symptoms include premature fruit drop, yellowing of leaves starting from the older fronds, blackening of the inflorescence, and eventually the death of the tree.",
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Cause',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        " Caused by a phytoplasma, this disease is transmitted by the planthopper insect Myndus crudus.",
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Mitigation',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Mitigation involves removing and destroying affected trees, planting resistant varieties, and controlling the planthopper population using insecticides.",
                        style: TextStyle(fontSize: 16),
                      ),
                      // Add more detailed information
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
