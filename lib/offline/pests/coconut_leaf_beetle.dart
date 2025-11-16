// TODO Implement this library.

import 'package:early_application_1/models/infos.dart';
import 'package:flutter/material.dart';

class CoconutLeafBeetlePage extends StatefulWidget {
  final Infos pest;

  CoconutLeafBeetlePage({required this.pest});

  @override
  _CoconutLeafBeetlePageState createState() => _CoconutLeafBeetlePageState();
}

class _CoconutLeafBeetlePageState extends State<CoconutLeafBeetlePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    List<String> images = [
      widget.pest.imageUrl,
      'assets/clb2.jpg', // Replace with actual image paths
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
                        """The Brontispa popularly known as Coconut Leaf Beetle is an invasive pest that causes serious damage to both young and mature coconuts and ornamental palms, drying the young shoots and eventually killing the whole tree. • Both larvae and adults are destructive, inhabiting the developing and unopened spear leaves of the coconut where they feed on the leaf tissues. • Damage palms appear burnt at a distance. """,
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
                        """The Brontispa popularly known as Coconut Leaf Beetle is an invasive pest that causes serious damage to both young and mature coconuts and ornamental palms, drying the young shoots and eventually killing the whole tree. • Both larvae and adults are destructive, inhabiting the developing and unopened spear leaves of the coconut where they feed on the leaf tissues. • Damage palms appear burnt at a distance. """,
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
                        """Control measures for the coconut hispine beetle include cultural practices such as promptly removing and destroying infested leaves, biological methods such as encouraging natural enemies like parasitoid wasps, and chemical control through judicious application of insecticides, all integrated into a comprehensive management plan tailored to the specific conditions of the infestation and local ecosystem.""",
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
