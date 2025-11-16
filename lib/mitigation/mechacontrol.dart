import 'package:early_application_1/models/infos.dart';
import 'package:flutter/material.dart';

class Mechacontrol extends StatefulWidget {
  final Infos mitig;

  Mechacontrol({required this.mitig});

  @override
  _MechacontrolState createState() => _MechacontrolState();
}

class _MechacontrolState extends State<Mechacontrol> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    List<String> images = [
      widget.mitig.imageUrl,
      'assets/crb.jpg', // Replace with actual image paths
      // Replace with actual image paths
    ];

    return Scaffold(
      appBar: AppBar(title: Text(widget.mitig.name)),
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
              widget.mitig.name,
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
                        widget.mitig.description,
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
                        "Bud rot, also known as Botrytis cinerea, is a fungal disease that affects cannabis and other plants, causing the buds to turn brown or gray and become mushy. It typically starts inside the bud and spreads outward, making early detection difficult. High humidity and poor air circulation are common contributors to the development of this destructive mold.",
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
                        "Initial symptoms include yellowing and browning of young leaves, followed by the collapse of the central shoot. As the disease progresses, a foul smell emanates from the rotting bud and nearby tissues",
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
                        "The disease is caused by the fungus Phytophthora palmivora, which thrives in waterlogged, poorly drained soils and can be spread through water splashes, contaminated tools, and infected planting materials.",
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
                        "Mitigation includes ensuring good drainage in plantations, using disease-free planting materials, avoiding injuries to the tree, and applying appropriate fungicides to the infected area.",
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
