// TODO Implement this library.

import 'package:early_application_1/models/infos.dart';
import 'package:flutter/material.dart';

class CoconutScaleInsectPage extends StatefulWidget {
  final Infos pest;

  CoconutScaleInsectPage({required this.pest});

  @override
  _CoconutScaleInsectPageState createState() => _CoconutScaleInsectPageState();
}

class _CoconutScaleInsectPageState extends State<CoconutScaleInsectPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    List<String> images = [
      widget.pest.imageUrl,
      'assets/csi2.jpg', // Replace with actual image paths
      // Replace with actual image paths
    ];

    return Scaffold(
      appBar: AppBar(title: Text(widget.pest.name)),
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
              widget.pest.name,
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
                        widget.pest.description,
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
                        """The coconut scale insect (CSI), also known as Aspidiotus destructor, is a serious pest that affects coconut palms and other plants in tropical and subtropical regions.
It's also known as the transparent scale because the insect's body is visible beneath the scale""",
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Biology and Behavior',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        """The coconut scale insect, Aspidiotus destructor, is a significant pest in tropical regions, undergoing incomplete metamorphosis with egg, nymph, and adult stages, where eggs are typically laid beneath the female's protective scale, and nymphs emerge to feed on plant sap, while adult females remain immobile under their waxy scales.""",
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Control Measures',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        """Control measures for coconut scale insects include cultural practices such as regular pruning and sanitation, promoting plant health to reduce susceptibility, and biological control methods like introducing natural enemies such as ladybugs to manage infestations.""",
                        style: TextStyle(fontSize: 16),
                      ),
                      // Add more detailed information as needed
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
