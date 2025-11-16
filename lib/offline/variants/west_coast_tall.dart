// TODO Implement this library.

import 'package:early_application_1/models/infos.dart';
import 'package:flutter/material.dart';

class WestCoastTallPage extends StatefulWidget {
  final Infos variants;

  WestCoastTallPage({required this.variants});

  @override
  _WestCoastTallPageState createState() => _WestCoastTallPageState();
}

class _WestCoastTallPageState extends State<WestCoastTallPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    List<String> images = [
      widget.variants.imageUrl,
      'assets/crb.jpg', // Replace with actual image paths
      // Replace with actual image paths
    ];

    return Scaffold(
      appBar: AppBar(title: Text(widget.variants.name)),
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
              widget.variants.name,
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
                        widget.variants.description,
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
                        """The West Coast Tall (WCT) coconut tree is a tall variety of coconut palm that produces more coconuts per year than the East Coast Tall variety and has a higher oil content. WCT coconut trees can grow to 15–18 meters tall with a stem girth of 75–79 centimeters. The leaves are long with medium-sized petioles, and the fruits can be oval or oblong in shape and vary in color from green to brown.
                        
WCT coconut trees are known for their sweet water content, thick and creamy flesh, and high levels of healthy fats, vitamins, minerals, and dietary fiber. The water content makes them ideal for drinking or using in recipes, while the flesh is great for making desserts like coconut cream pies or laddoos. """,
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Soil:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        """WCT palm grows in all type of soil, especially grow well in littoral sand as well as in the interior and is somewhat tolerant to moisture stress in the soil.""",
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Time take for bearing:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text("6 to 7 years", style: TextStyle(fontSize: 16)),
                      Text(
                        'Average Yield:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "80 nuts / palm / year",
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Copra content:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "80 nuts / palm / year",
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Special Features:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        " It is recommended for large scale cultivation in coastal regions of Tamil Nadu, Kerala, Karnataka, Gujarat, Bihar, Madhya Pradesh, Lakshadweep, Orissa and Tripura. The tree also yields, on tapping, good quantity and quality of coconut juice or toddy which can be fermented or converted into jaggery or sugar. It can be preferred for both edible purposes and soap manufacture.",
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
